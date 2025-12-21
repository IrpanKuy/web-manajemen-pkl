<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProfilePembimbingSeeder extends Seeder
{
    public function run(): void
    {
        $userPembimbings = DB::table('users')->where('role', 'pembimbing')->get();
        $mitraIds = DB::table('mitra_industris')->pluck('id')->toArray();

        // Distribusi pembimbing ke mitra (beberapa mitra punya lebih dari 1 pembimbing)
        // Mitra 1: pembimbing 1, 2
        // Mitra 2: pembimbing 3, 4
        // Mitra 3: pembimbing 5
        // Mitra 4: pembimbing 6
        // Mitra 5: pembimbing 7, 8
        
        $pembimbingToMitra = [
            0 => 0, // Pembimbing 1 -> Mitra 1
            1 => 0, // Pembimbing 2 -> Mitra 1
            2 => 1, // Pembimbing 3 -> Mitra 2
            3 => 1, // Pembimbing 4 -> Mitra 2
            4 => 2, // Pembimbing 5 -> Mitra 3
            5 => 3, // Pembimbing 6 -> Mitra 4
            6 => 4, // Pembimbing 7 -> Mitra 5
            7 => 4, // Pembimbing 8 -> Mitra 5
        ];

        foreach ($userPembimbings as $index => $user) {
            $mitraIndex = $pembimbingToMitra[$index] ?? ($index % count($mitraIds));
            
            DB::table('profile_pembimbings')->insert([
                'user_id' => $user->id,
                'mitra_industri_id' => $mitraIds[$mitraIndex],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}