<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Approval\PengajuanMasukSiswa;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use App\Models\Siswa\Izin;
use App\Models\User;
use App\Models\User\ProfileSiswa;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Inertia\Inertia;

class DashboardController extends Controller
{
    /**
     * Display the pendamping dashboard.
     */
    public function index()
    {
        // Summary counts
        $totalMitra = MitraIndustri::count();
        $totalSiswa = ProfileSiswa::count();
        $totalSupervisor = User::where('role', 'supervisors')->count();
        
        // Siswa yang belum memilih tempat PKL (belum ada di pkl_placements atau belum ada pengajuan)
        $siswaWithPlacement = PklPlacement::pluck('profile_siswa_id')->toArray();
        $siswaWithPengajuan = PengajuanMasukSiswa::pluck('profile_siswa_id')->toArray();
        $siswaBelumPKL = ProfileSiswa::whereNotIn('id', array_merge($siswaWithPlacement, $siswaWithPengajuan))->count();
        
        // Pengajuan PKL dengan status pending
        $pengajuanPending = PengajuanMasukSiswa::where('status', 'pending')->count();
        
        // Siswa sudah diterima (status PKL berjalan)
        $siswaDiterima = PklPlacement::where('status', 'berjalan')->count();

        // Pie chart: Absensi hari ini berdasarkan status
        $today = Carbon::today();
        $absensiToday = Absensi::whereDate('tanggal', $today)
            ->selectRaw('status_kehadiran, COUNT(*) as total')
            ->groupBy('status_kehadiran')
            ->pluck('total', 'status_kehadiran')
            ->toArray();

        $absensiChart = [
            'labels' => ['Hadir', 'Telat', 'Izin', 'Sakit', 'Alpha', 'Pending'],
            'data' => [
                $absensiToday['hadir'] ?? 0,
                $absensiToday['telat'] ?? 0,
                $absensiToday['izin'] ?? 0,
                $absensiToday['sakit'] ?? 0,
                $absensiToday['alpha'] ?? 0,
                $absensiToday['pending'] ?? 0,
            ],
            'colors' => ['#4CAF50', '#FF9800', '#00BCD4', '#9C27B0', '#F44336', '#9E9E9E'],
        ];

        // Izin terbaru (5 terakhir)
        $izinTerbaru = Izin::with(['siswa.user', 'siswa.jurusan', 'approver'])
            ->latest()
            ->take(5)
            ->get();

        return Inertia::render('pendamping/dashboard', [
            'summary' => [
                'total_mitra' => $totalMitra,
                'total_siswa' => $totalSiswa,
                'total_supervisor' => $totalSupervisor,
                'siswa_belum_pkl' => $siswaBelumPKL,
                'pengajuan_pending' => $pengajuanPending,
                'siswa_diterima' => $siswaDiterima,
            ],
            'absensiChart' => $absensiChart,
            'izinTerbaru' => $izinTerbaru,
        ]);
    }
}
