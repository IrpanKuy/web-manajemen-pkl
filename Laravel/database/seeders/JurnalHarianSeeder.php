<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class JurnalHarianSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil semua placement yang berjalan
        $placements = DB::table('pkl_placements')
            ->where('status', 'berjalan')
            ->get();

        $today = Carbon::today();

        // ================================================================
        // SKENARIO JURNAL:
        // - Generate jurnal untuk 10 hari ke belakang
        // - Status valid: pending, disetujui, revisi
        // - Berbagai judul kegiatan
        // - Untuk hari ini: beberapa tanpa jurnal (untuk testing)
        // ================================================================

        $juduls = [
            'Meeting dan Briefing',
            'Pengembangan Fitur',
            'Bug Fixing',
            'Testing dan QA',
            'Dokumentasi Teknis',
            'Review Code',
            'Deployment Aplikasi',
            'Maintenance Server',
            'Research Teknologi',
            'Diskusi Tim',
        ];

        $deskripsis = [
            'Melakukan meeting pagi bersama tim untuk membahas target harian dan progress project.',
            'Mengembangkan fitur baru pada aplikasi sesuai dengan spesifikasi yang diberikan.',
            'Memperbaiki bug yang ditemukan pada testing phase kemarin.',
            'Melakukan testing terhadap fitur yang sudah dikembangkan untuk memastikan kualitas.',
            'Membuat dokumentasi teknis untuk fitur-fitur yang sudah selesai dikembangkan.',
            'Melakukan code review untuk memastikan kualitas kode sesuai standar.',
            'Melakukan deployment aplikasi ke server staging untuk UAT.',
            'Melakukan maintenance rutin pada server dan memastikan service berjalan normal.',
            'Melakukan research tentang teknologi baru yang akan diimplementasikan.',
            'Berdiskusi dengan tim tentang arsitektur dan solusi teknis.',
        ];

        // Status valid sesuai migration: pending, disetujui, revisi
        $statusList = ['pending', 'disetujui', 'disetujui', 'disetujui', 'revisi'];
        
        // Alasan revisi pembimbing 
        $alasanRevisiList = [
            'Mohon jelaskan lebih detail kegiatan yang dilakukan.',
            'Deskripsi kurang lengkap, tambahkan hasil kerja.',
            'Perlu tambahan foto kegiatan.',
        ];

        // Komentar pendamping (beberapa jurnal ada komentar, beberapa tidak)
        $komentarPendampingList = [
            null,
            'Bagus, pertahankan kerja kerasmu!',
            'Terus tingkatkan kemampuan teknismu.',
            null,
            'Excellent progress!',
        ];

        foreach ($placements as $placementIndex => $placement) {
            if (!$placement->pembimbing_id) continue;

            for ($i = 1; $i <= 10; $i++) {
                $date = $today->copy()->subDays($i);

                // Skip weekend
                if ($date->isWeekend()) continue;

                // Skip hari ini dan kemarin untuk placement pertama (untuk testing form jurnal)
                if ($i <= 1 && $placementIndex === 0) continue;

                $jurnalIndex = ($i + $placementIndex) % count($juduls);
                $status = $statusList[($i + $placementIndex) % count($statusList)];

                // Tentukan alasan revisi jika status revisi
                $alasanRevisi = null;
                if ($status === 'revisi') {
                    $alasanRevisi = $alasanRevisiList[($i + $placementIndex) % count($alasanRevisiList)];
                }

                // Komentar pendamping - random
                $komentarPendamping = $komentarPendampingList[($i + $placementIndex) % count($komentarPendampingList)];

                DB::table('jurnal_harians')->insert([
                    'profile_siswa_id' => $placement->profile_siswa_id,
                    'mitra_industri_id' => $placement->mitra_industri_id,
                    'pendamping_id' => null, // Will be set when pendamping comments
                    'pembimbing_id' => $placement->pembimbing_id,
                    'tanggal' => $date->format('Y-m-d'),
                    'judul' => $juduls[$jurnalIndex],
                    'deskripsi' => $deskripsis[$jurnalIndex],
                    'foto_kegiatan' => rand(0, 1) ? 'jurnal/foto_kegiatan_sample.jpg' : null,
                    'status' => $status,
                    'alasan_revisi_pembimbing' => $alasanRevisi,
                    'komentar_pendamping' => $komentarPendamping,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}