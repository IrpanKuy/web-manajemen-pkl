<?php

namespace App\Models\Instansi;

use App\Http\Controllers\ProfilePembimbingController;
use App\Models\Approval\PengajuanMasukSiswa;
use App\Models\Approval\PengajuanPengeluaranSiswa;
use App\Models\ProfilePembimbing;
use App\Models\Siswa\Absensi;
use App\Models\Siswa\Izin;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class MitraIndustri extends Model
{
    protected static function booted()
    {
        static::creating(function ($mitra) {
            $mitra->qr_value = (string) Str::uuid();
        });
    }
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
        'qr_value',
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
    public function pengajuanPengeluaran()
    {
        return $this->hasMany(PengajuanPengeluaranSiswa::class);
    }   

    public function izins()
    {
        return $this->hasMany(Izin::class);
    }
}