<?php

namespace App\Services;

use App\Models\PurchaseOrder;
use Illuminate\Support\Facades\DB;

class PurchaseOrderNumberGenerator
{
    /**
     * Generate PO number: PO-YYYYMMDD-XXX
     */
    public function generate(string $organizationId): string
    {
        $today = now()->format('Ymd');
        $prefix = "PO-{$today}-";

        $lastPo = DB::table('purchase_orders')
            ->where('organization_id', $organizationId)
            ->where('po_number', 'like', $prefix . '%')
            ->orderByDesc('po_number')
            ->lockForUpdate()
            ->first();

        if ($lastPo) {
            $lastSeq = (int) substr($lastPo->po_number, -3);
            $nextSeq = $lastSeq + 1;
        } else {
            $nextSeq = 1;
        }

        return $prefix . str_pad($nextSeq, 3, '0', STR_PAD_LEFT);
    }
}
