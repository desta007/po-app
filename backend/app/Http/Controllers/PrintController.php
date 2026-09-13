<?php

namespace App\Http\Controllers;

use App\Models\Organization;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Services\PdfExportService;
use Illuminate\Http\Request;
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

        $url = URL::temporarySignedRoute(
            'print.render',
            now()->addMinutes(self::SIGNED_TTL_MINUTES),
            $params,
        );

        return response()->json(['url' => $url]);
    }

    /**
     * Stream PDF inline. Publik namun divalidasi middleware `signed`.
     * Tidak ada user terautentikasi → filter `organization_id` secara eksplisit.
     */
    public function render(Request $request)
    {
        $type = $request->query('type');
        $orgId = $request->query('org');

        if (! $type || ! $orgId) {
            abort(404);
        }

        if ($type === 'catalog') {
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

            $filename = 'Katalog-'.Str::slug($org->name ?: 'produk').'.pdf';

            return $this->pdfService->generateCatalog($org, $products)->stream($filename);
        }

        $ids = (array) $request->query('ids', []);
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

        // Pertahankan urutan sesuai permintaan.
        $ordered = collect($ids)
            ->map(fn ($id) => $pos->firstWhere('id', $id))
            ->filter()
            ->values();

        switch ($type) {
            case 'po-invoice':
                return $this->pdfService
                    ->generateInvoice($ordered->first())
                    ->stream("Invoice-{$ordered->first()->po_number}.pdf");

            case 'po-corporate':
                return $this->pdfService
                    ->generateCorporateInvoice($ordered->first())
                    ->stream("Invoice-{$ordered->first()->po_number}.pdf");

            case 'po-labels':
                return $this->pdfService
                    ->generateLabels($ordered, $request->query('size', self::LABEL_SIZES[0]))
                    ->stream('Labels-'.now()->format('Ymd-His').'.pdf');

            case 'po-address-labels':
                return $this->pdfService
                    ->generateAddressLabels($ordered, $request->query('size', self::ADDRESS_LABEL_SIZES[0]))
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
