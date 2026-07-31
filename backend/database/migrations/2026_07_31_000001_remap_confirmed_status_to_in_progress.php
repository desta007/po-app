<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Workflow disederhanakan: status 'confirmed' dihapus dan digabung ke 'in_progress'.
 * Remap data PO lama beserta riwayatnya.
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('purchase_orders')
            ->where('status', 'confirmed')
            ->update(['status' => 'in_progress']);

        DB::table('po_status_history')
            ->where('from_status', 'confirmed')
            ->update(['from_status' => 'in_progress']);

        DB::table('po_status_history')
            ->where('to_status', 'confirmed')
            ->update(['to_status' => 'in_progress']);
    }

    public function down(): void
    {
        // Penggabungan tidak dapat dibalik secara akurat (data 'confirmed' asli hilang).
        // Sengaja dibiarkan no-op.
    }
};
