<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class JurusanSeeder extends Seeder
{
    public function run(): void
    {
        $jurusans = [
            ['nama_jurusan' => 'Rekayasa Perangkat Lunak'],
            ['nama_jurusan' => 'Teknik Komputer Jaringan'],
            ['nama_jurusan' => 'Desain Komunikasi Visual'],
            ['nama_jurusan' => 'Multimedia'],
            ['nama_jurusan' => 'Sistem Informasi Jaringan'],
        ];

        foreach ($jurusans as $jurusan) {
            DB::table('jurusans')->insert(array_merge($jurusan, [
                'created_at' => now(), 'updated_at' => now()
            ]));
        }
    }
}