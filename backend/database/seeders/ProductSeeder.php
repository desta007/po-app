<?php

namespace Database\Seeders;

use App\Models\Organization;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $org = Organization::where('slug', 'dapur-kue-sari')->first();

        $products = [
            ['name' => 'Kue Lapis Legit', 'price' => 185000, 'unit' => 'pcs', 'category' => 'Kue Basah', 'sku' => 'KLL-001', 'stock_qty' => 10],
            ['name' => 'Brownies Panggang', 'price' => 65000, 'unit' => 'loyang', 'category' => 'Kue Kering', 'sku' => 'BP-001', 'stock_qty' => 20],
            ['name' => 'Nastar Keju (500gr)', 'price' => 95000, 'unit' => 'toples', 'category' => 'Kue Kering', 'sku' => 'NK-001', 'stock_qty' => 15],
            ['name' => 'Bolu Gulung Vanilla', 'price' => 55000, 'unit' => 'pcs', 'category' => 'Kue Basah', 'sku' => 'BGV-001', 'stock_qty' => 25],
            ['name' => 'Kue Tart Ulang Tahun', 'price' => 250000, 'unit' => 'pcs', 'category' => 'Tart', 'sku' => 'KTU-001', 'stock_qty' => 5],
            ['name' => 'Croissant Butter (6pcs)', 'price' => 78000, 'unit' => 'box', 'category' => 'Roti', 'sku' => 'CB-001', 'stock_qty' => 30],
            ['name' => 'Risol Mayo (20pcs)', 'price' => 60000, 'unit' => 'box', 'category' => 'Snack Box', 'sku' => 'RM-001', 'stock_qty' => 40],
            ['name' => 'Lemper Ayam (20pcs)', 'price' => 50000, 'unit' => 'box', 'category' => 'Snack Box', 'sku' => 'LA-001', 'stock_qty' => 40],
            ['name' => 'Snack Box Paket A', 'price' => 25000, 'unit' => 'box', 'category' => 'Snack Box', 'sku' => 'SBA-001', 'stock_qty' => 100],
            ['name' => 'Snack Box Paket B', 'price' => 35000, 'unit' => 'box', 'category' => 'Snack Box', 'sku' => 'SBB-001', 'stock_qty' => 100],
            ['name' => 'Red Velvet Cake', 'price' => 275000, 'unit' => 'pcs', 'category' => 'Tart', 'sku' => 'RVC-001', 'stock_qty' => 5],
            ['name' => 'Puding Karamel (cup)', 'price' => 12000, 'unit' => 'pcs', 'category' => 'Dessert', 'sku' => 'PK-001', 'stock_qty' => 50],
        ];

        foreach ($products as $p) {
            Product::create(array_merge($p, ['organization_id' => $org->id]));
        }
    }
}
