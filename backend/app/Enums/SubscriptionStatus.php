<?php

namespace App\Enums;

enum SubscriptionStatus: string
{
    case PENDING = 'pending';
    case ACTIVE = 'active';
    case EXPIRED = 'expired';
    case REJECTED = 'rejected';

    public function label(): string
    {
        return match ($this) {
            self::PENDING => 'Menunggu',
            self::ACTIVE => 'Aktif',
            self::EXPIRED => 'Kedaluwarsa',
            self::REJECTED => 'Ditolak',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::PENDING => '#D97706',
            self::ACTIVE => '#70AD47',
            self::EXPIRED => '#9CA3AF',
            self::REJECTED => '#C00000',
        };
    }
}
