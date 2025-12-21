<?php

namespace App\Http\Controllers\supervisor;

use App\Exports\SupervisorAbsensiBulananExport;
use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Maatwebsite\Excel\Facades\Excel;

class DataAbsensiBulananController extends Controller
{
    /**
     * Display monthly attendance recap for students at this mitra.
     */
    public function index(Request $request)
    {
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();
        $bulan = $request->bulan ?? Carbon::now()->format('Y-m');
        $tanggal = Carbon::parse($bulan);

        if (!$mitra) {
            return Inertia::render('supervisors/data-absensi-bulanan', [
                'rekapAbsensi' => [],
                'summary' => [],
                'bulan' => $bulan,
            ]);
        }

        // Ambil siswa yang PKL di mitra ini
        $placements = PklPlacement::where('mitra_industri_id', $mitra->id)
            ->where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'pembimbing'])
            ->get();

        // Untuk setiap siswa, hitung rekap absensi bulanan
        $rekapAbsensi = $placements->map(function ($placement) use ($tanggal) {
            $siswaId = $placement->profile_siswa_id;

            // Query absensi per status
            $absensi = Absensi::where('profile_siswa_id', $siswaId)
                ->whereMonth('tanggal', $tanggal->month)
                ->whereYear('tanggal', $tanggal->year)
                ->selectRaw('status_kehadiran, COUNT(*) as total')
                ->groupBy('status_kehadiran')
                ->pluck('total', 'status_kehadiran')
                ->toArray();

            // Hitung total hari kerja
            $totalHari = array_sum($absensi);

            // Hitung persentase kehadiran
            $hadir = ($absensi['hadir'] ?? 0) + ($absensi['telat'] ?? 0);
            $persentase = $totalHari > 0 ? round(($hadir / $totalHari) * 100, 1) : 0;

            return [
                'siswa' => [
                    'id' => $placement->siswa->id,
                    'name' => $placement->siswa->user->name,
                    'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                ],
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
            'total_hadir' => $rekapAbsensi->sum('rekap.hadir'),
            'total_telat' => $rekapAbsensi->sum('rekap.telat'),
            'total_izin' => $rekapAbsensi->sum('rekap.izin'),
            'total_sakit' => $rekapAbsensi->sum('rekap.sakit'),
            'total_alpha' => $rekapAbsensi->sum('rekap.alpha'),
        ];

        return Inertia::render('supervisors/data-absensi-bulanan', [
            'rekapAbsensi' => $rekapAbsensi,
            'summary' => $summary,
            'bulan' => $bulan,
        ]);
    }

    /**
     * Export rekap absensi bulanan ke Excel
     */
    public function export(Request $request)
    {
        $bulan = $request->bulan ?? Carbon::now()->format('Y-m');
        $filename = 'rekap_absensi_' . $bulan . '.xlsx';

        return Excel::download(new SupervisorAbsensiBulananExport($bulan), $filename);
    }
}

