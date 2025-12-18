<?php

namespace App\Http\Controllers\pembimbing;

use App\Http\Controllers\Controller;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class SiswaBimbinganController extends Controller
{
    /**
     * Display a listing of students under pembimbing's guidance.
     */
    public function index(Request $request)
    {
        $pembimbingId = Auth::id();

        // Ambil siswa yang dibimbing melalui pkl_placements
        $placements = PklPlacement::where('pembimbing_id', $pembimbingId)
            ->with([
                'siswa.user',
                'siswa.jurusan',
                'mitra'
            ])
            // Filter berdasarkan status placement
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            // Filter pencarian
            ->when($request->search, function ($query, $search) {
                $query->whereHas('siswa.user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->paginate(10)
            ->withQueryString();

        // Hitung summary
        $allPlacements = PklPlacement::where('pembimbing_id', $pembimbingId)->get();
        $summary = [
            'total' => $allPlacements->count(),
            'berjalan' => $allPlacements->where('status', 'berjalan')->count(),
            'selesai' => $allPlacements->where('status', 'selesai')->count(),
            'pending' => $allPlacements->where('status', 'pending')->count(),
        ];

        return Inertia::render('pembimbing/siswaBimbingan', [
            'placements' => $placements,
            'summary' => $summary,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
            ],
        ]);
    }

    /**
     * Display the specified student details.
     */
    public function show($id)
    {
        $pembimbingId = Auth::id();

        $placement = PklPlacement::where('pembimbing_id', $pembimbingId)
            ->where('id', $id)
            ->with([
                'siswa.user',
                'siswa.jurusan',
                'mitra.alamat',
            ])
            ->firstOrFail();

        return Inertia::render('pembimbing/detailSiswa', [
            'placement' => $placement,
        ]);
    }
}
