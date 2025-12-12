<?php

namespace App\Models\Approval;

use App\Models\User\ProfileSiswa;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class MentorRequest extends Model
{
    protected $fillable = [
        'profile_siswa_id',
        'pembimbing_lama_id',
        'pembimbing_baru_id',
        'alasan',
        'status',
    ];

    public function siswa()
    {
        return $this->belongsTo(ProfileSiswa::class, 'profile_siswa_id');
    }

    public function pembimbingLama()
    {
        return $this->belongsTo(User::class, 'pembimbing_lama_id');
    }

    public function pembimbingBaru()
    {
        return $this->belongsTo(User::class, 'pembimbing_baru_id');
    }
}