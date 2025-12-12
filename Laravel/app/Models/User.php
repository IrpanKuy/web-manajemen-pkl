<?php

namespace App\Models;

use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\User\ProfilePembimbing;
use App\Models\User\ProfileSiswa;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'phone',
        'role',      // admin, guru, siswa, owner, pembimbing
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    // Relasi Profile
    public function siswas()
    {
        return $this->hasOne(ProfileSiswa::class);
    }

    public function mitraIndustri()
    {
        return $this->hasOne(MitraIndustri::class, 'supervisors_id');
    }

    public function pembimbings()
    {
        return $this->hasOne(ProfilePembimbing::class);
    }

    // Relasi sebagai Pembimbing Industri (Has Many Placements)
    public function placementsAsPembimbings()
    {
        return $this->hasMany(PklPlacement::class, 'pembimbing_id');
    }
    

    // --- SCOPES (LOGIC QUERY) ---

    /**
     * Scope untuk User Internal (Pendamping & Supervisors)
     * Pendamping = Guru/Admin
     */
    public function scopeInternal(Builder $query)
    {
        return $query->whereIn('role', ['pendamping', 'supervisors']);
    }

    /**
     * Scope untuk Siswa + Load Data Profil & Jurusan
     */
    public function scopeSiswa(Builder $query)
    {
        return $query->where('role', 'siswa')->with(['siswas.jurusan']);
    }

    public function scopePendamping(Builder $query)
    {
        return $query->where('role', 'pendamping');
    }

    public function scopeSupervisors(Builder $query)
    {
        return $query->where('role', 'supervisors');
    }

    /**
     * Scope untuk Pembimbing + Load Data Profil & Mitra Industri
     */
    public function scopePembimbing(Builder $query)
    {
        return $query->where('role', 'pembimbing')->with(['pembimbing.mitra']);
    }
}
