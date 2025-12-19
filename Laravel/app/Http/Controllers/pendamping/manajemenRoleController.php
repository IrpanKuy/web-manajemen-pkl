<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class manajemenRoleController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Only show pendamping users
        $users = User::where('role', 'pendamping')->latest()->paginate(10);

        return Inertia::render('pendamping/ManajemenRole/show', [
            'users' => $users,
        ]);
    }

    public function edit()
    {

    }

    public function create()
    {
        
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string|max:20',
            'password' => 'required|string|min:8',
            'is_active' => 'boolean',
        ]);

        // Force role to pendamping
        $validated['role'] = 'pendamping';
        
        // Enkripsi Password
        $validated['password'] = Hash::make($validated['password']);
        
        // Default Active jika tidak dikirim
        $validated['is_active'] = $request->boolean('is_active', true);

        User::create($validated);

        return redirect()->back()->with('success', 'Pendamping berhasil dibuat.');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            // Ignore email unique milik user ini sendiri
            'email' => ['required', 'email', Rule::unique('users')->ignore($user->id)],
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:8', // Password boleh kosong saat edit
            'is_active' => 'boolean',
        ]);

        // Force role to pendamping
        $validated['role'] = 'pendamping';

        // Cek jika password diisi, maka update. Jika kosong, hapus dari array agar tidak terupdate null.
        if ($request->filled('password')) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);

        return redirect()->back()->with('success', 'Pendamping berhasil diperbarui.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return redirect()->back()->with('success', 'User berhasil dihapus.');
    }
}
