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
        Schema::create('pengajuan_pengeluaran_siswas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('profile_siswa_id')->constrained('profile_siswas')->onDelete('cascade');
            $table->foreignId('mitra_industri_id')->constrained('mitra_industris')->onDelete('cascade');
            $table->text('alasan_pengeluaran');
            $table->date('tgl_ajuan');
            $table->enum('status', ['pending', 'diterima', 'ditolak'])->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pengajuan_pengeluaran_siswas');
    }
};
