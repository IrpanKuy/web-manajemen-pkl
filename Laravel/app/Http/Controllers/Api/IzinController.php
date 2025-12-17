<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Izin;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class IzinController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->siswas) {
            return response()->json(['success' => false, 'message' => 'User bukan siswa'], 403);
        }

        $profileSiswaId = $user->siswas->id;
        $query = Izin::where('profile_siswa_id', $profileSiswaId);

         if ($request->has('month') && $request->has('year')) {
            $month = $request->month;
            $year = $request->year;
            $query->whereMonth('tgl_mulai', $month)->whereYear('tgl_mulai', $year);
        }

        $izins = $query->orderBy('tgl_mulai', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $izins,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'tgl_mulai' => 'required|date',
            'tgl_selesai' => 'required|date|after_or_equal:tgl_mulai',
            'keterangan' => 'required|string',
            'bukti' => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:2048', // File input name 'bukti'
        ]);

        $user = $request->user();
        $siswa = $user->siswas;

        // Cari Penempatan Aktif
        $placement = PklPlacement::where('profile_siswa_id', $siswa->id)
            ->where('status', 'berjalan') // Atau status aktif lainnya
            ->first();

        // Fallback jika tidak ada status berjalan, ambil yang terbaru
        if (!$placement) {
             $placement = PklPlacement::where('profile_siswa_id', $siswa->id)
                ->latest()
                ->first();
        }

        if (!$placement) {
            return response()->json(['success' => false, 'message' => 'Tidak ada penempatan PKL aktif'], 400);
        }

        // Logic Durasi
        $start = Carbon::parse($request->tgl_mulai);
        $end = Carbon::parse($request->tgl_selesai);
        $durasi = $start->diffInDays($end) + 1;

        // Upload Bukti
        $buktiPath = null;
        if ($request->hasFile('bukti')) {
            $buktiPath = $request->file('bukti')->store('bukti_izin', 'public');
        }

        $izin = Izin::create([
            'profile_siswa_id' => $siswa->id,
            'mitra_industri_id' => $placement->mitra_industri_id,
            'tgl_mulai' => $request->tgl_mulai,
            'tgl_selesai' => $request->tgl_selesai,
            'durasi_hari' => $durasi,
            'keterangan' => $request->keterangan,
            'bukti_path' => $buktiPath,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan izin berhasil dibuat',
            'data' => $izin
        ], 201);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $izin = Izin::where('id', $id)
                    ->where('profile_siswa_id', $user->siswas->id)
                    ->first();

        if (!$izin) {
            return response()->json(['success' => false, 'message' => 'Izin tidak ditemukan'], 404);
        }

        if ($izin->status !== 'pending') {
            return response()->json(['success' => false, 'message' => 'Hanya izin pending yang dapat dibatalkan'], 400);
        }

        $izin->delete();

        return response()->json([
            'success' => true,
            'message' => 'Izin berhasil dibatalkan'
        ]);
    }
}
