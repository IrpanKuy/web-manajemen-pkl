<?php

namespace App\Exports;

use App\Models\Siswa\Absensi;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithTitle;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class AbsensiBulananExport implements FromQuery, WithHeadings, WithMapping, WithStyles, ShouldAutoSize, WithTitle
{
    protected $bulan;
    protected $mitraId;
    protected $siswaId;

    public function __construct($bulan = null, $mitraId = null, $siswaId = null)
    {
        $this->bulan = $bulan ?? date('Y-m');
        $this->mitraId = $mitraId;
        $this->siswaId = $siswaId;
    }

    public function query()
    {
        $query = Absensi::query()
            ->with(['siswa.user', 'siswa.jurusan', 'mitra'])
            ->whereYear('tanggal', substr($this->bulan, 0, 4))
            ->whereMonth('tanggal', substr($this->bulan, 5, 2));

        if ($this->mitraId) {
            $query->where('mitra_industri_id', $this->mitraId);
        }

        if ($this->siswaId) {
            $query->where('profile_siswa_id', $this->siswaId);
        }

        return $query->orderBy('tanggal')->orderBy('profile_siswa_id');
    }

    public function title(): string
    {
        return 'Absensi ' . $this->bulan;
    }

    public function headings(): array
    {
        return [
            'No',
            'Tanggal',
            'Nama Siswa',
            'NISN',
            'Jurusan',
            'Mitra Industri',
            'Jam Masuk',
            'Jam Pulang',
            'Status',
        ];
    }

    public function map($absensi): array
    {
        static $no = 0;
        $no++;

        return [
            $no,
            $absensi->tanggal ? date('d/m/Y', strtotime($absensi->tanggal)) : '-',
            $absensi->siswa?->user?->name ?? '-',
            $absensi->siswa?->nisn ?? '-',
            $absensi->siswa?->jurusan?->nama_jurusan ?? '-',
            $absensi->mitra?->nama_instansi ?? '-',
            $absensi->jam_masuk ?? '-',
            $absensi->jam_pulang ?? '-',
            ucfirst($absensi->status_kehadiran ?? 'pending'),
        ];
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
