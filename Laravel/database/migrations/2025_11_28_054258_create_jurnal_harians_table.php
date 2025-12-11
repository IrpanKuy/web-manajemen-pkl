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
        Schema::create('jurnal_harians', function (Blueprint $table) {
            $table->id();
            $table->foreignId('profile_siswa_id')->constrained('profile_siswas')->onDelete('cascade');
            $table->foreignId('pembimbing_id')->constrained('users'); // Approval ke user pembimbing
            $table->date('tanggal');
            $table->string('judul');
            $table->text('deskripsi');
            $table->string('foto_kegiatan')->nullable();
            $table->enum('status', ['pending', 'disetujui', 'revisi'])->default('pending');
            $table->text('komentar')->nullable();
            $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jurnal_harians');
    }
};
