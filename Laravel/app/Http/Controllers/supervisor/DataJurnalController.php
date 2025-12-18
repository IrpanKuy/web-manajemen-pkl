<?php

namespace App\Http\Controllers\supervisor;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class DataJurnalController extends Controller
{
    /**
     * Display a listing of student journals at this mitra (monthly).
     */
    public function index(Request $request)
    {
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();
        $bulan = $request->bulan ?? Carbon::now()->format('Y-m');
        $tanggal = Carbon::parse($bulan);

        if (!$mitra) {
            return Inertia::render('supervisors/data-jurnal', [
                'jurnals' => [],
                'bulan' => $bulan,
            ]);
        }

        // Ambil siswa yang PKL di mitra ini
        $siswaIds = PklPlacement::where('mitra_industri_id', $mitra->id)
            ->where('status', 'berjalan')
            ->pluck('profile_siswa_id');

        $jurnals = JurnalHarian::whereIn('profile_siswa_id', $siswaIds)
            ->with(['siswa.user', 'siswa.jurusan', 'pembimbing'])
            ->whereMonth('tanggal', $tanggal->month)
            ->whereYear('tanggal', $tanggal->year)
            // Filter pencarian
            ->when($request->search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('judul', 'like', "%{$search}%")
                        ->orWhereHas('siswa.user', function ($q2) use ($search) {
                            $q2->where('name', 'like', "%{$search}%");
                        });
                });
            })
            // Filter status
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            ->latest('tanggal')
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('supervisors/data-jurnal', [
            'jurnals' => $jurnals,
            'bulan' => $bulan,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
                'bulan' => $bulan,
            ],
        ]);
    }
}
