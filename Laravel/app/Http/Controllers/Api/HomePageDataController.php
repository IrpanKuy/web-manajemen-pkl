<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

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

        $siswaId = $siswa->id;

        // 2. Ambil Data Penempatan
        $dataPenempatan = PklPlacement::where('siswa_id', $siswaId)
                            ->with(['mitra', 'pembimbing']) 
                            ->first(); 

        // 3. Siapkan Data Default (Jika belum dapat tempat PKL)
        $namaInstansi = "Belum ditempatkan";
        $namaPembimbing = "Belum ada";

        // Jika data penempatan ADA, baru isi variabelnya
        if ($dataPenempatan) {
            $namaInstansi = $dataPenempatan->mitra->nama_instansi ?? "Data Mitra Terhapus";
            $namaPembimbing = $dataPenempatan->pembimbing->name ?? "Belum ditentukan";
        }

        // 4. Data Absensi & Jurnal 
        $today = Carbon::now()->format('Y-m-d');
        
        $absensiHarian = Absensi::where('siswa_id', $siswaId)
                            ->whereDate('tanggal', $today) 
                            ->first(); 

        $jurnalHarian = JurnalHarian::where('siswa_id', $siswaId)
                            ->whereDate('tanggal', $today)
                            ->first(); 

        return response()->json([
            'success' => true,
            'message' => 'Data berhasil diambil',
            'data' => [
                'penempatan' => [
                    'status' => $dataPenempatan ? true : false,
                    'nama_instansi' => $namaInstansi,
                    'pembimbing' => $namaPembimbing,
                ],
                'absensi' => $absensiHarian, 
                'jurnal' => $jurnalHarian
            ]
        ]);
    }
}