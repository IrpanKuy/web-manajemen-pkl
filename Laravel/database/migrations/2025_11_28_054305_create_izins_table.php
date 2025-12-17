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
        Schema::create('izins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('profile_siswa_id')->constrained('profile_siswas')->onDelete('cascade');
            $table->foreignId('mitra_industri_id')->constrained('mitra_industris');
            $table->date('tgl_mulai');
            $table->date('tgl_selesai');
            $table->integer('durasi_hari');
            $table->text('keterangan');
            $table->string('bukti_path')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->foreignId('approved_by')->nullable()->constrained('users'); // User (Guru/Pembimbing)
            $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('izins');
    }
};
