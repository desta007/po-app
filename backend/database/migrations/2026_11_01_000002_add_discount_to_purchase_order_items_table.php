<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Snapshot diskon produk per item. unit_price tetap berisi harga NET (setelah
     * diskon) sehingga subtotal = quantity × unit_price tidak berubah; kolom ini
     * hanya mencatat harga normal & potongan per unit saat pesanan dibuat.
     */
    public function up(): void
    {
        Schema::table('purchase_order_items', function (Blueprint $table) {
            $table->decimal('original_price', 15, 2)->nullable()->after('unit_price');
            $table->decimal('discount_amount', 15, 2)->default(0)->after('original_price');
        });
    }

    public function down(): void
    {
        Schema::table('purchase_order_items', function (Blueprint $table) {
            $table->dropColumn(['original_price', 'discount_amount']);
        });
    }
};
