<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->boolean('discount_enabled')->default(false)->after('cost');
            $table->string('discount_type', 10)->nullable()->after('discount_enabled');
            $table->decimal('discount_value', 15, 2)->default(0)->after('discount_type');
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['discount_enabled', 'discount_type', 'discount_value']);
        });
    }
};
