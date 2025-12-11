<?php

namespace App\Models\Pendamping;

use App\Models\User\ProfileSiswa;
use Illuminate\Database\Eloquent\Model;

class Jurusan extends Model
{
    protected $fillable = ['nama_jurusan'];

    public function siswas()
    {
        return $this->hasMany(ProfileSiswa::class);
    }
}
