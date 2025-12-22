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

        $query = JurnalHarian::where('profile_siswa_id', $profileSiswaId)
            ->with(['pendamping:id,name']);

        // Filter by Month and Year
        if ($request->has('month') && $request->has('year')) {
            $month = $request->month; // 1-12
            $year = $request->year;
            $query->whereMonth('tanggal', $month)->whereYear('tanggal', $year);
        }

        // Filter by komentar_pendamping status
        if ($request->has('has_komentar')) {
            if ($request->has_komentar === 'true' || $request->has_komentar === '1') {
                $query->whereNotNull('komentar_pendamping')->where('komentar_pendamping', '!=', '');
            } else {
                $query->where(function($q) {
                    $q->whereNull('komentar_pendamping')->orWhere('komentar_pendamping', '');
                });
            }
        }

        // Order by latest
        $jurnals = $query->orderBy('tanggal', 'desc')->get();

        // Summary
        $totalJurnal = $jurnals->count();
        $withKomentar = $jurnals->filter(function($j) {
            return !empty($j->komentar_pendamping);
        })->count();

        return response()->json([
            'success' => true,
            'data' => $jurnals,
            'summary' => [
                'total_jurnal' => $totalJurnal,
                'dengan_komentar' => $withKomentar,
                'tanpa_komentar' => $totalJurnal - $withKomentar,
            ]
        ]);
    }

    public function show($id)
    {
        $jurnal = JurnalHarian::with(['siswa.user', 'pembimbing', 'pendamping:id,name', 'mitra:id,nama_instansi'])->find($id);

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

        // Cek penempatan aktif untuk mendapatkan pembimbing, pendamping, dan mitra
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
            'pendamping_id' => $placement->pendamping_id,
            'mitra_industri_id' => $placement->mitra_industri_id,
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

    /**
     * Update jurnal (untuk revisi dari siswa)
     */
    public function update(Request $request, $id)
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

        $jurnal = JurnalHarian::where('id', $id)
            ->where('profile_siswa_id', $siswa->id)
            ->first();

        if (!$jurnal) {
            return response()->json([
                'success' => false,
                'message' => 'Jurnal tidak ditemukan.'
            ], 404);
        }

        // Hanya bisa update jika status revisi
        if ($jurnal->status !== 'revisi') {
            return response()->json([
                'success' => false,
                'message' => 'Jurnal hanya bisa diubah jika berstatus revisi.'
            ], 400);
        }

        // Handle upload foto jika ada
        $fotoPath = $jurnal->foto_kegiatan;
        if ($request->hasFile('foto_kegiatan')) {
            $fotoPath = $request->file('foto_kegiatan')->store('jurnal_foto', 'public');
        }

        $jurnal->update([
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'foto_kegiatan' => $fotoPath,
            'status' => 'pending', // Ubah status kembali ke pending
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Jurnal berhasil diperbarui dan dikirim ulang untuk review!',
            'data' => $jurnal->fresh()
        ]);
    }
}

