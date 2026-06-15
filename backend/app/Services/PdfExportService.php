<?php

namespace App\Services;

use App\Models\PurchaseOrder;
use Barryvdh\DomPDF\Facade\Pdf;

class PdfExportService
{
    public function generateInvoice(PurchaseOrder $po): \Barryvdh\DomPDF\PDF
    {
        $po->load('items', 'customer', 'organization');

        return Pdf::loadView('pdf.invoice', [
            'po' => $po,
            'organization' => $po->organization,
            'customer' => $po->customer,
            'items' => $po->items,
        ])->setPaper([0, 0, 226.77, 841.89], 'portrait');
    }
}
