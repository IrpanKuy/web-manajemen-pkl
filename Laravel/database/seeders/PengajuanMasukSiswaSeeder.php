<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PengajuanMasukSiswaSeeder extends Seeder
{
    public function run(): void
    {
        $students = DB::table('profile_siswas')->get();
        $mitraIds = DB::table('mitra_industris')->pluck('id')->toArray();

        // ================================================================
        // SKENARIO PENGAJUAN:
        // Siswa 1-3: TIDAK ada pengajuan (belum memilih PKL)
        // Siswa 4-6: Pengajuan status 'pending'
        // Siswa 7-9: Pengajuan status 'ditolak'
        // Siswa 10-15: Pengajuan status 'diterima' (akan masuk PKL)
        // ================================================================

        foreach ($students as $index => $student) {
            $siswaNum = $index + 1;

            // Siswa 1-3: Skip (tidak buat pengajuan)
            if ($siswaNum <= 3) {
                continue;
            }

            // Tentukan status berdasarkan nomor siswa
            if ($siswaNum <= 6) {
                // Siswa 4-6: Pending
                $status = 'pending';
                $alasan = null;
                $mitraId = $mitraIds[($siswaNum - 4) % count($mitraIds)];
            } elseif ($siswaNum <= 9) {
                // Siswa 7-9: Ditolak
                $status = 'ditolak';
                $alasan = 'Kuota penuh untuk jurusan ini.';
                $mitraId = $mitraIds[($siswaNum - 7) % count($mitraIds)];
            } else {
                // Siswa 10-15: Diterima
                $status = 'diterima';
                $alasan = null;
                // Distribusi ke mitra berbeda
                $mitraId = $mitraIds[($siswaNum - 10) % count($mitraIds)];
            }

            DB::table('pengajuan_masuk_siswas')->insert([
                'profile_siswa_id' => $student->id,
                'mitra_industri_id' => $mitraId,
                'durasi' => 6,
                'cv_path' => "cv/siswa_{$student->id}.pdf",
                'deskripsi' => 'Saya sangat tertarik untuk magang di perusahaan ini karena sesuai dengan bidang keahlian saya.',
                'tgl_ajuan' => now()->subDays(rand(5, 20)),
                'status' => $status,
                'alasan_penolakan' => $alasan,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}