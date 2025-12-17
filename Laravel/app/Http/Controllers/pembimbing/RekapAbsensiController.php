<?php

namespace App\Http\Controllers\pembimbing;

use App\Http\Controllers\Controller;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class RekapAbsensiController extends Controller
{
    /**
     * Display monthly attendance recap for students under pembimbing.
     */
    public function index(Request $request)
    {
        $pembimbingId = Auth::id();
        $bulan = $request->bulan ?? Carbon::now()->format('Y-m');
        $tanggal = Carbon::parse($bulan);

        // Ambil siswa yang dibimbing melalui pkl_placements
        $placements = PklPlacement::where('pembimbing_id', $pembimbingId)
            ->where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'mitra'])
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

            // Hitung total hari kerja (berdasarkan absensi yang ada)
            $totalHari = array_sum($absensi);

            // Hitung persentase kehadiran (hadir + telat dianggap masuk)
            $hadir = ($absensi['hadir'] ?? 0) + ($absensi['telat'] ?? 0);
            $persentase = $totalHari > 0 ? round(($hadir / $totalHari) * 100, 1) : 0;

            return [
                'siswa' => [
                    'id' => $placement->siswa->id,
                    'name' => $placement->siswa->user->name,
                    'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                ],
                'mitra' => $placement->mitra->nama_mitra ?? '-',
                'rekap' => [
                    'hadir' => $absensi['hadir'] ?? 0,
                    'telat' => $absensi['telat'] ?? 0,
                    'izin' => $absensi['izin'] ?? 0,
                    'sakit' => $absensi['sakit'] ?? 0,
                    'alpha' => $absensi['alpha'] ?? 0,
                    'pending' => $absensi['pending'] ?? 0,
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

        return Inertia::render('pembimbing/rekapAbsensi', [
            'rekapAbsensi' => $rekapAbsensi,
            'summary' => $summary,
            'bulan' => $bulan,
        ]);
    }
}
