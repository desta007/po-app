<?php

namespace App\Console\Commands;

use App\Models\Customer;
use App\Models\PurchaseOrder;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class RecalculateCustomerStats extends Command
{
    protected $signature = 'customers:recalculate-stats {--org= : Batasi hanya untuk organization_id tertentu}';

    protected $description = 'Hitung ulang total_orders & total_revenue pelanggan dari PO completed yang belum dihapus.';

    public function handle(): int
    {
        $query = Customer::query();

        if ($orgId = $this->option('org')) {
            $query->where('organization_id', $orgId);
        }

        $total = $query->count();
        $this->info("Menghitung ulang statistik untuk {$total} pelanggan...");

        $updated = 0;

        $query->chunkById(200, function ($customers) use (&$updated) {
            foreach ($customers as $customer) {
                // Hanya PO completed & belum soft-deleted yang dihitung
                // (konsisten dengan penambahan counter saat status jadi completed).
                $stats = PurchaseOrder::where('customer_id', $customer->id)
                    ->where('status', 'completed')
                    ->select(
                        DB::raw('COUNT(*) as orders'),
                        DB::raw('COALESCE(SUM(total), 0) as revenue')
                    )
                    ->first();

                $newOrders = (int) $stats->orders;
                $newRevenue = (float) $stats->revenue;

                if ((int) $customer->total_orders !== $newOrders
                    || (float) $customer->total_revenue !== $newRevenue) {
                    $customer->forceFill([
                        'total_orders' => $newOrders,
                        'total_revenue' => $newRevenue,
                    ])->saveQuietly();
                    $updated++;
                }
            }
        });

        $this->info("Selesai. {$updated} pelanggan diperbarui.");

        return self::SUCCESS;
    }
}
