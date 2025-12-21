<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AlamatSeeder extends Seeder
{
    public function run(): void
    {
        $mitras = DB::table('mitra_industris')->get();

        // Koordinat di area Jakarta
        $alamats = [
            [
                'profinsi' => 'DKI Jakarta',
                'kabupaten' => 'Jakarta Selatan',
                'kecamatan' => 'Kebayoran Baru',
                'kode_pos' => '12110',
                'detail' => 'Jl. Jend. Gatot Subroto Kav. 52',
                'lat' => -6.2297,
                'long' => 106.8191,
            ],
            [
                'profinsi' => 'DKI Jakarta',
                'kabupaten' => 'Jakarta Pusat',
                'kecamatan' => 'Menteng',
                'kode_pos' => '10310',
                'detail' => 'Jl. MH Thamrin No. 28',
                'lat' => -6.1944,
                'long' => 106.8229,
            ],
            [
                'profinsi' => 'DKI Jakarta',
                'kabupaten' => 'Jakarta Pusat',
                'kecamatan' => 'Tanah Abang',
                'kode_pos' => '10220',
                'detail' => 'Jl. Sudirman Kav. 21',
                'lat' => -6.2146,
                'long' => 106.8185,
            ],
            [
                'profinsi' => 'DKI Jakarta',
                'kabupaten' => 'Jakarta Pusat',
                'kecamatan' => 'Gambir',
                'kode_pos' => '10110',
                'detail' => 'Jl. Medan Merdeka Selatan No. 10',
                'lat' => -6.1754,
                'long' => 106.8272,
            ],
            [
                'profinsi' => 'DKI Jakarta',
                'kabupaten' => 'Jakarta Selatan',
                'kecamatan' => 'Setiabudi',
                'kode_pos' => '12910',
                'detail' => 'Pasaraya Blok M, Jl. Iskandarsyah II',
                'lat' => -6.2436,
                'long' => 106.7989,
            ],
        ];

        foreach ($mitras as $index => $mitra) {
            $idx = $index % count($alamats);
            $alamat = $alamats[$idx];

            DB::table('alamats')->insert([
                'mitra_industri_id' => $mitra->id,
                'profinsi' => $alamat['profinsi'],
                'kabupaten' => $alamat['kabupaten'],
                'kecamatan' => $alamat['kecamatan'],
                'kode_pos' => $alamat['kode_pos'],
                'detail_alamat' => $alamat['detail'],
                'location' => DB::raw("ST_GeomFromText('POINT({$alamat['long']} {$alamat['lat']})', 4326)"),
                'radius_meter' => 100,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}