<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            JurusanSeeder::class,
            UserSeeder::class,
            ProfileSiswaSeeder::class,
            MitraIndustriSeeder::class,
            AlamatSeeder::class,
            ProfilePembimbingSeeder::class,
            PengajuanMasukSiswaSeeder::class,
            PklPlacementSeeder::class,
            AbsensiSeeder::class,
            JurnalHarianSeeder::class,
            IzinSeeder::class,
            MentorRequestSeeder::class,
        ]);
    }
}