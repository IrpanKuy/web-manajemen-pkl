<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Izin;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;

class RekapIzinController extends Controller
{
    /**
     * Display leave/permission recap for pendamping.
     */
    public function index(Request $request)
    {
        // Get all active placements
        $placementsQuery = PklPlacement::where('status', 'berjalan');

        // Filter by pembimbing
        if ($request->pembimbing_id) {
            $placementsQuery->where('pembimbing_id', $request->pembimbing_id);
        }

        // Filter by mitra
        if ($request->mitra_id) {
            $placementsQuery->where('mitra_industri_id', $request->mitra_id);
        }

        $siswaIds = $placementsQuery->pluck('profile_siswa_id');

        // Query izin
        $izinsQuery = Izin::whereIn('profile_siswa_id', $siswaIds)
            ->with(['siswa.user', 'siswa.jurusan', 'approver', 'mitra']);

        // Filter search
        if ($request->search) {
            $izinsQuery->where(function ($q) use ($request) {
                $q->where('keterangan', 'like', "%{$request->search}%")
                    ->orWhereHas('siswa.user', function ($q2) use ($request) {
                        $q2->where('name', 'like', "%{$request->search}%");
                    });
            });
        }

        // Filter status
        if ($request->status) {
            $izinsQuery->where('status', $request->status);
        }

        $izins = $izinsQuery->latest()
            ->paginate(15)
            ->withQueryString();

        // Summary
        $allIzins = Izin::whereIn('profile_siswa_id', $siswaIds)->get();

        $summary = [
            'total' => $allIzins->count(),
            'pending' => $allIzins->where('status', 'pending')->count(),
            'approved' => $allIzins->where('status', 'approved')->count(),
            'rejected' => $allIzins->where('status', 'rejected')->count(),
        ];

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/rekap-izin', [
            'izins' => $izins,
            'summary' => $summary,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
                'pembimbing_id' => $request->pembimbing_id,
                'mitra_id' => $request->mitra_id,
            ],
            'pembimbings' => $pembimbings,
            'mitras' => $mitras,
        ]);
    }
}
