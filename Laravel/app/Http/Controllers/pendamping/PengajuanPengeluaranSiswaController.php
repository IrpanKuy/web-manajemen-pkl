<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Approval\PengajuanPengeluaranSiswa;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Inertia\Inertia;

class PengajuanPengeluaranSiswaController extends Controller
{
    /**
     * Display a listing of pengajuan pengeluaran.
     */
    public function index(Request $request)
    {
        $query = PengajuanPengeluaranSiswa::with([
            'siswa.user',
            'siswa.jurusan',
            'mitra'
        ]);

        // Filter by search
        if ($request->search) {
            $query->where(function ($q) use ($request) {
                $q->whereHas('siswa.user', function ($q2) use ($request) {
                    $q2->where('name', 'like', "%{$request->search}%");
                })->orWhereHas('mitra', function ($q2) use ($request) {
                    $q2->where('nama_instansi', 'like', "%{$request->search}%");
                });
            });
        }

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by mitra
        if ($request->mitra_id) {
            $query->where('mitra_industri_id', $request->mitra_id);
        }

        $pengajuans = $query->latest()
            ->paginate(15)
            ->withQueryString();

        // Summary
        $allPengajuans = PengajuanPengeluaranSiswa::all();
        $summary = [
            'total' => $allPengajuans->count(),
            'pending' => $allPengajuans->where('status', 'pending')->count(),
            'diterima' => $allPengajuans->where('status', 'diterima')->count(),
            'ditolak' => $allPengajuans->where('status', 'ditolak')->count(),
        ];

        // Get filter options
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/pengajuan-pengeluaran/index', [
            'pengajuans' => $pengajuans,
            'summary' => $summary,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
                'mitra_id' => $request->mitra_id,
            ],
            'mitras' => $mitras,
        ]);
    }

    /**
     * Approve the pengajuan pengeluaran.
     */
    public function approve($id)
    {
        $pengajuan = PengajuanPengeluaranSiswa::findOrFail($id);

        // Update status pengajuan to diterima
        $pengajuan->update(['status' => 'diterima']);

        // Update PKL placement status to gagal
        $placement = PklPlacement::where('profile_siswa_id', $pengajuan->profile_siswa_id)
            ->where('mitra_industri_id', $pengajuan->mitra_industri_id)
            ->where('status', 'berjalan')
            ->first();

        if ($placement) {
            $placement->update(['status' => 'gagal']);
        }

        return redirect()->back()->with('success', 'Pengajuan pengeluaran siswa berhasil disetujui. Status PKL siswa telah diubah menjadi gagal.');
    }

    /**
     * Reject the pengajuan pengeluaran.
     */
    public function reject($id)
    {
        $pengajuan = PengajuanPengeluaranSiswa::findOrFail($id);

        // Update status pengajuan to ditolak
        $pengajuan->update(['status' => 'ditolak']);

        return redirect()->back()->with('success', 'Pengajuan pengeluaran siswa berhasil ditolak.');
    }
}
