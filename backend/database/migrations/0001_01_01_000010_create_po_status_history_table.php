<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('po_status_history', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('po_id');
            $table->string('from_status', 50)->nullable();
            $table->string('to_status', 50);
            $table->foreignId('changed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('reason')->nullable();
            $table->timestamp('changed_at')->useCurrent();

            $table->foreign('po_id')
                  ->references('id')
                  ->on('purchase_orders')
                  ->cascadeOnDelete();

            $table->index(['po_id', 'changed_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('po_status_history');
    }
};
