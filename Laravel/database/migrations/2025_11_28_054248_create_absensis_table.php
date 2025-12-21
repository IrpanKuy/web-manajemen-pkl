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
         Schema::create('absensis', function (Blueprint $table) {
        $table->id();
        $table->foreignId('profile_siswa_id')->constrained('profile_siswas')->onDelete('cascade');
        $table->foreignId('mitra_industri_id')->constrained('mitra_industris'); // Snapshot lokasi
        $table->date('tanggal');
        
        $table->time('jam_masuk')->nullable();
        $table->time('jam_pulang')->nullable();
        
        // PostGIS
        // $table->geography('location_masuk', subtype: 'POINT', srid: 4326)->nullable();
        // $table->geography('location_pulang', subtype: 'POINT', srid: 4326)->nullable();
        
        $table->enum('status_kehadiran', ['hadir', 'telat', 'izin', 'sakit', 'alpha', 'pending'])->default('pending');
        $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('absensis');
    }
};
