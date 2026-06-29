<?php

namespace App\Enums;

enum SubscriptionPlan: string
{
    case FREE = 'free';
    case PREMIUM = 'premium';

    public function label(): string
    {
        return match ($this) {
            self::FREE => 'Gratis',
            self::PREMIUM => 'Premium',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::FREE => '#9CA3AF',
            self::PREMIUM => '#D97706',
        };
    }
}
