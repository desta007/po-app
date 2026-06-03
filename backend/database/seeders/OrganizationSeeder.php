<?php

namespace Database\Seeders;

use App\Models\Organization;
use Illuminate\Database\Seeder;

class OrganizationSeeder extends Seeder
{
    public function run(): void
    {
        Organization::create([
            'name' => 'Dapur Kue Sari',
            'slug' => 'dapur-kue-sari',
            'phone' => '081234567890',
            'address' => 'Jl. Cihampelas No. 42, Bandung, Jawa Barat 40131',
            'settings' => [
                'timezone' => 'Asia/Jakarta',
                'currency' => 'IDR',
                'po_prefix' => 'PO',
            ],
        ]);
    }
}
