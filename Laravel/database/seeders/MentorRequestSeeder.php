<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MentorRequestSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil placement yang berjalan
        $placements = DB::table('pkl_placements')
            ->where('status', 'berjalan')
            ->get();

        // ================================================================
        // SKENARIO MENTOR REQUEST:
        // Status valid: pending, disetujui, ditolak
        // - 1 request pending (untuk testing persetujuan)
        // - 1 request disetujui (contoh yang sudah disetujui)
        // - 1 request ditolak (contoh yang ditolak)
        // ================================================================

        $alasanList = [
            'Ingin fokus ke bidang backend development, pembimbing saat ini lebih ahli di frontend.',
            'Jadwal pembimbing saat ini sulit untuk konsultasi karena sering meeting.',
            'Pembimbing baru memiliki expertise yang lebih sesuai dengan project saya.',
        ];

        $statusList = ['pending', 'disetujui', 'ditolak'];

        foreach ($placements->take(3) as $index => $placement) {
            // Cari pembimbing lain di mitra yang sama
            $pembimbingLainIds = DB::table('profile_pembimbings')
                ->where('mitra_industri_id', $placement->mitra_industri_id)
                ->where('user_id', '!=', $placement->pembimbing_id)
                ->pluck('user_id')
                ->toArray();

            // Jika tidak ada pembimbing lain, skip
            if (empty($pembimbingLainIds)) continue;

            $pembimbingBaruId = $pembimbingLainIds[array_rand($pembimbingLainIds)];

            DB::table('mentor_requests')->insert([
                'profile_siswa_id' => $placement->profile_siswa_id,
                'pembimbing_lama_id' => $placement->pembimbing_id,
                'pembimbing_baru_id' => $pembimbingBaruId,
                'alasan' => $alasanList[$index % count($alasanList)],
                'status' => $statusList[$index % count($statusList)],
                'created_at' => now()->subDays(rand(1, 5)),
                'updated_at' => now(),
            ]);
        }
    }
}