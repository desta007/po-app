<?php

use App\Models\User;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        User::firstOrCreate(
            ['email' => 'superadmin@poscheduler.com'],
            [
                'name' => 'Super Admin',
                'full_name' => 'Super Admin',
                'password' => 'password123',
                'is_super_admin' => true,
            ]
        );
    }

    public function down(): void
    {
        User::where('email', 'superadmin@poscheduler.com')->delete();
    }
};
