<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Pendamping\Jurusan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class DataSiswaController extends Controller
{
    public function index()
    {
        // Scope 'siswa' otomatis load relasi profile & jurusan
        $siswas = User::siswa()
            ->latest()
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('pendamping/data-siswa', [
            'siswas' => $siswas,
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(),
        ]);
    }

    public function create()
    {
    }

    public function store(Request $request)
    {
        $request->validate([
            // Validasi Data User
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:20',
            // Validasi Data Profil Siswa
            'nisn' => 'required|string|unique:profile_siswas,nisn',
            'jurusan_id' => 'required|exists:jurusans,id',
            'is_active' => 'boolean',
        ]);

        DB::transaction(function () use ($request) {
            // A. Create User
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'role' => 'siswa', // Hardcode role siswa
                'is_active' => $request->is_active,
            ]);

            // B. Create Profil Siswa
            $user->siswas()->create([
                'nisn' => $request->nisn,
                'jurusan_id' => $request->jurusan_id,
            ]);
        });

        return redirect()->route('data-siswa.index')->with('success', 'Siswa berhasil ditambahkan.');
    }

    public function edit(User $user)
    {
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => ['required', 'email', Rule::unique('users')->ignore($request->id)],
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:8',
            // Validasi Profil (Ignore NISN milik sendiri saat update)
            'nisn' => ['required'],
            'jurusan_id' => 'required|exists:jurusans,id',
            'is_active' => 'boolean',
        ]);

        DB::transaction(function () use ($request, $id) {
            // Cari user
            $siswa = User::findOrFail($id);

            // 1. Siapkan array data User dasar
            $userData = [
                'name'  => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'is_active' => $request->is_active,
            ];

            // 2. Cek Password: Jika diisi, tambahkan ke dalam array $userData
            if ($request->filled('password')) {
                $userData['password'] = Hash::make($request->password);
            }

            // 3. Eksekusi Update User (Hanya 1 kali query database) ✨
            $siswa->update($userData);

            // 4. Update Profil Siswa
            // Catatan: Ini asumsinya data profile SUDAH ADA sebelumnya.
            $siswa->siswas()->update([
                'nisn'       => $request->nisn,
                'jurusan_id' => $request->jurusan_id,
            ]);
        });

        return redirect()->route('data-siswa.index')->with('success', 'Data Siswa diperbarui.');
    }

    public function destroy($id)
    {
        User::findOrFail($id)->delete();
        return redirect()->route('data-siswa.index')->with('success', 'Siswa dihapus.');
    }
}