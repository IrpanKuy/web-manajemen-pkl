<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('password');
        $users = [];

        // 1. Buat 10 Siswa
        for ($i = 1; $i <= 10; $i++) {
            $users[] = [
                'name' => "Siswa ke-$i",
                'email' => "siswa$i@sekolah.com",
                'password' => $password,
                'role' => 'siswa',
                'phone' => "0812000000$i",
                'is_active' => true,
                'is_admin' => false,
                'created_at' => now(), 'updated_at' => now()
            ];
        }

        // 2. Buat 5 Pembimbing Industri (Mentor)
        for ($i = 1; $i <= 5; $i++) {
            $users[] = [
                'name' => "Mentor Industri $i",
                'email' => "mentor$i@industri.com",
                'password' => $password,
                'role' => 'pembimbing',
                'phone' => "0813000000$i",
                'is_active' => true,
                'is_admin' => false,
                'created_at' => now(), 'updated_at' => now()
            ];
        }

        // 3. Buat 3 Pendamping (Guru Sekolah)
        for ($i = 1; $i <= 3; $i++) {
            $users[] = [
                'name' => "Guru Pendamping $i",
                'email' => "guru$i@sekolah.com",
                'password' => $password,
                'role' => 'pendamping',
                'phone' => "0814000000$i",
                'is_active' => true,
                'is_admin' => $i === 1, // First pendamping is admin
                'created_at' => now(), 'updated_at' => now()
            ];
        }

        // 4. [PENTING] Buat 5 Supervisor (Kepala Mitra)
        // Jumlah ini HARUS SAMA dengan jumlah Mitra yang akan dibuat
        for ($i = 1; $i <= 5; $i++) {
            $users[] = [
                'name' => "Supervisor Mitra $i",
                'email' => "spv$i@mitra.com", // Email unik: spv1@mitra.com, dst
                'password' => $password,
                'role' => 'supervisors',
                'phone' => "0815000000$i",
                'is_active' => true,
                'is_admin' => false,
                'created_at' => now(), 'updated_at' => now()
            ];
        }

        DB::table('users')->insert($users);
    }
}