<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Alarm kesehatan WAHA: cek status session WhatsApp dan beri notifikasi in-app
 * ke semua super admin bila session tidak WORKING.
 *
 * Latar belakang: setelah gangguan jaringan/DNS sesaat, WAHA bisa jatuh ke
 * FAILED dan tidak reconnect sendiri — WhatsApp otomatis mati berhari-hari
 * tanpa ada yang tahu. Dijadwalkan tiap 5 menit di routes/console.php.
 */
class CheckWhatsAppStatus extends Command
{
    protected $signature = 'whatsapp:check-status';

    protected $description = 'Cek status session WAHA dan beri tahu super admin bila WhatsApp otomatis tidak berfungsi.';

    /** Jumlah pengecekan buruk berturut-turut sebelum alarm dikirim (hindari alarm palsu karena gangguan sekejap). */
    private const BAD_CHECKS_BEFORE_ALERT = 2;

    /** Status transisi — tidak dihitung buruk maupun pulih. */
    private const TRANSIENT_STATUSES = ['STARTING'];

    private const CACHE_BAD_COUNT = 'whatsapp_health.bad_count';

    private const CACHE_ALERTED = 'whatsapp_health.alerted';

    public function handle(NotificationService $notifications): int
    {
        if (config('whatsapp.driver') !== 'waha') {
            $this->info('Driver WhatsApp bukan waha — pengecekan dilewati.');

            return self::SUCCESS;
        }

        $status = $this->fetchSessionStatus();
        $this->line("Status session WAHA: {$status}");

        if (in_array($status, self::TRANSIENT_STATUSES, true)) {
            return self::SUCCESS;
        }

        if ($status === 'WORKING') {
            if (Cache::get(self::CACHE_ALERTED)) {
                $this->notifySuperAdmins(
                    $notifications,
                    'WhatsApp otomatis kembali normal',
                    'Session WAHA sudah WORKING lagi. Cek pesan yang gagal terkirim selama gangguan (php artisan queue:failed) dan kirim ulang hanya yang masih relevan.',
                );
                Log::info('[WAHA] Session pulih (WORKING).');
            }
            Cache::forget(self::CACHE_BAD_COUNT);
            Cache::forget(self::CACHE_ALERTED);

            return self::SUCCESS;
        }

        $badCount = (int) Cache::get(self::CACHE_BAD_COUNT, 0) + 1;
        Cache::forever(self::CACHE_BAD_COUNT, $badCount);

        if ($badCount >= self::BAD_CHECKS_BEFORE_ALERT && ! Cache::get(self::CACHE_ALERTED)) {
            $this->notifySuperAdmins(
                $notifications,
                "WhatsApp otomatis bermasalah — status {$status}",
                $this->adviceFor($status),
            );
            Cache::forever(self::CACHE_ALERTED, true);
            Log::error('[WAHA] Session tidak WORKING — alarm dikirim ke super admin.', ['status' => $status]);
        }

        return self::SUCCESS;
    }

    /**
     * Status session dari WAHA (WORKING, FAILED, STOPPED, SCAN_QR_CODE, STARTING),
     * atau UNREACHABLE bila server WAHA tidak bisa dihubungi.
     */
    private function fetchSessionStatus(): string
    {
        $url = rtrim((string) config('whatsapp.waha_url'), '/');
        $session = config('whatsapp.waha_session', 'default');
        $apiKey = (string) config('whatsapp.waha_api_key');

        try {
            $response = Http::withHeaders(array_filter(['X-Api-Key' => $apiKey ?: null]))
                ->timeout(10)
                ->acceptJson()
                ->get("{$url}/api/sessions/{$session}");

            if (! $response->successful()) {
                Log::warning('[WAHA] Cek status gagal.', ['status' => $response->status(), 'body' => $response->body()]);

                return $response->status() === 404 ? 'NOT_FOUND' : 'UNREACHABLE';
            }

            return strtoupper((string) ($response->json('status') ?: 'UNKNOWN'));
        } catch (\Throwable $e) {
            Log::warning('[WAHA] Cek status melempar exception.', ['error' => $e->getMessage()]);

            return 'UNREACHABLE';
        }
    }

    private function adviceFor(string $status): string
    {
        $impact = 'Notifikasi WhatsApp checkout katalog dan panggilan antrian Resto tidak terkirim.';

        $advice = match ($status) {
            'FAILED', 'STOPPED' => 'Buka dashboard WAHA lalu klik Restart pada session (jangan Logout dulu). Bila tetap gagal, Logout → Start → scan QR ulang.',
            'SCAN_QR_CODE' => 'Session perlu ditautkan ulang: buka dashboard WAHA, tampilkan QR, lalu scan dari WhatsApp di HP (Perangkat Tertaut → Tautkan Perangkat).',
            'UNREACHABLE' => 'Server WAHA tidak bisa dihubungi. Cek VPS dan container WAHA (docker compose ps / logs).',
            'NOT_FOUND' => 'Session tidak ditemukan di WAHA. Cek nama session (WAHA_SESSION) atau buat ulang session di dashboard.',
            default => 'Cek dashboard WAHA dan log container.',
        };

        return "{$impact} {$advice}";
    }

    private function notifySuperAdmins(NotificationService $notifications, string $title, string $message): void
    {
        User::where('is_super_admin', true)->where('is_active', true)->each(function (User $admin) use ($notifications, $title, $message) {
            // Daftar notifikasi difilter per org aktif user, jadi ikuti org aktif super admin.
            $notifications->createInAppNotification(
                userId: $admin->id,
                title: $title,
                message: $message,
                orgId: $admin->current_org_id,
            );
        });
    }
}
