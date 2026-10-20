<?php

namespace Tests\Feature;

use App\Console\Commands\CheckWhatsAppStatus;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

/**
 * Alarm kesehatan WAHA ke super admin.
 *
 * @see CheckWhatsAppStatus
 */
class CheckWhatsAppStatusTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'whatsapp.driver' => 'waha',
            'whatsapp.waha_url' => 'https://waha.test',
            'whatsapp.waha_session' => 'default',
        ]);

        $this->admin = User::factory()->create(['is_super_admin' => true]);
        User::factory()->create(['is_super_admin' => false]);
    }

    /** Antrekan status yang dikembalikan WAHA, satu per pemanggilan command. */
    private function fakeStatuses(string ...$statuses): void
    {
        $sequence = Http::sequence();
        foreach ($statuses as $status) {
            $sequence->push(['name' => 'default', 'status' => $status]);
        }
        Http::fake(['waha.test/*' => $sequence]);
    }

    private function runCheck(int $times = 1): void
    {
        for ($i = 0; $i < $times; $i++) {
            $this->artisan('whatsapp:check-status')->assertSuccessful();
        }
    }

    public function test_working_session_sends_no_alert(): void
    {
        $this->fakeStatuses('WORKING', 'WORKING');

        $this->runCheck(2);

        $this->assertSame(0, Notification::where('user_id', $this->admin->id)->count());
    }

    public function test_single_bad_check_does_not_alert_yet(): void
    {
        $this->fakeStatuses('FAILED');

        $this->runCheck();

        $this->assertSame(0, Notification::where('user_id', $this->admin->id)->count());
    }

    public function test_alerts_super_admins_once_after_consecutive_failures(): void
    {
        $this->fakeStatuses('FAILED', 'FAILED', 'FAILED', 'FAILED');

        $this->runCheck(4);

        $alerts = Notification::where('user_id', $this->admin->id)->get();
        $this->assertCount(1, $alerts, 'Alarm hanya dikirim sekali selama gangguan berlangsung.');
        $this->assertSame($this->admin->id, $alerts->first()->user_id);
        $this->assertStringContainsString('FAILED', $alerts->first()->title);
    }

    public function test_sends_recovery_notice_and_rearms(): void
    {
        $this->fakeStatuses('FAILED', 'FAILED', 'WORKING', 'SCAN_QR_CODE', 'SCAN_QR_CODE');

        $this->runCheck(5);

        $titles = Notification::where('user_id', $this->admin->id)->orderBy('created_at')->pluck('title')->all();
        $this->assertCount(3, $titles);
        $this->assertStringContainsString('FAILED', $titles[0]);
        $this->assertStringContainsString('kembali normal', $titles[1]);
        $this->assertStringContainsString('SCAN_QR_CODE', $titles[2]);
    }

    public function test_starting_status_neither_counts_nor_resets(): void
    {
        $this->fakeStatuses('FAILED', 'STARTING', 'FAILED');

        $this->runCheck(3);

        $this->assertSame(1, Notification::where('user_id', $this->admin->id)->count());
    }

    public function test_unreachable_waha_triggers_alert(): void
    {
        Http::fake(fn () => throw new ConnectionException('getaddrinfo EAI_AGAIN'));

        $this->runCheck(2);

        $this->assertStringContainsString('UNREACHABLE', Notification::where('user_id', $this->admin->id)->first()->title);
    }

    public function test_skipped_when_driver_is_not_waha(): void
    {
        config(['whatsapp.driver' => 'log']);
        Http::fake();

        $this->runCheck(3);

        Http::assertNothingSent();
        $this->assertSame(0, Notification::where('user_id', $this->admin->id)->count());
    }
}
