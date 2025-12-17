<?php

namespace App\Models\Siswa;

use App\Models\User\ProfileSiswa;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class Izin extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'mitra_industri_id',
        'tgl_mulai',
        'tgl_selesai',
        'durasi_hari',
        'keterangan',
        'bukti_path',
        'status',
        'approved_by',
    ];

    public function siswa()
    {
        return $this->belongsTo(ProfileSiswa::class, 'profile_siswa_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}