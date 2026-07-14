<?php

namespace Tests\Feature;

use App\Enums\SubscriptionPlan;
use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Crypt;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OnlineStoreSettingTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array{0: User, 1: Organization}
     */
    private function actingOwner(SubscriptionPlan $plan = SubscriptionPlan::PREMIUM, string $role = 'owner'): array
    {
        $org = Organization::create([
            'name' => 'Toko Kue',
            'slug' => 'toko-kue',
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

    public function test_premium_owner_can_save_and_server_key_is_encrypted_and_hidden(): void
    {
        [, $org] = $this->actingOwner();

        $response = $this->putJson('/api/settings/online-store', [
            'midtrans' => [
                'is_enabled' => true,
                'is_production' => false,
                'client_key' => 'SB-Mid-client-abc',
                'server_key' => 'SB-Mid-server-secret',
            ],
            'shipping' => [
                'flat_rates' => [['name' => 'Dalam Kota', 'cost' => 10000]],
                'allow_pickup' => true,
                'allow_shipping_tbd' => false,
            ],
        ]);

        $response->assertOk()
            ->assertJsonPath('data.midtrans.is_enabled', true)
            ->assertJsonPath('data.midtrans.server_key_set', true)
            ->assertJsonPath('data.shipping.flat_rates.0.name', 'Dalam Kota');

        // Secret is never echoed back to the client.
        $response->assertJsonMissingPath('data.midtrans.server_key');

        // Stored encrypted, decryptable back to the original.
        $stored = $org->refresh()->settings['online_store']['midtrans']['server_key'];
        $this->assertNotEquals('SB-Mid-server-secret', $stored);
        $this->assertEquals('SB-Mid-server-secret', Crypt::decryptString($stored));
        $this->assertEquals('SB-Mid-server-secret', $org->midtransServerKey());
        $this->assertTrue($org->isOnlinePaymentEnabled());
    }

    public function test_blank_server_key_keeps_the_existing_one(): void
    {
        [, $org] = $this->actingOwner();

        $this->putJson('/api/settings/online-store', [
            'midtrans' => ['is_enabled' => true, 'client_key' => 'c1', 'server_key' => 'SECRET-1'],
            'shipping' => ['flat_rates' => []],
        ])->assertOk();

        // Second save without a server_key must not wipe the stored one.
        $this->putJson('/api/settings/online-store', [
            'midtrans' => ['is_enabled' => true, 'client_key' => 'c2', 'server_key' => ''],
            'shipping' => ['flat_rates' => []],
        ])->assertOk();

        $this->assertEquals('SECRET-1', $org->refresh()->midtransServerKey());
        $this->assertEquals('c2', $org->onlineStore()['midtrans']['client_key']);
    }

    public function test_cannot_enable_payment_without_a_server_key(): void
    {
        $this->actingOwner();

        $this->putJson('/api/settings/online-store', [
            'midtrans' => ['is_enabled' => true, 'client_key' => 'c1', 'server_key' => ''],
            'shipping' => ['flat_rates' => []],
        ])->assertStatus(422);
    }

    public function test_free_plan_owner_is_blocked_from_saving(): void
    {
        $this->actingOwner(SubscriptionPlan::FREE);

        $this->putJson('/api/settings/online-store', [
            'midtrans' => ['is_enabled' => false, 'client_key' => '', 'server_key' => ''],
            'shipping' => ['flat_rates' => []],
        ])->assertStatus(403);
    }

    public function test_staff_role_cannot_update_online_store(): void
    {
        $this->actingOwner(SubscriptionPlan::PREMIUM, 'staff');

        $this->putJson('/api/settings/online-store', [
            'midtrans' => ['is_enabled' => false, 'client_key' => '', 'server_key' => ''],
            'shipping' => ['flat_rates' => []],
        ])->assertStatus(403);
    }
}
