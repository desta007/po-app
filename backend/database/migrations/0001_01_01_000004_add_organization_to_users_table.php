<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('full_name', 255)->after('name')->nullable();
            $table->string('phone', 20)->after('email')->nullable();
            $table->text('avatar_url')->nullable();
            $table->uuid('current_org_id')->nullable();
            $table->timestamp('last_login_at')->nullable();

            $table->foreign('current_org_id')
                  ->references('id')
                  ->on('organizations')
                  ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['current_org_id']);
            $table->dropColumn(['full_name', 'phone', 'avatar_url', 'current_org_id', 'last_login_at']);
        });
    }
};
