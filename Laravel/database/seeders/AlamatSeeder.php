<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AlamatSeeder extends Seeder
{
    public function run(): void
    {
        $mitras = DB::table('mitra_industris')->get();

        foreach ($mitras as $index => $mitra) {
            // Kita geser koordinat sedikit tiap iterasi agar tidak menumpuk di peta
            $lat = -7.250445 + ($index * 0.01); 
            $long = 112.768845 + ($index * 0.01);

            DB::table('alamats')->insert([
                'mitra_industri_id' => $mitra->id,
                'profinsi' => 'Jawa Timur',
                'kabupaten' => 'Surabaya',
                'kecamatan' => 'Sukolilo',
                'kode_pos' => '6011' . $index,
                'detail_alamat' => "Jl. Raya Industri No. " . ($index + 1),
                'location' => DB::raw("ST_GeomFromText('POINT($long $lat)', 4326)"),
                'radius_meter' => 50,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}