<?php

namespace App\Mail;

use App\Models\PurchaseOrder;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class DeliveryReminder extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public PurchaseOrder $po, public string $dayLabel = 'besok') {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: "Pengingat Pengiriman {$this->dayLabel}: {$this->po->po_number}",
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'mail.delivery-reminder',
            with: [
                'po' => $this->po->load('items', 'customer'),
                'dayLabel' => $this->dayLabel,
            ],
        );
    }
}
