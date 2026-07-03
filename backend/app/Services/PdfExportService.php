<?php

namespace App\Services;

use App\Models\PurchaseOrder;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Collection;
use setasign\Fpdi\Fpdi;

class PdfExportService
{
    public function generateInvoice(PurchaseOrder $po): \Barryvdh\DomPDF\PDF
    {
        $po->load('items', 'customer', 'organization');

        $paperHeight = $this->calculatePaperHeight($po);

        return Pdf::loadView('pdf.invoice', [
            'po' => $po,
            'organization' => $po->organization,
            'customer' => $po->customer,
            'items' => $po->items,
        ])->setPaper([0, 0, 226.77, $paperHeight], 'portrait');
    }

    /**
     * Calculate paper height in points based on content.
     * 1mm = 2.835 points
     */
    private function calculatePaperHeight(PurchaseOrder $po): float
    {
        $mmToPoints = 2.835;

        // Base heights in mm — adjusted for actual CSS rendering
        // @page margin: 5mm top + 5mm bottom, plus body padding
        $margin = 12;

        // Header: org name (18px bold), address, phone + border-bottom padding (10px) + margin-bottom (10px)
        $header = 28;

        // Invoice info section: "INVOICE" title (14px bold) + PO number + table rows + borders/padding
        $invoiceInfo = 34;

        // Items table header row with border
        $tableHeader = 10;

        // Summary section: subtotal + total with border-top padding
        $summary = 24;

        // Footer: text + border-top + margin-top (15px) + padding
        $footer = 14;

        // Dynamic heights
        // Each item uses 2 <tr>: one for name, one for "qty x price = subtotal"
        $itemHeight = 14;
        $itemCount = $po->items->count();

        // Items with notes take extra space (additional <span> line)
        $itemsWithNotes = $po->items->filter(fn($item) => !empty($item->notes))->count();

        // Conditional sections
        $hasDiscount = $po->discount > 0;
        $hasTax = $po->tax > 0;
        $hasShipping = $po->shipping_cost > 0;
        $hasNotes = !empty($po->notes);
        $hasBankInfo = !empty($po->organization->settings['bank_info']['bank_name'] ?? null);
        $hasLogo = !empty($po->organization->logo_url);
        $hasPhone = !empty($po->customer->phone);
        $hasPaymentMethod = !empty($po->payment_method);

        $totalMm = $margin
            + $header
            + ($hasLogo ? 15 : 0)   // logo img (40px max) + margin
            + $invoiceInfo
            + ($hasPhone ? 5 : 0)
            + ($hasPaymentMethod ? 5 : 0)
            + $tableHeader
            + ($itemCount * $itemHeight)
            + ($itemsWithNotes * 5)
            + $summary
            + ($hasDiscount ? 5 : 0)
            + ($hasTax ? 5 : 0)
            + ($hasShipping ? 5 : 0)
            + ($hasNotes ? 16 : 0)   // notes section: border-top + padding + text
            + ($hasBankInfo ? 21 : 0) // bank info: border-top + 3 lines of text + padding
            + $footer;

        // Safety buffer to prevent content overflow causing a page break
        $totalMm += 8;

        return round($totalMm * $mmToPoints, 2);
    }

    /**
     * Generate corporate-style invoice (A4 paper).
     */
    public function generateCorporateInvoice(PurchaseOrder $po): \Barryvdh\DomPDF\PDF
    {
        $po->load('items', 'customer', 'organization');

        return Pdf::loadView('pdf.invoice-corporate', [
            'po' => $po,
            'organization' => $po->organization,
            'customer' => $po->customer,
            'items' => $po->items,
        ])->setPaper('a4', 'portrait');
    }

    /**
     * Generate merged PDF from multiple POs.
     *
     * @param Collection<int, PurchaseOrder> $purchaseOrders
     * @param string $format 'receipt' or 'corporate'
     * @return string PDF binary content
     */
    public function generateBulkPdf(Collection $purchaseOrders, string $format): string
    {
        $tempFiles = [];

        try {
            // Generate individual PDFs and save to temp files
            foreach ($purchaseOrders as $po) {
                $pdf = $format === 'corporate'
                    ? $this->generateCorporateInvoice($po)
                    : $this->generateInvoice($po);

                $tempFile = tempnam(sys_get_temp_dir(), 'po_pdf_');
                file_put_contents($tempFile, $pdf->output());
                $tempFiles[] = $tempFile;
            }

            // Merge all PDFs using FPDI
            $merger = new Fpdi();

            foreach ($tempFiles as $file) {
                $pageCount = $merger->setSourceFile($file);
                for ($i = 1; $i <= $pageCount; $i++) {
                    $templateId = $merger->importPage($i);
                    $size = $merger->getTemplateSize($templateId);
                    $merger->AddPage($size['orientation'], [$size['width'], $size['height']]);
                    $merger->useTemplate($templateId);
                }
            }

            return $merger->Output('S');
        } finally {
            // Clean up temp files
            foreach ($tempFiles as $file) {
                if (file_exists($file)) {
                    @unlink($file);
                }
            }
        }
    }

    /**
     * Generate product labels PDF from multiple POs.
     *
     * @param Collection<int, PurchaseOrder> $purchaseOrders
     * @param string $size '40x20' or '50x20'
     * @return \Barryvdh\DomPDF\PDF
     */
    public function generateLabels(Collection $purchaseOrders, string $size): \Barryvdh\DomPDF\PDF
    {
        $dimensionsMap = [
            '25x15' => ['width' => 25, 'height' => 15],
            '30x15' => ['width' => 30, 'height' => 15],
            '30x20' => ['width' => 30, 'height' => 20],
        ];
        $dimensions = $dimensionsMap[$size] ?? $dimensionsMap['30x20'];

        // Build flat list of labels: one per quantity unit per product item per PO
        $labels = [];
        foreach ($purchaseOrders as $po) {
            $po->load('items', 'customer');
            $orderDate = \Carbon\Carbon::parse($po->order_date)->translatedFormat('d M y');

            foreach ($po->items as $item) {
                $qty = max(1, (int) $item->quantity);
                for ($i = 0; $i < $qty; $i++) {
                    $labels[] = [
                        'po_number' => $po->po_number,
                        'order_date' => $orderDate,
                        'customer' => $po->customer->name ?? '-',
                        'product' => $item->product_name,
                    ];
                }
            }
        }

        $labelWidth = $dimensions['width'];
        $labelHeight = $dimensions['height'];

        // Paper size = single column strip: width matches label, height = all labels stacked
        $paperWidth = $labelWidth;
        $paperHeight = $labelHeight * count($labels);

        // Convert mm to points (1mm = 2.835pt)
        $mmToPt = 2.835;
        $paperWidthPt = round($paperWidth * $mmToPt, 2);
        $paperHeightPt = round($paperHeight * $mmToPt, 2);

        return Pdf::loadView('pdf.labels', [
            'labels' => $labels,
            'labelWidth' => $labelWidth,
            'labelHeight' => $labelHeight,
            'paperWidth' => $paperWidth,
            'paperHeight' => $paperHeight,
        ])->setPaper([0, 0, $paperWidthPt, $paperHeightPt], 'portrait');
    }

    /**
     * Generate receipt-style invoice as PNG image.
     */
    public function generateInvoiceImage(PurchaseOrder $po): string
    {
        $pdf = $this->generateInvoice($po);
        $pdfContent = $pdf->output();

        if (!extension_loaded('imagick')) {
            throw new \RuntimeException('Imagick extension is required for image export.');
        }

        $imagick = new \Imagick();
        $imagick->setResolution(200, 200);
        $imagick->readImageBlob($pdfContent);
        $imagick->setImageFormat('png');
        $imagick->setImageBackgroundColor('white');
        $imagick->setImageAlphaChannel(\Imagick::ALPHACHANNEL_REMOVE);
        $imagick->mergeImageLayers(\Imagick::LAYERMETHOD_FLATTEN);

        $imageBlob = $imagick->getImageBlob();
        $imagick->clear();
        $imagick->destroy();

        return $imageBlob;
    }
}
