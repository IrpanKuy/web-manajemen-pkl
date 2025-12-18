<?php

namespace App\Http\Controllers\pembimbing;

use App\Http\Controllers\Controller;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class AbsensiHarianController extends Controller
{
    /**
     * Display daily attendance for students under pembimbing.
     * Default: today's date
     */
    public function index(Request $request)
    {
        $pembimbingId = Auth::id();
        $tanggal = $request->tanggal ?? Carbon::today()->format('Y-m-d');

        // Ambil siswa yang dibimbing melalui pkl_placements
        $placements = PklPlacement::where('pembimbing_id', $pembimbingId)
            ->where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'mitra'])
            ->get();

        // Ambil data absensi untuk tanggal yang dipilih
        $siswaIds = $placements->pluck('profile_siswa_id');

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
                'mitra' => $placement->mitra->nama_mitra ?? '-',
                'absensi' => $absensi ? [
                    'id' => $absensi->id,
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

        return Inertia::render('pembimbing/absensiHarian', [
            'dataHarian' => $dataHarian,
            'summary' => $summary,
            'tanggal' => $tanggal,
        ]);
    }
}
