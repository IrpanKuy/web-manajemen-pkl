<?php

namespace App\Models\Instansi;

use App\Models\User\ProfileSiswa;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class JurnalHarian extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'mitra_industri_id',
        'pembimbing_id',
        'pendamping_id',
        'tanggal',
        'judul',
        'deskripsi',
        'foto_kegiatan',
        'status',
        'alasan_revisi_pembimbing',
        'komentar_pendamping',
    ];

    public function siswa()
    {
        return $this->belongsTo(ProfileSiswa::class, 'profile_siswa_id');
    }

    public function pembimbing()
    {
        return $this->belongsTo(User::class, 'pembimbing_id');
    }

    public function pendamping()
    {
        return $this->belongsTo(User::class, 'pendamping_id');
    }

    public function mitra()
    {
        return $this->belongsTo(MitraIndustri::class, 'mitra_industri_id');
    }
}

