<?php

namespace App\Models\Instansi;

use App\Models\User\ProfileSiswa;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class JurnalHarian extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'pembimbing_id',
        'tanggal',
        'judul',
        'deskripsi',
        'foto_kegiatan',
        'status',
        'komentar',
    ];

    public function siswa()
    {
        return $this->belongsTo(ProfileSiswa::class, 'profile_siswa_id');
    }

    public function pembimbing()
    {
        return $this->belongsTo(User::class, 'pembimbing_id');
    }
}
