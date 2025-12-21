<?php

namespace App\Imports;

use App\Models\User;
use App\Models\User\ProfileSiswa;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Maatwebsite\Excel\Concerns\ToCollection;
use Maatwebsite\Excel\Concerns\WithHeadingRow;

class SiswaImport implements ToCollection, WithHeadingRow
{
    public $errors = [];
    public $successCount = 0;

    public function collection(Collection $rows)
    {
        foreach ($rows as $index => $row) {
            $rowNumber = $index + 2; // +2 karena heading row + index mulai dari 0
            
            // Skip baris kosong
            if (empty($row['nama']) && empty($row['email'])) {
                continue;
            }

            // Validasi data
            $validator = Validator::make($row->toArray(), [
                'nama' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'nisn' => 'required|string|unique:profile_siswas,nisn',
                'no_hp' => 'nullable|string|max:20',
                'jurusan_id' => 'required|exists:jurusans,id',
                'password' => 'nullable|string|min:6',
            ], [
                'nama.required' => "Baris $rowNumber: Nama harus diisi",
                'email.required' => "Baris $rowNumber: Email harus diisi",
                'email.email' => "Baris $rowNumber: Format email tidak valid",
                'email.unique' => "Baris $rowNumber: Email sudah terdaftar",
                'nisn.required' => "Baris $rowNumber: NISN harus diisi",
                'nisn.unique' => "Baris $rowNumber: NISN sudah terdaftar",
                'jurusan_id.required' => "Baris $rowNumber: Jurusan ID harus diisi",
                'jurusan_id.exists' => "Baris $rowNumber: Jurusan tidak ditemukan",
            ]);

            if ($validator->fails()) {
                foreach ($validator->errors()->all() as $error) {
                    $this->errors[] = $error;
                }
                continue;
            }

            try {
                // Buat user
                $user = User::create([
                    'name' => $row['nama'],
                    'email' => $row['email'],
                    'phone' => $row['no_hp'] ?? null,
                    'password' => Hash::make($row['password'] ?? 'password123'),
                    'role' => 'siswa',
                    'is_active' => true,
                    'is_admin' => false,
                ]);

                // Buat profile siswa
                ProfileSiswa::create([
                    'user_id' => $user->id,
                    'jurusan_id' => $row['jurusan_id'],
                    'nisn' => $row['nisn'],
                    'device_id' => 'imported_' . uniqid(),
                ]);

                $this->successCount++;
            } catch (\Exception $e) {
                $this->errors[] = "Baris $rowNumber: Gagal menyimpan data - " . $e->getMessage();
            }
        }
    }
}
