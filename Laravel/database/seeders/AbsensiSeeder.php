<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AbsensiSeeder extends Seeder
{
    public function run(): void
    {
        // Hanya ambil placement yang berjalan
        $placements = DB::table('pkl_placements')->where('status', 'berjalan')->get();
        $today = Carbon::today();

        // ================================================================
        // SKENARIO ABSENSI:
        // - Generate absensi untuk 10 hari ke belakang
        // - Berbagai status: hadir, telat, izin, sakit
        // - Untuk hari ini: sebagian belum absen (untuk testing)
        // ================================================================

        $statusList = ['hadir', 'hadir', 'hadir', 'hadir', 'telat', 'izin', 'sakit'];

        foreach ($placements as $placementIndex => $placement) {
            // Generate absensi untuk 10 hari ke belakang
            for ($i = 0; $i <= 10; $i++) {
                $date = $today->copy()->subDays($i);

                // Skip weekend
                if ($date->isWeekend()) continue;

                // Status kehadiran bervariasi
                $status = $statusList[($i + $placementIndex) % count($statusList)];

                // Untuk hari ini: placement pertama belum absen (untuk testing absen masuk)
                if ($i === 0 && $placementIndex === 0) {
                    // Buat absensi kosong (belum absen masuk)
                    DB::table('absensis')->insert([
                        'profile_siswa_id' => $placement->profile_siswa_id,
                        'mitra_industri_id' => $placement->mitra_industri_id,
                        'tanggal' => $date->format('Y-m-d'),
                        'jam_masuk' => null,
                        'jam_pulang' => null,
                        'status_kehadiran' => 'pending',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                    continue;
                }

                // Untuk hari ini: placement kedua sudah absen masuk belum pulang
                if ($i === 0 && $placementIndex === 1) {
                    DB::table('absensis')->insert([
                        'profile_siswa_id' => $placement->profile_siswa_id,
                        'mitra_industri_id' => $placement->mitra_industri_id,
                        'tanggal' => $date->format('Y-m-d'),
                        'jam_masuk' => '08:05:00',
                        'jam_pulang' => null,
                        'status_kehadiran' => 'hadir',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                    continue;
                }

                // Hari-hari sebelumnya: full data
                $jamMasuk = in_array($status, ['izin', 'sakit']) ? null : ($status == 'telat' ? '08:20:00' : '07:50:00');
                $jamPulang = in_array($status, ['izin', 'sakit']) ? null : '17:05:00';

                DB::table('absensis')->insert([
                    'profile_siswa_id' => $placement->profile_siswa_id,
                    'mitra_industri_id' => $placement->mitra_industri_id,
                    'tanggal' => $date->format('Y-m-d'),
                    'jam_masuk' => $jamMasuk,
                    'jam_pulang' => $jamPulang,
                    'status_kehadiran' => $status,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}