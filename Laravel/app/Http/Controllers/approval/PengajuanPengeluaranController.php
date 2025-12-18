<?php

namespace App\Http\Controllers\approval;

use App\Http\Controllers\Controller;
use App\Models\Approval\PengajuanPengeluaranSiswa;
use App\Models\Instansi\MitraIndustri;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;

class PengajuanPengeluaranController extends Controller
{
    /**
     * Store a newly created pengajuan pengeluaran.
     */
    public function store(Request $request)
    {
        $request->validate([
            'profile_siswa_id' => 'required|exists:profile_siswas,id',
            'alasan_pengeluaran' => 'required|string',
        ]);

        // Ambil mitra dari supervisor yang login
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();

        if (!$mitra) {
            return redirect()->back()->with('error', 'Mitra industri tidak ditemukan');
        }

        PengajuanPengeluaranSiswa::create([
            'profile_siswa_id' => $request->profile_siswa_id,
            'mitra_industri_id' => $mitra->id,
            'alasan_pengeluaran' => $request->alasan_pengeluaran,
            'tgl_ajuan' => Carbon::now(),
            'status' => 'pending',
        ]);

        return redirect()->back()->with('success', 'Pengajuan berhasil! Kamu akan segera dihubungi pendamping siswa.');
    }
}
