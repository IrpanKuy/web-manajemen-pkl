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
        Schema::create('alamats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mitra_industri_id')->constrained('mitra_industris')->onDelete('cascade');
            $table->string('profinsi');
            $table->string('kabupaten');
            $table->string('kecamatan');
            $table->string('kode_pos');
            $table->text('detail_alamat');
        
            // PostGIS Geography
            $table->geography('location', subtype: 'POINT', srid: 4326); 
            $table->integer('radius_meter')->default(50);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('alamats');
    }
};
