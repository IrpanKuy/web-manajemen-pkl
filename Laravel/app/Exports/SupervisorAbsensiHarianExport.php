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

class SupervisorAbsensiHarianExport implements FromCollection, WithHeadings, WithStyles, WithTitle
{
    protected $tanggal;
    protected $mitraId;

    public function __construct(?string $tanggal = null)
    {
        $this->tanggal = $tanggal ?? Carbon::today()->format('Y-m-d');
        
        // Get mitra dari supervisor yang login
        $mitra = MitraIndustri::where('supervisors_id', Auth::id())->first();
        $this->mitraId = $mitra ? $mitra->id : null;
    }

    public function collection()
    {
        if (!$this->mitraId) {
            return collect([]);
        }

        // Ambil siswa yang PKL di mitra ini
        $placements = PklPlacement::where('mitra_industri_id', $this->mitraId)
            ->where('status', 'berjalan')
            ->with(['siswa.user', 'siswa.jurusan', 'pembimbing'])
            ->get();

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
                'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                'pembimbing' => $placement->pembimbing->name ?? '-',
                'jam_masuk' => $absensi?->jam_masuk ?? '-',
                'jam_pulang' => $absensi?->jam_pulang ?? '-',
                'status' => $absensi?->status_kehadiran ?? 'Belum Absen',
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
