<?php

namespace App\Http\Controllers\pembimbing;

use App\Http\Controllers\Controller;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Izin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class PengajuanIzinController extends Controller
{
    /**
     * Display a listing of leave requests from students under pembimbing.
     */
    public function index(Request $request)
    {
        $pembimbingId = Auth::id();

        // Ambil siswa yang dibimbing
        $siswaIds = PklPlacement::where('pembimbing_id', $pembimbingId)
            ->where('status', 'berjalan')
            ->pluck('profile_siswa_id');

        // Query izin dari siswa yang dibimbing
        $izins = Izin::whereIn('profile_siswa_id', $siswaIds)
            ->with(['siswa.user', 'siswa.jurusan', 'approver'])
            // Filter berdasarkan status
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            // Filter pencarian
            ->when($request->search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('keterangan', 'like', "%{$search}%")
                        ->orWhereHas('siswa.user', function ($q2) use ($search) {
                            $q2->where('name', 'like', "%{$search}%");
                        });
                });
            })
            ->latest()
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('pembimbing/pengajuanIzin', [
            'izins' => $izins,
            'filters' => [
                'search' => $request->search,
                'status' => $request->status,
            ],
        ]);
    }

    /**
     * Update the specified leave request.
     */
    public function update(Request $request, $id)
    {
        $izin = Izin::findOrFail($id);

        $request->validate([
            'status' => 'required|in:approved,rejected',
        ]);

        $izin->update([
            'status' => $request->status,
            'approved_by' => Auth::id(),
        ]);

        $message = $request->status === 'approved'
            ? 'Pengajuan izin disetujui.'
            : 'Pengajuan izin ditolak.';

        return redirect()->route('pengajuan-izin.index')->with('success', $message);
    }
}
