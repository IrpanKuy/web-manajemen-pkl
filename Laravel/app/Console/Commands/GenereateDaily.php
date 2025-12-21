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
    protected $signature = 'daily:generate';

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
        $now = Carbon::now();
        
        $this->line("Current time: {$now->toDateTimeString()}");
        $this->line("Today: {$today->toDateString()}");
        $this->line("");

        // ================================================================
        // STEP 1: Update status PKL dari 'pending' menjadi 'berjalan' 
        //         jika hari ini >= tgl_mulai
        // ================================================================
        $placementsToStart = PklPlacement::where('status', 'pending')
            ->whereDate('tgl_mulai', '<=', $today)
            ->get();

        foreach ($placementsToStart as $placement) {
            $placement->update(['status' => 'berjalan']);
            $this->info("PKL Placement ID {$placement->id} (Siswa ID: {$placement->profile_siswa_id}) status diubah dari 'pending' menjadi 'berjalan'");
        }

        if ($placementsToStart->count() > 0) {
            $this->line("Total {$placementsToStart->count()} PKL placement(s) dimulai.");
        } else {
            $this->line("Tidak ada PKL placement yang dimulai hari ini.");
        }

        $this->line("");

        // ================================================================
        // STEP 2: Update status PKL menjadi 'selesai' jika hari ini >= tgl_selesai
        // ================================================================
        $placementsToComplete = PklPlacement::where('status', 'berjalan')
            ->whereDate('tgl_selesai', '<=', $today)
            ->get();

        foreach ($placementsToComplete as $placement) {
            $placement->update(['status' => 'selesai']);
            $this->info("PKL Placement ID {$placement->id} (Siswa ID: {$placement->profile_siswa_id}) status diubah menjadi 'selesai'");
        }

        if ($placementsToComplete->count() > 0) {
            $this->line("Total {$placementsToComplete->count()} PKL placement(s) selesai.");
        } else {
            $this->line("Tidak ada PKL placement yang selesai hari ini.");
        }

        $this->line("");

        // ================================================================
        // STEP 3: Generate absensi HANYA untuk PKL dengan status 'berjalan'
        // ================================================================
        $activePlacements = PklPlacement::with('mitra')
            ->where('status', 'berjalan')
            ->get();

        $this->line("Generating absensi untuk {$activePlacements->count()} PKL placement aktif...");

        foreach ($activePlacements as $placement) {
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
                $this->line("✓ Generated absensi for Siswa ID: {$placement->profile_siswa_id}");
            } else {
                $this->line("- Absensi already exists for Siswa ID: {$placement->profile_siswa_id}");
            }
        }

        $this->line("");
        $this->info("Daily generate completed!");
    }
}
