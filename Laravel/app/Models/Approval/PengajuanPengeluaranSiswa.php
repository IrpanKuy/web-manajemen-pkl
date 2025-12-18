<?php

namespace App\Models\Approval;

use App\Models\Instansi\MitraIndustri;
use App\Models\User\ProfileSiswa;
use Illuminate\Database\Eloquent\Model;

class PengajuanPengeluaranSiswa extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'mitra_industri_id',
        'alasan_pengeluaran',
        'tgl_ajuan',
        'status',
    ];

    protected $casts = [
        'tgl_ajuan' => 'date',
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
