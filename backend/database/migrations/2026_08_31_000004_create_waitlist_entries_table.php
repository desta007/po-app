<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('waitlist_entries', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('organization_id');
            $table->integer('queue_number');                    // nomor antrian harian, reset per hari
            $table->string('guest_name');
            $table->unsignedSmallInteger('party_size')->default(1);
            $table->string('phone', 30)->nullable();
            $table->string('status', 20)->default('waiting');   // waiting | called | seated | cancelled | no_show
            $table->uuid('table_id')->nullable();               // diisi saat seated (peta meja)
            $table->string('table_label', 50)->nullable();      // snapshot label meja
            $table->text('notes')->nullable();
            $table->timestamp('called_at')->nullable();
            $table->unsignedTinyInteger('call_count')->default(0);
            $table->timestamp('seated_at')->nullable();
            $table->timestamps();

            $table->foreign('organization_id')->references('id')->on('organizations')->cascadeOnDelete();
            $table->foreign('table_id')->references('id')->on('resto_tables')->nullOnDelete();
            $table->index(['organization_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('waitlist_entries');
    }
};
