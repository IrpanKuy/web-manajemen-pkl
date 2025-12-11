<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AbsensiSeeder extends Seeder
{
    public function run(): void
    {
        $placements = DB::table('pkl_placements')->where('status', 'berjalan')->get();
        
        // Loop 5 hari ke belakang
        for ($i = 0; $i < 5; $i++) {
            $date = Carbon::now()->subDays($i);
            
            // Jangan buat absen di hari minggu
            if ($date->isWeekend()) continue;

            foreach ($placements as $placement) {
                // Randomize jam masuk/pulang & status
                $status = rand(1, 10) > 8 ? 'telat' : 'hadir'; // 20% peluang telat
                $jamMasuk = $status == 'telat' ? '08:15:00' : '07:45:00';
                
                // Koordinat dummy (gunakan milik mitra)
                $mitraLoc = DB::table('alamats')
                            ->where('mitra_industri_id', $placement->mitra_industri_id)
                            ->value(DB::raw("ST_AsText(location)")); 
                
                // Jika null (misal blm ada alamat), fallback hardcode
                $locSql = $mitraLoc 
                    ? "ST_GeomFromText('$mitraLoc', 4326)" 
                    : "ST_GeomFromText('POINT(112.7900 -7.2800)', 4326)";

                DB::table('absensis')->insert([
                    'profile_siswa_id' => $placement->profile_siswa_id,
                    'mitra_industri_id' => $placement->mitra_industri_id,
                    'tanggal' => $date->format('Y-m-d'),
                    'jam_masuk' => $jamMasuk,
                    'jam_pulang' => '17:00:00',
                    'location_masuk' => DB::raw($locSql),
                    'location_pulang' => DB::raw($locSql),
                    'status_kehadiran' => $status,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}