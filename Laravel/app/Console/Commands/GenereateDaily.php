<?php

namespace App\Console\Commands;

use App\Models\Instansi\PklPlacement;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class GenereateDaily extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'attendance:generate';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command absensi harian';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $today = Carbon::today();
        $pklPlacement = PklPlacement::with('mitra')->get();

        // if($today->isWeekend()) {
        //     $this->info('Hari ini adalah akhir pekan. Tidak ada absensi yang dibuat.');
        //     return 0;
        // }
        $now = Carbon::now();
        $this->line("Current time: {$now->toDateTimeString()}");
        $this->line("Today: {$today->toDateString()}");

        foreach ($pklPlacement as $placement) {
            $tanggalMasuk = Carbon::parse($placement->tgl_mulai);
            $tanggalSelesai = Carbon::parse($placement->tgl_selesai);

            // if ($tanggalMasuk->gt($today) || $tanggalSelesai->lt($today)) {
            // Cek apakah absensi untuk hari ini sudah ada
            $existingAbsensi = \App\Models\Siswa\Absensi::where('profile_siswa_id', $placement->profile_siswa_id)
                ->where('tanggal', $today->toDateString())
                ->exists();

            if (!$existingAbsensi) {
                \App\Models\Siswa\Absensi::create([
                    'profile_siswa_id' => $placement->profile_siswa_id,
                    'mitra_industri_id' => $placement->mitra_industri_id,
                    'tanggal' => $today->toDateString(),
                    'status_kehadiran' => 'pending',
                ]);
                $this->line("Generated absensi for siswa ID: {$placement->profile_siswa_id}");
            } else {
                $this->line("Absensi already exists for siswa ID: {$placement->profile_siswa_id}");
            }
        // }
            // $this->line("belum waktunya pkl");
        }
    }
}
