<?php

namespace App\Jobs;

use App\Services\WhatsAppService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class SendWhatsAppNotification implements ShouldQueue
{
    use Queueable;

    /** Retry a few times before giving up — transient WAHA/network errors are common. */
    public int $tries = 3;

    /** Seconds to wait between retries. */
    public int $backoff = 30;

    public function __construct(
        public string $phone,
        public string $message,
    ) {}

    public function handle(WhatsAppService $wa): void
    {
        if (! $wa->send($this->phone, $this->message)) {
            // Throwing lets the queue worker retry (up to $tries).
            throw new \RuntimeException("WhatsApp send failed for {$this->phone}");
        }
    }
}
