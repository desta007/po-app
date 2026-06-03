<?php

namespace App\Services;

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

class WhatsAppService
{
    private WhatsAppDriverInterface $driver;

    public function __construct()
    {
        $driverType = config('whatsapp.driver', 'log');

        $this->driver = match ($driverType) {
            'log' => new LogWhatsAppDriver(),
            // 'fonnte' => new FonnteWhatsAppDriver(),
            default => new LogWhatsAppDriver(),
        };
    }

    public function send(string $phone, string $message): bool
    {
        return $this->driver->send($phone, $message);
    }
}
