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

class PendampingAbsensiHarianExport implements FromCollection, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
{
    protected $tanggal;
    protected $mitraId;
    protected $pembimbingId;

    public function __construct(?string $tanggal = null, $mitraId = null, $pembimbingId = null)
    {
        $this->tanggal = $tanggal ?? Carbon::today()->format('Y-m-d');
        $this->mitraId = $mitraId;
        $this->pembimbingId = $pembimbingId;
    }

    public function collection()
    {
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
        $siswaIds = $placements->pluck('profile_siswa_id');

        // Ambil data absensi untuk tanggal yang dipilih
        $absensiData = Absensi::whereIn('profile_siswa_id', $siswaIds)
            ->whereDate('tanggal', $this->tanggal)
            ->get()
            ->keyBy('profile_siswa_id');

        $data = [];
        $no = 1;

        foreach ($placements as $placement) {
            $absensi = $absensiData->get($placement->profile_siswa_id);

            $data[] = [
                'no' => $no++,
                'nama' => $placement->siswa->user->name ?? '-',
                'nisn' => $placement->siswa->nisn ?? '-',
                'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                'mitra' => $placement->mitra->nama_mitra ?? '-',
                'pembimbing' => $placement->pembimbing->name ?? '-',
                'jam_masuk' => $absensi?->jam_masuk ?? '-',
                'jam_pulang' => $absensi?->jam_pulang ?? '-',
                'status' => $absensi?->status_kehadiran ? ucfirst($absensi->status_kehadiran) : 'Belum Absen',
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
            'Jam Masuk',
            'Jam Pulang',
            'Status',
        ];
    }

    public function title(): string
    {
        return 'Absensi ' . Carbon::parse($this->tanggal)->format('d F Y');
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
