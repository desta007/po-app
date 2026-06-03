<?php

namespace App\Jobs;

use App\Enums\PurchaseOrderStatus;
use App\Models\PurchaseOrder;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Mail;
use App\Mail\PurchaseOrderConfirmation;
use App\Mail\DeliveryReminder;

class SendEmailNotification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public PurchaseOrder $po,
        public PurchaseOrderStatus $status,
    ) {}

    public function handle(): void
    {
        $email = $this->po->customer?->email;
        if (!$email) return;

        $mailable = match ($this->status) {
            PurchaseOrderStatus::CONFIRMED => new PurchaseOrderConfirmation($this->po),
            default => null,
        };

        if ($mailable) {
            Mail::to($email)->send($mailable);
        }
    }
}
