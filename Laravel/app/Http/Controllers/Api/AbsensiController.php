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
        $placement = PklPlacement::where('profile_siswa_id', $user->siswas->id)
            ->where('status', 'berjalan')
            ->with(['mitra']) // Eager load mitra
            ->first();

        if (!$placement || !$placement->mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki penempatan PKL aktif.',
            ], 404);
        }

        $mitra = $placement->mitra;

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
        SELECT 
            mitra_industris.id,
            alamats.location, 
            ST_DistanceSphere(
                geometry(alamats.location), 
                ST_MakePoint(?, ?)
            ) as distance
        FROM mitra_industris
        JOIN alamats ON alamats.mitra_industri_id = mitra_industris.id 
        WHERE mitra_industris.id = ?
    ", [
        $request->longitude, 
        $request->latitude, 
        $mitra->id
    ]);

        $distance = $distanceQuery->distance ?? 999999;
        $maxRadius = $mitra->radius_meter ?? 100; // Default 100m jika null

        // if ($distance > $maxRadius) {
        //     return response()->json([
        //         'success' => false,
        //         'message' => "Anda berada di luar radius lokasi PKL. Jarak: " . round($distance) . "m (Maks: {$maxRadius}m)",
        //     ], 400);
        // }

        // 4. Cek apakah sudah ada absensi hari ini
        $existingAbsensi = Absensi::where('profile_siswa_id', $user->siswas->id)
            ->whereDate('tanggal', now()->toDateString())
            ->first();

        // Return error jika tidak ada absensi yang ditemukan
        if (!$existingAbsensi) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada data absensi untuk hari ini. Hubungi admin untuk membuat jadwal absensi.',
            ], 404);
        }

        // 5. Cek apakah ini absen masuk atau absen pulang
        if ($existingAbsensi->jam_masuk === null) {
            // --- ABSEN MASUK ---
            $now = now();
            $jamMasukMitra = $mitra->jam_masuk; // Format: "HH:mm:ss"
            
            // Tentukan status kehadiran berdasarkan jam masuk mitra
            $statusKehadiran = 'hadir';
            if ($jamMasukMitra) {
                $jamMasukTarget = \Carbon\Carbon::parse($now->format('Y-m-d') . ' ' . $jamMasukMitra);
                if ($now->gt($jamMasukTarget)) {
                    $statusKehadiran = 'telat';
                }
            }

            $existingAbsensi->update([
                'jam_masuk' => $now->format('H:i:s'),
                'status_kehadiran' => $statusKehadiran,
            ]);

            $message = $statusKehadiran === 'telat' 
                ? 'Anda terlambat! Jam masuk: ' . $jamMasukMitra . ', Anda absen: ' . $now->format('H:i:s')
                : 'Berhasil absen masuk!';

            return response()->json([
                'success' => true,
                'message' => $message,
                'status_kehadiran' => $statusKehadiran,
                'data' => $existingAbsensi,
                'distance' => round($distance) . 'm'
            ]);

        } elseif ($existingAbsensi->jam_pulang === null) {
            // --- ABSEN PULANG ---
            $existingAbsensi->update([
                'jam_pulang' => now()->format('H:i:s'),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Berhasil absen pulang!',
                'data' => $existingAbsensi,
                'distance' => round($distance) . 'm'
            ]);
        } else {
            // Sudah absen masuk dan pulang
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah menyelesaikan absensi hari ini.',
            ], 400);
        }
    }
    public function history(Request $request)
    {
        $user = $request->user();
        if (!$user->siswas) {
             return response()->json(['success' => false, 'message' => 'User bukan siswa'], 403);
        }

        $profileSiswaId = $user->siswas->id;

        $query = Absensi::where('profile_siswa_id', $profileSiswaId);

        if ($request->has('month') && $request->has('year')) {
            $month = $request->month;
            $year = $request->year;
            $query->whereMonth('tanggal', $month)->whereYear('tanggal', $year);
        }

        $absensis = $query->orderBy('tanggal', 'desc')->get();

        // Calculate Summary
        // status_kehadiran: 'hadir', 'telat', 'izin', 'sakit', 'alpha', 'pending'
        $totalHadir = $absensis->where('status_kehadiran', 'hadir')->count();
        $totalTelat = $absensis->where('status_kehadiran', 'telat')->count();
        $totalSakit = $absensis->where('status_kehadiran', 'sakit')->count();
        $totalIzin = $absensis->where('status_kehadiran', 'izin')->count();
        $totalAlpha = $absensis->where('status_kehadiran', 'alpha')->count();

        // Total hari hadir = Hadir + Telat? Or just Hadir? 
        // Image shows "Total Hadir 22 Hari" and "Terlambat 3 Kali".
        // Usually "Terlambat" is also "Hadir" but late.
        // Assuming 'hadir' in DB means strictly on time, and 'telat' means late.
        // If so, Total Hadir displayed might be sum of 'hadir' + 'telat'.
        // Let's return raw counts and let frontend decide, or return a composite.
        // The image shows "Total Hadir 22 Hari". It's possible this includes 'telat'.
        // Let's provide breakdown.

        return response()->json([
            'success' => true,
            'data' => $absensis,
            'summary' => [
                'hadir' => $totalHadir,
                'telat' => $totalTelat,
                'sakit' => $totalSakit,
                'izin' => $totalIzin,
                'alpha' => $totalAlpha,
                // Composite for UI convenience, assuming Total Hadir includes Telat
                'total_hadir_count' => $totalHadir + $totalTelat
            ]
        ]);
    }
}
