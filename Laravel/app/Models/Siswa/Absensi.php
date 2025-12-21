<?php

namespace App\Models\Siswa;

use App\Models\Instansi\MitraIndustri;
use App\Models\User\ProfileSiswa;
use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'mitra_industri_id',
        'tanggal',
        'jam_masuk',
        'jam_pulang',
        // 'location_masuk', // PostGIS
        // 'location_pulang', // PostGIS
        'status_kehadiran',
    ];
    
    public function siswa()
    {
        return $this->belongsTo(ProfileSiswa::class, 'profile_siswa_id');
    }

    public function mitra()
    {
        return $this->belongsTo(MitraIndustri::class, 'mitra_industri_id');
    }
}