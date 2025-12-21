<?php

namespace App\Exports;

use App\Models\User;
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class SiswaExport implements FromQuery, WithHeadings, WithMapping, WithStyles, ShouldAutoSize
{
    protected $search;
    protected $jurusanId;

    public function __construct($search = null, $jurusanId = null)
    {
        $this->search = $search;
        $this->jurusanId = $jurusanId;
    }

    public function query()
    {
        $query = User::query()
            ->where('role', 'siswa')
            ->with(['siswas.jurusan']);

        // Apply search filter
        if ($this->search) {
            $query->where(function ($q) {
                $q->where('name', 'ilike', '%' . $this->search . '%')
                  ->orWhere('email', 'ilike', '%' . $this->search . '%')
                  ->orWhereHas('siswas', function ($sq) {
                      $sq->where('nisn', 'ilike', '%' . $this->search . '%');
                  });
            });
        }

        // Apply jurusan filter
        if ($this->jurusanId) {
            $query->whereHas('siswas', function ($q) {
                $q->where('jurusan_id', $this->jurusanId);
            });
        }

        return $query->orderBy('name');
    }

    public function headings(): array
    {
        return [
            'No',
            'Nama',
            'Email',
            'No HP',
            'NISN',
            'Jurusan',
            'Status Akun',
        ];
    }

    public function map($user): array
    {
        static $no = 0;
        $no++;
        
        return [
            $no,
            $user->name,
            $user->email,
            $user->phone ?? '-',
            $user->siswas->nisn ?? '-',
            $user->siswas->jurusan->nama_jurusan ?? '-',
            $user->is_active ? 'Aktif' : 'Tidak Aktif',
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
