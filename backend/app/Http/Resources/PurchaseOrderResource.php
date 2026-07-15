<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PurchaseOrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'organization_id' => $this->organization_id,
            'po_number' => $this->po_number,
            'customer_id' => $this->customer_id,
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'order_date' => $this->order_date?->toDateString(),
            'delivery_date' => $this->delivery_date?->toDateString(),
            'status' => $this->status?->value,
            'source' => $this->source,
            'payment_status' => $this->payment_status?->value,
            'payment_method' => $this->payment_method,
            'dp_amount' => (float) $this->dp_amount,
            'paid_amount' => (float) $this->paid_amount,
            'subtotal' => (float) $this->subtotal,
            'discount' => (float) $this->discount,
            'tax' => (float) $this->tax,
            'shipping_cost' => (float) $this->shipping_cost,
            'shipping_method' => $this->shipping_method,
            'tracking_number' => $this->tracking_number,
            'total' => (float) $this->total,
            'notes' => $this->notes,
            'created_by' => $this->created_by,
            'items' => PurchaseOrderItemResource::collection($this->whenLoaded('items')),
            'status_history' => PurchaseOrderStatusHistoryResource::collection($this->whenLoaded('statusHistory')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
