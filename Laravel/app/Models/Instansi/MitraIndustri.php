<?php

namespace App\Models\Instansi;

use App\Http\Controllers\ProfilePembimbingController;
use App\Models\Approval\PengajuanMasukSiswa;
use App\Models\ProfilePembimbing;
use App\Models\Siswa\Absensi;
use App\Models\User\User;
use Illuminate\Database\Eloquent\Model;

class MitraIndustri extends Model
{
    protected $fillable = [
        'nama_instansi',
        'tanggal_masuk',
        'pendamping_id',
        'supervisors_id',
        'deskripsi',
        'bidang_usaha',
        'alamat',
        'location',     // PostGIS column
        'radius_meter',
        'jam_masuk',
        'jam_pulang',
        'kuota',
        'jurusan_ids',  // JSON Array
    ];

    protected $casts = [
        'jurusan_ids' => 'array',
    ];

    public function pembimbings()
    {
        return $this->hasMany(ProfilePembimbingController::class);
    }

    public function pengajuanMasuk()
    {
        return $this->hasOne(PengajuanMasukSiswa::class);
    }
    public function alamat()
    {
        return $this->hasOne(Alamat::class);
    }

    public function pendamping()
    {
        return $this->belongsTo(User::class, 'pendamping_id');
    }
    
    public function supervisor()
    {
        return $this->belongsTo(User::class, 'supervisors_id');
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