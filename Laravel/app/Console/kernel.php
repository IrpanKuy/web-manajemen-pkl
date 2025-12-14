<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Jalankan command 'attendance:generate' setiap hari pukul 01:00 pagi
        $schedule->command('attendance:generate')
                 ->everyMinute()
                 ->withoutOverlapping() // Mencegah tumpang tindih jika proses lama
                 ->onSuccess(function () {
                     // Lakukan sesuatu jika berhasil
                 })
                 ->onFailure(function () {
                     // Kirim notifikasi jika gagal
                 });

        // Catatan: Logika untuk "kecuali hari Minggu" sudah ada di dalam command-nya.
        // Namun, jika Anda ingin lebih eksplisit, bisa juga seperti ini:
        // $schedule->command('attendance:generate')->weekdays()->dailyAt('01:00');
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');
        require base_path('routes/console.php');
    }
}