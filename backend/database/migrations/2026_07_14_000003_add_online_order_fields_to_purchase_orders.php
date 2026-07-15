<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->string('source', 20)->default('internal')->after('status'); // internal|catalog
            $table->string('shipping_method', 100)->nullable()->after('shipping_cost');
            $table->string('tracking_number', 100)->nullable()->after('shipping_method');
        });

        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->index(['organization_id', 'source']);
        });
    }

    public function down(): void
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->dropIndex(['organization_id', 'source']);
            $table->dropColumn(['source', 'shipping_method', 'tracking_number']);
        });
    }
};
