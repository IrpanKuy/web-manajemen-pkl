<?php

namespace App\Models\User;

use App\Models\Instansi\MitraIndustri;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class ProfilePembimbing extends Model
{
    protected $fillable = [
        'user_id',
        'mitra_industri_id',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mitra()
    {
        return $this->belongsTo(MitraIndustri::class, 'mitra_industri_id');
    }
}