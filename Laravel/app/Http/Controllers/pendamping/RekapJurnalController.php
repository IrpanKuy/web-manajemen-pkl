<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
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

        // Query jurnal langsung berdasarkan mitra_id yang ada di jurnal
        $jurnalsQuery = JurnalHarian::with(['siswa.user', 'siswa.jurusan', 'pembimbing', 'pendamping', 'mitra'])
            ->whereMonth('tanggal', $tanggal->month)
            ->whereYear('tanggal', $tanggal->year);

        // Filter by mitra (dari kolom mitra_industri_id di jurnal)
        if ($request->mitra_id) {
            $jurnalsQuery->where('mitra_industri_id', $request->mitra_id);
        }

        // Filter by pembimbing
        if ($request->pembimbing_id) {
            $jurnalsQuery->where('pembimbing_id', $request->pembimbing_id);
        }

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

        // Filter by komentar_pendamping
        if ($request->has_komentar !== null && $request->has_komentar !== '') {
            if ($request->has_komentar === '1' || $request->has_komentar === 'true') {
                $jurnalsQuery->whereNotNull('komentar_pendamping')->where('komentar_pendamping', '!=', '');
            } else {
                $jurnalsQuery->where(function($q) {
                    $q->whereNull('komentar_pendamping')->orWhere('komentar_pendamping', '');
                });
            }
        }

        $jurnals = $jurnalsQuery->latest('tanggal')
            ->paginate(15)
            ->withQueryString();

        // Summary - ambil semua jurnal untuk bulan ini
        $allJurnals = JurnalHarian::whereMonth('tanggal', $tanggal->month)
            ->whereYear('tanggal', $tanggal->year)
            ->get();

        $summary = [
            'total' => $allJurnals->count(),
            'pending' => $allJurnals->where('status', 'pending')->count(),
            'disetujui' => $allJurnals->where('status', 'disetujui')->count(),
            'revisi' => $allJurnals->where('status', 'revisi')->count(),
            'dengan_komentar' => $allJurnals->filter(function($j) { return !empty($j->komentar_pendamping); })->count(),
        ];

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        
        // Ambil mitra yang ada di jurnal bulan ini
        $mitraIds = JurnalHarian::whereMonth('tanggal', $tanggal->month)
            ->whereYear('tanggal', $tanggal->year)
            ->whereNotNull('mitra_industri_id')
            ->distinct()
            ->pluck('mitra_industri_id');
        $mitras = MitraIndustri::whereIn('id', $mitraIds)->get(['id', 'nama_instansi']);

        return Inertia::render('pendamping/rekap-jurnal', [
            'jurnals' => $jurnals,
            'summary' => $summary,
            'bulan' => $bulan,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
                'pembimbing_id' => $request->pembimbing_id,
                'mitra_id' => $request->mitra_id,
                'has_komentar' => $request->has_komentar,
                'bulan' => $bulan,
            ],
            'pembimbings' => $pembimbings,
            'mitras' => $mitras,
        ]);
    }

    /**
     * Beri komentar pada jurnal
     */
    public function beriKomentar(Request $request, $id)
    {
        $request->validate([
            'komentar_pendamping' => 'required|string|max:1000',
        ]);

        $jurnal = JurnalHarian::findOrFail($id);

        $jurnal->update([
            'komentar_pendamping' => $request->komentar_pendamping,
            'pendamping_id' => Auth::id(),
        ]);

        return redirect()->back()->with('success', 'Komentar berhasil ditambahkan!');
    }
}

