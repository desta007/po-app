<?php

namespace Tests\Feature;

use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\User;
use App\Services\PurchaseOrderService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StockManagementTest extends TestCase
{
    use RefreshDatabase;

    private function makeStore(array $productOverrides = []): array
    {
        $org = Organization::create(['name' => 'Toko Kue', 'slug' => 'toko-kue']);

        $owner = User::factory()->create(['current_org_id' => $org->id]);
        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $owner->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        $product = Product::create(array_merge([
            'organization_id' => $org->id,
            'name' => 'Brownies',
            'price' => 50000,
            'stock_qty' => 10,
            'track_stock' => true,
            'is_active' => true,
            'show_in_catalog' => true,
        ], $productOverrides));

        return [$org, $owner, $product];
    }

    public function test_catalog_checkout_decrements_stock_and_marks_source(): void
    {
        [$org, , $product] = $this->makeStore(['stock_qty' => 10]);

        $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '081234567890',
            'items' => [['product_id' => $product->id, 'quantity' => 3]],
        ])->assertCreated();

        $this->assertEquals(7, $product->refresh()->stock_qty);
        $this->assertEquals('catalog', PurchaseOrder::firstOrFail()->source);
    }

    public function test_checkout_does_not_decrement_when_track_stock_disabled(): void
    {
        [$org, , $product] = $this->makeStore(['stock_qty' => 10, 'track_stock' => false]);

        $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '081234567890',
            'items' => [['product_id' => $product->id, 'quantity' => 3]],
        ])->assertCreated();

        $this->assertEquals(10, $product->refresh()->stock_qty);
    }

    public function test_cancelling_catalog_order_restores_stock(): void
    {
        [$org, , $product] = $this->makeStore(['stock_qty' => 10]);

        $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '081234567890',
            'items' => [['product_id' => $product->id, 'quantity' => 4]],
        ])->assertCreated();

        $this->assertEquals(6, $product->refresh()->stock_qty);

        $po = PurchaseOrder::firstOrFail();
        app(PurchaseOrderService::class)->cancel($po, 'Pelanggan membatalkan');

        $this->assertEquals(10, $product->refresh()->stock_qty);
    }

    public function test_cancelling_non_catalog_order_does_not_touch_stock(): void
    {
        [$org, $owner, $product] = $this->makeStore(['stock_qty' => 10]);

        // Internal order (source defaults to 'internal'); stock was never reserved.
        $customer = \App\Models\Customer::create(['organization_id' => $org->id, 'name' => 'X', 'phone' => '08111']);
        $po = PurchaseOrder::create([
            'organization_id' => $org->id,
            'po_number' => 'PO-INT-001',
            'customer_id' => $customer->id,
            'order_date' => now()->toDateString(),
            'delivery_date' => now()->toDateString(),
            'status' => 'draft',
            'subtotal' => 50000,
            'total' => 50000,
            'created_by' => $owner->id,
        ]);
        $po->items()->create([
            'product_id' => $product->id,
            'product_name' => 'Brownies',
            'quantity' => 2,
            'unit_price' => 50000,
            'subtotal' => 100000,
            'sort_order' => 0,
        ]);

        app(PurchaseOrderService::class)->cancel($po, 'batal');

        // Stock unchanged — internal orders don't reserve/restore via this flow.
        $this->assertEquals(10, $product->refresh()->stock_qty);
    }
}
