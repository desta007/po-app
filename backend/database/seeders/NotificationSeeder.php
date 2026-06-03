<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\Organization;
use App\Models\PurchaseOrder;
use App\Models\User;
use Illuminate\Database\Seeder;

class NotificationSeeder extends Seeder
{
    public function run(): void
    {
        $org = Organization::where('slug', 'dapur-kue-sari')->first();
        $admin = User::where('email', 'admin@demo.com')->first();
        $pos = PurchaseOrder::where('organization_id', $org->id)->limit(5)->get();

        $samples = [
            ['title' => 'PO dikonfirmasi', 'message' => 'Pesanan %s telah dikonfirmasi.', 'read' => true],
            ['title' => 'Pengiriman besok', 'message' => 'Pengiriman besok: pesanan %s untuk %s.', 'read' => true],
            ['title' => 'PO baru dibuat', 'message' => 'Pesanan baru %s telah dibuat.', 'read' => false],
            ['title' => 'Pembayaran diterima', 'message' => 'Pembayaran untuk %s telah diterima.', 'read' => false],
            ['title' => 'Pengiriman hari ini', 'message' => '3 pesanan harus dikirim hari ini.', 'read' => false],
        ];

        foreach ($samples as $idx => $sample) {
            $po = $pos[$idx] ?? $pos->first();
            Notification::create([
                'organization_id' => $org->id,
                'user_id' => $admin->id,
                'po_id' => $po?->id,
                'channel' => 'in_app',
                'title' => $sample['title'],
                'message' => sprintf($sample['message'], $po?->po_number ?? '', $po?->customer?->name ?? ''),
                'status' => 'delivered',
                'sent_at' => now()->subHours($idx * 3),
                'read_at' => $sample['read'] ? now()->subHours($idx * 2) : null,
            ]);
        }
    }
}
