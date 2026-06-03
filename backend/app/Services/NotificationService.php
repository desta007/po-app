<?php

namespace App\Services;

use App\Enums\NotificationChannel;
use App\Enums\NotificationStatus;
use App\Enums\PurchaseOrderStatus;
use App\Jobs\SendEmailNotification;
use App\Models\Notification;
use App\Models\PurchaseOrder;
use App\Models\User;

class NotificationService
{
    public function createInAppNotification(
        ?int $userId,
        string $title,
        string $message,
        ?string $poId = null,
        ?string $orgId = null
    ): Notification {
        return Notification::create([
            'organization_id' => $orgId ?? auth()->user()?->current_org_id,
            'user_id' => $userId,
            'po_id' => $poId,
            'channel' => NotificationChannel::IN_APP,
            'title' => $title,
            'message' => $message,
            'status' => NotificationStatus::DELIVERED,
            'sent_at' => now(),
        ]);
    }

    public function notifyStatusChange(PurchaseOrder $po, PurchaseOrderStatus $from, PurchaseOrderStatus $to): void
    {
        $title = "PO {$po->po_number} — {$to->label()}";
        $message = "Status pesanan {$po->po_number} berubah dari {$from->label()} menjadi {$to->label()}.";

        // In-app notification to the creator
        if ($po->created_by) {
            $this->createInAppNotification(
                $po->created_by,
                $title,
                $message,
                $po->id,
                $po->organization_id,
            );
        }

        // Email notification
        if ($po->customer?->email) {
            SendEmailNotification::dispatch($po, $to);
        }
    }

    public function notifyDeliveryReminder(PurchaseOrder $po, string $reminderType): void
    {
        $dayLabel = $reminderType === 'h-1' ? 'besok' : 'hari ini';
        $title = "Pengingat pengiriman {$dayLabel}";
        $message = "Pesanan {$po->po_number} untuk {$po->customer->name} dijadwalkan dikirim {$dayLabel}.";

        if ($po->created_by) {
            $this->createInAppNotification(
                $po->created_by,
                $title,
                $message,
                $po->id,
                $po->organization_id,
            );
        }
    }
}
