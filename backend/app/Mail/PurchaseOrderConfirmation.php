<?php

namespace App\Mail;

use App\Models\PurchaseOrder;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class PurchaseOrderConfirmation extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public PurchaseOrder $po) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: "Konfirmasi Pesanan {$this->po->po_number}",
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'mail.po-confirmation',
            with: [
                'po' => $this->po->load('items', 'customer', 'organization'),
            ],
        );
    }
}
