<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            OrganizationSeeder::class,
            UserSeeder::class,
            CustomerSeeder::class,
            ProductSeeder::class,
            PurchaseOrderSeeder::class,
            NotificationSeeder::class,
        ]);
    }
}
