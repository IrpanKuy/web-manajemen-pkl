<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Inertia\Inertia;

class RekapJurnalController extends Controller
{
    /**
     * Display journal recap for pendamping.
     */
    public function index(Request $request)
    {
        $bulan = $request->bulan ?? Carbon::now()->format('Y-m');
        $tanggal = Carbon::parse($bulan);

        // Ambil semua siswa yang memiliki PKL aktif
        $placementsQuery = PklPlacement::where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'mitra', 'pembimbing']);

        // Filter by pembimbing
        if ($request->pembimbing_id) {
            $placementsQuery->where('pembimbing_id', $request->pembimbing_id);
        }

        // Filter by mitra
        if ($request->mitra_id) {
            $placementsQuery->where('mitra_industri_id', $request->mitra_id);
        }

        $placements = $placementsQuery->get();
        $siswaIds = $placements->pluck('profile_siswa_id');

        // Query jurnal
        $jurnalsQuery = JurnalHarian::whereIn('profile_siswa_id', $siswaIds)
            ->with(['siswa.user', 'siswa.jurusan', 'pembimbing'])
            ->whereMonth('tanggal', $tanggal->month)
            ->whereYear('tanggal', $tanggal->year);

        // Filter search
        if ($request->search) {
            $jurnalsQuery->where(function ($q) use ($request) {
                $q->where('judul', 'like', "%{$request->search}%")
                    ->orWhereHas('siswa.user', function ($q2) use ($request) {
                        $q2->where('name', 'like', "%{$request->search}%");
                    });
            });
        }

        // Filter status
        if ($request->status) {
            $jurnalsQuery->where('status', $request->status);
        }

        $jurnals = $jurnalsQuery->latest('tanggal')
            ->paginate(15)
            ->withQueryString();

        // Summary
        $allJurnals = JurnalHarian::whereIn('profile_siswa_id', $siswaIds)
            ->whereMonth('tanggal', $tanggal->month)
            ->whereYear('tanggal', $tanggal->year)
            ->get();

        $summary = [
            'total' => $allJurnals->count(),
            'pending' => $allJurnals->where('status', 'pending')->count(),
            'disetujui' => $allJurnals->where('status', 'disetujui')->count(),
            'revisi' => $allJurnals->where('status', 'revisi')->count(),
        ];

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/rekap-jurnal', [
            'jurnals' => $jurnals,
            'summary' => $summary,
            'bulan' => $bulan,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
                'pembimbing_id' => $request->pembimbing_id,
                'mitra_id' => $request->mitra_id,
                'bulan' => $bulan,
            ],
            'pembimbings' => $pembimbings,
            'mitras' => $mitras,
        ]);
    }
}
