<?php

namespace App\Http\Controllers\pembimbing;

use App\Http\Controllers\Controller;
use App\Models\Approval\MentorRequest;
use App\Models\Instansi\PklPlacement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class MentorRequestController extends Controller
{
    /**
     * Display a listing of mentor requests for current pembimbing.
     */
    public function index()
    {
        $pembimbingId = Auth::id();

        // Ambil permintaan ganti pembimbing yang ditujukan ke pembimbing yang login
        $requests = MentorRequest::where('pembimbing_baru_id', $pembimbingId)
            ->with([
                'siswa.user',
                'siswa.jurusan',
                'pembimbingLama'
            ])
            ->latest()
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('pembimbing/mentorRequest', [
            'requests' => $requests,
        ]);
    }

    /**
     * Update the specified mentor request.
     */
    public function update(Request $request, $id)
    {
        $mentorRequest = MentorRequest::findOrFail($id);

        $request->validate([
            'status' => 'required|in:disetujui,ditolak',
        ]);

        DB::transaction(function () use ($request, $mentorRequest) {
            // Update status mentor request
            $mentorRequest->update([
                'status' => $request->status,
            ]);

            // Jika disetujui, update pembimbing_id di pkl_placements
            if ($request->status === 'disetujui') {
                // Cari placement aktif siswa
                $placement = PklPlacement::where('profile_siswa_id', $mentorRequest->profile_siswa_id)
                    ->where('status', 'berjalan')
                    ->first();

                if ($placement) {
                    $placement->update([
                        'pembimbing_id' => $mentorRequest->pembimbing_baru_id,
                    ]);
                }
            }
        });

        $message = $request->status === 'disetujui'
            ? 'Permintaan ganti pembimbing disetujui.'
            : 'Permintaan ganti pembimbing ditolak.';

        return redirect()->route('mentor-request.index')->with('success', $message);
    }
}
