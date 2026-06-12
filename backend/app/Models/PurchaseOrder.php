<?php

namespace App\Models;

use App\Enums\PaymentStatus;
use App\Enums\PurchaseOrderStatus;
use App\Traits\BelongsToOrganization;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class PurchaseOrder extends Model
{
    use HasUuids, HasFactory, SoftDeletes, BelongsToOrganization;

    protected $fillable = [
        'organization_id',
        'po_number',
        'customer_id',
        'order_date',
        'delivery_date',
        'status',
        'payment_status',
        'payment_method',
        'dp_amount',
        'paid_amount',
        'subtotal',
        'discount',
        'tax',
        'shipping_cost',
        'total',
        'notes',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'status' => PurchaseOrderStatus::class,
            'payment_status' => PaymentStatus::class,
            'order_date' => 'date',
            'delivery_date' => 'date',
            'dp_amount' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'subtotal' => 'decimal:2',
            'discount' => 'decimal:2',
            'tax' => 'decimal:2',
            'shipping_cost' => 'decimal:2',
            'total' => 'decimal:2',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(PurchaseOrderItem::class, 'po_id')->orderBy('sort_order');
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(PurchaseOrderStatusHistory::class, 'po_id')->orderByDesc('changed_at');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
