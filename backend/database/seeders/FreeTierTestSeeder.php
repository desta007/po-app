<?php

namespace Database\Seeders;

use App\Enums\SubscriptionPlan;
use App\Models\Customer;
use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Models\PurchaseOrderStatusHistory;
use App\Models\User;
use Illuminate\Database\Seeder;

/**
 * Seeder untuk test fitur pembatasan free tier.
 *
 * Membuat 3 skenario:
 * 1. free@demo.com    — Org free, 19 PO bulan ini, 9 produk, 1 member (owner saja)
 *                       → Bisa tambah 1 lagi sebelum limit tercapai
 * 2. limit@demo.com   — Org free, 20 PO bulan ini, 10 produk, 2 member
 *                       → Sudah di limit, aksi berikutnya akan ditolak
 * 3. premium@demo.com — Org premium, banyak data
 *                       → Tidak ada batasan
 *
 * Jalankan: php artisan db:seed --class=FreeTierTestSeeder
 */
class FreeTierTestSeeder extends Seeder
{
    public function run(): void
    {
        $this->createNearLimitScenario();
        $this->createAtLimitScenario();
        $this->createPremiumScenario();
        $this->createInvitableUsers();
    }

    /**
     * Skenario 1: Free user, hampir limit (sisa 1 slot)
     * - 19 PO bulan ini (limit 20)
     * - 9 produk (limit 10)
     * - 1 member/owner saja (limit 2)
     */
    private function createNearLimitScenario(): void
    {
        $org = Organization::create([
            'name' => 'Toko Roti Bahagia',
            'slug' => 'toko-roti-bahagia',
            'phone' => '081200001111',
            'address' => 'Jl. Sudirman No. 10, Jakarta',
            'plan' => SubscriptionPlan::FREE,
        ]);

        $owner = User::create([
            'name' => 'Andi Prasetyo',
            'full_name' => 'Andi Prasetyo',
            'email' => 'free@demo.com',
            'password' => 'password123',
            'phone' => '081200001111',
            'current_org_id' => $org->id,
        ]);

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $owner->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        // 5 customers
        $customers = $this->seedCustomers($org->id, [
            ['name' => 'Bu Yuni', 'phone' => '081200010001'],
            ['name' => 'Pak Hendra', 'phone' => '081200010002'],
            ['name' => 'Toko Maju Jaya', 'phone' => '081200010003'],
            ['name' => 'CV Sumber Rezeki', 'phone' => '081200010004'],
            ['name' => 'Ibu Kartini', 'phone' => '081200010005'],
        ]);

        // 9 produk (limit 10, sisa 1)
        $products = $this->seedProducts($org->id, [
            ['name' => 'Roti Tawar', 'price' => 15000, 'unit' => 'pcs', 'category' => 'Roti', 'sku' => 'RT-001'],
            ['name' => 'Roti Coklat', 'price' => 8000, 'unit' => 'pcs', 'category' => 'Roti', 'sku' => 'RC-001'],
            ['name' => 'Donat Gula', 'price' => 5000, 'unit' => 'pcs', 'category' => 'Donat', 'sku' => 'DG-001'],
            ['name' => 'Donat Coklat', 'price' => 6000, 'unit' => 'pcs', 'category' => 'Donat', 'sku' => 'DC-001'],
            ['name' => 'Croissant', 'price' => 12000, 'unit' => 'pcs', 'category' => 'Pastry', 'sku' => 'CR-001'],
            ['name' => 'Bolu Kukus', 'price' => 25000, 'unit' => 'pcs', 'category' => 'Kue', 'sku' => 'BK-001'],
            ['name' => 'Kue Sus', 'price' => 3000, 'unit' => 'pcs', 'category' => 'Kue', 'sku' => 'KS-001'],
            ['name' => 'Pisang Goreng Box', 'price' => 30000, 'unit' => 'box', 'category' => 'Snack', 'sku' => 'PG-001'],
            ['name' => 'Snack Box Mini', 'price' => 20000, 'unit' => 'box', 'category' => 'Snack', 'sku' => 'SBM-001'],
        ]);

        // 19 PO bulan ini (limit 20, sisa 1)
        $this->seedPurchaseOrders($org, $owner, $customers, $products, 19);
    }

    /**
     * Skenario 2: Free user, sudah di limit (tidak bisa tambah lagi)
     * - 20 PO bulan ini (tepat limit)
     * - 10 produk (tepat limit)
     * - 2 member (tepat limit)
     */
    private function createAtLimitScenario(): void
    {
        $org = Organization::create([
            'name' => 'Warung Nasi Sederhana',
            'slug' => 'warung-nasi-sederhana',
            'phone' => '081200002222',
            'address' => 'Jl. Gatot Subroto No. 55, Jakarta',
            'plan' => SubscriptionPlan::FREE,
        ]);

        $owner = User::create([
            'name' => 'Maya Anggraeni',
            'full_name' => 'Maya Anggraeni',
            'email' => 'limit@demo.com',
            'password' => 'password123',
            'phone' => '081200002222',
            'current_org_id' => $org->id,
        ]);

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $owner->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        // Tambah 1 staff (total 2 member = tepat limit)
        $staff = User::create([
            'name' => 'Doni Saputra',
            'full_name' => 'Doni Saputra',
            'email' => 'doni.staff@demo.com',
            'password' => 'password123',
            'phone' => '081200002223',
            'current_org_id' => $org->id,
        ]);

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $staff->id,
            'role' => 'staff',
            'invited_by' => $owner->id,
            'joined_at' => now(),
        ]);

        // 5 customers
        $customers = $this->seedCustomers($org->id, [
            ['name' => 'Pak Joko', 'phone' => '081200020001'],
            ['name' => 'Bu Sri Wahyuni', 'phone' => '081200020002'],
            ['name' => 'Kantor PT Abadi', 'phone' => '081200020003'],
            ['name' => 'Ibu Melani', 'phone' => '081200020004'],
            ['name' => 'Pak Bambang', 'phone' => '081200020005'],
        ]);

        // 10 produk (tepat limit)
        $products = $this->seedProducts($org->id, [
            ['name' => 'Nasi Goreng', 'price' => 18000, 'unit' => 'porsi', 'category' => 'Nasi', 'sku' => 'NG-001'],
            ['name' => 'Nasi Uduk', 'price' => 15000, 'unit' => 'porsi', 'category' => 'Nasi', 'sku' => 'NU-001'],
            ['name' => 'Nasi Kuning', 'price' => 16000, 'unit' => 'porsi', 'category' => 'Nasi', 'sku' => 'NK-001'],
            ['name' => 'Mie Goreng', 'price' => 15000, 'unit' => 'porsi', 'category' => 'Mie', 'sku' => 'MG-001'],
            ['name' => 'Ayam Goreng', 'price' => 22000, 'unit' => 'porsi', 'category' => 'Lauk', 'sku' => 'AG-001'],
            ['name' => 'Ikan Bakar', 'price' => 28000, 'unit' => 'porsi', 'category' => 'Lauk', 'sku' => 'IB-001'],
            ['name' => 'Soto Ayam', 'price' => 18000, 'unit' => 'porsi', 'category' => 'Kuah', 'sku' => 'SA-001'],
            ['name' => 'Nasi Box A', 'price' => 25000, 'unit' => 'box', 'category' => 'Box', 'sku' => 'NBA-001'],
            ['name' => 'Nasi Box B', 'price' => 35000, 'unit' => 'box', 'category' => 'Box', 'sku' => 'NBB-001'],
            ['name' => 'Nasi Box Premium', 'price' => 50000, 'unit' => 'box', 'category' => 'Box', 'sku' => 'NBP-001'],
        ]);

        // 20 PO bulan ini (tepat limit)
        $this->seedPurchaseOrders($org, $owner, $customers, $products, 20);
    }

    /**
     * Skenario 3: Premium user, tanpa batasan
     */
    private function createPremiumScenario(): void
    {
        $org = Organization::create([
            'name' => 'Bakery Premium Jaya',
            'slug' => 'bakery-premium-jaya',
            'phone' => '081200003333',
            'address' => 'Jl. Kuningan No. 99, Jakarta',
            'plan' => SubscriptionPlan::PREMIUM,
        ]);

        $owner = User::create([
            'name' => 'Reza Firmansyah',
            'full_name' => 'Reza Firmansyah',
            'email' => 'premium@demo.com',
            'password' => 'password123',
            'phone' => '081200003333',
            'current_org_id' => $org->id,
        ]);

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $owner->id,
            'role' => 'owner',
            'joined_at' => now(),
        ]);

        // 3 staff untuk premium
        foreach (['Siti Nurhaliza', 'Eko Prasetyo', 'Dewi Lestari'] as $i => $name) {
            $u = User::create([
                'name' => $name,
                'full_name' => $name,
                'email' => 'premium.staff' . ($i + 1) . '@demo.com',
                'password' => 'password123',
                'current_org_id' => $org->id,
            ]);
            OrganizationMember::create([
                'organization_id' => $org->id,
                'user_id' => $u->id,
                'role' => 'staff',
                'invited_by' => $owner->id,
                'joined_at' => now(),
            ]);
        }

        $customers = $this->seedCustomers($org->id, [
            ['name' => 'Hotel Grand', 'phone' => '081200030001'],
            ['name' => 'Cafe Moderen', 'phone' => '081200030002'],
            ['name' => 'PT Catering Indo', 'phone' => '081200030003'],
        ]);

        $products = $this->seedProducts($org->id, [
            ['name' => 'Wedding Cake 3 Tier', 'price' => 2500000, 'unit' => 'pcs', 'category' => 'Wedding', 'sku' => 'WC3-001'],
            ['name' => 'Cupcake Box (12pcs)', 'price' => 180000, 'unit' => 'box', 'category' => 'Cupcake', 'sku' => 'CB12-001'],
            ['name' => 'Macarons Box (24pcs)', 'price' => 320000, 'unit' => 'box', 'category' => 'Pastry', 'sku' => 'MB24-001'],
            ['name' => 'Danish Pastry Box', 'price' => 150000, 'unit' => 'box', 'category' => 'Pastry', 'sku' => 'DPB-001'],
            ['name' => 'Artisan Bread Sourdough', 'price' => 85000, 'unit' => 'pcs', 'category' => 'Roti', 'sku' => 'ABS-001'],
            ['name' => 'Tart Buah Segar', 'price' => 275000, 'unit' => 'pcs', 'category' => 'Tart', 'sku' => 'TBS-001'],
            ['name' => 'Eclair Coklat (6pcs)', 'price' => 120000, 'unit' => 'box', 'category' => 'Pastry', 'sku' => 'EC6-001'],
            ['name' => 'Roti Gandum Organik', 'price' => 45000, 'unit' => 'pcs', 'category' => 'Roti', 'sku' => 'RGO-001'],
            ['name' => 'Cheese Cake NY Style', 'price' => 350000, 'unit' => 'pcs', 'category' => 'Cake', 'sku' => 'CCNY-001'],
            ['name' => 'Chocolate Lava Cake', 'price' => 65000, 'unit' => 'pcs', 'category' => 'Cake', 'sku' => 'CLC-001'],
            ['name' => 'Tiramisu Cup', 'price' => 35000, 'unit' => 'pcs', 'category' => 'Dessert', 'sku' => 'TC-001'],
            ['name' => 'Cinnamon Roll (4pcs)', 'price' => 68000, 'unit' => 'box', 'category' => 'Roti', 'sku' => 'CR4-001'],
            ['name' => 'Mille Crepe Cake', 'price' => 290000, 'unit' => 'pcs', 'category' => 'Cake', 'sku' => 'MCC-001'],
            ['name' => 'Pie Susu Bali (10pcs)', 'price' => 95000, 'unit' => 'box', 'category' => 'Kue', 'sku' => 'PSB-001'],
            ['name' => 'Opera Cake Slice', 'price' => 42000, 'unit' => 'pcs', 'category' => 'Cake', 'sku' => 'OCS-001'],
        ]);

        // 25 PO — premium tidak ada batasan
        $this->seedPurchaseOrders($org, $owner, $customers, $products, 25);
    }

    /**
     * User yang bisa diundang sebagai anggota tim (belum tergabung org manapun)
     */
    private function createInvitableUsers(): void
    {
        User::create([
            'name' => 'Citra Ramadhani',
            'full_name' => 'Citra Ramadhani',
            'email' => 'invite1@demo.com',
            'password' => 'password123',
            'phone' => '081200099001',
        ]);

        User::create([
            'name' => 'Fajar Nugroho',
            'full_name' => 'Fajar Nugroho',
            'email' => 'invite2@demo.com',
            'password' => 'password123',
            'phone' => '081200099002',
        ]);
    }

    // --- Helper Methods ---

    private function seedCustomers(string $orgId, array $data): array
    {
        $customers = [];
        foreach ($data as $c) {
            $customers[] = Customer::create(array_merge($c, ['organization_id' => $orgId]));
        }
        return $customers;
    }

    private function seedProducts(string $orgId, array $data): array
    {
        $products = [];
        foreach ($data as $p) {
            $products[] = Product::create(array_merge($p, [
                'organization_id' => $orgId,
                'stock_qty' => rand(5, 50),
                'show_in_catalog' => true,
            ]));
        }
        return $products;
    }

    private function seedPurchaseOrders(
        Organization $org,
        User $creator,
        array $customers,
        array $products,
        int $count
    ): void {
        $statuses = ['draft', 'confirmed', 'in_progress', 'completed'];
        $paymentStatuses = ['unpaid', 'dp', 'paid'];

        for ($i = 1; $i <= $count; $i++) {
            $customer = $customers[array_rand($customers)];
            $status = $statuses[array_rand($statuses)];
            $paymentStatus = $paymentStatuses[array_rand($paymentStatuses)];

            $dayOffset = rand(0, 25);
            $orderDate = now()->startOfMonth()->addDays($dayOffset);
            $deliveryDate = $orderDate->copy()->addDays(rand(1, 7));

            $numItems = rand(1, 3);
            $selectedKeys = array_rand($products, min($numItems, count($products)));
            if (!is_array($selectedKeys)) $selectedKeys = [$selectedKeys];

            $subtotal = 0;
            $itemsData = [];
            foreach ($selectedKeys as $idx => $key) {
                $product = $products[$key];
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

            $discount = rand(0, 1) ? rand(1, 3) * 5000 : 0;
            $total = max(0, $subtotal - $discount);
            $dpAmount = $paymentStatus === 'dp' ? round($total * 0.5) : 0;
            $paidAmount = $paymentStatus === 'paid' ? $total : $dpAmount;

            $poNumber = 'PO-' . $orderDate->format('Ymd') . '-' . str_pad($i, 3, '0', STR_PAD_LEFT);

            $po = PurchaseOrder::create([
                'organization_id' => $org->id,
                'po_number' => $poNumber,
                'customer_id' => $customer->id,
                'order_date' => $orderDate->toDateString(),
                'delivery_date' => $deliveryDate->toDateString(),
                'status' => $status,
                'payment_status' => $paymentStatus,
                'dp_amount' => $dpAmount,
                'paid_amount' => $paidAmount,
                'subtotal' => $subtotal,
                'discount' => $discount,
                'tax' => 0,
                'total' => $total,
                'created_by' => $creator->id,
                'created_at' => $orderDate,
            ]);

            foreach ($itemsData as $item) {
                PurchaseOrderItem::create(array_merge($item, ['po_id' => $po->id]));
            }

            PurchaseOrderStatusHistory::create([
                'po_id' => $po->id,
                'from_status' => null,
                'to_status' => 'draft',
                'changed_by' => $creator->id,
                'changed_at' => $po->created_at,
            ]);
        }
    }
}
