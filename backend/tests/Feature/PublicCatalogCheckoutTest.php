<?php

namespace Tests\Feature;

use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PublicCatalogCheckoutTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Create a store (organization + owner) and return it with a catalog product.
     *
     * @return array{0: Organization, 1: Product}
     */
    private function makeStore(array $productOverrides = []): array
    {
        $org = Organization::create([
            'name' => 'Toko Kue',
            'slug' => 'toko-kue',
            'phone' => '08123456789',
        ]);

        $owner = User::factory()->create();
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
            'is_active' => true,
            'show_in_catalog' => true,
        ], $productOverrides));

        return [$org, $product];
    }

    public function test_checkout_ignores_client_price_and_name_and_uses_database_values(): void
    {
        [$org, $product] = $this->makeStore();

        $response = $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'items' => [[
                'product_id' => $product->id,
                'product_name' => 'HARGA MURAH BANGET',
                'quantity' => 2,
                'unit_price' => 1,
            ]],
        ]);

        $response->assertCreated();

        $po = PurchaseOrder::firstOrFail();
        $this->assertEquals(100000, (float) $po->total);   // 2 x 50.000, bukan 2 x 1
        $this->assertEquals(100000, (float) $po->subtotal);

        $item = $po->items()->firstOrFail();
        $this->assertEquals(50000, (float) $item->unit_price);
        $this->assertEquals('Brownies', $item->product_name); // bukan "HARGA MURAH BANGET"
    }

    public function test_checkout_rejects_quantity_exceeding_stock(): void
    {
        [$org, $product] = $this->makeStore(['stock_qty' => 3]);

        $response = $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'items' => [[
                'product_id' => $product->id,
                'quantity' => 4,
            ]],
        ]);

        $response->assertStatus(422);
        $this->assertEquals(0, PurchaseOrder::count());
    }

    public function test_checkout_rejects_product_from_another_store(): void
    {
        [$org] = $this->makeStore();

        $otherOrg = Organization::create(['name' => 'Toko Lain', 'slug' => 'toko-lain']);
        $foreignProduct = Product::create([
            'organization_id' => $otherOrg->id,
            'name' => 'Produk Toko Lain',
            'price' => 1000,
            'stock_qty' => 5,
            'is_active' => true,
            'show_in_catalog' => true,
        ]);

        $response = $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'items' => [[
                'product_id' => $foreignProduct->id,
                'quantity' => 1,
            ]],
        ]);

        $response->assertStatus(422);
        $this->assertEquals(0, PurchaseOrder::count());
    }

    public function test_checkout_rejects_product_hidden_from_catalog(): void
    {
        [$org, $product] = $this->makeStore(['show_in_catalog' => false]);

        $response = $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'items' => [[
                'product_id' => $product->id,
                'quantity' => 1,
            ]],
        ]);

        $response->assertStatus(422);
        $this->assertEquals(0, PurchaseOrder::count());
    }

    public function test_valid_checkout_creates_purchase_order(): void
    {
        [$org, $product] = $this->makeStore();

        $response = $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'customer_address' => 'Jl. Mawar No. 1',
            'items' => [[
                'product_id' => $product->id,
                'quantity' => 3,
            ]],
        ]);

        $response->assertCreated()->assertJsonStructure(['message', 'po_number']);
        $this->assertEquals(1, PurchaseOrder::count());
        $this->assertEquals(150000, (float) PurchaseOrder::firstOrFail()->total);
    }
}
