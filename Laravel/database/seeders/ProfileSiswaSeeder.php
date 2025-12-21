<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProfileSiswaSeeder extends Seeder
{
    public function run(): void
    {
        $users = DB::table('users')->where('role', 'siswa')->get();
        $jurusanIds = DB::table('jurusans')->pluck('id')->toArray();

        foreach ($users as $index => $user) {
            DB::table('profile_siswas')->insert([
                'user_id' => $user->id,
                'jurusan_id' => $jurusanIds[$index % count($jurusanIds)], // Rotasi jurusan
                'nisn' => '1000' . str_pad($index + 1, 6, '0', STR_PAD_LEFT),
                'device_id' => 'device_' . uniqid(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}