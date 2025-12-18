<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;

class PenempatanSiswaController extends Controller
{
    /**
     * Display a listing of student placements.
     */
    public function index(Request $request)
    {
        $placementsQuery = PklPlacement::with([
            'siswa.user',
            'siswa.jurusan',
            'mitra',
            'pembimbing'
        ]);

        // Filter by search
        if ($request->search) {
            $placementsQuery->where(function ($q) use ($request) {
                $q->whereHas('siswa.user', function ($q2) use ($request) {
                    $q2->where('name', 'like', "%{$request->search}%");
                })->orWhereHas('mitra', function ($q2) use ($request) {
                    $q2->where('nama_instansi', 'like', "%{$request->search}%");
                });
            });
        }

        // Filter by status
        if ($request->status) {
            $placementsQuery->where('status', $request->status);
        }

        // Filter by pembimbing
        if ($request->pembimbing_id) {
            $placementsQuery->where('pembimbing_id', $request->pembimbing_id);
        }

        // Filter by mitra
        if ($request->mitra_id) {
            $placementsQuery->where('mitra_industri_id', $request->mitra_id);
        }

        $placements = $placementsQuery->latest()
            ->paginate(15)
            ->withQueryString();

        // Summary
        $allPlacements = PklPlacement::all();
        $summary = [
            'total' => $allPlacements->count(),
            'pending' => $allPlacements->where('status', 'pending')->count(),
            'berjalan' => $allPlacements->where('status', 'berjalan')->count(),
            'selesai' => $allPlacements->where('status', 'selesai')->count(),
        ];

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/penempatan-siswa/index', [
            'placements' => $placements,
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

    /**
     * Display the specified placement.
     */
    public function show($id)
    {
        $placement = PklPlacement::with([
            'siswa.user',
            'siswa.jurusan',
            'mitra.supervisor',
            'mitra.alamat',
            'pembimbing'
        ])->findOrFail($id);

        return Inertia::render('pendamping/penempatan-siswa/show', [
            'placement' => $placement,
        ]);
    }
}
