<?php

namespace App\Http\Controllers\supervisor;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class DataSiswaPklController extends Controller
{
    /**
     * Display a listing of students in PKL at this mitra.
     */
    public function index(Request $request)
    {
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();

        if (!$mitra) {
            return Inertia::render('supervisors/data-siswa-pkl', [
                'placements' => [],
                'mitra' => null,
            ]);
        }

        $placements = PklPlacement::where('mitra_industri_id', $mitra->id)
            ->with([
                'siswa.user',
                'siswa.jurusan',
                'pembimbing'
            ])
            // Filter status
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

        return Inertia::render('supervisors/data-siswa-pkl', [
            'placements' => $placements,
            'mitra' => $mitra,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
            ],
        ]);
    }

    /**
     * Beri nilai untuk siswa yang PKL-nya sudah selesai.
     */
    public function beriNilai(Request $request, $id)
    {
        $request->validate([
            'nilai' => 'required|integer|min:0|max:100',
            'komentar_supervisor' => 'nullable|string|max:500',
        ]);

        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();

        if (!$mitra) {
            return back()->withErrors(['error' => 'Anda tidak memiliki akses ke mitra ini.']);
        }

        $placement = PklPlacement::where('id', $id)
            ->where('mitra_industri_id', $mitra->id)
            ->where('status', 'selesai')
            ->first();

        if (!$placement) {
            return back()->withErrors(['error' => 'Placement tidak ditemukan atau status bukan selesai.']);
        }

        $placement->update([
            'nilai' => $request->nilai,
            'komentar_supervisor' => $request->komentar_supervisor,
        ]);

        return back()->with('success', 'Nilai berhasil disimpan.');
    }
}
