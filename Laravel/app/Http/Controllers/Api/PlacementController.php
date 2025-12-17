<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PlacementController extends Controller
{
    public function show(Request $request)
    {
        $user = Auth::user();

        if (!$user) {
             return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 403);
        }

        // Get Active Placement
        // Assuming latest or active based on status. For now, fetching the first one found.
        $placement = PklPlacement::where('profile_siswa_id', $user->siswas->id)
            ->with(['mitra.alamat', 'pembimbing']) // Eager load mitra with address, and pembimbing
            ->latest('tgl_mulai')
            ->first();

        if (!$placement) {
             return response()->json([
                'success' => false,
                'message' => 'Belum ada penetapan lokasi PKL.',
                'data' => null
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $placement
        ]);
    }
}
