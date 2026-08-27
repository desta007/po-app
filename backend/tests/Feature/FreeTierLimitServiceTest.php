<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Organization;
use App\Models\PurchaseOrder;
use App\Services\FreeTierLimitService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class FreeTierLimitServiceTest extends TestCase
{
    use RefreshDatabase;

    private function makeOrg(): Organization
    {
        $slug = 'org-' . Str::lower(Str::random(8));

        return Organization::create([
            'name' => 'Toko ' . $slug,
            'slug' => $slug,
            'phone' => '08123456789',
        ]);
    }

    private function makePo(Organization $org): PurchaseOrder
    {
        $customer = Customer::create([
            'organization_id' => $org->id,
            'name' => 'Test',
            'phone' => '0800' . Str::random(6),
        ]);

        return PurchaseOrder::create([
            'organization_id' => $org->id,
            'po_number' => 'PO-' . now()->format('Ymd') . '-' . Str::random(4),
            'customer_id' => $customer->id,
            'order_date' => now()->toDateString(),
            'delivery_date' => now()->toDateString(),
        ]);
    }

    public function test_monthly_po_count_excludes_soft_deleted(): void
    {
        $org = $this->makeOrg();
        $service = new FreeTierLimitService();

        // 11 PO dibuat, lalu 7 dihapus → tersisa 4.
        $pos = [];
        for ($i = 0; $i < 11; $i++) {
            $pos[] = $this->makePo($org);
        }
        for ($i = 0; $i < 7; $i++) {
            $pos[$i]->delete(); // soft delete
        }

        $this->assertSame(4, $service->getMonthlyPoCount($org->id));
    }

    public function test_usage_summary_reflects_remaining_po_only(): void
    {
        $org = $this->makeOrg();
        $service = new FreeTierLimitService();

        $a = $this->makePo($org);
        $this->makePo($org);
        $a->delete();

        $summary = $service->getUsageSummary($org->id, false);
        $this->assertSame(1, $summary['po_monthly']['current']);
        $this->assertSame(FreeTierLimitService::PO_MONTHLY_LIMIT, $summary['po_monthly']['limit']);
    }
}
