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

        // Kita buat data pengajuan lebih banyak dari jumlah siswa (misal 1 siswa pernah ditolak lalu daftar lagi)
        $statuses = ['pending', 'diterima', 'ditolak'];

        foreach ($students as $index => $student) {
            // Skenario: 5 siswa pertama Diterima
            // 3 siswa berikutnya Ditolak
            // Sisanya Pending
            
            if ($index < 5) {
                $status = 'diterima';
                $alasan = null;
            } elseif ($index < 8) {
                $status = 'pending';
                $alasan = null;
            } else {
                $status = 'ditolak';
                $alasan = 'Kuota penuh untuk jurusan ini.';
            }

            DB::table('pengajuan_masuk_siswas')->insert([
                'profile_siswa_id' => $student->id,
                'mitra_industri_id' => $mitraIds[array_rand($mitraIds)],
                'durasi' => 6,
                'cv_path' => "cv/siswa_{$student->id}.pdf",
                'deskripsi' => 'Mohon izin untuk magang.',
                'tgl_ajuan' => now()->subDays(rand(1, 10)),
                'status' => $status,
                'alasan_penolakan' => $alasan,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}