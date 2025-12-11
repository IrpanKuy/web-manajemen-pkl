<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Pendamping\Jurusan;
use Illuminate\Http\Request;
use Inertia\Inertia;

class JurusanController extends Controller
{
    /**
     * Menampilkan daftar jurusan
     */
    public function index()
    {
        $jurusans = Jurusan::latest()->get();

        return Inertia::render('pendamping/jurusan', [
            'jurusans' => $jurusans
        ]);
    }

    /**
     * Halaman form tambah jurusan
     */
    public function create()
    {
    }

    /**
     * Menyimpan jurusan baru
     */
    public function store(Request $request)
    {
        // dd($request);
        $request->validate([
            'nama_jurusan' => 'required|string|max:255|unique:jurusans,nama_jurusan',
        ]);

        Jurusan::create([
            'nama_jurusan' => $request->nama_jurusan
        ]);

        return redirect()->route('jurusan.index')->with('success', 'Jurusan berhasil ditambahkan.');
    }

    /**
     * Halaman form edit jurusan
     */
    public function edit(Jurusan $jurusan)
    {
    }

    /**
     * Update data jurusan
     */
    public function update(Request $request, Jurusan $jurusan)
    {
        $request->validate([
            // Unique tapi abaikan ID diri sendiri saat update
            'nama_jurusan' => 'required|string|max:255|unique:jurusans,nama_jurusan,' . $jurusan->id,
        ]);

        $jurusan->update([
            'nama_jurusan' => $request->nama_jurusan
        ]);

        return redirect()->route('jurusan.index')->with('success', 'Jurusan berhasil diperbarui.');
    }

    /**
     * Hapus jurusan
     */
    public function destroy(Jurusan $jurusan)
    {
        // Cek apakah jurusan ini dipakai siswa sebelum hapus
        if ($jurusan->siswas()->exists()) {
            return back()->with('error', 'Jurusan tidak bisa dihapus karena masih memiliki siswa.');
        }

        $jurusan->delete();
        return redirect()->back()->with('success', 'Jurusan berhasil dihapus.');
    }
}