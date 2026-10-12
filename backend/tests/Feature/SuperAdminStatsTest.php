<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Organization;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Super admin tak punya current_org_id, sehingga scope `organization` pada
 * PurchaseOrder fail-closed. Statistik admin harus tetap menghitung PO
 * semua organisasi (tanpa PO yang sudah dihapus).
 */
class SuperAdminStatsTest extends TestCase
{
    use RefreshDatabase;

    private function makePo(Organization $org, string $status, float $total, int $seq): PurchaseOrder
    {
        $customer = Customer::create([
            'organization_id' => $org->id,
            'name' => 'Budi',
            'phone' => '0812345678'.$seq,
        ]);

        return PurchaseOrder::create([
            'organization_id' => $org->id,
            'customer_id' => $customer->id,
            'po_number' => sprintf('PO-20261012-%03d', $seq),
            'status' => $status,
            'order_date' => now(),
            'delivery_date' => now()->addDay(),
            'total' => $total,
        ]);
    }

    /** @return array{0: Organization, 1: Organization, 2: string} */
    private function seedData(): array
    {
        $orgA = Organization::create(['name' => 'Toko A', 'slug' => 'toko-a']);
        $orgB = Organization::create(['name' => 'Toko B', 'slug' => 'toko-b']);

        $this->makePo($orgA, 'completed', 100000, 1);
        $this->makePo($orgA, 'completed', 50000, 2);
        $this->makePo($orgA, 'draft', 70000, 3);
        $this->makePo($orgB, 'completed', 25000, 4);
        $this->makePo($orgB, 'completed', 999000, 5)->delete(); // soft-deleted, diabaikan

        $admin = User::factory()->create(['is_super_admin' => true]);

        return [$orgA, $orgB, $admin->createToken('auth-token')->plainTextToken];
    }

    public function test_organizations_list_shows_po_count_and_revenue_per_org(): void
    {
        [$orgA, $orgB, $token] = $this->seedData();

        $rows = collect($this->withToken($token)->getJson('/api/admin/organizations')->assertOk()->json('data'))
            ->keyBy('id');

        $this->assertSame(3, $rows[$orgA->id]['purchase_orders_count']);
        $this->assertEquals(150000, $rows[$orgA->id]['total_revenue']);
        $this->assertSame(1, $rows[$orgB->id]['purchase_orders_count']);
        $this->assertEquals(25000, $rows[$orgB->id]['total_revenue']);
    }

    public function test_dashboard_totals_include_all_organizations(): void
    {
        [, , $token] = $this->seedData();

        $res = $this->withToken($token)->getJson('/api/admin/dashboard')->assertOk();

        $this->assertSame(4, $res->json('total_purchase_orders'));
        $this->assertEquals(175000, $res->json('total_revenue'));

        $thisMonth = collect($res->json('monthly_growth'))->last();
        $this->assertSame(4, $thisMonth['pos']);
        $this->assertEquals(175000, $thisMonth['revenue']);

        $top = collect($res->json('top_organizations'))->keyBy('name');
        $this->assertEquals(150000, $top['Toko A']['total_revenue']);
        $this->assertEquals(25000, $top['Toko B']['total_revenue']);
    }
}
