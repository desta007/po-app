<?php

namespace App\Http\Controllers;

use App\Enums\PaymentStatus;
use App\Enums\PurchaseOrderStatus;
use App\Http\Concerns\VerifiesCustomerPhone;
use App\Models\Organization;
use App\Models\PaymentTransaction;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderStatusHistory;
use App\Services\MidtransService;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PublicPaymentController extends Controller
{
    use VerifiesCustomerPhone;

    public function __construct(
        private MidtransService $midtrans,
        private NotificationService $notificationService,
    ) {}

    /**
     * Create a Snap token for an unpaid order. Public, but the caller must prove
     * ownership of the order by supplying the matching customer phone number.
     */
    public function pay(Request $request, string $slug, string $poNumber): JsonResponse
    {
        $request->validate([
            'phone' => ['required', 'string', 'max:20'],
        ]);

        $org = Organization::where('slug', $slug)->firstOrFail();

        if (! $org->isOnlinePaymentEnabled()) {
            return response()->json([
                'message' => 'Toko ini belum mengaktifkan pembayaran online.',
            ], 422);
        }

        $po = PurchaseOrder::where('organization_id', $org->id)
            ->where('po_number', $poNumber)
            ->with('customer')
            ->firstOrFail();

        if (! $this->phonesMatch($request->input('phone'), $po->customer?->phone)) {
            return response()->json(['message' => 'Nomor HP tidak cocok dengan pesanan ini.'], 403);
        }

        if ($po->payment_status === PaymentStatus::PAID) {
            return response()->json(['message' => 'Pesanan ini sudah lunas.'], 422);
        }

        try {
            $transaction = $this->midtrans->createSnapTransaction($org, $po);
        } catch (\Throwable $e) {
            Log::warning('Midtrans snap creation failed', ['po' => $po->id, 'error' => $e->getMessage()]);
            return response()->json(['message' => 'Gagal memulai pembayaran. Silakan coba lagi.'], 502);
        }

        return response()->json([
            'snap_token' => $transaction->snap_token,
            'client_key' => $this->midtrans->clientKey($org),
            'is_production' => $this->midtrans->isProduction($org),
        ]);
    }

    /**
     * Midtrans server-to-server notification handler. Authenticated by signature,
     * not by session — so it lives outside the auth middleware group.
     */
    public function webhook(Request $request, string $slug): JsonResponse
    {
        $org = Organization::where('slug', $slug)->first();
        if (! $org) {
            return response()->json(['message' => 'Not found.'], 404);
        }

        $payload = $request->all();

        if (! $this->midtrans->verifySignature($org, $payload)) {
            Log::warning('Midtrans webhook signature mismatch', ['org' => $org->id, 'order_id' => $payload['order_id'] ?? null]);
            return response()->json(['message' => 'Invalid signature.'], 403);
        }

        $transaction = PaymentTransaction::where('organization_id', $org->id)
            ->where('gateway_order_id', $payload['order_id'] ?? '')
            ->first();

        if (! $transaction) {
            return response()->json(['message' => 'Transaction not found.'], 404);
        }

        // Already settled — acknowledge without reprocessing (idempotent).
        if ($transaction->status === 'paid') {
            return response()->json(['message' => 'Already processed.']);
        }

        $newStatus = $this->midtrans->mapStatus($payload);

        DB::transaction(function () use ($transaction, $payload, $newStatus) {
            $transaction->update([
                'status' => $newStatus,
                'payment_type' => $payload['payment_type'] ?? $transaction->payment_type,
                'gateway_response' => $payload,
                'paid_at' => $newStatus === 'paid' ? now() : $transaction->paid_at,
            ]);

            if ($newStatus === 'paid') {
                $this->markOrderPaid($transaction->purchaseOrder);
            }
        });

        return response()->json(['message' => 'OK']);
    }

    private function markOrderPaid(PurchaseOrder $po): void
    {
        if ($po->payment_status === PaymentStatus::PAID) {
            return;
        }

        $fromStatus = $po->status;
        $po->payment_status = PaymentStatus::PAID;
        $po->paid_amount = $po->total;
        $po->payment_method = 'Midtrans';

        // Move a fresh draft forward to confirmed on successful payment.
        if ($po->status === PurchaseOrderStatus::DRAFT) {
            $po->status = PurchaseOrderStatus::CONFIRMED;
        }
        $po->save();

        if ($fromStatus !== $po->status) {
            PurchaseOrderStatusHistory::create([
                'po_id' => $po->id,
                'from_status' => $fromStatus->value,
                'to_status' => $po->status->value,
                'changed_by' => $po->created_by,
                'changed_at' => now(),
            ]);
        }

        if ($po->created_by) {
            $totalFormatted = number_format((float) $po->total, 0, ',', '.');
            $this->notificationService->createInAppNotification(
                userId: $po->created_by,
                title: "Pembayaran diterima — {$po->po_number}",
                message: "Pesanan {$po->po_number} telah dibayar lunas sebesar Rp{$totalFormatted} melalui pembayaran online.",
                poId: $po->id,
                orgId: $po->organization_id,
            );
        }
    }
}
