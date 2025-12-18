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

class LaporanHarianController extends Controller
{
    /**
     * Display daily attendance report.
     */
    public function index(Request $request)
    {
        $tanggal = $request->tanggal ?? Carbon::today()->format('Y-m-d');

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
                'id' => $placement->id,
                'siswa' => [
                    'id' => $placement->siswa->id,
                    'name' => $placement->siswa->user->name,
                    'nisn' => $placement->siswa->nisn,
                    'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                ],
                'mitra' => $placement->mitra->nama_mitra ?? '-',
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

        // Get filter options
        $pembimbings = User::where('role', 'pembimbing')->where('is_active', true)->get(['id', 'name']);
        $mitras = MitraIndustri::all(['id', 'nama_instansi']);

        return Inertia::render('pendamping/laporan/harian', [
            'dataHarian' => $dataHarian,
            'summary' => $summary,
            'tanggal' => $tanggal,
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
