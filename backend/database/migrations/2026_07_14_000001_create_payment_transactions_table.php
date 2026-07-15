<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payment_transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->uuid('po_id');
            $table->string('gateway', 30)->default('midtrans');
            $table->string('gateway_order_id', 120)->unique();
            $table->text('snap_token')->nullable();
            $table->string('status', 30)->default('pending'); // pending|paid|expired|failed|refunded
            $table->string('payment_type', 50)->nullable();
            $table->decimal('amount', 15, 2);
            $table->jsonb('gateway_response')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->foreign('organization_id')
                  ->references('id')
                  ->on('organizations')
                  ->cascadeOnDelete();

            $table->foreign('po_id')
                  ->references('id')
                  ->on('purchase_orders')
                  ->cascadeOnDelete();

            $table->index(['organization_id', 'po_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payment_transactions');
    }
};
