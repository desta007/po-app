<?php

namespace App\Enums;

enum DiscountType: string
{
    case PERCENT = 'percent';
    case NOMINAL = 'nominal';

    public function label(): string
    {
        return match ($this) {
            self::PERCENT => 'Persen',
            self::NOMINAL => 'Nominal',
        };
    }
}
