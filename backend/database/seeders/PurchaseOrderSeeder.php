<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Organization;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\PurchaseOrderStatusHistory;
use App\Models\User;
use Illuminate\Database\Seeder;

class PurchaseOrderSeeder extends Seeder
{
    public function run(): void
    {
        $org = Organization::where('slug', 'dapur-kue-sari')->first();
        $admin = User::where('email', 'admin@demo.com')->first();
        $customers = Customer::where('organization_id', $org->id)->get();
        $products = Product::where('organization_id', $org->id)->get();

        $statuses = ['draft', 'draft', 'draft', 'draft', 'draft',
                     'confirmed', 'confirmed', 'confirmed', 'confirmed', 'confirmed',
                     'in_progress', 'in_progress', 'in_progress', 'in_progress', 'in_progress', 'in_progress', 'in_progress', 'in_progress',
                     'completed', 'completed', 'completed', 'completed', 'completed',
                     'cancelled', 'cancelled'];

        $paymentStatuses = ['unpaid', 'unpaid', 'unpaid', 'unpaid', 'unpaid', 'unpaid', 'unpaid', 'unpaid', 'unpaid', 'unpaid',
                           'dp', 'dp', 'dp', 'dp', 'dp', 'dp', 'dp', 'dp',
                           'paid', 'paid', 'paid', 'paid', 'paid', 'paid', 'paid'];

        $notes = [
            'Tolong tulisan Happy Birthday Mama', 'Kirim sebelum jam 10 pagi', 'Warna merah ya',
            'Untuk acara kantor', 'Pakai topping keju extra', null, null, null, null, null,
            'Tidak pakai kacang (alergi)', 'Packaging gift wrap', 'Minta diantar ke lantai 3',
            null, null, null, null, null, null, null, null, null, null, null, null,
        ];

        $poNumber = 1;

        for ($i = 0; $i < 25; $i++) {
            $dayOffset = rand(-15, 10);
            $deliveryDate = now()->addDays($dayOffset)->toDateString();
            $orderDate = now()->addDays($dayOffset - rand(1, 5))->toDateString();
            $customer = $customers->random();

            $numItems = rand(1, 4);
            $selectedProducts = $products->random($numItems);

            $itemsData = [];
            $subtotal = 0;
            foreach ($selectedProducts as $idx => $product) {
                $qty = rand(1, 10);
                $itemSubtotal = $qty * $product->price;
                $subtotal += $itemSubtotal;
                $itemsData[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'quantity' => $qty,
                    'unit_price' => $product->price,
                    'subtotal' => $itemSubtotal,
                    'sort_order' => $idx,
                ];
            }

            $discount = rand(0, 1) ? rand(1, 5) * 10000 : 0;
            $tax = rand(0, 1) ? round($subtotal * 0.11, 0) : 0;
            $total = $subtotal - $discount + $tax;

            $status = $statuses[$i];
            $paymentStatus = $paymentStatuses[$i];
            $dpAmount = $paymentStatus === 'dp' ? round($total * 0.5) : 0;
            $paidAmount = $paymentStatus === 'paid' ? $total : $dpAmount;

            $poNum = 'PO-' . now()->addDays($dayOffset - rand(1, 5))->format('Ymd') . '-' . str_pad($poNumber++, 3, '0', STR_PAD_LEFT);

            $po = PurchaseOrder::create([
                'organization_id' => $org->id,
                'po_number' => $poNum,
                'customer_id' => $customer->id,
                'order_date' => $orderDate,
                'delivery_date' => $deliveryDate,
                'status' => $status,
                'payment_status' => $paymentStatus,
                'dp_amount' => $dpAmount,
                'paid_amount' => $paidAmount,
                'subtotal' => $subtotal,
                'discount' => $discount,
                'tax' => $tax,
                'total' => $total,
                'notes' => $notes[$i] ?? null,
                'created_by' => $admin->id,
            ]);

            foreach ($itemsData as $item) {
                PurchaseOrderItem::create(array_merge($item, ['po_id' => $po->id]));
            }

            // Status history
            PurchaseOrderStatusHistory::create([
                'po_id' => $po->id, 'from_status' => null, 'to_status' => 'draft',
                'changed_by' => $admin->id, 'changed_at' => $po->created_at,
            ]);

            $transitions = match ($status) {
                'confirmed' => [['draft', 'confirmed']],
                'in_progress' => [['draft', 'confirmed'], ['confirmed', 'in_progress']],
                'completed' => [['draft', 'confirmed'], ['confirmed', 'in_progress'], ['in_progress', 'completed']],
                'cancelled' => [['draft', 'cancelled']],
                default => [],
            };

            foreach ($transitions as $idx => $t) {
                PurchaseOrderStatusHistory::create([
                    'po_id' => $po->id,
                    'from_status' => $t[0],
                    'to_status' => $t[1],
                    'changed_by' => $admin->id,
                    'reason' => $t[1] === 'cancelled' ? 'Customer membatalkan pesanan' : null,
                    'changed_at' => $po->created_at->addHours($idx + 1),
                ]);
            }

            // Update customer stats for completed orders
            if ($status === 'completed') {
                $customer->increment('total_orders');
                $customer->increment('total_revenue', $total);
            }
        }
    }
}
