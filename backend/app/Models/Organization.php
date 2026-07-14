<?php

namespace App\Models;

use App\Enums\SubscriptionPlan;
use App\Enums\SubscriptionStatus;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\Crypt;

class Organization extends Model
{
    use HasUuids;

    protected $fillable = [
        'name',
        'slug',
        'phone',
        'address',
        'logo_url',
        'settings',
        'plan',
    ];

    protected function casts(): array
    {
        return [
            'settings' => 'array',
            'plan' => SubscriptionPlan::class,
        ];
    }

    public function members(): HasMany
    {
        return $this->hasMany(OrganizationMember::class);
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'organization_members')
            ->withPivot('role', 'joined_at');
    }

    public function customers(): HasMany
    {
        return $this->hasMany(Customer::class);
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function purchaseOrders(): HasMany
    {
        return $this->hasMany(PurchaseOrder::class);
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }

    public function isPremium(): bool
    {
        return $this->plan === SubscriptionPlan::PREMIUM;
    }

    /**
     * Online store configuration bag stored inside the settings JSON.
     *
     * @return array<string, mixed>
     */
    public function onlineStore(): array
    {
        return $this->settings['online_store'] ?? [];
    }

    /**
     * Decrypt the Midtrans server key, or null when it is unset/undecryptable.
     */
    public function midtransServerKey(): ?string
    {
        $encrypted = $this->onlineStore()['midtrans']['server_key'] ?? null;

        if (! $encrypted) {
            return null;
        }

        try {
            return Crypt::decryptString($encrypted);
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * Whether this store can accept online payments right now.
     */
    public function isOnlinePaymentEnabled(): bool
    {
        return (bool) ($this->onlineStore()['midtrans']['is_enabled'] ?? false)
            && $this->midtransServerKey() !== null;
    }

    /**
     * Check if active subscription has expired and downgrade to free if so.
     * Returns the latest active/expired subscription info.
     */
    public function checkSubscriptionExpiry(): ?Subscription
    {
        $latestSubscription = $this->subscriptions()
            ->whereIn('status', [SubscriptionStatus::ACTIVE, SubscriptionStatus::EXPIRED, SubscriptionStatus::PENDING])
            ->orderByDesc('created_at')
            ->first();

        if ($latestSubscription
            && $latestSubscription->status === SubscriptionStatus::ACTIVE
            && $latestSubscription->expires_at
            && $latestSubscription->expires_at->isPast()
        ) {
            $latestSubscription->update(['status' => SubscriptionStatus::EXPIRED]);
            $this->update(['plan' => SubscriptionPlan::FREE]);
            $latestSubscription->refresh();
        }

        return $latestSubscription;
    }
}
