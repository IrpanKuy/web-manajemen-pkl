<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MitraIndustriSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Ambil SEMUA ID Supervisor yang baru dibuat
        // Urutkan biar rapi (spv1 dapet PT pertama, dst)
        $supervisorIds = DB::table('users')
                            ->where('role', 'supervisors')
                            ->orderBy('id')
                            ->pluck('id')
                            ->toArray();

        // 2. Ambil ID Guru Pendamping (Random aja, karena 1 guru bisa pegang banyak mitra)
        $pendampingIds = DB::table('users')
                            ->where('role', 'pendamping')
                            ->pluck('id')
                            ->toArray();

        // 3. Ambil Jurusan
        $allJurusanIds = DB::table('jurusans')->pluck('id')->toArray();

        // 4. Data Dummy Perusahaan (Siapkan 5 data sesuai jumlah supervisor)
        $companies = [
            ['PT. Telkom Indonesia', 'Telekomunikasi', 'Menyediakan layanan jaringan dan internet fiber optic.'],
            ['CV. Kreatif Digital', 'Software House', 'Fokus pada pembuatan aplikasi web dan mobile.'],
            ['PT. Gudang Garam Tbk', 'Manufaktur', 'Industri pengolahan tembakau dan distribusi.'],
            ['Dinas Kominfo Jatim', 'Pemerintahan', 'Layanan teknologi informasi untuk pemerintahan daerah.'],
            ['PT. Gojek Tokopedia', 'Teknologi', 'Platform on-demand services dan e-commerce terbesar.'],
        ];

        // 5. Loop Supervisor-nya
        foreach ($supervisorIds as $index => $spvId) {
            
            // Pastikan data company tersedia (jika supervisor lebih banyak dari data dummy)
            if (!isset($companies[$index])) break;

            $companyData = $companies[$index];

            DB::table('mitra_industris')->insert([
                // [KUNCI] Set ID Supervisor di sini. 
                // Karena kita loop $supervisorIds, 1 SPV pasti cuma punya 1 Mitra ini.
                'supervisors_id' => $spvId, 
                
                'pendamping_id' => $pendampingIds[array_rand($pendampingIds)],
                'nama_instansi' => $companyData[0],
                'bidang_usaha' => $companyData[1],
                'deskripsi' => $companyData[2],
                
                'tanggal_masuk' => now()->startOfYear(),
                'jam_masuk' => '08:00:00',
                'jam_pulang' => '16:00:00',
                'kuota' => rand(5, 15),
                'jurusan_ids' => json_encode($allJurusanIds), // Menerima semua jurusan
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}