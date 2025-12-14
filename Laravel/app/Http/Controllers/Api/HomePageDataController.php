<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;

class HomePageDataController extends Controller
{
    public function index(Request $request){
        // 1. Ambil User & Cek Relasi Siswa
        $user = $request->user();
        
        // Gunakan tanda tanya (?) biar gak error kalau null
        $siswa = $user->siswas; 
        
        // JAGA-JAGA: Kalau user login tapi data siswanya gak ada
        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Profil siswa tidak ditemukan.',
                'data' => null
            ], 404);
        }

        $profileSiswaId = $siswa->id;

        // 2. Ambil Data Penempatan
        $dataPenempatan = PklPlacement::where('profile_siswa_id', $profileSiswaId)
                            ->with(['mitra', 'pembimbing']) 
                            ->first(); 

        // 4. Data Absensi & Jurnal 
        $today = Carbon::now()->format('Y-m-d');
        $tglMasukPkl = $dataPenempatan->tgl_mulai ?? "Tanggal masuk PKL belum ditentukan";
        $tglSelesaiPkl = $dataPenempatan->tgl_selesai ?? "Tanggal selesai PKL belum ditentukan";
        
        $absensiHarian = Absensi::where('profile_siswa_id', $profileSiswaId)
                            ->whereDate('tanggal', $today) 
                            ->first(); 
        $jurnalHarian = JurnalHarian::where('profile_siswa_id', $profileSiswaId)
                            ->whereDate('tanggal', $today)
                            ->first(); 
        $statusAbsensi = '';

        if(!$absensiHarian){
            return response()->json([
                'success' => false,
                'message' => 'Absensi tidak ditemukan.',
                'today' => $today,
                'data' => null
            ], 404);
        }
        // cek absensi
        if ($absensiHarian->jam_masuk === null) {
            $statusAbsensi = 'absenMasuk';
        }elseif ($absensiHarian->jam_pulang === null && $jurnalHarian === null) {
            $statusAbsensi = 'buatJurnal';
        }else {
            $statusAbsensi = 'absenPulang';
        };
        
        return response()->json([
            'success' => true,
            'message' => 'Data berhasil diambil',
            'statusAbsensi' => $statusAbsensi,
            'data' => [
                'penempatan' => $dataPenempatan,
                'absensi' => $absensiHarian, 
                'jurnal' => $jurnalHarian
            ]
        ]);
    }
}