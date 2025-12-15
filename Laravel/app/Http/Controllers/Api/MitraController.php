<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MitraController extends Controller
{
    /**
     * Get list of Mitra Industri filtered by Student's Jurusan
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        
        // Ensure user is a student
        if (!$user->siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. User is not a student.'
            ], 403);
        }

        $jurusanId = $user->siswa->jurusan_id;

        // Query Mitra
        $query = MitraIndustri::with('alamat');

        // Filter by Jurusan
        // jurusan_ids is a JSON array in DB, e.g., ["1", "2"]
        // We use JSON_CONTAINS or LIKE depending on DB. Assuming MySql/Postgres json support.
        // For compatibility and simplicity if json search fails, usually LIKE '%"ID"%' works for json arrays stored as text.
        // But Laravel 'whereJsonContains' is best.
        if ($jurusanId) {
            $query->whereJsonContains('jurusan_ids', (string)$jurusanId);
        }

        // Optional: Search by Name (Local filter in App, but backend search is efficient)
        if ($request->has('search')) {
            $search = $request->search;
            $query->where('nama_instansi', 'like', "%{$search}%");
        }

        $mitras = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Data mitra berhasil diambil.',
            'data' => $mitras
        ]);
    }

    /**
     * Get Detail Mitra
     */
    public function show($id)
    {
        $mitra = MitraIndustri::with('alamat')->find($id);

        if (!$mitra) {
            return response()->json([
                'success' => false,
                'message' => 'Mitra tidak ditemukan.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail mitra berhasil diambil.',
            'data' => $mitra
        ]);
    }
}
