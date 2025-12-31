<?php

namespace App\Exports;

use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Absensi;
use Illuminate\Support\Carbon;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class PendampingAbsensiBulananExport implements FromCollection, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
{
    protected $bulan;
    protected $mitraId;
    protected $pembimbingId;

    public function __construct(?string $bulan = null, $mitraId = null, $pembimbingId = null)
    {
        $this->bulan = $bulan ?? Carbon::now()->format('Y-m');
        $this->mitraId = $mitraId;
        $this->pembimbingId = $pembimbingId;
    }

    public function collection()
    {
        $tanggal = Carbon::parse($this->bulan);

        // Ambil semua siswa yang memiliki placement aktif
        $placementsQuery = PklPlacement::where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'mitra', 'pembimbing']);

        // Filter by pembimbing
        if ($this->pembimbingId) {
            $placementsQuery->where('pembimbing_id', $this->pembimbingId);
        }

        // Filter by mitra
        if ($this->mitraId) {
            $placementsQuery->where('mitra_industri_id', $this->mitraId);
        }

        $placements = $placementsQuery->get();

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
                'nisn' => $placement->siswa->nisn ?? '-',
                'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                'mitra' => $placement->mitra->nama_mitra ?? '-',
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
            'NISN',
            'Jurusan',
            'Mitra Industri',
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
