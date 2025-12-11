<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('mentor_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('profile_siswa_id')->constrained('profile_siswas');
            $table->foreignId('pembimbing_lama_id')->nullable()->constrained('users');
            $table->foreignId('pembimbing_baru_id')->constrained('users');
            $table->text('alasan')->nullable();
            $table->enum('status', ['pending', 'disetujui', 'ditolak'])->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mentor_requests');
    }
};
