<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class IzinSeeder extends Seeder
{
    public function run(): void
    {
        $placements = DB::table('pkl_placements')->get();
        $pendamping = DB::table('users')->where('role', 'pendamping')->first();

        // Ambil 5 penempatan secara acak untuk diberi izin
        $targets = $placements->take(5);

        foreach ($targets as $placement) {
            DB::table('izins')->insert([
                'profile_siswa_id' => $placement->profile_siswa_id,
                'mitra_industri_id' => $placement->mitra_industri_id,
                'durasi_hari' => rand(1, 3),
                'keterangan' => 'Sakit / Keperluan Keluarga',
                'bukti_path' => 'izin/dokumen_sakit.jpg',
                'status' => 'approved',
                'approved_by' => $pendamping->id,
                'created_at' => now()->subDays(rand(10, 30)),
                'updated_at' => now(),
            ]);
        }
    }
}