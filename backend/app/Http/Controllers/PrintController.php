<?php

namespace App\Http\Controllers;

use App\Models\Organization;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Services\PdfExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Str;

/**
 * Mencetak PDF di browser iOS WebKit (mis. Bluefy/WebBLE di iPhone).
 *
 * Latar belakang: WKWebView TIDAK andal merender PDF yang diberikan sebagai
 * `blob:`/`data:` URL lewat navigasi tab — tab hanya "loading" lalu kosong.
 * Namun WKWebView merender PDF dari URL https NYATA dengan baik. Endpoint export
 * biasa butuh Bearer token yang tak bisa dikirim lewat navigasi browser polos,
 * jadi alurnya:
 *   1. Frontend memanggil `POST print/sign` (terautentikasi) → dapat URL
 *      ber-tanda-tangan sementara (TTL pendek) ke `print.render`.
 *   2. Browser iOS diarahkan ke URL itu → `render()` menstream PDF inline.
 *
 * `render()` TIDAK terautentikasi (divalidasi oleh middleware `signed`), sehingga
 * global scope organisasi tidak aktif — kita WAJIB memfilter `organization_id`
 * secara manual dari parameter yang sudah ditandatangani.
 */
class PrintController extends Controller
{
    /** TTL URL tanda tangan (menit). Cukup untuk membuka PDF, cukup singkat agar aman. */
    private const SIGNED_TTL_MINUTES = 10;

    /** Ukuran label produk yang diizinkan (mirror validasi di PurchaseOrderController). */
    private const LABEL_SIZES = ['25x15', '30x15', '30x20', '50x30'];

    /** Ukuran label alamat yang diizinkan. */
    private const ADDRESS_LABEL_SIZES = ['100x150', '100x100', '80x50', '60x50', '50x50'];

    public function __construct(
        private PdfExportService $pdfService,
    ) {}

    /**
     * Terbitkan URL bertanda-tangan sementara untuk mencetak PDF di iOS.
     * Terautentikasi + org.access, jadi global scope memastikan user hanya bisa
     * meminta PO milik organisasinya sendiri.
     */
    public function sign(Request $request)
    {
        $data = $request->validate([
            'type' => ['required', 'in:po-invoice,po-corporate,po-labels,po-address-labels,po-bulk,catalog'],
            'id' => ['nullable', 'uuid'],
            'ids' => ['nullable', 'array', 'min:1', 'max:50'],
            'ids.*' => ['required', 'uuid'],
            'size' => ['nullable', 'string'],
            'format' => ['nullable', 'in:receipt,corporate'],
        ]);

        $orgId = $request->user()->current_org_id;
        $type = $data['type'];

        $params = ['type' => $type, 'org' => $orgId];

        if ($type === 'catalog') {
            // Tak butuh id; katalog dibuat untuk organisasi user.
        } else {
            // Kumpulkan id PO yang diminta (single lewat `id`, atau banyak lewat `ids`).
            $ids = $data['ids'] ?? (isset($data['id']) ? [$data['id']] : []);
            if (empty($ids)) {
                return response()->json(['message' => 'PO tidak ditentukan.'], 422);
            }

            // Global scope aktif di sini → hanya menghitung PO milik org user.
            $found = PurchaseOrder::whereIn('id', $ids)->pluck('id')->all();
            if (count($found) !== count($ids)) {
                return response()->json(['message' => 'Sebagian PO tidak ditemukan.'], 404);
            }

            $params['ids'] = array_values($ids);

            if (in_array($type, ['po-labels', 'po-address-labels'], true)) {
                $allowed = $type === 'po-labels' ? self::LABEL_SIZES : self::ADDRESS_LABEL_SIZES;
                $size = $data['size'] ?? $allowed[0];
                if (! in_array($size, $allowed, true)) {
                    return response()->json(['message' => 'Ukuran label tidak valid.'], 422);
                }
                $params['size'] = $size;
            }

            if ($type === 'po-bulk') {
                $params['format'] = $data['format'] ?? 'receipt';
            }
        }

        // mode=view → halaman viewer HTML (punya tombol Print/Bagikan untuk iOS).
        $params['mode'] = 'view';

        $url = URL::temporarySignedRoute(
            'print.render',
            now()->addMinutes(self::SIGNED_TTL_MINUTES),
            $params,
        );

        return response()->json(['url' => $url]);
    }

    /**
     * Titik masuk render (publik, divalidasi middleware `signed`).
     *
     * - `mode=raw`  → stream PDF inline (opsi "Simpan PDF").
     * - `mode=view` → halaman HTML dokumen + tombol Print yang memanggil
     *   `window.print()` → dialog AirPrint. Diperlukan karena Bluefy/WKWebView
     *   TIDAK memberi opsi Print pada PDF (malah mengunduh), sedangkan
     *   `window.print()` pada halaman HTML memicu cetak dengan benar.
     */
    public function render(Request $request)
    {
        if ($request->query('mode') === 'raw') {
            return $this->streamPdf($request);
        }

        return $this->printableHtml($request);
    }

    /**
     * Halaman HTML dokumen yang bisa dicetak via window.print(). Blade PDF dipakai
     * ulang sebagai HTML (is_html=true) lalu disisipi bar kontrol + skrip cetak.
     */
    private function printableHtml(Request $request)
    {
        $type = $request->query('type');
        $orgId = $request->query('org');

        if (! $type || ! $orgId) {
            abort(404);
        }

        if ($type === 'catalog') {
            [$org, $products] = $this->loadCatalog($orgId);
            $doc = $this->pdfService->htmlCatalog($org, $products);
        } else {
            $ordered = $this->loadOrderedPos($orgId, (array) $request->query('ids', []));

            $doc = match ($type) {
                'po-invoice' => $this->pdfService->htmlInvoice($ordered->first()),
                'po-corporate' => $this->pdfService->htmlCorporateInvoice($ordered->first()),
                'po-labels' => $this->pdfService->htmlLabels($ordered, $request->query('size', self::LABEL_SIZES[0])),
                'po-address-labels' => $this->pdfService->htmlAddressLabels($ordered, $request->query('size', self::ADDRESS_LABEL_SIZES[0])),
                'po-bulk' => $this->pdfService->htmlBulk($ordered, $request->query('format', 'receipt')),
                default => abort(404),
            };
        }

        return response($this->injectPrintControls($doc, $request));
    }

    /**
     * Sisipkan bar kontrol (tombol Print + link Simpan PDF) dan skrip auto-print
     * ke dokumen HTML. Skrip WAJIB file eksternal 'self' (CSP `script-src 'self'`
     * memblokir inline). Bar disembunyikan saat mencetak (@media print).
     */
    private function injectPrintControls(string $html, Request $request): string
    {
        $params = ['type' => $request->query('type'), 'org' => $request->query('org'), 'mode' => 'raw'];
        if ($request->query('ids')) {
            $params['ids'] = (array) $request->query('ids');
        }
        if ($request->query('size')) {
            $params['size'] = $request->query('size');
        }
        if ($request->query('format')) {
            $params['format'] = $request->query('format');
        }
        $rawUrl = URL::temporarySignedRoute('print.render', now()->addMinutes(self::SIGNED_TTL_MINUTES), $params);

        $bar = '<style>@media screen{#__pbar{position:fixed;left:0;right:0;bottom:0;display:flex;gap:10px;'
            .'justify-content:center;padding:12px 12px calc(12px + env(safe-area-inset-bottom));'
            .'background:rgba(17,24,39,.94);z-index:2147483647}'
            .'#__pbar a,#__pbar button{flex:1;max-width:220px;padding:13px 16px;border-radius:12px;border:0;'
            .'font:600 16px -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;text-align:center;'
            .'text-decoration:none;-webkit-tap-highlight-color:transparent}'
            .'#__pbtn{background:#2563eb;color:#fff}#__pdf{background:#374151;color:#fff}'
            .'body{padding-bottom:96px!important}}'
            .'@media print{#__pbar{display:none!important}body{padding-bottom:0!important}}</style>'
            .'<div id="__pbar">'
            .'<button id="__pbtn" type="button">🖨️ Print</button>'
            .'<a id="__pdf" href="'.e($rawUrl).'">⬇️ Simpan PDF</a>'
            .'</div>'
            .'<script src="/js/print-auto.js"></script>';

        if (stripos($html, '</body>') !== false) {
            return preg_replace('/<\/body>/i', $bar.'</body>', $html, 1);
        }

        return $html.$bar;
    }

    /**
     * @return array{0: Organization, 1: Collection}
     */
    private function loadCatalog(string $orgId): array
    {
        $org = Organization::find($orgId);
        if (! $org) {
            abort(404);
        }

        $products = Product::withoutGlobalScope('organization')
            ->where('organization_id', $orgId)
            ->where('is_active', true)
            ->where('show_in_catalog', true)
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        return [$org, $products];
    }

    /**
     * Muat PO (difilter organisasi manual, urut sesuai permintaan) atau abort(404).
     */
    private function loadOrderedPos(string $orgId, array $ids): Collection
    {
        if (empty($ids)) {
            abort(404);
        }

        $pos = PurchaseOrder::withoutGlobalScope('organization')
            ->where('organization_id', $orgId)
            ->whereIn('id', $ids)
            ->with('items', 'customer', 'organization')
            ->get();

        if ($pos->isEmpty()) {
            abort(404);
        }

        return collect($ids)
            ->map(fn ($id) => $pos->firstWhere('id', $id))
            ->filter()
            ->values();
    }

    /**
     * Stream PDF inline (mode=raw). Publik namun divalidasi middleware `signed`.
     * Tidak ada user terautentikasi → filter `organization_id` secara eksplisit.
     */
    private function streamPdf(Request $request)
    {
        $type = $request->query('type');
        $orgId = $request->query('org');

        if (! $type || ! $orgId) {
            abort(404);
        }

        if ($type === 'catalog') {
            [$org, $products] = $this->loadCatalog($orgId);
            $filename = 'Katalog-'.Str::slug($org->name ?: 'produk').'.pdf';

            return $this->pdfService->generateCatalog($org, $products)->stream($filename);
        }

        $ordered = $this->loadOrderedPos($orgId, (array) $request->query('ids', []));

        switch ($type) {
            case 'po-invoice':
                return $this->pdfService->generateInvoice($ordered->first())
                    ->stream("Invoice-{$ordered->first()->po_number}.pdf");
            case 'po-corporate':
                return $this->pdfService->generateCorporateInvoice($ordered->first())
                    ->stream("Invoice-{$ordered->first()->po_number}.pdf");
            case 'po-labels':
                return $this->pdfService->generateLabels($ordered, $request->query('size', self::LABEL_SIZES[0]))
                    ->stream('Labels-'.now()->format('Ymd-His').'.pdf');
            case 'po-address-labels':
                return $this->pdfService->generateAddressLabels($ordered, $request->query('size', self::ADDRESS_LABEL_SIZES[0]))
                    ->stream('AddressLabels-'.now()->format('Ymd-His').'.pdf');
            case 'po-bulk':
                $content = $this->pdfService->generateBulkPdf($ordered, $request->query('format', 'receipt'));
                $filename = 'Bulk-Invoice-'.now()->format('Ymd-His').'.pdf';

                return response($content, 200, [
                    'Content-Type' => 'application/pdf',
                    'Content-Disposition' => "inline; filename=\"{$filename}\"",
                ]);
        }

        abort(404);
    }
}
