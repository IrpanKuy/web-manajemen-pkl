<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PklPlacementSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil pengajuan yang diterima
        $accepted = DB::table('pengajuan_masuk_siswas')->where('status', 'diterima')->get();
        $pembimbingIds = DB::table('users')->where('role', 'pembimbing')->pluck('id')->toArray();
        
        $today = Carbon::today();

        // ================================================================
        // SKENARIO PKL PLACEMENT:
        // Dari siswa yang diterima (Siswa 10-15):
        // - Siswa 10-12: Status 'pending' (PKL mulai minggu depan)
        // - Siswa 13-14: Status 'berjalan' (PKL sudah mulai)
        // - Siswa 15: Status 'selesai' (PKL sudah selesai dengan nilai)
        // ================================================================

        foreach ($accepted as $index => $pengajuan) {
            $orderNum = $index + 1; // 1-6

            if ($orderNum <= 3) {
                // Siswa 10-12: PKL Pending (mulai 5 hari lagi)
                $status = 'pending';
                $tglMulai = $today->copy()->addDays(5);
                $tglSelesai = $today->copy()->addDays(5)->addMonths(6);
                $nilai = null;
                $komentar = null;
            } elseif ($orderNum <= 5) {
                // Siswa 13-14: PKL Berjalan (mulai 1 bulan lalu)
                $status = 'berjalan';
                $tglMulai = $today->copy()->subMonth();
                $tglSelesai = $today->copy()->addMonths(5);
                $nilai = null;
                $komentar = null;
            } else {
                // Siswa 15: PKL Selesai (dengan nilai)
                $status = 'selesai';
                $tglMulai = $today->copy()->subMonths(7);
                $tglSelesai = $today->copy()->subMonth();
                $nilai = 87;
                $komentar = 'Siswa sangat disiplin dan memiliki kemampuan teknis yang baik. Dapat bekerja sama dengan tim.';
            }

            // Pilih pembimbing dari mitra yang sama
            $mitraPembimbings = DB::table('profile_pembimbings')
                ->where('mitra_industri_id', $pengajuan->mitra_industri_id)
                ->pluck('user_id')
                ->toArray();

            $pembimbingId = !empty($mitraPembimbings) 
                ? $mitraPembimbings[array_rand($mitraPembimbings)] 
                : $pembimbingIds[array_rand($pembimbingIds)];

            DB::table('pkl_placements')->insert([
                'profile_siswa_id' => $pengajuan->profile_siswa_id,
                'mitra_industri_id' => $pengajuan->mitra_industri_id,
                'pembimbing_id' => $pembimbingId,
                'tgl_mulai' => $tglMulai->format('Y-m-d'),
                'tgl_selesai' => $tglSelesai->format('Y-m-d'),
                'nilai' => $nilai,
                'komentar_supervisor' => $komentar,
                'status' => $status,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}