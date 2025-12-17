<?php

namespace App\Http\Controllers\pembimbing;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use App\Models\User\ProfileSiswa;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class JurnalSiswaController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $pembimbingId = Auth::id();

        // Query jurnal dengan filter
        $jurnals = JurnalHarian::where('pembimbing_id', $pembimbingId)
            ->with(['siswa.user', 'siswa.jurusan'])
            // Filter pencarian nama siswa atau judul jurnal
            ->when($request->search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('judul', 'like', "%{$search}%")
                        ->orWhereHas('siswa.user', function ($q2) use ($search) {
                            $q2->where('name', 'like', "%{$search}%");
                        });
                });
            })
            // Filter berdasarkan siswa tertentu
            ->when($request->siswa_id, function ($query, $siswaId) {
                $query->where('profile_siswa_id', $siswaId);
            })
            // Filter berdasarkan bulan
            ->when($request->bulan, function ($query, $bulan) {
                $tanggal = Carbon::parse($bulan);
                $query->whereMonth('tanggal', $tanggal->month)
                    ->whereYear('tanggal', $tanggal->year);
            })
            ->latest('tanggal')
            ->paginate(10)
            ->withQueryString();

        // Ambil daftar siswa yang dibimbing untuk filter dropdown
        $siswaList = ProfileSiswa::whereHas('jurnalHarians', function ($q) use ($pembimbingId) {
            $q->where('pembimbing_id', $pembimbingId);
        })
            ->with('user:id,name')
            ->get()
            ->map(function ($siswa) {
                return [
                    'id' => $siswa->id,
                    'name' => $siswa->user->name,
                ];
            });

        return Inertia::render('pembimbing/jurnalSiswa', [
            'jurnals' => $jurnals,
            'siswaList' => $siswaList,
            'filters' => [
                'search' => $request->search,
                'siswa_id' => $request->siswa_id,
                'bulan' => $request->bulan,
            ],
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $jurnal = JurnalHarian::findOrFail($id);

        // Validasi
        $request->validate([
            'status' => 'required|in:disetujui,revisi',
            'komentar' => 'nullable|string|max:1000',
        ]);

        // Update jurnal
        $jurnal->update([
            'status' => $request->status,
            'komentar' => $request->komentar,
        ]);

        $message = $request->status === 'disetujui'
            ? 'Jurnal berhasil disetujui.'
            : 'Jurnal ditandai untuk revisi.';

        return redirect()->route('jurnal-siswa.index')->with('success', $message);
    }
}
