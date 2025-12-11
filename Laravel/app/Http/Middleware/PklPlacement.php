<?php

namespace App\Models;

use App\Models\Instansi\MitraIndustri;
use App\Models\User\User;
use Illuminate\Database\Eloquent\Model;

class PklPlacement extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'mitra_industri_id',
        'pembimbing_id',        // User ID (Industri)
        'tgl_mulai',
        'tgl_selesai',
        'status',
    ];

    public function siswa()
    {
        return $this->belongsTo(ProfileSiswa::class, 'profile_siswa_id');
    }

    public function mitra()
    {
        return $this->belongsTo(MitraIndustri::class, 'mitra_industri_id');
    }

    // Relasi ke User langsung (Pembimbing Lapangan)
    public function pembimbing()
    {
        return $this->belongsTo(User::class, 'pembimbing_id');
    }

}
