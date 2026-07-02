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
        $query = PurchaseOrder::with('customer', 'items');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('po_number', 'ilike', "%{$search}%")
                  ->orWhereHas('customer', function ($cq) use ($search) {
                      $cq->where('name', 'ilike', "%{$search}%")
                         ->orWhere('phone', 'ilike', "%{$search}%");
                  })
                  ->orWhereHas('items', function ($iq) use ($search) {
                      $iq->where('product_name', 'ilike', "%{$search}%");
                  });
            });
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($paymentStatus = $request->input('payment_status')) {
            $query->where('payment_status', $paymentStatus);
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

        $sortBy = $request->input('sort_by', 'created_at');
        $sortDir = $request->input('sort_dir', 'desc');
        $allowedSorts = ['created_at', 'delivery_date', 'order_date', 'po_number', 'total'];
        if (!in_array($sortBy, $allowedSorts)) {
            $sortBy = 'created_at';
        }

        $pos = $query->orderBy($sortBy, $sortDir === 'asc' ? 'asc' : 'desc')
            ->paginate($request->input('per_page', 20));

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
            'payment_method' => ['nullable', 'string', 'max:100'],
        ]);

        $purchaseOrder->update([
            'payment_status' => $request->payment_status,
            'paid_amount' => $request->paid_amount,
            'payment_method' => $request->payment_method,
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

    public function bulkExportPdf(Request $request)
    {
        $request->validate([
            'ids' => ['required', 'array', 'min:1', 'max:50'],
            'ids.*' => ['required', 'uuid'],
            'format' => ['required', 'in:receipt,corporate'],
        ]);

        $pos = PurchaseOrder::whereIn('id', $request->ids)
            ->with('items', 'customer', 'organization')
            ->get();

        if ($pos->isEmpty()) {
            return response()->json(['message' => 'Tidak ada PO yang ditemukan.'], 404);
        }

        // Maintain the order from request
        $ordered = collect($request->ids)
            ->map(fn($id) => $pos->firstWhere('id', $id))
            ->filter();

        $pdfContent = $this->pdfService->generateBulkPdf($ordered, $request->format);

        $filename = 'Bulk-Invoice-' . now()->format('Ymd-His') . '.pdf';

        return response($pdfContent, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => "inline; filename=\"{$filename}\"",
        ]);
    }

    public function exportPdf(PurchaseOrder $purchaseOrder)
    {
        $pdf = $this->pdfService->generateInvoice($purchaseOrder);

        return $pdf->download("Invoice-{$purchaseOrder->po_number}.pdf");
    }

    public function exportCorporatePdf(PurchaseOrder $purchaseOrder)
    {
        $pdf = $this->pdfService->generateCorporateInvoice($purchaseOrder);

        return $pdf->download("Invoice-{$purchaseOrder->po_number}.pdf");
    }

    public function exportImage(PurchaseOrder $purchaseOrder)
    {
        try {
            $imageBlob = $this->pdfService->generateInvoiceImage($purchaseOrder);

            return response($imageBlob, 200, [
                'Content-Type' => 'image/png',
                'Content-Disposition' => "inline; filename=\"Invoice-{$purchaseOrder->po_number}.png\"",
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }

    public function exportHtml(PurchaseOrder $purchaseOrder)
    {
        $purchaseOrder->load('items', 'customer', 'organization');
        
        // Pass a flag so the view can use URL instead of local path for the logo
        $html = view('pdf.invoice', [
            'po' => $purchaseOrder,
            'organization' => $purchaseOrder->organization,
            'customer' => $purchaseOrder->customer,
            'items' => $purchaseOrder->items,
            'is_html' => true,
        ])->render();

        return response($html);
    }
}
