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
        Schema::create('pkl_placements', function (Blueprint $table) {
        $table->id();
        $table->foreignId('profile_siswa_id')->constrained('profile_siswas')->onDelete('cascade');
        $table->foreignId('mitra_industri_id')->constrained('mitra_industris')->onDelete('cascade');
        
        // Relasi ke User (Role: Pembimbing Industri)
        $table->foreignId('pembimbing_id')->nullable()->constrained('users')->nullOnDelete();
        
        $table->date('tgl_mulai');
        $table->date('tgl_selesai');
        $table->enum('status', ['pending', 'berjalan', 'selesai', 'gagal'])->default('pending');
        $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pkl_placements');
    }
};
