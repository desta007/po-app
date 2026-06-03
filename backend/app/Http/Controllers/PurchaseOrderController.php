<?php

namespace App\Http\Controllers;

use App\Enums\PurchaseOrderStatus;
use App\Http\Requests\PurchaseOrder\CancelPurchaseOrderRequest;
use App\Http\Requests\PurchaseOrder\StorePurchaseOrderRequest;
use App\Http\Requests\PurchaseOrder\UpdatePurchaseOrderRequest;
use App\Http\Requests\PurchaseOrder\UpdateStatusRequest;
use App\Http\Resources\PurchaseOrderResource;
use App\Models\PurchaseOrder;
use App\Services\PdfExportService;
use App\Services\PurchaseOrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class PurchaseOrderController extends Controller
{
    public function __construct(
        private PurchaseOrderService $poService,
        private PdfExportService $pdfService,
    ) {}

    public function index(Request $request): AnonymousResourceCollection
    {
        $query = PurchaseOrder::with('customer');

        if ($search = $request->input('search')) {
            $query->where('po_number', 'ilike', "%{$search}%");
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($customerId = $request->input('customer_id')) {
            $query->where('customer_id', $customerId);
        }

        if ($from = $request->input('from_date')) {
            $query->where('delivery_date', '>=', $from);
        }

        if ($to = $request->input('to_date')) {
            $query->where('delivery_date', '<=', $to);
        }

        $pos = $query->orderByDesc('created_at')
            ->paginate($request->input('per_page', 15));

        return PurchaseOrderResource::collection($pos);
    }

    public function store(StorePurchaseOrderRequest $request): JsonResponse
    {
        $data = $request->except('items');
        $items = $request->input('items');

        $po = $this->poService->create($data, $items);

        return response()->json([
            'data' => new PurchaseOrderResource($po->load('items', 'customer', 'statusHistory')),
            'message' => 'Purchase Order berhasil dibuat.',
        ], 201);
    }

    public function show(PurchaseOrder $purchaseOrder): PurchaseOrderResource
    {
        return new PurchaseOrderResource(
            $purchaseOrder->load('items', 'customer', 'statusHistory', 'creator')
        );
    }

    public function update(UpdatePurchaseOrderRequest $request, PurchaseOrder $purchaseOrder): JsonResponse
    {
        $data = $request->except('items');
        $items = $request->input('items', []);

        $po = $this->poService->update($purchaseOrder, $data, $items);

        return response()->json([
            'data' => new PurchaseOrderResource($po->load('items', 'customer', 'statusHistory')),
            'message' => 'Purchase Order berhasil diperbarui.',
        ]);
    }

    public function destroy(PurchaseOrder $purchaseOrder): JsonResponse
    {
        $purchaseOrder->delete();

        return response()->json(['message' => 'Purchase Order berhasil dihapus.']);
    }

    public function updateStatus(UpdateStatusRequest $request, PurchaseOrder $purchaseOrder): JsonResponse
    {
        $newStatus = PurchaseOrderStatus::from($request->status);
        $po = $this->poService->updateStatus($purchaseOrder, $newStatus, $request->reason);

        return response()->json([
            'data' => new PurchaseOrderResource($po),
            'message' => "Status berhasil diubah menjadi {$newStatus->label()}.",
        ]);
    }

    public function cancel(CancelPurchaseOrderRequest $request, PurchaseOrder $purchaseOrder): JsonResponse
    {
        $po = $this->poService->cancel($purchaseOrder, $request->reason);

        return response()->json([
            'data' => new PurchaseOrderResource($po),
            'message' => 'Purchase Order berhasil dibatalkan.',
        ]);
    }

    public function updatePayment(Request $request, PurchaseOrder $purchaseOrder): JsonResponse
    {
        $request->validate([
            'payment_status' => ['required', 'in:unpaid,dp,paid'],
            'paid_amount' => ['required', 'numeric', 'min:0'],
        ]);

        $purchaseOrder->update([
            'payment_status' => $request->payment_status,
            'paid_amount' => $request->paid_amount,
        ]);

        return response()->json([
            'data' => new PurchaseOrderResource($purchaseOrder->fresh('items', 'customer', 'statusHistory')),
            'message' => 'Status pembayaran berhasil diperbarui.',
        ]);
    }

    public function duplicate(PurchaseOrder $purchaseOrder): JsonResponse
    {
        $newPo = $this->poService->duplicate($purchaseOrder);

        return response()->json([
            'data' => new PurchaseOrderResource($newPo->load('items', 'customer')),
            'message' => 'Purchase Order berhasil diduplikasi.',
        ], 201);
    }

    public function exportPdf(PurchaseOrder $purchaseOrder)
    {
        $pdf = $this->pdfService->generateInvoice($purchaseOrder);

        return $pdf->download("Invoice-{$purchaseOrder->po_number}.pdf");
    }
}
