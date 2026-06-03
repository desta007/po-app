<?php

namespace App\Services;

use App\Models\PurchaseOrder;

class ReminderService
{
    public function __construct(
        private NotificationService $notificationService,
    ) {}

    /**
     * Process reminders for POs with delivery date matching the given type.
     * @param string $type 'h-1' for tomorrow, 'h-0' for today
     */
    public function processReminders(string $type): int
    {
        $targetDate = match ($type) {
            'h-1' => now()->addDay()->toDateString(),
            'h-0' => now()->toDateString(),
            default => now()->addDay()->toDateString(),
        };

        $pos = PurchaseOrder::withoutGlobalScopes()
            ->where('delivery_date', $targetDate)
            ->whereNotIn('status', ['completed', 'cancelled'])
            ->with('customer')
            ->get();

        foreach ($pos as $po) {
            $this->notificationService->notifyDeliveryReminder($po, $type);
        }

        return $pos->count();
    }
}
