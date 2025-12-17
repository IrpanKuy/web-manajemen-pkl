<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Instansi\JurnalHarian;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class JurnalController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user->siswas) {
            return response()->json(['success' => false, 'message' => 'User bukan siswa'], 403);
        }

        $profileSiswaId = $user->siswas->id;

        $query = JurnalHarian::where('profile_siswa_id', $profileSiswaId);

        // Filter by Month and Year
        if ($request->has('month') && $request->has('year')) {
            $month = $request->month; // 1-12
            $year = $request->year;
            $query->whereMonth('tanggal', $month)->whereYear('tanggal', $year);
        }

        // Order by latest
        $jurnals = $query->orderBy('tanggal', 'desc')->get();

        // Summary
        $totalJurnal = $jurnals->count();

        return response()->json([
            'success' => true,
            'data' => $jurnals,
            'summary' => [
                'total_jurnal' => $totalJurnal
            ]
        ]);
    }
}
