<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class IzinSeeder extends Seeder
{
    public function run(): void
    {
        $placements = DB::table('pkl_placements')
            ->whereIn('status', ['berjalan', 'selesai'])
            ->get();
        
        $pendamping = DB::table('users')->where('role', 'pendamping')->first();

        // ================================================================
        // SKENARIO IZIN:
        // - Berbagai status: pending, approved, rejected
        // - Berbagai jenis: sakit, izin keluarga, etc
        // ================================================================

        $keteranganList = [
            ['Sakit demam dan flu', 'izin/surat_dokter.jpg'],
            ['Keperluan keluarga mendesak', 'izin/surat_orang_tua.jpg'],
            ['Menghadiri acara keluarga', 'izin/bukti_undangan.jpg'],
            ['Kontrol kesehatan rutin', 'izin/surat_rs.jpg'],
            ['Mengurus dokumen penting', null],
        ];

        $statusList = ['pending', 'approved', 'approved', 'rejected'];

        foreach ($placements->take(4) as $index => $placement) {
            $ket = $keteranganList[$index % count($keteranganList)];
            $status = $statusList[$index % count($statusList)];

            $tglMulai = Carbon::now()->subDays(rand(5, 20));
            $durasi = rand(1, 3);
            $tglSelesai = $tglMulai->copy()->addDays($durasi - 1);

            DB::table('izins')->insert([
                'profile_siswa_id' => $placement->profile_siswa_id,
                'mitra_industri_id' => $placement->mitra_industri_id,
                'tgl_mulai' => $tglMulai->format('Y-m-d'),
                'tgl_selesai' => $tglSelesai->format('Y-m-d'),
                'durasi_hari' => $durasi,
                'keterangan' => $ket[0],
                'bukti_path' => $ket[1],
                'status' => $status,
                'approved_by' => $status !== 'pending' ? $pendamping->id : null,
                'created_at' => $tglMulai->subDay(),
                'updated_at' => now(),
            ]);
        }

        // Tambah 1 izin pending untuk siswa yang berjalan (untuk testing)
        $activePlacement = DB::table('pkl_placements')
            ->where('status', 'berjalan')
            ->first();

        if ($activePlacement) {
            DB::table('izins')->insert([
                'profile_siswa_id' => $activePlacement->profile_siswa_id,
                'mitra_industri_id' => $activePlacement->mitra_industri_id,
                'tgl_mulai' => Carbon::now()->addDays(2)->format('Y-m-d'),
                'tgl_selesai' => Carbon::now()->addDays(3)->format('Y-m-d'),
                'durasi_hari' => 2,
                'keterangan' => 'Izin untuk mengurus perpanjangan KTP',
                'bukti_path' => null,
                'status' => 'pending',
                'approved_by' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}