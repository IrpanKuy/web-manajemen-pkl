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

        foreach ($userPembimbings as $user) {
            DB::table('profile_pembimbings')->insert([
                'user_id' => $user->id,
                'mitra_industri_id' => $mitraIds[array_rand($mitraIds)],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}