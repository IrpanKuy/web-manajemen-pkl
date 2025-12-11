<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MentorRequestSeeder extends Seeder
{
    public function run(): void
    {
        $students = DB::table('profile_siswas')->limit(5)->get();
        $pembimbings = DB::table('users')->where('role', 'pembimbing')->limit(2)->get();

        if ($pembimbings->count() < 2) return; // Safety check

        foreach ($students as $student) {
            DB::table('mentor_requests')->insert([
                'profile_siswa_id' => $student->id,
                'pembimbing_lama_id' => $pembimbings[0]->id,
                'pembimbing_baru_id' => $pembimbings[1]->id,
                'alasan' => 'Ingin fokus ke bidang backend, mentor lama frontend.',
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}