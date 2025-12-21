<?php

namespace App\Exports;

use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithTitle;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class SupervisorAbsensiBulananExport implements FromCollection, WithHeadings, WithStyles, WithTitle
{
    protected $bulan;
    protected $mitraId;

    public function __construct(?string $bulan = null)
    {
        $this->bulan = $bulan ?? Carbon::now()->format('Y-m');
        
        // Get mitra dari supervisor yang login
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();
        $this->mitraId = $mitra ? $mitra->id : null;
    }

    public function collection()
    {
        if (!$this->mitraId) {
            return collect([]);
        }

        $tanggal = Carbon::parse($this->bulan);
        
        // Ambil siswa yang PKL di mitra ini
        $placements = PklPlacement::where('mitra_industri_id', $this->mitraId)
            ->where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'pembimbing'])
            ->get();

        $data = [];
        $no = 1;

        foreach ($placements as $placement) {
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

            $data[] = [
                'no' => $no++,
                'nama' => $placement->siswa->user->name ?? '-',
                'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                'pembimbing' => $placement->pembimbing->name ?? '-',
                'hadir' => $absensi['hadir'] ?? 0,
                'telat' => $absensi['telat'] ?? 0,
                'izin' => $absensi['izin'] ?? 0,
                'sakit' => $absensi['sakit'] ?? 0,
                'alpha' => $absensi['alpha'] ?? 0,
                'total' => $totalHari,
                'persentase' => $persentase . '%',
            ];
        }

        return collect($data);
    }

    public function headings(): array
    {
        return [
            'No',
            'Nama Siswa',
            'Jurusan',
            'Pembimbing',
            'Hadir',
            'Telat',
            'Izin',
            'Sakit',
            'Alpha',
            'Total Hari',
            'Kehadiran %',
        ];
    }

    public function title(): string
    {
        return 'Rekap Absensi ' . Carbon::parse($this->bulan)->format('F Y');
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => [
                'font' => [
                    'bold' => true,
                    'color' => ['argb' => 'FFFFFFFF'],
                ],
                'fill' => [
                    'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                    'startColor' => ['argb' => 'FF4A60AA'],
                ],
            ],
        ];
    }
}
