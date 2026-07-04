<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class PurchaseOrdersExport implements FromCollection, WithHeadings, WithMapping, WithStyles, ShouldAutoSize
{
    public function __construct(private Collection $purchaseOrders) {}

    public function collection(): Collection
    {
        return $this->purchaseOrders;
    }

    public function headings(): array
    {
        return [
            'No',
            'No. PO',
            'Customer',
            'No. HP',
            'Tgl Order',
            'Tgl Kirim',
            'Produk',
            'Qty',
            'Subtotal',
            'Diskon',
            'Pajak',
            'Ongkir',
            'Total',
            'Status',
            'Status Bayar',
            'DP',
            'Dibayar',
            'Sisa',
            'Catatan',
        ];
    }

    /**
     * @param \App\Models\PurchaseOrder $po
     */
    public function map($po): array
    {
        static $rowNum = 0;
        $rowNum++;

        $items = $po->items->map(fn($item) => "{$item->product_name} ({$item->quantity}x)")->implode(', ');
        $totalQty = $po->items->sum('quantity');

        return [
            $rowNum,
            $po->po_number,
            $po->customer?->name ?? '-',
            $po->customer?->phone ?? '-',
            $po->order_date?->format('d/m/Y'),
            $po->delivery_date?->format('d/m/Y'),
            $items,
            $totalQty,
            $po->subtotal,
            $po->discount,
            $po->tax,
            $po->shipping_cost ?? 0,
            $po->total,
            $po->status?->label(),
            $po->payment_status?->label(),
            $po->dp_amount,
            $po->paid_amount,
            max(0, $po->total - $po->paid_amount),
            $po->notes ?? '',
        ];
    }

    public function styles(Worksheet $sheet): array
    {
        return [
            1 => [
                'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
                'fill' => [
                    'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                    'startColor' => ['rgb' => '1F4E79'],
                ],
            ],
        ];
    }
}
