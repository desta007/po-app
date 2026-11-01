<?php

namespace Tests\Feature;

use App\Enums\SubscriptionPlan;
use App\Models\Customer;
use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProductDiscountTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: User, 1: Organization}
     */
    private function actingMember(SubscriptionPlan $plan = SubscriptionPlan::PREMIUM, string $role = 'owner', string $slug = 'toko-kue'): array
    {
        $org = Organization::create([
            'name' => 'Toko Kue',
            'slug' => $slug,
            'phone' => '08123456789',
            'plan' => $plan,
        ]);

        $user = User::factory()->create(['current_org_id' => $org->id]);
        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $user->id,
            'role' => $role,
            'joined_at' => now(),
        ]);

        Sanctum::actingAs($user);

        return [$user, $org];
    }

    private function makeProduct(Organization $org, array $overrides = []): Product
    {
        return Product::create(array_merge([
            'organization_id' => $org->id,
            'name' => 'Brownies',
            'price' => 50000,
            'stock_qty' => 10,
            'is_active' => true,
            'show_in_catalog' => true,
        ], $overrides));
    }

    // ── Perhitungan di model ───────────────────────────────────────────

    public function test_percent_and_nominal_discount_are_computed_for_premium_org(): void
    {
        [, $org] = $this->actingMember();

        $percent = $this->makeProduct($org, ['discount_enabled' => true, 'discount_type' => 'percent', 'discount_value' => 20]);
        $nominal = $this->makeProduct($org, ['name' => 'Bolu', 'discount_enabled' => true, 'discount_type' => 'nominal', 'discount_value' => 7500]);

        $this->assertSame(10000.0, $percent->discountAmount());
        $this->assertSame(40000.0, $percent->finalPrice());
        $this->assertSame(7500.0, $nominal->discountAmount());
        $this->assertSame(42500.0, $nominal->finalPrice());
    }

    public function test_discount_is_ignored_when_disabled_or_org_is_not_premium(): void
    {
        [, $org] = $this->actingMember(SubscriptionPlan::FREE);

        $product = $this->makeProduct($org, ['discount_enabled' => true, 'discount_type' => 'percent', 'discount_value' => 20]);
        $this->assertFalse($product->hasActiveDiscount());
        $this->assertSame(50000.0, $product->finalPrice());

        $org->update(['plan' => SubscriptionPlan::PREMIUM]);
        $product->update(['discount_enabled' => false]);
        $this->assertFalse($product->fresh()->hasActiveDiscount());
    }

    // ── API master produk ──────────────────────────────────────────────

    public function test_premium_owner_can_set_discount_and_resource_exposes_final_price(): void
    {
        $this->actingMember();

        $response = $this->postJson('/api/products', [
            'name' => 'Brownies',
            'price' => 50000,
            'discount_enabled' => true,
            'discount_type' => 'percent',
            'discount_value' => 10,
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.discount_enabled', true)
            ->assertJsonPath('data.discount_type', 'percent')
            ->assertJsonPath('data.has_active_discount', true)
            ->assertJsonPath('data.final_price', 45000);
    }

    public function test_admin_can_set_discount(): void
    {
        [, $org] = $this->actingMember(role: 'admin');
        $product = $this->makeProduct($org);

        $this->putJson("/api/products/{$product->id}", [
            'discount_enabled' => true,
            'discount_type' => 'nominal',
            'discount_value' => 5000,
        ])->assertOk()->assertJsonPath('data.final_price', 45000);
    }

    public function test_free_org_cannot_enable_discount(): void
    {
        $this->actingMember(SubscriptionPlan::FREE);

        $this->postJson('/api/products', [
            'name' => 'Brownies',
            'price' => 50000,
            'discount_enabled' => true,
            'discount_type' => 'percent',
            'discount_value' => 10,
        ])->assertForbidden()
            ->assertJsonPath('upgrade_required', true)
            ->assertJsonPath('resource', 'product_discount');

        $this->assertDatabaseCount('products', 0);
    }

    public function test_staff_cannot_change_discount_but_can_edit_other_fields(): void
    {
        [, $org] = $this->actingMember(role: 'staff');
        $product = $this->makeProduct($org, ['discount_enabled' => true, 'discount_type' => 'percent', 'discount_value' => 10]);

        $this->putJson("/api/products/{$product->id}", ['discount_value' => 50])
            ->assertForbidden();
        $this->assertEquals(10, (float) $product->fresh()->discount_value);

        // Klien yang mengirim ulang nilai diskon yang sama (form penuh) tetap boleh menyimpan.
        $this->putJson("/api/products/{$product->id}", [
            'name' => 'Brownies Coklat',
            'discount_enabled' => true,
            'discount_type' => 'percent',
            'discount_value' => 10,
        ])->assertOk();
        $this->assertSame('Brownies Coklat', $product->fresh()->name);
    }

    public function test_viewer_remains_read_only(): void
    {
        [, $org] = $this->actingMember(role: 'viewer');
        $product = $this->makeProduct($org);

        $this->getJson("/api/products/{$product->id}")->assertOk();
        $this->putJson("/api/products/{$product->id}", ['name' => 'Ganti'])->assertForbidden();
    }

    public function test_discount_validation_rules(): void
    {
        [, $org] = $this->actingMember();

        $base = ['name' => 'Brownies', 'price' => 50000, 'discount_enabled' => true];

        $this->postJson('/api/products', $base + ['discount_value' => 10])
            ->assertUnprocessable()->assertJsonValidationErrors('discount_type');
        $this->postJson('/api/products', $base + ['discount_type' => 'percent', 'discount_value' => 150])
            ->assertUnprocessable()->assertJsonValidationErrors('discount_value');
        $this->postJson('/api/products', $base + ['discount_type' => 'nominal', 'discount_value' => 60000])
            ->assertUnprocessable()->assertJsonValidationErrors('discount_value');
        $this->postJson('/api/products', $base + ['discount_type' => 'percent', 'discount_value' => 0])
            ->assertUnprocessable()->assertJsonValidationErrors('discount_value');
        $this->postJson('/api/products', $base + ['discount_type' => 'bogo', 'discount_value' => 10])
            ->assertUnprocessable()->assertJsonValidationErrors('discount_type');

        // Update parsial: menurunkan harga di bawah diskon nominal yang ada ditolak.
        $product = $this->makeProduct($org, ['discount_enabled' => true, 'discount_type' => 'nominal', 'discount_value' => 20000]);
        $this->putJson("/api/products/{$product->id}", ['price' => 15000])
            ->assertUnprocessable()->assertJsonValidationErrors('discount_value');
    }

    // ── PO internal ────────────────────────────────────────────────────

    public function test_internal_po_stores_discount_snapshot_derived_on_server(): void
    {
        [, $org] = $this->actingMember();
        $customer = Customer::create(['organization_id' => $org->id, 'name' => 'Budi', 'phone' => '0811111111']);
        $product = $this->makeProduct($org);

        $this->postJson('/api/purchase-orders', [
            'customer_id' => $customer->id,
            'delivery_date' => now()->addDay()->toDateString(),
            'discount' => 1000,
            'items' => [
                ['product_id' => $product->id, 'product_name' => 'Brownies', 'quantity' => 2, 'unit_price' => 40000, 'original_price' => 50000],
                ['product_name' => 'Custom', 'quantity' => 1, 'unit_price' => 30000],
            ],
        ])->assertCreated()
            ->assertJsonPath('data.items.0.original_price', 50000)
            ->assertJsonPath('data.items.0.discount_amount', 10000);

        $po = PurchaseOrder::firstOrFail();
        $this->assertEquals(110000, (float) $po->subtotal);   // 2×40.000 + 30.000
        $this->assertEquals(109000, (float) $po->total);      // diskon pesanan tetap ditumpuk

        $custom = $po->items()->where('product_name', 'Custom')->firstOrFail();
        $this->assertNull($custom->original_price);
        $this->assertEquals(0, (float) $custom->discount_amount);
    }

    // ── Checkout katalog ───────────────────────────────────────────────

    public function test_catalog_shows_and_checkout_charges_discounted_price(): void
    {
        Queue::fake();
        [, $org] = $this->actingMember();
        $product = $this->makeProduct($org, ['discount_enabled' => true, 'discount_type' => 'percent', 'discount_value' => 20]);

        $this->getJson("/api/catalog/{$org->slug}")
            ->assertOk()
            ->assertJsonPath('products.0.final_price', 40000)
            ->assertJsonPath('products.0.has_active_discount', true);

        $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'items' => [['product_id' => $product->id, 'quantity' => 2, 'unit_price' => 1]],
        ])->assertCreated()->assertJsonPath('total', 80000);

        $item = PurchaseOrder::firstOrFail()->items()->firstOrFail();
        $this->assertEquals(40000, (float) $item->unit_price);
        $this->assertEquals(50000, (float) $item->original_price);
        $this->assertEquals(10000, (float) $item->discount_amount);
        $this->assertEquals(80000, (float) $item->subtotal);
    }

    public function test_checkout_uses_normal_price_when_org_is_not_premium(): void
    {
        Queue::fake();
        [, $org] = $this->actingMember(SubscriptionPlan::FREE);
        $product = $this->makeProduct($org, ['discount_enabled' => true, 'discount_type' => 'percent', 'discount_value' => 20]);

        $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '0811111111',
            'items' => [['product_id' => $product->id, 'quantity' => 1]],
        ])->assertCreated()->assertJsonPath('total', 50000);

        $item = PurchaseOrder::firstOrFail()->items()->firstOrFail();
        $this->assertNull($item->original_price);
        $this->assertEquals(0, (float) $item->discount_amount);
    }
}
