<?php

namespace Tests\Feature;

use App\Enums\PaymentStatus;
use App\Enums\PurchaseOrderStatus;
use App\Models\Customer;
use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\PaymentTransaction;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class MidtransPaymentTest extends TestCase
{
    use RefreshDatabase;

    private string $serverKey = 'SB-Mid-server-testkey';

    private function makeStore(bool $onlinePayment = true): array
    {
        $settings = [];
        if ($onlinePayment) {
            $settings['online_store'] = [
                'midtrans' => [
                    'is_enabled' => true,
                    'is_production' => false,
                    'client_key' => 'SB-Mid-client-xyz',
                    'server_key' => Crypt::encryptString($this->serverKey),
                ],
                'shipping' => [
                    'flat_rates' => [['name' => 'Dalam Kota', 'cost' => 10000]],
                    'allow_pickup' => true,
                    'allow_shipping_tbd' => false,
                ],
            ];
        }

        $org = Organization::create([
            'name' => 'Toko Kue',
            'slug' => 'toko-kue',
            'settings' => $settings,
        ]);

        $owner = User::factory()->create(['current_org_id' => $org->id]);
        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $owner->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        $product = Product::create([
            'organization_id' => $org->id,
            'name' => 'Brownies',
            'price' => 50000,
            'stock_qty' => 10,
            'is_active' => true,
            'show_in_catalog' => true,
        ]);

        return [$org, $owner, $product];
    }

    private function makeOrder(Organization $org, User $owner, float $total = 100000): PurchaseOrder
    {
        $customer = Customer::create([
            'organization_id' => $org->id,
            'name' => 'Budi',
            'phone' => '081234567890',
        ]);

        return PurchaseOrder::create([
            'organization_id' => $org->id,
            'po_number' => 'PO-20260714-001',
            'customer_id' => $customer->id,
            'order_date' => now()->toDateString(),
            'delivery_date' => now()->toDateString(),
            'status' => 'draft',
            'payment_status' => 'unpaid',
            'subtotal' => $total,
            'total' => $total,
            'created_by' => $owner->id,
        ]);
    }

    private function signature(string $orderId, string $statusCode, string $gross): string
    {
        return hash('sha512', $orderId . $statusCode . $gross . $this->serverKey);
    }

    // --- Checkout shipping (server-authoritative) ---

    public function test_checkout_applies_configured_flat_shipping_rate(): void
    {
        [$org, , $product] = $this->makeStore();

        $response = $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '081234567890',
            'shipping_method' => 'Dalam Kota',
            'items' => [['product_id' => $product->id, 'quantity' => 2]],
        ]);

        $response->assertCreated()
            ->assertJsonPath('shipping_cost', 10000)
            ->assertJsonPath('total', 110000)          // 2*50.000 + 10.000
            ->assertJsonPath('online_payment_available', true);
    }

    public function test_checkout_ignores_unknown_shipping_method(): void
    {
        [$org, , $product] = $this->makeStore();

        $this->postJson("/api/catalog/{$org->slug}/checkout", [
            'customer_name' => 'Budi',
            'customer_phone' => '081234567890',
            'shipping_method' => 'Teleportasi Gratis Ongkir -99999',
            'items' => [['product_id' => $product->id, 'quantity' => 1]],
        ])->assertCreated()->assertJsonPath('shipping_cost', 0)->assertJsonPath('total', 50000);
    }

    // --- Pay (Snap token) ---

    public function test_pay_creates_snap_transaction_for_matching_phone(): void
    {
        [$org, $owner] = $this->makeStore();
        $po = $this->makeOrder($org, $owner);

        Http::fake([
            'app.sandbox.midtrans.com/*' => Http::response(['token' => 'snap-token-123', 'redirect_url' => 'https://x'], 201),
        ]);

        $response = $this->postJson("/api/catalog/{$org->slug}/orders/{$po->po_number}/pay", [
            'phone' => '081234567890',
        ]);

        $response->assertOk()
            ->assertJsonPath('snap_token', 'snap-token-123')
            ->assertJsonPath('client_key', 'SB-Mid-client-xyz');

        $this->assertDatabaseHas('payment_transactions', [
            'po_id' => $po->id,
            'status' => 'pending',
            'snap_token' => 'snap-token-123',
        ]);
    }

    public function test_pay_rejects_wrong_phone(): void
    {
        [$org, $owner] = $this->makeStore();
        $po = $this->makeOrder($org, $owner);

        $this->postJson("/api/catalog/{$org->slug}/orders/{$po->po_number}/pay", [
            'phone' => '080000000000',
        ])->assertStatus(403);
    }

    public function test_pay_blocked_when_online_payment_disabled(): void
    {
        [$org, $owner] = $this->makeStore(onlinePayment: false);
        $po = $this->makeOrder($org, $owner);

        $this->postJson("/api/catalog/{$org->slug}/orders/{$po->po_number}/pay", [
            'phone' => '081234567890',
        ])->assertStatus(422);
    }

    // --- Webhook ---

    public function test_webhook_with_valid_signature_marks_order_paid_and_confirmed(): void
    {
        [$org, $owner] = $this->makeStore();
        $po = $this->makeOrder($org, $owner);

        $orderId = $po->po_number . '-abc123';
        PaymentTransaction::create([
            'organization_id' => $org->id,
            'po_id' => $po->id,
            'gateway' => 'midtrans',
            'gateway_order_id' => $orderId,
            'status' => 'pending',
            'amount' => 100000,
        ]);

        $payload = [
            'order_id' => $orderId,
            'status_code' => '200',
            'gross_amount' => '100000.00',
            'transaction_status' => 'settlement',
            'payment_type' => 'qris',
            'signature_key' => $this->signature($orderId, '200', '100000.00'),
        ];

        $this->postJson("/api/webhooks/midtrans/{$org->slug}", $payload)->assertOk();

        $po->refresh();
        $this->assertEquals(PaymentStatus::PAID, $po->payment_status);
        $this->assertEquals(PurchaseOrderStatus::CONFIRMED, $po->status);
        $this->assertEquals(100000, (float) $po->paid_amount);
        $this->assertDatabaseHas('payment_transactions', ['gateway_order_id' => $orderId, 'status' => 'paid']);
    }

    public function test_webhook_with_invalid_signature_is_rejected(): void
    {
        [$org, $owner] = $this->makeStore();
        $po = $this->makeOrder($org, $owner);

        $orderId = $po->po_number . '-abc123';
        PaymentTransaction::create([
            'organization_id' => $org->id,
            'po_id' => $po->id,
            'gateway_order_id' => $orderId,
            'status' => 'pending',
            'amount' => 100000,
        ]);

        $payload = [
            'order_id' => $orderId,
            'status_code' => '200',
            'gross_amount' => '100000.00',
            'transaction_status' => 'settlement',
            'signature_key' => 'totally-wrong-signature',
        ];

        $this->postJson("/api/webhooks/midtrans/{$org->slug}", $payload)->assertStatus(403);

        $po->refresh();
        $this->assertEquals(PaymentStatus::UNPAID, $po->payment_status);
    }

    public function test_webhook_is_idempotent_for_already_paid_order(): void
    {
        [$org, $owner] = $this->makeStore();
        $po = $this->makeOrder($org, $owner);
        $po->update(['payment_status' => 'paid', 'status' => 'confirmed', 'paid_amount' => 100000]);

        $orderId = $po->po_number . '-abc123';
        PaymentTransaction::create([
            'organization_id' => $org->id,
            'po_id' => $po->id,
            'gateway_order_id' => $orderId,
            'status' => 'paid',
            'amount' => 100000,
        ]);

        $payload = [
            'order_id' => $orderId,
            'status_code' => '200',
            'gross_amount' => '100000.00',
            'transaction_status' => 'settlement',
            'signature_key' => $this->signature($orderId, '200', '100000.00'),
        ];

        $this->postJson("/api/webhooks/midtrans/{$org->slug}", $payload)->assertOk();

        // Already-paid order is acknowledged without reprocessing → no new status history.
        $this->assertEquals(0, $po->statusHistory()->count());
        $this->assertEquals(PaymentStatus::PAID, $po->refresh()->payment_status);
    }

    // --- Order status tracking ---

    public function test_order_status_requires_matching_phone(): void
    {
        [$org, $owner] = $this->makeStore();
        $po = $this->makeOrder($org, $owner);

        $this->getJson("/api/catalog/{$org->slug}/orders/{$po->po_number}?phone=081234567890")
            ->assertOk()
            ->assertJsonPath('data.po_number', $po->po_number)
            ->assertJsonPath('data.payment_status', 'unpaid');

        $this->getJson("/api/catalog/{$org->slug}/orders/{$po->po_number}?phone=080000000000")
            ->assertStatus(403);
    }
}
