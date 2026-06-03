<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id')->nullable();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->uuid('po_id')->nullable();
            $table->string('channel', 50);
            $table->string('recipient', 255)->nullable();
            $table->string('title', 255)->nullable();
            $table->text('message')->nullable();
            $table->string('template_key', 100)->nullable();
            $table->jsonb('payload')->default('{}');
            $table->string('status', 50)->default('pending');
            $table->text('error_message')->nullable();
            $table->timestamp('scheduled_at')->nullable();
            $table->timestamp('sent_at')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();

            $table->foreign('organization_id')
                  ->references('id')
                  ->on('organizations')
                  ->cascadeOnDelete();

            $table->foreign('po_id')
                  ->references('id')
                  ->on('purchase_orders')
                  ->nullOnDelete();

            $table->index(['user_id', 'read_at']);
            $table->index(['status', 'scheduled_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
