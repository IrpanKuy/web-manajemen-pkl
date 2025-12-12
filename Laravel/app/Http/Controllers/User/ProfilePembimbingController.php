<?php

namespace App\Http\Controllers;

use App\Models\Instansi\MitraIndustri;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class ProfilePembimbingController extends Controller
{
    public function index()
    {
        // Scope 'pembimbing' otomatis load relasi profile & mitra
        $pembimbings = User::pembimbing()
            ->latest()
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('Users/Pembimbing/Index', [
            'pembimbings' => $pembimbings
        ]);
    }

    public function create()
    {
        // Kirim list Mitra Industri untuk dropdown
        return Inertia::render('Users/Pembimbing/Create', [
            'mitra_industris' => MitraIndustri::select('id', 'nama_instansi')->get()
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            // User Data
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:20',
            // Profil Pembimbing
            'mitra_industri_id' => 'required|exists:mitra_industris,id',
            'jabatan' => 'required|string|max:100',
        ]);

        DB::transaction(function () use ($request) {
            // A. Create User
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'role' => 'pembimbing', // Hardcode role pembimbing
                'is_active' => true,
            ]);

            // B. Create Profil Pembimbing
            $user->pembimbing()->create([
                'mitra_industri_id' => $request->mitra_industri_id,
                'jabatan' => $request->jabatan,
            ]);
        });

        return redirect()->route('pembimbing.index')->with('success', 'Pembimbing berhasil ditambahkan.');
    }

    public function edit(User $user)
    {
        $user->load('pembimbing');

        return Inertia::render('Users/Pembimbing/Edit', [
            'user' => $user,
            'mitra_industris' => MitraIndustri::select('id', 'nama_instansi')->get()
        ]);
    }

    public function update(Request $request, User $user)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => ['required', 'email', Rule::unique('users')->ignore($user->id)],
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:8',
            // Validasi Profil
            'mitra_industri_id' => 'required|exists:mitra_industris,id',
            'jabatan' => 'required|string|max:100',
        ]);

        DB::transaction(function () use ($request, $user) {
            // Update User
            $userData = [
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
            ];

            if ($request->filled('password')) {
                $userData['password'] = Hash::make($request->password);
            }

            $user->update($userData);

            // Update Profil Pembimbing
            $user->pembimbing()->update([
                'mitra_industri_id' => $request->mitra_industri_id,
                'jabatan' => $request->jabatan,
            ]);
        });

        return redirect()->route('pembimbing.index')->with('success', 'Data Pembimbing diperbarui.');
    }

    public function destroy(User $user)
    {
        $user->delete();
        return redirect()->back()->with('success', 'Pembimbing dihapus.');
    }
}