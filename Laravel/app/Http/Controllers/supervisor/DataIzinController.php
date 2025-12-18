<?php

namespace App\Http\Controllers\supervisor;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Izin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class DataIzinController extends Controller
{
    /**
     * Display a listing of leave requests from students at this mitra.
     */
    public function index(Request $request)
    {
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();

        if (!$mitra) {
            return Inertia::render('supervisors/data-izin', [
                'izins' => [],
            ]);
        }

        $izins = Izin::where('mitra_industri_id', $mitra->id)
            ->with(['siswa.user', 'siswa.jurusan', 'approver'])
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

        return Inertia::render('supervisors/data-izin', [
            'izins' => $izins,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
            ],
        ]);
    }
}
