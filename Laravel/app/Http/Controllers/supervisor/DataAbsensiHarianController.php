<?php

namespace App\Http\Controllers\supervisor;

use App\Exports\SupervisorAbsensiHarianExport;
use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Maatwebsite\Excel\Facades\Excel;

class DataAbsensiHarianController extends Controller
{
    /**
     * Display daily attendance for students at this mitra.
     */
    public function index(Request $request)
    {
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();
        $tanggal = $request->tanggal ?? Carbon::today()->format('Y-m-d');

        if (!$mitra) {
            return Inertia::render('supervisors/data-absensi-harian', [
                'dataHarian' => [],
                'summary' => [],
                'tanggal' => $tanggal,
            ]);
        }

        // Ambil siswa yang PKL di mitra ini
        $placements = PklPlacement::where('mitra_industri_id', $mitra->id)
            ->where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'pembimbing'])
            ->get();

        $siswaIds = $placements->pluck('profile_siswa_id');

        // Ambil data absensi untuk tanggal yang dipilih
        $absensiData = Absensi::whereIn('profile_siswa_id', $siswaIds)
            ->whereDate('tanggal', $tanggal)
            ->get()
            ->keyBy('profile_siswa_id');

        // Gabungkan data siswa dengan absensi
        $dataHarian = $placements->map(function ($placement) use ($absensiData) {
            $absensi = $absensiData->get($placement->profile_siswa_id);

            return [
                'siswa' => [
                    'id' => $placement->siswa->id,
                    'name' => $placement->siswa->user->name,
                    'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                ],
                'pembimbing' => $placement->pembimbing->name ?? '-',
                'absensi' => $absensi ? [
                    'jam_masuk' => $absensi->jam_masuk,
                    'jam_pulang' => $absensi->jam_pulang,
                    'status_kehadiran' => $absensi->status_kehadiran,
                ] : null,
            ];
        });

        // Hitung summary
        $summary = [
            'total_siswa' => $placements->count(),
            'hadir' => $absensiData->where('status_kehadiran', 'hadir')->count(),
            'telat' => $absensiData->where('status_kehadiran', 'telat')->count(),
            'izin' => $absensiData->where('status_kehadiran', 'izin')->count(),
            'sakit' => $absensiData->where('status_kehadiran', 'sakit')->count(),
            'alpha' => $absensiData->where('status_kehadiran', 'alpha')->count(),
            'belum_absen' => $placements->count() - $absensiData->count(),
        ];

        return Inertia::render('supervisors/data-absensi-harian', [
            'dataHarian' => $dataHarian,
            'summary' => $summary,
            'tanggal' => $tanggal,
        ]);
    }

    /**
     * Export absensi harian ke Excel
     */
    public function export(Request $request)
    {
        $tanggal = $request->tanggal ?? Carbon::today()->format('Y-m-d');
        $filename = 'absensi_harian_' . $tanggal . '.xlsx';

        return Excel::download(new SupervisorAbsensiHarianExport($tanggal), $filename);
    }
}

