<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('password');
        $users = [];

        // ================================================================
        // SISWA (15 Total - Berbagai Skenario)
        // ================================================================
        // Siswa 1-3: Belum memilih tempat PKL (tidak ada pengajuan)
        // Siswa 4-6: Sudah mengajukan tapi pending
        // Siswa 7-9: Pengajuan ditolak
        // Siswa 10-12: PKL status pending (menunggu tanggal mulai)
        // Siswa 13-14: PKL status berjalan
        // Siswa 15: PKL status selesai (dengan nilai)
        
        $siswaNama = [
            'Ahmad Rizki',      // 1 - belum pkl
            'Budi Santoso',     // 2 - belum pkl
            'Citra Dewi',       // 3 - belum pkl
            'Dani Pratama',     // 4 - pengajuan pending
            'Eka Putri',        // 5 - pengajuan pending
            'Fajar Rahman',     // 6 - pengajuan pending
            'Gita Nirmala',     // 7 - ditolak
            'Hendra Wijaya',    // 8 - ditolak
            'Indah Sari',       // 9 - ditolak
            'Joko Susilo',      // 10 - pkl pending
            'Kartini Wulan',    // 11 - pkl pending
            'Lukman Hakim',     // 12 - pkl pending
            'Maya Anggraini',   // 13 - pkl berjalan
            'Nanda Kusuma',     // 14 - pkl berjalan
            'Oscar Prasetyo',   // 15 - pkl selesai
        ];

        foreach ($siswaNama as $i => $nama) {
            $idx = $i + 1;
            $users[] = [
                'name' => $nama,
                'email' => "siswa{$idx}@sekolah.com",
                'password' => $password,
                'role' => 'siswa',
                'phone' => "08120000" . str_pad($idx, 3, '0', STR_PAD_LEFT),
                'is_active' => true,
                'is_admin' => false,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // ================================================================
        // PEMBIMBING INDUSTRI (8 Total)
        // ================================================================
        $pembimbingNama = [
            'Ir. Suharto',
            'Dr. Bambang',
            'Hj. Aminah',
            'Drs. Suparman',
            'Ibu Maria',
            'Pak Rahman',
            'Bu Siti',
            'Pak Jaya',
        ];

        foreach ($pembimbingNama as $i => $nama) {
            $idx = $i + 1;
            $users[] = [
                'name' => $nama,
                'email' => "mentor{$idx}@industri.com",
                'password' => $password,
                'role' => 'pembimbing',
                'phone' => "08130000" . str_pad($idx, 3, '0', STR_PAD_LEFT),
                'is_active' => true,
                'is_admin' => false,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // ================================================================
        // GURU PENDAMPING (3 Total)
        // ================================================================
        $guruNama = [
            ['Pak Agus Widodo', true],   // Admin
            ['Bu Lina Marlina', false],
            ['Pak Budi Raharjo', false],
        ];

        foreach ($guruNama as $i => $data) {
            $idx = $i + 1;
            $users[] = [
                'name' => $data[0],
                'email' => "guru{$idx}@sekolah.com",
                'password' => $password,
                'role' => 'pendamping',
                'phone' => "08140000" . str_pad($idx, 3, '0', STR_PAD_LEFT),
                'is_active' => true,
                'is_admin' => $data[1],
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        // ================================================================
        // SUPERVISOR MITRA (5 Total)
        // ================================================================
        $supervisorNama = [
            'HRD Telkom',
            'Manager Kreatif Digital',
            'Kepala SDM Gudang Garam',
            'Kadis Kominfo',
            'HR GoTo',
        ];

        foreach ($supervisorNama as $i => $nama) {
            $idx = $i + 1;
            $users[] = [
                'name' => $nama,
                'email' => "spv{$idx}@mitra.com",
                'password' => $password,
                'role' => 'supervisors',
                'phone' => "08150000" . str_pad($idx, 3, '0', STR_PAD_LEFT),
                'is_active' => true,
                'is_admin' => false,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }

        DB::table('users')->insert($users);
    }
}