<?php

namespace App\Enums;

enum PaymentStatus: string
{
    case UNPAID = 'unpaid';
    case DP = 'dp';
    case PAID = 'paid';

    public function label(): string
    {
        return match ($this) {
            self::UNPAID => 'Belum Bayar',
            self::DP => 'DP',
            self::PAID => 'Lunas',
        };
    }
}
