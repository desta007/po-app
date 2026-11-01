<?php

namespace App\Models;

use App\Enums\DiscountType;
use App\Traits\BelongsToOrganization;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasUuids, HasFactory, SoftDeletes, BelongsToOrganization;

    protected $fillable = [
        'organization_id',
        'name',
        'sku',
        'description',
        'unit',
        'price',
        'cost',
        'discount_enabled',
        'discount_type',
        'discount_value',
        'category',
        'image_url',
        'images',
        'stock_qty',
        'track_stock',
        'is_active',
        'show_in_catalog',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'cost' => 'decimal:2',
            'discount_enabled' => 'boolean',
            'discount_type' => DiscountType::class,
            'discount_value' => 'decimal:2',
            'images' => 'array',
            'track_stock' => 'boolean',
            'is_active' => 'boolean',
            'show_in_catalog' => 'boolean',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    /**
     * Diskon produk hanya berlaku untuk organisasi Premium. Jika organisasi turun
     * ke Free, pengaturan diskon tetap tersimpan tetapi tidak diterapkan.
     *
     * Memakai relasi `organization` — untuk koleksi produk, set/eager-load relasi
     * itu dulu agar tidak terjadi N+1 query.
     */
    public function hasActiveDiscount(): bool
    {
        return $this->discount_enabled
            && $this->discount_type !== null
            && (float) $this->discount_value > 0
            && (bool) $this->organization?->isPremium();
    }

    /** Potongan per unit (Rupiah), tidak pernah melebihi harga jual. */
    public function discountAmount(): float
    {
        if (! $this->hasActiveDiscount()) {
            return 0.0;
        }

        $price = (float) $this->price;
        $amount = $this->discount_type === DiscountType::PERCENT
            ? $price * (float) $this->discount_value / 100
            : (float) $this->discount_value;

        return round(min($amount, $price), 2);
    }

    /** Harga jual per unit setelah diskon produk. */
    public function finalPrice(): float
    {
        return round((float) $this->price - $this->discountAmount(), 2);
    }
}
