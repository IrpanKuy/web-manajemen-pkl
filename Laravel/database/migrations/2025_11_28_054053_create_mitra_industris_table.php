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
        Schema::create('mitra_industris', function (Blueprint $table) {
        $table->id();
        $table->foreignId('pendamping_id')->constrained('users');
        $table->foreignId('supervisors_id')->constrained('users');
        $table->string('nama_instansi');
        $table->text('deskripsi')->nullable();
        $table->string('bidang_usaha');
        
        $table->date('tanggal_masuk');
        $table->time('jam_masuk');
        $table->time('jam_pulang');
        $table->integer('kuota');
        $table->json('jurusan_ids')->nullable(); // Disimpan sebagai JSON Array
        $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mitra_industris');
    }
};
