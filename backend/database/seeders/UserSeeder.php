<?php

namespace Database\Seeders;

use App\Models\Organization;
use App\Models\OrganizationMember;
use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $org = Organization::where('slug', 'dapur-kue-sari')->first();

        $admin = User::create([
            'name' => 'Sari Wulandari',
            'full_name' => 'Sari Wulandari',
            'email' => 'admin@demo.com',
            'password' => 'password123',
            'phone' => '081234567890',
            'current_org_id' => $org->id,
        ]);

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $admin->id,
            'role' => 'owner',
        ]);

        $staff = User::create([
            'name' => 'Rina Permatasari',
            'full_name' => 'Rina Permatasari',
            'email' => 'staff@demo.com',
            'password' => 'password123',
            'phone' => '081298765432',
            'current_org_id' => $org->id,
        ]);

        OrganizationMember::create([
            'organization_id' => $org->id,
            'user_id' => $staff->id,
            'role' => 'staff',
        ]);
    }
}
