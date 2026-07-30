<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

interface WhatsAppDriverInterface
{
    public function send(string $phone, string $message): bool;
}

class LogWhatsAppDriver implements WhatsAppDriverInterface
{
    public function send(string $phone, string $message): bool
    {
        Log::channel('single')->info('[WhatsApp Mock] Sending to: ' . $phone, [
            'message' => $message,
        ]);
        return true;
    }
}

/**
 * Sends WhatsApp messages through a self-hosted WAHA instance
 * (https://waha.devlike.pro) using its /api/sendText endpoint.
 */
class WahaWhatsAppDriver implements WhatsAppDriverInterface
{
    public function send(string $phone, string $message): bool
    {
        $chatId = $this->toChatId($phone);
        if (! $chatId) {
            Log::warning('[WAHA] Skipped send — invalid phone number.', ['phone' => $phone]);
            return false;
        }

        $url = rtrim((string) config('whatsapp.waha_url'), '/');
        $session = config('whatsapp.waha_session', 'default');
        $apiKey = (string) config('whatsapp.waha_api_key');

        try {
            $response = Http::withHeaders(array_filter([
                'X-Api-Key' => $apiKey ?: null,
            ]))
                ->timeout(15)
                ->acceptJson()
                ->post("{$url}/api/sendText", [
                    'session' => $session,
                    'chatId' => $chatId,
                    'text' => $message,
                ]);

            if ($response->successful()) {
                return true;
            }

            Log::error('[WAHA] Send failed.', [
                'chatId' => $chatId,
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            return false;
        } catch (\Throwable $e) {
            Log::error('[WAHA] Send threw an exception.', [
                'chatId' => $chatId,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Normalise an Indonesian phone number to WAHA's chatId format: 628xxxxxxxx@c.us.
     * Returns null when there are no usable digits.
     */
    private function toChatId(string $phone): ?string
    {
        $digits = preg_replace('/\D+/', '', $phone) ?? '';

        if ($digits === '') {
            return null;
        }

        if (str_starts_with($digits, '0')) {
            $digits = '62' . substr($digits, 1);
        } elseif (str_starts_with($digits, '8')) {
            // Bare local mobile number (e.g. 812xxxx) — assume Indonesia.
            $digits = '62' . $digits;
        }

        return $digits . '@c.us';
    }
}

class WhatsAppService
{
    private WhatsAppDriverInterface $driver;

    public function __construct()
    {
        $driverType = config('whatsapp.driver', 'log');

        $this->driver = match ($driverType) {
            'log' => new LogWhatsAppDriver(),
            'waha' => new WahaWhatsAppDriver(),
            default => new LogWhatsAppDriver(),
        };
    }

    public function send(string $phone, string $message): bool
    {
        return $this->driver->send($phone, $message);
    }
}
