<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use App\Models\User;
use App\Exports\AbsensiBulananExport;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Inertia\Inertia;
use Maatwebsite\Excel\Facades\Excel;

class LaporanBulananController extends Controller
{
    /**
     * Display monthly attendance report.
     */
    public function index(Request $request)
    {
        $bulan = $request->bulan ?? Carbon::now()->format('Y-m');
        $tanggal = Carbon::parse($bulan);

        // Ambil semua siswa yang memiliki placement aktif
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

        // Filter search
        if ($request->search) {
            $placementsQuery->whereHas('siswa.user', function ($q) use ($request) {
                $q->where('name', 'like', "%{$request->search}%");
            });
        }

        $placements = $placementsQuery->get();

        // Untuk setiap siswa, hitung rekap absensi bulanan
        $dataBulanan = $placements->map(function ($placement) use ($tanggal) {
            $siswaId = $placement->profile_siswa_id;

            // Query absensi per status
            $absensi = Absensi::where('profile_siswa_id', $siswaId)
                ->whereMonth('tanggal', $tanggal->month)
                ->whereYear('tanggal', $tanggal->year)
                ->selectRaw('status_kehadiran, COUNT(*) as total')
                ->groupBy('status_kehadiran')
                ->pluck('total', 'status_kehadiran')
                ->toArray();

            $totalHari = array_sum($absensi);
            $hadir = ($absensi['hadir'] ?? 0) + ($absensi['telat'] ?? 0);
            $persentase = $totalHari > 0 ? round(($hadir / $totalHari) * 100, 1) : 0;

            return [
                'id' => $placement->id,
                'siswa' => [
                    'id' => $placement->siswa->id,
                    'name' => $placement->siswa->user->name,
                    'nisn' => $placement->siswa->nisn,
                    'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                ],
                'mitra' => $placement->mitra->nama_mitra ?? '-',
                'pembimbing' => $placement->pembimbing->name ?? '-',
                'rekap' => [
                    'hadir' => $absensi['hadir'] ?? 0,
                    'telat' => $absensi['telat'] ?? 0,
                    'izin' => $absensi['izin'] ?? 0,
                    'sakit' => $absensi['sakit'] ?? 0,
                    'alpha' => $absensi['alpha'] ?? 0,
                ],
                'total_hari' => $totalHari,
                'persentase_kehadiran' => $persentase,
            ];
        });

        // Hitung summary keseluruhan
        $summary = [
            'total_siswa' => $placements->count(),
            'total_hadir' => $dataBulanan->sum('rekap.hadir'),
            'total_telat' => $dataBulanan->sum('rekap.telat'),
            'total_izin' => $dataBulanan->sum('rekap.izin'),
            'total_sakit' => $dataBulanan->sum('rekap.sakit'),
            'total_alpha' => $dataBulanan->sum('rekap.alpha'),
        ];

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/laporan/bulanan', [
            'dataBulanan' => $dataBulanan,
            'summary' => $summary,
            'bulan' => $bulan,
            'filters' => [
                'search' => $request->search,
                'pembimbing_id' => $request->pembimbing_id,
                'mitra_id' => $request->mitra_id,
            ],
            'pembimbings' => $pembimbings,
            'mitras' => $mitras,
        ]);
    }

    /**
     * Export monthly attendance report to Excel
     */
    public function export(Request $request)
    {
        $bulan = $request->get('bulan', date('Y-m'));
        $mitraId = $request->get('mitra_id');
        
        $filename = 'laporan-absensi-bulanan-' . $bulan . '.xlsx';
        
        return Excel::download(new AbsensiBulananExport($bulan, $mitraId), $filename);
    }
}

