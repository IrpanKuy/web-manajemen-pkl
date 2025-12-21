<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class JurnalController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->siswas) {
            return response()->json(['success' => false, 'message' => 'User bukan siswa'], 403);
        }

        $profileSiswaId = $user->siswas->id;

        $query = JurnalHarian::where('profile_siswa_id', $profileSiswaId);

        // Filter by Month and Year
        if ($request->has('month') && $request->has('year')) {
            $month = $request->month; // 1-12
            $year = $request->year;
            $query->whereMonth('tanggal', $month)->whereYear('tanggal', $year);
        }

        // Order by latest
        $jurnals = $query->orderBy('tanggal', 'desc')->get();

        // Summary
        $totalJurnal = $jurnals->count();

        return response()->json([
            'success' => true,
            'data' => $jurnals,
            'summary' => [
                'total_jurnal' => $totalJurnal
            ]
        ]);
    }

    public function show($id)
    {
        $jurnal = JurnalHarian::with(['siswa.user', 'pembimbing'])->find($id);

        if (!$jurnal) {
            return response()->json([
                'success' => false,
                'message' => 'Jurnal tidak ditemukan.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $jurnal
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'foto_kegiatan' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $user = $request->user();
        $siswa = $user->siswas;

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'User bukan siswa'
            ], 403);
        }

        // Cek penempatan aktif untuk mendapatkan pembimbing
        $placement = PklPlacement::where('profile_siswa_id', $siswa->id)
            ->where('status', 'berjalan')
            ->first();

        if (!$placement) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada penempatan PKL aktif.'
            ], 404);
        }

        // Cek apakah sudah ada jurnal hari ini
        $today = Carbon::now()->format('Y-m-d');
        $existingJurnal = JurnalHarian::where('profile_siswa_id', $siswa->id)
            ->whereDate('tanggal', $today)
            ->first();

        if ($existingJurnal) {
            return response()->json([
                'success' => false,
                'message' => 'Jurnal untuk hari ini sudah ada.'
            ], 400);
        }

        // Handle upload foto
        $fotoPath = null;
        if ($request->hasFile('foto_kegiatan')) {
            $fotoPath = $request->file('foto_kegiatan')->store('jurnal_foto', 'public');
        }

        $jurnal = JurnalHarian::create([
            'profile_siswa_id' => $siswa->id,
            'pembimbing_id' => $placement->pembimbing_id,
            'tanggal' => $today,
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'foto_kegiatan' => $fotoPath,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jurnal berhasil dibuat!',
            'data' => $jurnal
        ], 201);
    }
}
