<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class JurnalHarianSeeder extends Seeder
{
    public function run(): void
    {
        $placements = DB::table('pkl_placements')->get();

        for ($i = 0; $i < 5; $i++) {
            $date = Carbon::now()->subDays($i);
            if ($date->isWeekend()) continue;

            foreach ($placements as $placement) {
                // Pastikan placement punya pembimbing
                if(!$placement->pembimbing_id) continue;

                DB::table('jurnal_harians')->insert([
                    'profile_siswa_id' => $placement->profile_siswa_id,
                    'pembimbing_id' => $placement->pembimbing_id,
                    'tanggal' => $date->format('Y-m-d'),
                    'judul' => 'Kegiatan Harian ' . $date->format('d/m'),
                    'deskripsi' => 'Melakukan maintenance server dan update aplikasi.',
                    'foto_kegiatan' => null,
                    'status' => rand(0, 1) ? 'disetujui' : 'pending',
                    'komentar' => 'Laporan diterima.',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}