<?php

namespace App\Services;

use App\Enums\PurchaseOrderStatus;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\PurchaseOrderStatusHistory;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PurchaseOrderService
{
    public function __construct(
        private PurchaseOrderNumberGenerator $numberGenerator,
        private NotificationService $notificationService,
    ) {}

    public function create(array $data, array $items): PurchaseOrder
    {
        return DB::transaction(function () use ($data, $items) {
            $orgId = auth()->user()->current_org_id;
            $data['po_number'] = $this->numberGenerator->generate($orgId);
            $data['organization_id'] = $orgId;
            $data['created_by'] = auth()->id();
            $data['status'] = 'draft';

            $calculated = $this->calculateTotals($items, $data['discount'] ?? 0, $data['tax'] ?? 0, $data['shipping_cost'] ?? 0);
            $data = array_merge($data, $calculated);

            $po = PurchaseOrder::create($data);

            foreach ($items as $index => $item) {
                $po->items()->create([
                    'product_id' => $item['product_id'] ?? null,
                    'product_name' => $item['product_name'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'subtotal' => round($item['quantity'] * $item['unit_price'], 2),
                    'notes' => $item['notes'] ?? null,
                    'sort_order' => $index,
                ]);
            }

            // Log initial status
            PurchaseOrderStatusHistory::create([
                'po_id' => $po->id,
                'from_status' => null,
                'to_status' => 'draft',
                'changed_by' => auth()->id(),
                'changed_at' => now(),
            ]);

            return $po->load('items', 'customer');
        });
    }

    public function update(PurchaseOrder $po, array $data, array $items): PurchaseOrder
    {
        return DB::transaction(function () use ($po, $data, $items) {
            $calculated = $this->calculateTotals($items, $data['discount'] ?? $po->discount, $data['tax'] ?? $po->tax, $data['shipping_cost'] ?? $po->shipping_cost);
            $data = array_merge($data, $calculated);

            $po->update($data);

            // Delete existing items and recreate
            $po->items()->delete();

            foreach ($items as $index => $item) {
                $po->items()->create([
                    'product_id' => $item['product_id'] ?? null,
                    'product_name' => $item['product_name'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'subtotal' => round($item['quantity'] * $item['unit_price'], 2),
                    'notes' => $item['notes'] ?? null,
                    'sort_order' => $index,
                ]);
            }

            return $po->load('items', 'customer');
        });
    }

    public function updateStatus(PurchaseOrder $po, PurchaseOrderStatus $newStatus, ?string $reason = null): PurchaseOrder
    {
        if (!$po->status->canTransitionTo($newStatus)) {
            throw ValidationException::withMessages([
                'status' => "Tidak dapat mengubah status dari '{$po->status->label()}' ke '{$newStatus->label()}'.",
            ]);
        }

        $oldStatus = $po->status;

        $po->update(['status' => $newStatus]);

        PurchaseOrderStatusHistory::create([
            'po_id' => $po->id,
            'from_status' => $oldStatus->value,
            'to_status' => $newStatus->value,
            'changed_by' => auth()->id(),
            'reason' => $reason,
            'changed_at' => now(),
        ]);

        // Update customer stats when completed
        if ($newStatus === PurchaseOrderStatus::COMPLETED) {
            $customer = $po->customer;
            $customer->increment('total_orders');
            $customer->increment('total_revenue', $po->total);
        }

        // Send notification
        $this->notificationService->notifyStatusChange($po, $oldStatus, $newStatus);

        return $po->fresh('items', 'customer', 'statusHistory');
    }

    public function cancel(PurchaseOrder $po, string $reason): PurchaseOrder
    {
        return $this->updateStatus($po, PurchaseOrderStatus::CANCELLED, $reason);
    }

    public function duplicate(PurchaseOrder $po): PurchaseOrder
    {
        $items = $po->items->map(fn ($item) => [
            'product_id' => $item->product_id,
            'product_name' => $item->product_name,
            'quantity' => $item->quantity,
            'unit_price' => $item->unit_price,
            'notes' => $item->notes,
        ])->toArray();

        return $this->create([
            'customer_id' => $po->customer_id,
            'order_date' => now()->toDateString(),
            'delivery_date' => now()->addDay()->toDateString(),
            'discount' => $po->discount,
            'tax' => $po->tax,
            'notes' => $po->notes,
        ], $items);
    }

    public function calculateTotals(array $items, float $discount = 0, float $tax = 0, float $shippingCost = 0): array
    {
        $subtotal = collect($items)->sum(fn ($item) => round($item['quantity'] * $item['unit_price'], 2));
        $total = $subtotal - $discount + $tax + $shippingCost;

        return [
            'subtotal' => round($subtotal, 2),
            'discount' => round($discount, 2),
            'tax' => round($tax, 2),
            'shipping_cost' => round($shippingCost, 2),
            'total' => round($total, 2),
        ];
    }
}
