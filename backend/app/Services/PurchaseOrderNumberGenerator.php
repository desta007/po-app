<?php

namespace App\Services;

use App\Models\PurchaseOrder;
use Illuminate\Support\Facades\DB;

class PurchaseOrderNumberGenerator
{
    /**
     * Generate PO number: PO-YYYYMMDD-XXX
     *
     * Nomor urut (XXX) adalah penghitung berjalan per-organisasi yang TIDAK
     * pernah reset — terus bertambah walaupun berganti hari, bulan, atau tahun.
     * Prefix tanggal tetap dipertahankan hanya sebagai penanda kapan PO dibuat.
     */
    public function generate(string $organizationId): string
    {
        $today = now()->format('Ymd');
        $prefix = "PO-{$today}-";

        // Ambil semua nomor PO milik organisasi ini (lock agar aman dari race
        // condition saat dua PO dibuat bersamaan) lalu cari nomor urut tertinggi.
        // Diproses di PHP supaya portabel antara PostgreSQL (produksi) dan
        // SQLite (test), dan tetap benar untuk data lama yang dulunya reset
        // harian — urutan cukup diambil dari segmen terakhir setiap nomor.
        $poNumbers = DB::table('purchase_orders')
            ->where('organization_id', $organizationId)
            ->lockForUpdate()
            ->pluck('po_number');

        $maxSeq = 0;
        foreach ($poNumbers as $poNumber) {
            $poNumber = (string) $poNumber;
            $lastDash = strrpos($poNumber, '-');
            $seq = (int) ($lastDash === false ? $poNumber : substr($poNumber, $lastDash + 1));
            if ($seq > $maxSeq) {
                $maxSeq = $seq;
            }
        }

        $nextSeq = $maxSeq + 1;

        return $prefix . str_pad((string) $nextSeq, 3, '0', STR_PAD_LEFT);
    }
}
