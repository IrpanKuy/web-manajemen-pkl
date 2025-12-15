<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Siswa\Absensi;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AbsensiController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'qr_value' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = Auth::user();

        // 1. Cari Penempatan PKL Siswa yang Aktif
        // Asumsi: Siswa hanya punya 1 penempatan aktif di satu waktu
        $placement = PklPlacement::where('siswa_id', $user->siswa->id)
            ->where('status', 'berjalan')
            ->with(['mitraIndustri']) // Eager load mitra
            ->first();

        if (!$placement || !$placement->mitraIndustri) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki penempatan PKL aktif.',
            ], 404);
        }

        $mitra = $placement->mitraIndustri;

        // 2. Validasi QR Code
        if ($mitra->qr_value !== $request->qr_value) {
            return response()->json([
                'success' => false,
                'message' => 'QR Code tidak valid atau bukan untuk instansi ini.',
            ], 400);
        }

        // 3. Validasi Jarak (Geolocation) menggunakan PostGIS
        // Lokasi Mitra disimpan di kolom 'location' (geometry point)
        // Kita hitung jarak antara titik Mitra dengan LatLong input user
        $distanceQuery = DB::selectOne("
            SELECT ST_DistanceSphere(
                geometry(location), 
                ST_MakePoint(?, ?)
            ) as distance
            FROM mitra_industris
            WHERE id = ?
        ", [
            $request->longitude, 
            $request->latitude, 
            $mitra->id
        ]);

        $distance = $distanceQuery->distance ?? 999999;
        $maxRadius = $mitra->radius_meter ?? 100; // Default 100m jika null

        if ($distance > $maxRadius) {
            return response()->json([
                'success' => false,
                'message' => "Anda berada di luar radius lokasi PKL. Jarak: " . round($distance) . "m (Maks: {$maxRadius}m)",
            ], 400);
        }

        // 4. Cek apakah sudah absen hari ini
        $existingAbsensi = Absensi::where('pkl_placement_id', $placement->id)
            ->whereDate('created_at', now()->toDateString())
            ->first();

        if ($existingAbsensi) {
            // Jika sudah absen masuk, mungkin ini absen pulang? (Logic sederhana dulu: absen masuk hanya sekali)
            if ($existingAbsensi->jam_pulang == null) {
                // Update Absen Pulang
                $existingAbsensi->update([
                    'jam_pulang' => now(),
                    // Update lokasi pulang jika perlu?
                ]);
                return response()->json([
                    'success' => true,
                    'message' => 'Berhasil absen pulang!',
                    'data' => $existingAbsensi
                ]);
            }
            
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah melakukan absensi lengkap hari ini.',
            ], 400);
        }

        // 5. Simpan Absensi Masuk
        $absensi = Absensi::create([
            'pkl_placement_id' => $placement->id,
            'status' => 'hadir',
            'jam_masuk' => now(),
            // 'jam_pulang' => null,
            // 'keterangan' => '',
            // 'foto_bukti' => '', // Jika ada fitur foto
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Berhasil absen masuk!',
            'data' => $absensi,
            'distance' => round($distance) . 'm'
        ]);
    }
}
