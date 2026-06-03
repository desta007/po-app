<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Organization;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(): void
    {
        $org = Organization::where('slug', 'dapur-kue-sari')->first();

        $customers = [
            ['name' => 'Ibu Dewi Susanti', 'phone' => '081311112222', 'address' => 'Jl. Dago No. 15, Bandung', 'email' => 'dewi@email.com'],
            ['name' => 'Pak Ahmad Hidayat', 'phone' => '081322223333', 'address' => 'Jl. Braga No. 88, Bandung', 'email' => 'ahmad@email.com'],
            ['name' => 'Bu Ratna Sari', 'phone' => '081333334444', 'address' => 'Jl. Merdeka No. 10, Bandung'],
            ['name' => 'PT Berkah Catering', 'phone' => '081344445555', 'address' => 'Jl. Asia Afrika No. 50, Bandung', 'email' => 'order@berkahcatering.com'],
            ['name' => 'Toko Roti Makmur', 'phone' => '081355556666', 'address' => 'Jl. Setiabudi No. 23, Bandung'],
            ['name' => 'Ibu Lina Marlina', 'phone' => '081366667777', 'address' => 'Jl. Pasteur No. 12, Bandung'],
            ['name' => 'Pak Budi Santoso', 'phone' => '081377778888', 'address' => 'Jl. Pajajaran No. 77, Bandung', 'email' => 'budi.s@email.com'],
            ['name' => 'CV Pesta Rasa', 'phone' => '081388889999', 'address' => 'Jl. Gatot Subroto No. 30, Bandung', 'email' => 'info@pestarasa.id'],
            ['name' => 'Bu Ningsih Rahayu', 'phone' => '081399990000', 'address' => 'Jl. Diponegoro No. 5, Bandung'],
            ['name' => 'Kantor Kecamatan Coblong', 'phone' => '081300001111', 'address' => 'Jl. Siliwangi No. 1, Bandung'],
        ];

        foreach ($customers as $c) {
            Customer::create(array_merge($c, ['organization_id' => $org->id]));
        }
    }
}
