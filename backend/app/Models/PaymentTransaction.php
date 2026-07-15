<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaymentTransaction extends Model
{
    use HasUuids;

    protected $fillable = [
        'organization_id',
        'po_id',
        'gateway',
        'gateway_order_id',
        'snap_token',
        'status',
        'payment_type',
        'amount',
        'gateway_response',
        'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'gateway_response' => 'array',
            'amount' => 'decimal:2',
            'paid_at' => 'datetime',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function purchaseOrder(): BelongsTo
    {
        return $this->belongsTo(PurchaseOrder::class, 'po_id');
    }
}
