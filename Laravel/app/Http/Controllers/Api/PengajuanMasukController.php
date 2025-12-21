<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Approval\PengajuanMasukSiswa;
use App\Models\Siswa\ProfileSiswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PengajuanMasukController extends Controller
{
    public function store(Request $request)
    {
        $user = Auth::user();

        if (!$user) {
             return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Only students can apply.'
            ], 403);
        }

        $profileSiswas = $user->siswas; // Assuming 'siswa' relation points to ProfileSiswa or similar

        $validator = Validator::make($request->all(), [
            'mitra_id' => 'required|exists:mitra_industris,id',
            'durasi' => 'required|integer|min:1',
            'deskripsi' => 'required|string',
            'cv' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048', // Image as per request
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation Error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Upload CV
            $cvPath = null;
            if ($request->hasFile('cv')) {
                $cvPath = $request->file('cv')->store('cv_uploads', 'public');
            }

            // Create Pengajuan
            $pengajuan = PengajuanMasukSiswa::create([
                'profile_siswa_id' => $profileSiswas->id,
                'mitra_industri_id' => $request->mitra_id,
                'durasi' => $request->durasi,
                'cv_path' => $cvPath,
                'deskripsi' => $request->deskripsi,
                'tgl_ajuan' => now(),
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan berhasil dikirim.',
                'data' => $pengajuan
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat menyimpan pengajuan: ' . $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Get latest application status for the logged-in student
     */
    public function getStatus(Request $request)
    {
         $user = Auth::user();

        if (!$user) {
             return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 403);
        }
        
        // Get latest pengajuan (assuming one active at a time or retrieve list)
        // For simplicity, retrieving the latest one.
        $pengajuan = PengajuanMasukSiswa::where('profile_siswa_id', $user->siswas->id)
            ->with('mitra')
            ->latest()
            ->first();

        if (!$pengajuan) {
             return response()->json([
                'success' => true,
                'data' => null // No application
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $pengajuan
        ]);
    }

    /**
     * Get all application history for the logged-in student
     */
    public function getHistory(Request $request)
    {
         $user = Auth::user();

        if (!$user) {
             return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 403);
        }

        $pengajuanList = PengajuanMasukSiswa::where('profile_siswa_id', $user->siswas->id)
            ->with('mitra')
            ->orderBy('tgl_ajuan', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $pengajuanList
        ]);
    }
}
