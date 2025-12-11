<?php

namespace App\Models\User;

use App\Models\Instansi\PklPlacement;
use App\Models\Pendamping\Jurusan;
use App\Models\Siswa\Absensi;
use Illuminate\Database\Eloquent\Model;

class ProfileSiswa extends Model
{
    protected $fillable = [
        'user_id',
        'jurusan_id',
        'nisn',
        'device_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function jurusan()
    {
        return $this->belongsTo(Jurusan::class);
    }

    public function activePlacement()
    {
        return $this->hasOne(PklPlacement::class)->where('status', 'berjalan');
    }
    
    public function placements()
    {
        return $this->hasMany(PklPlacement::class);
    }

    public function absensis()
    {
        return $this->hasMany(Absensi::class);
    }
}