<?php

namespace App\Services;

use App\Models\Organization;
use App\Models\PaymentTransaction;
use App\Models\PurchaseOrder;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use RuntimeException;

class MidtransService
{
    /**
     * Create a Snap transaction against the organization's own Midtrans account
     * and persist a pending PaymentTransaction. Returns that transaction.
     */
    public function createSnapTransaction(Organization $org, PurchaseOrder $po): PaymentTransaction
    {
        $serverKey = $org->midtransServerKey();
        if (! $serverKey) {
            throw new RuntimeException('Midtrans server key is not configured for this organization.');
        }

        $isProduction = (bool) ($org->onlineStore()['midtrans']['is_production'] ?? false);
        $grossAmount = (int) round((float) $po->total);

        // A fresh, unique order id per attempt so retries after expiry are accepted by Midtrans.
        $gatewayOrderId = $po->po_number . '-' . substr(str_replace('-', '', (string) Str::uuid()), 0, 10);

        $po->loadMissing('customer');

        $payload = [
            'transaction_details' => [
                'order_id' => $gatewayOrderId,
                'gross_amount' => $grossAmount,
            ],
            'item_details' => [[
                'id' => $po->id,
                'price' => $grossAmount,
                'quantity' => 1,
                'name' => Str::limit('Pesanan ' . $po->po_number, 48, ''),
            ]],
            'customer_details' => [
                'first_name' => Str::limit($po->customer?->name ?? 'Pelanggan', 50, ''),
                'phone' => $po->customer?->phone,
            ],
        ];

        $response = Http::withBasicAuth($serverKey, '')
            ->acceptJson()
            ->asJson()
            ->timeout(20)
            ->post($this->snapBaseUrl($isProduction) . '/snap/v1/transactions', $payload);

        if (! $response->successful() || ! $response->json('token')) {
            $reason = $response->json('error_messages.0') ?? 'Gagal membuat transaksi pembayaran.';
            throw new RuntimeException($reason);
        }

        return PaymentTransaction::create([
            'organization_id' => $org->id,
            'po_id' => $po->id,
            'gateway' => 'midtrans',
            'gateway_order_id' => $gatewayOrderId,
            'snap_token' => $response->json('token'),
            'status' => 'pending',
            'amount' => $grossAmount,
        ]);
    }

    /**
     * Verify the SHA512 signature Midtrans sends on notification callbacks.
     */
    public function verifySignature(Organization $org, array $payload): bool
    {
        $serverKey = $org->midtransServerKey();
        if (! $serverKey) {
            return false;
        }

        $expected = hash('sha512',
            ($payload['order_id'] ?? '')
            . ($payload['status_code'] ?? '')
            . ($payload['gross_amount'] ?? '')
            . $serverKey
        );

        return hash_equals($expected, (string) ($payload['signature_key'] ?? ''));
    }

    /**
     * Normalise a Midtrans notification into our internal status vocabulary.
     */
    public function mapStatus(array $payload): string
    {
        $transaction = $payload['transaction_status'] ?? '';
        $fraud = $payload['fraud_status'] ?? 'accept';

        return match ($transaction) {
            'capture' => $fraud === 'accept' ? 'paid' : 'pending',
            'settlement' => 'paid',
            'pending' => 'pending',
            'deny' => 'failed',
            'cancel', 'expire' => 'expired',
            'refund', 'partial_refund' => 'refunded',
            default => 'pending',
        };
    }

    public function clientKey(Organization $org): ?string
    {
        return $org->onlineStore()['midtrans']['client_key'] ?? null;
    }

    public function isProduction(Organization $org): bool
    {
        return (bool) ($org->onlineStore()['midtrans']['is_production'] ?? false);
    }

    private function snapBaseUrl(bool $isProduction): string
    {
        return $isProduction ? 'https://app.midtrans.com' : 'https://app.sandbox.midtrans.com';
    }
}
