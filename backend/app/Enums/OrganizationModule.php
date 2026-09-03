<?php

namespace App\Enums;

enum OrganizationModule: string
{
    case RESTO = 'resto';

    public function label(): string
    {
        return match ($this) {
            self::RESTO => 'Resto (Waiting List)',
        };
    }

    /**
     * Harga langganan modul per bulan (Rupiah).
     */
    public function price(): int
    {
        return match ($this) {
            self::RESTO => 50000,
        };
    }
}
