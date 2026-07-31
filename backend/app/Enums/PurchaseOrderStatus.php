<?php

namespace App\Enums;

enum PurchaseOrderStatus: string
{
    case DRAFT = 'draft';
    case IN_PROGRESS = 'in_progress';
    case COMPLETED = 'completed';
    case CANCELLED = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::DRAFT => 'Baru',
            self::IN_PROGRESS => 'Diproses',
            self::COMPLETED => 'Selesai',
            self::CANCELLED => 'Dibatalkan',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::DRAFT => '#9CA3AF',
            self::IN_PROGRESS => '#FFC000',
            self::COMPLETED => '#C8A2C8',
            self::CANCELLED => '#C00000',
        };
    }

    /**
     * Valid transitions from this status.
     * @return PurchaseOrderStatus[]
     */
    public function allowedTransitions(): array
    {
        return match ($this) {
            self::DRAFT => [self::IN_PROGRESS, self::CANCELLED],
            self::IN_PROGRESS => [self::COMPLETED, self::CANCELLED],
            self::COMPLETED => [],
            self::CANCELLED => [],
        };
    }

    public function canTransitionTo(self $target): bool
    {
        return in_array($target, $this->allowedTransitions());
    }
}
