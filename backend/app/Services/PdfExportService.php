<?php

namespace App\Services;

use App\Models\PurchaseOrder;
use Barryvdh\DomPDF\Facade\Pdf;

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

        // Header: org name (16px bold), address, phone + border-bottom padding (10px) + margin-bottom (10px)
        $header = 25;

        // Invoice info section: "INVOICE" title (12px bold) + PO number + table rows + borders/padding
        $invoiceInfo = 30;

        // Items table header row with border
        $tableHeader = 8;

        // Summary section: subtotal + total with border-top padding
        $summary = 20;

        // Footer: text + border-top + margin-top (15px) + padding
        $footer = 12;

        // Dynamic heights
        // Each item uses 2 <tr>: one for name, one for "qty x price = subtotal"
        $itemHeight = 12;
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
            + ($itemsWithNotes * 4)
            + $summary
            + ($hasDiscount ? 5 : 0)
            + ($hasTax ? 5 : 0)
            + ($hasShipping ? 5 : 0)
            + ($hasNotes ? 14 : 0)   // notes section: border-top + padding + text
            + ($hasBankInfo ? 18 : 0) // bank info: border-top + 3 lines of text + padding
            + $footer;

        // Safety buffer to prevent content overflow causing a page break
        $totalMm += 5;

        return round($totalMm * $mmToPoints, 2);
    }
}
