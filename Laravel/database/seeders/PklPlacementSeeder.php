<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PklPlacementSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil pengajuan yang diterima
        $accepted = DB::table('pengajuan_masuk_siswas')->where('status', 'diterima')->get();
        $pembimbingIds = DB::table('users')->where('role', 'pembimbing')->pluck('id')->toArray();

        foreach ($accepted as $pengajuan) {
            DB::table('pkl_placements')->insert([
                'profile_siswa_id' => $pengajuan->profile_siswa_id,
                'mitra_industri_id' => $pengajuan->mitra_industri_id,
                'pembimbing_id' => $pembimbingIds[array_rand($pembimbingIds)],
                'tgl_mulai' => now()->startOfMonth(),
                'tgl_selesai' => now()->addMonths(6),
                'status' => 'berjalan',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}