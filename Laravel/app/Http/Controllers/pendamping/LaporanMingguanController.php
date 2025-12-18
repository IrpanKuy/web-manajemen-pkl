<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Inertia\Inertia;

class LaporanMingguanController extends Controller
{
    /**
     * Display weekly attendance report.
     */
    public function index(Request $request)
    {
        // Default: minggu ini
        $tanggalMulai = $request->tanggal_mulai 
            ?? Carbon::now()->startOfWeek()->format('Y-m-d');
        $tanggalSelesai = $request->tanggal_selesai 
            ?? Carbon::now()->endOfWeek()->format('Y-m-d');

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

        // Untuk setiap siswa, hitung rekap absensi mingguan
        $dataMingguan = $placements->map(function ($placement) use ($tanggalMulai, $tanggalSelesai) {
            $siswaId = $placement->profile_siswa_id;

            // Query absensi per status
            $absensi = Absensi::where('profile_siswa_id', $siswaId)
                ->whereBetween('tanggal', [$tanggalMulai, $tanggalSelesai])
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
            'total_hadir' => $dataMingguan->sum('rekap.hadir'),
            'total_telat' => $dataMingguan->sum('rekap.telat'),
            'total_izin' => $dataMingguan->sum('rekap.izin'),
            'total_sakit' => $dataMingguan->sum('rekap.sakit'),
            'total_alpha' => $dataMingguan->sum('rekap.alpha'),
        ];

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/laporan/mingguan', [
            'dataMingguan' => $dataMingguan,
            'summary' => $summary,
            'tanggalMulai' => $tanggalMulai,
            'tanggalSelesai' => $tanggalSelesai,
            'filters' => [
                'search' => $request->search,
                'pembimbing_id' => $request->pembimbing_id,
                'mitra_id' => $request->mitra_id,
            ],
            'pembimbings' => $pembimbings,
            'mitras' => $mitras,
        ]);
    }
}
