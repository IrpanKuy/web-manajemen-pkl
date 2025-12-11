<?php

namespace App\Http\Controllers\supervisor;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\User\ProfilePembimbing;
use App\Models\User\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class AkunPembimbingController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Query ALL data dengan role pembimbing (tanpa paginate)
        $pembimbings = User::where('role', 'pembimbing')
            ->latest()
            ->get();

        return Inertia::render('supervisors/akun-pembimbing', [
            'pembimbings' => $pembimbings, // Mengirim Array, bukan Object Paginator
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string|max:20',
            'password' => 'required|min:8',
            'is_active' => 'boolean',
        ]);
        

        DB::transaction(function () use ($request) {
            $id = Auth::user()->id;
            $mitra = MitraIndustri::where('supervisors_id', $id)->select('id')->first();
            
            // 1. Buat User
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => 'pembimbing', // Role otomatis diset pembimbing
                'is_active' => $request->is_active,
            ]);

            ProfilePembimbing::create(['user_id' => $user->id, 'mitra_industri_id' => $mitra->id]); 
        });

        return redirect()->route('akun-pembimbing.index')->with('success', 'Akun Pembimbing berhasil dibuat.');
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'email',
                Rule::unique('users')->ignore($user->id),
            ],
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|min:8',
            'is_active' => 'boolean',
        ]);

        $dataToUpdate = [
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'is_active' => $request->is_active,
        ];

        // Hanya update password jika diisi
        if ($request->filled('password')) {
            $dataToUpdate['password'] = Hash::make($request->password);
        }

        $user->update($dataToUpdate);

        return redirect()->route('akun-pembimbing.index')->with('success', 'Data Pembimbing berhasil diperbarui.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $user = User::findOrFail($id);
        
        // Menghapus user (profile akan terhapus cascade jika disetting di database)
        $user->delete();

        return redirect()->back()->with('success', 'Akun Pembimbing berhasil dihapus.');
    }
}
