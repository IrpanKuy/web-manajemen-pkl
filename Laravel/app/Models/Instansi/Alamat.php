<?php

namespace App\Models\Instansi;

use Illuminate\Database\Eloquent\Model;

class Alamat extends Model
{
    protected $fillable = [
        'mitra_industri_id',
        'profinsi',
        'kabupaten',
        'kecamatan',
        'kode_pos',
        'detail_alamat',
        'location',     // PostGIS column
        'radius_meter',
    ];

    public function mitraIndustri()
    {
        return $this->belongsTo(MitraIndustri::class);
    }
}
