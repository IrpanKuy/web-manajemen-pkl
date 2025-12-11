<?php

namespace App\Models\Approval;

use App\Models\Instansi\MitraIndustri;
use App\Models\User\ProfileSiswa;
use Illuminate\Database\Eloquent\Model;

class PengajuanMasukSiswa extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'mitra_industri_id',
        'durasi',
        'cv_path',
        'deskripsi',
        'tgl_ajuan',
        'status',
        'alasan_penolakan',
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