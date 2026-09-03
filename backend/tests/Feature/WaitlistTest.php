<?php

namespace Tests\Feature;

use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\OrganizationModule;
use App\Models\RestoTable;
use App\Jobs\SendWhatsAppNotification;
use App\Models\User;
use App\Models\WaitlistEntry;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Str;
use Tests\TestCase;

class WaitlistTest extends TestCase
{
    use RefreshDatabase;

    private function makeOrg(bool $withResto = true): array
    {
        $slug = 'resto-' . Str::lower(Str::random(8));
        $org = Organization::create(['name' => 'Resto ' . $slug, 'slug' => $slug]);

        $owner = User::factory()->create(['current_org_id' => $org->id]);
        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $owner->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        if ($withResto) {
            OrganizationModule::create([
                'organization_id' => $org->id,
                'module' => 'resto',
                'status' => 'active',
                'starts_at' => now(),
                'expires_at' => now()->addDays(30),
            ]);
        }

        return [$org, $owner];
    }

    public function test_waitlist_blocked_without_resto_module(): void
    {
        [, $owner] = $this->makeOrg(withResto: false);

        $this->actingAs($owner, 'sanctum')
            ->getJson('/api/waitlist')
            ->assertStatus(403)
            ->assertJson(['module_required' => true, 'module' => 'resto']);
    }

    public function test_add_guests_generate_sequential_daily_queue_numbers(): void
    {
        [, $owner] = $this->makeOrg();

        $first = $this->actingAs($owner, 'sanctum')
            ->postJson('/api/waitlist', ['guest_name' => 'Desta', 'party_size' => 2])
            ->assertCreated()->json('data');

        $second = $this->actingAs($owner, 'sanctum')
            ->postJson('/api/waitlist', ['guest_name' => 'Budi', 'party_size' => 4])
            ->assertCreated()->json('data');

        $this->assertSame(1, $first['queue_number']);
        $this->assertSame(2, $second['queue_number']);
        $this->assertSame('waiting', $first['status']);
    }

    public function test_call_marks_called_and_returns_announcement(): void
    {
        [, $owner] = $this->makeOrg();

        $entry = WaitlistEntry::create([
            'organization_id' => $owner->current_org_id,
            'queue_number' => 1,
            'guest_name' => 'Desta',
            'party_size' => 2,
            'status' => 'waiting',
        ]);

        $res = $this->actingAs($owner, 'sanctum')
            ->postJson("/api/waitlist/{$entry->id}/call")
            ->assertOk();

        $res->assertJsonPath('data.status', 'called');
        $res->assertJsonPath('data.call_count', 1);
        $this->assertStringContainsString('Desta', $res->json('announcement'));

        // Calling again increments the counter.
        $this->actingAs($owner, 'sanctum')
            ->postJson("/api/waitlist/{$entry->id}/call")
            ->assertJsonPath('data.call_count', 2);
    }

    public function test_call_dispatches_whatsapp_when_phone_present(): void
    {
        Queue::fake();
        [$org, $owner] = $this->makeOrg();

        $entry = WaitlistEntry::create([
            'organization_id' => $org->id,
            'queue_number' => 1,
            'guest_name' => 'Desta',
            'party_size' => 2,
            'phone' => '081234567890',
            'status' => 'waiting',
        ]);

        $this->actingAs($owner, 'sanctum')
            ->postJson("/api/waitlist/{$entry->id}/call")
            ->assertOk()
            ->assertJsonPath('whatsapp_sent', true);

        Queue::assertPushed(SendWhatsAppNotification::class, function ($job) {
            return $job->phone === '081234567890' && str_contains($job->message, 'Desta');
        });
    }

    public function test_call_does_not_dispatch_whatsapp_without_phone(): void
    {
        Queue::fake();
        [$org, $owner] = $this->makeOrg();

        $entry = WaitlistEntry::create([
            'organization_id' => $org->id,
            'queue_number' => 1,
            'guest_name' => 'Desta',
            'party_size' => 2,
            'status' => 'waiting',
        ]);

        $this->actingAs($owner, 'sanctum')
            ->postJson("/api/waitlist/{$entry->id}/call")
            ->assertOk()
            ->assertJsonPath('whatsapp_sent', false);

        Queue::assertNothingPushed();
    }

    public function test_seat_occupies_selected_table(): void
    {
        [$org, $owner] = $this->makeOrg();

        $table = RestoTable::create([
            'organization_id' => $org->id,
            'label' => 'Meja 5',
            'capacity' => 4,
            'status' => 'available',
        ]);
        $entry = WaitlistEntry::create([
            'organization_id' => $org->id,
            'queue_number' => 1,
            'guest_name' => 'Desta',
            'party_size' => 2,
            'status' => 'called',
        ]);

        $this->actingAs($owner, 'sanctum')
            ->postJson("/api/waitlist/{$entry->id}/seat", ['table_id' => $table->id])
            ->assertOk()
            ->assertJsonPath('data.status', 'seated')
            ->assertJsonPath('data.table_label', 'Meja 5');

        $this->assertSame('occupied', $table->refresh()->status);
    }

    public function test_cancel_from_seated_frees_table(): void
    {
        [$org, $owner] = $this->makeOrg();

        $table = RestoTable::create([
            'organization_id' => $org->id,
            'label' => 'Meja 1',
            'capacity' => 2,
            'status' => 'occupied',
        ]);
        $entry = WaitlistEntry::create([
            'organization_id' => $org->id,
            'queue_number' => 1,
            'guest_name' => 'Desta',
            'party_size' => 2,
            'status' => 'seated',
            'table_id' => $table->id,
            'table_label' => 'Meja 1',
        ]);

        $this->actingAs($owner, 'sanctum')
            ->postJson("/api/waitlist/{$entry->id}/cancel", ['status' => 'no_show'])
            ->assertOk()
            ->assertJsonPath('data.status', 'no_show');

        $this->assertSame('available', $table->refresh()->status);
    }

    public function test_index_returns_active_entries_and_stats(): void
    {
        [$org, $owner] = $this->makeOrg();

        WaitlistEntry::create(['organization_id' => $org->id, 'queue_number' => 1, 'guest_name' => 'A', 'party_size' => 1, 'status' => 'waiting']);
        WaitlistEntry::create(['organization_id' => $org->id, 'queue_number' => 2, 'guest_name' => 'B', 'party_size' => 1, 'status' => 'called']);
        WaitlistEntry::create(['organization_id' => $org->id, 'queue_number' => 3, 'guest_name' => 'C', 'party_size' => 1, 'status' => 'seated']);

        $res = $this->actingAs($owner, 'sanctum')->getJson('/api/waitlist')->assertOk();

        // Default view excludes seated.
        $this->assertCount(2, $res->json('data'));
        $this->assertSame(1, $res->json('stats.waiting'));
        $this->assertSame(1, $res->json('stats.called'));
        $this->assertSame(1, $res->json('stats.seated'));
    }

    public function test_entries_are_tenant_isolated(): void
    {
        [$orgA, $ownerA] = $this->makeOrg();
        [$orgB] = $this->makeOrg();

        WaitlistEntry::create(['organization_id' => $orgB->id, 'queue_number' => 1, 'guest_name' => 'Other', 'party_size' => 1, 'status' => 'waiting']);

        $res = $this->actingAs($ownerA, 'sanctum')->getJson('/api/waitlist')->assertOk();

        $this->assertCount(0, $res->json('data'));
    }
}
