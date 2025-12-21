<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MitraIndustriSeeder extends Seeder
{
    public function run(): void
    {
        $supervisorIds = DB::table('users')
            ->where('role', 'supervisors')
            ->orderBy('id')
            ->pluck('id')
            ->toArray();

        $pendampingIds = DB::table('users')
            ->where('role', 'pendamping')
            ->pluck('id')
            ->toArray();

        $allJurusanIds = DB::table('jurusans')->pluck('id')->toArray();

        // Data Mitra dengan koordinat Jakarta area
        $companies = [
            [
                'nama' => 'PT. Telkom Indonesia',
                'bidang' => 'Telekomunikasi',
                'deskripsi' => 'Perusahaan telekomunikasi terbesar di Indonesia yang menyediakan layanan jaringan, internet fiber optic, dan layanan digital.',
                'jam_masuk' => '08:00:00',
                'jam_pulang' => '17:00:00',
                'kuota' => 10,
            ],
            [
                'nama' => 'CV. Kreatif Digital',
                'bidang' => 'Software House',
                'deskripsi' => 'Software house yang fokus pada pembuatan aplikasi web, mobile, dan solusi digital untuk berbagai industri.',
                'jam_masuk' => '09:00:00',
                'jam_pulang' => '18:00:00',
                'kuota' => 5,
            ],
            [
                'nama' => 'PT. Bank Central Asia',
                'bidang' => 'Perbankan',
                'deskripsi' => 'Bank swasta terbesar di Indonesia dengan layanan perbankan digital yang inovatif.',
                'jam_masuk' => '08:00:00',
                'jam_pulang' => '16:00:00',
                'kuota' => 8,
            ],
            [
                'nama' => 'Dinas Kominfo DKI Jakarta',
                'bidang' => 'Pemerintahan',
                'deskripsi' => 'Layanan teknologi informasi dan komunikasi untuk pemerintahan daerah DKI Jakarta.',
                'jam_masuk' => '07:30:00',
                'jam_pulang' => '16:00:00',
                'kuota' => 6,
            ],
            [
                'nama' => 'PT. GoTo Gojek Tokopedia',
                'bidang' => 'Teknologi',
                'deskripsi' => 'Platform teknologi terbesar di Indonesia yang menyediakan layanan on-demand dan e-commerce.',
                'jam_masuk' => '10:00:00',
                'jam_pulang' => '19:00:00',
                'kuota' => 15,
            ],
        ];

        foreach ($supervisorIds as $index => $spvId) {
            if (!isset($companies[$index])) break;

            $company = $companies[$index];

            DB::table('mitra_industris')->insert([
                'supervisors_id' => $spvId,
                'pendamping_id' => $pendampingIds[$index % count($pendampingIds)],
                'nama_instansi' => $company['nama'],
                'bidang_usaha' => $company['bidang'],
                'deskripsi' => $company['deskripsi'],
                'tanggal_masuk' => now()->startOfYear(),
                'jam_masuk' => $company['jam_masuk'],
                'jam_pulang' => $company['jam_pulang'],
                'kuota' => $company['kuota'],
                'jurusan_ids' => json_encode($allJurusanIds),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}