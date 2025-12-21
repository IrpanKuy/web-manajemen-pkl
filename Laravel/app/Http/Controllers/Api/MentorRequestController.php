<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Approval\MentorRequest;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\PklPlacement;
use App\Models\User\ProfilePembimbing;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MentorRequestController extends Controller
{
    /**
     * Mendapatkan data halaman Ganti Pembimbing
     * - Pembimbing saat ini
     * - List pembimbing lain di mitra yang sama
     * - Status request yang pending (jika ada)
     * - Flag apakah bisa ganti pembimbing (jurnal pending check)
     */
    public function index()
    {
        $user = Auth::user();
        $siswa = $user->siswas;

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Anda bukan siswa',
            ], 403);
        }

        // Ambil placement aktif siswa
        $placement = PklPlacement::where('profile_siswa_id', $siswa->id)
            ->whereIn('status', ['berjalan', 'pending'])
            ->with(['pembimbing', 'mitra'])
            ->first();

        if (!$placement) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada penempatan PKL aktif',
            ], 404);
        }

        // Cek apakah ada jurnal yang belum disetujui
        $hasPendingJurnal = JurnalHarian::where('profile_siswa_id', $siswa->id)
            ->where('status', 'pending')
            ->exists();

        // Cek apakah ada request yang pending
        $pendingRequest = MentorRequest::where('profile_siswa_id', $siswa->id)
            ->where('status', 'pending')
            ->with(['pembimbingLama', 'pembimbingBaru'])
            ->first();

        // Ambil list pembimbing lain di mitra yang sama
        $otherMentors = [];
        if (!$pendingRequest) {
            $otherMentors = ProfilePembimbing::where('mitra_industri_id', $placement->mitra_industri_id)
                ->where('user_id', '!=', $placement->pembimbing_id)
                ->with('user')
                ->get()
                ->map(function ($profile) {
                    return [
                        'id' => $profile->user_id,
                        'name' => $profile->user->name ?? 'Unknown',
                        'email' => $profile->user->email ?? '',
                    ];
                });
        }

        return response()->json([
            'success' => true,
            'data' => [
                'current_pembimbing' => $placement->pembimbing ? [
                    'id' => $placement->pembimbing->id,
                    'name' => $placement->pembimbing->name,
                    'email' => $placement->pembimbing->email,
                ] : null,
                'mitra' => [
                    'id' => $placement->mitra->id,
                    'nama' => $placement->mitra->nama_instansi,
                ],
                'other_mentors' => $otherMentors,
                'pending_request' => $pendingRequest ? [
                    'id' => $pendingRequest->id,
                    'alasan' => $pendingRequest->alasan,
                    'status' => $pendingRequest->status,
                    'pembimbing_lama' => $pendingRequest->pembimbingLama ? [
                        'id' => $pendingRequest->pembimbingLama->id,
                        'name' => $pendingRequest->pembimbingLama->name,
                    ] : null,
                    'pembimbing_baru' => $pendingRequest->pembimbingBaru ? [
                        'id' => $pendingRequest->pembimbingBaru->id,
                        'name' => $pendingRequest->pembimbingBaru->name,
                    ] : null,
                    'created_at' => $pendingRequest->created_at->format('Y-m-d H:i:s'),
                ] : null,
                'can_change_mentor' => !$hasPendingJurnal && !$pendingRequest,
                'has_pending_jurnal' => $hasPendingJurnal,
            ],
        ]);
    }

    /**
     * Submit request ganti pembimbing
     */
    public function store(Request $request)
    {
        $request->validate([
            'pembimbing_baru_id' => 'required|exists:users,id',
            'alasan' => 'required|string|max:500',
        ]);

        $user = Auth::user();
        $siswa = $user->siswas;

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Anda bukan siswa',
            ], 403);
        }

        // Cek placement aktif
        $placement = PklPlacement::where('profile_siswa_id', $siswa->id)
            ->whereIn('status', ['berjalan', 'pending'])
            ->first();

        if (!$placement) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada penempatan PKL aktif',
            ], 404);
        }

        // Cek apakah ada jurnal pending
        $hasPendingJurnal = JurnalHarian::where('profile_siswa_id', $siswa->id)
            ->where('status', 'pending')
            ->exists();

        if ($hasPendingJurnal) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak bisa mengajukan karena ada jurnal yang belum disetujui pembimbing',
            ], 400);
        }

        // Cek apakah ada request pending
        $existingRequest = MentorRequest::where('profile_siswa_id', $siswa->id)
            ->where('status', 'pending')
            ->exists();

        if ($existingRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Sudah ada pengajuan ganti pembimbing yang masih pending',
            ], 400);
        }

        // Cek pembimbing baru adalah pembimbing di mitra yang sama
        $isValidMentor = ProfilePembimbing::where('mitra_industri_id', $placement->mitra_industri_id)
            ->where('user_id', $request->pembimbing_baru_id)
            ->exists();

        if (!$isValidMentor) {
            return response()->json([
                'success' => false,
                'message' => 'Pembimbing yang dipilih tidak valid',
            ], 400);
        }

        // Buat request
        $mentorRequest = MentorRequest::create([
            'profile_siswa_id' => $siswa->id,
            'pembimbing_lama_id' => $placement->pembimbing_id,
            'pembimbing_baru_id' => $request->pembimbing_baru_id,
            'alasan' => $request->alasan,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan ganti pembimbing berhasil dikirim',
            'data' => $mentorRequest,
        ], 201);
    }

    /**
     * Batalkan request ganti pembimbing
     */
    public function destroy($id)
    {
        $user = Auth::user();
        $siswa = $user->siswas;

        if (!$siswa) {
            return response()->json([
                'success' => false,
                'message' => 'Anda bukan siswa',
            ], 403);
        }

        $request = MentorRequest::where('id', $id)
            ->where('profile_siswa_id', $siswa->id)
            ->where('status', 'pending')
            ->first();

        if (!$request) {
            return response()->json([
                'success' => false,
                'message' => 'Request tidak ditemukan atau tidak bisa dibatalkan',
            ], 404);
        }

        $request->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil dibatalkan',
        ]);
    }
}
