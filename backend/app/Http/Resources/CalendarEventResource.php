<?php

namespace App\Http\Resources;

use App\Enums\PurchaseOrderStatus;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CalendarEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $statusColors = [
            'draft' => '#9CA3AF',
            'confirmed' => '#1F4E79',
            'in_progress' => '#FFC000',
            'completed' => '#70AD47',
            'cancelled' => '#C00000',
        ];

        $color = $statusColors[$this->status->value] ?? '#9CA3AF';

        return [
            'id' => $this->id,
            'title' => "{$this->po_number} - {$this->customer->name}",
            'start' => $this->delivery_date->toDateString(),
            'backgroundColor' => $color,
            'borderColor' => $color,
            'extendedProps' => [
                'po_number' => $this->po_number,
                'customer_name' => $this->customer->name,
                'status' => $this->status->value,
                'payment_status' => $this->payment_status->value,
                'total' => (float) $this->total,
                'items' => $this->items->map(fn($i) => [
                    'product_name' => $i->product_name,
                    'quantity' => (int) $i->quantity,
                ])->toArray(),
            ],
        ];
    }
}
