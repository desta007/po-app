<?php

namespace Tests\Feature;

use App\Models\Organization;
use App\Services\PurchaseOrderNumberGenerator;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class PurchaseOrderNumberGeneratorTest extends TestCase
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

    private function insertPo(Organization $org, string $poNumber, string $orderDate): void
    {
        $customerId = (string) Str::uuid();
        DB::table('customers')->insert([
            'id' => $customerId,
            'organization_id' => $org->id,
            'name' => 'Test',
            'phone' => '0800',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('purchase_orders')->insert([
            'id' => (string) Str::uuid(),
            'organization_id' => $org->id,
            'po_number' => $poNumber,
            'customer_id' => $customerId,
            'order_date' => $orderDate,
            'delivery_date' => $orderDate,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function test_sequence_does_not_reset_across_months(): void
    {
        $org = $this->makeOrg();
        $generator = new PurchaseOrderNumberGenerator();

        // PO terakhir bulan lalu bernomor urut 005.
        $this->insertPo($org, 'PO-20260731-005', '2026-07-31');

        // Sekarang bulan berikutnya — nomor urut harus lanjut ke 006, bukan reset ke 001.
        Carbon::setTestNow(Carbon::parse('2026-08-01 09:00:00'));
        $this->assertSame('PO-20260801-006', $generator->generate($org->id));
    }

    public function test_sequence_uses_global_max_not_last_row(): void
    {
        $org = $this->makeOrg();
        $generator = new PurchaseOrderNumberGenerator();

        // Data lama yang dulu reset harian: hari yang lebih baru justru punya nomor lebih kecil.
        $this->insertPo($org, 'PO-20260726-020', '2026-07-26');
        $this->insertPo($org, 'PO-20260727-003', '2026-07-27');

        Carbon::setTestNow(Carbon::parse('2026-08-01 09:00:00'));
        $this->assertSame('PO-20260801-021', $generator->generate($org->id));
    }

    public function test_first_po_starts_at_one(): void
    {
        $org = $this->makeOrg();
        $generator = new PurchaseOrderNumberGenerator();

        Carbon::setTestNow(Carbon::parse('2026-08-01 09:00:00'));
        $this->assertSame('PO-20260801-001', $generator->generate($org->id));
    }

    public function test_sequence_is_scoped_per_organization(): void
    {
        $orgA = $this->makeOrg();
        $orgB = $this->makeOrg();
        $generator = new PurchaseOrderNumberGenerator();

        $this->insertPo($orgA, 'PO-20260726-050', '2026-07-26');

        Carbon::setTestNow(Carbon::parse('2026-08-01 09:00:00'));
        // Org B tidak terpengaruh nomor org A.
        $this->assertSame('PO-20260801-001', $generator->generate($orgB->id));
    }

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }
}
