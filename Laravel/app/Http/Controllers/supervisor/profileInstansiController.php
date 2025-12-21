<?php

namespace App\Http\Controllers\supervisor;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use App\Models\Pendamping\Jurusan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Barryvdh\DomPDF\Facade\Pdf;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class profileInstansiController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $id = Auth::user()->id;
        $instansi = MitraIndustri::where('supervisors_id', $id)->with('pendamping:id,name')->first();
        
        // Hitung jumlah PKL placement aktif
        $activePlacementCount = PklPlacement::where('mitra_industri_id', $instansi->id)
            ->where('status', 'berjalan')
            ->count();
            
        return Inertia::render('supervisors/profile-instansi', [
            'mitra' => $instansi,
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(),
            'activePlacementCount' => $activePlacementCount,
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
        //
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
        $mitraIndustri = MitraIndustri::findOrFail($id);
        
        // Hitung jumlah PKL placement aktif
        $activePlacementCount = PklPlacement::where('mitra_industri_id', $id)
            ->where('status', 'berjalan')
            ->count();
        
        // Validasi kuota tidak boleh lebih kecil dari jumlah placement aktif
        if ($request->kuota < $activePlacementCount) {
            return redirect()->back()->withErrors([
                'kuota' => "Kuota tidak dapat dikurangi menjadi {$request->kuota}. Saat ini ada {$activePlacementCount} siswa PKL aktif."
            ]);
        }
        
        $request->validate([
            // Validasi Mitra
            'nama_instansi' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'bidang_usaha' => 'required|string|max:255',
            'jam_masuk' => 'required',
            'jam_pulang' => 'required',
            'kuota' => 'required|integer|min:1',
            'jurusan_ids' => 'required|array', // Array ID Jurusan
            'jurusan_ids.*' => 'exists:jurusans,id',
            'tanggal_masuk' => 'required|date',
        ]);

        // 1. Update Mitra
        $mitraIndustri->update([
            'pendamping_id' => $request->pendamping_id,
            'supervisors_id' => $request->supervisors_id,
            'nama_instansi' => $request->nama_instansi,
            'deskripsi' => $request->deskripsi,
            'bidang_usaha' => $request->bidang_usaha,
            'jam_masuk' => $request->jam_masuk,
            'jam_pulang' => $request->jam_pulang,
            'kuota' => $request->kuota,
            'jurusan_ids' => $request->jurusan_ids,
            'tanggal_masuk' => $request->tanggal_masuk
        ]);

        return redirect()->route('profile-instansi.index')
            ->with('success', 'Data Instansi Berhasil diperbarui.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }

    public function downloadQrCode()
    {
        $id = Auth::user()->id;
        $mitra = MitraIndustri::where('supervisors_id', $id)->firstOrFail();
        
        // Pastikan qr_value ada
        if (!$mitra->qr_value) {
            $mitra->qr_value = (string) \Illuminate\Support\Str::uuid();
            $mitra->save();
        }

        // Generate QR Code
        $qrCode = base64_encode(QrCode::format('svg')->size(300)->generate($mitra->qr_value));

        // Load View PDF
        $pdf = Pdf::loadView('pdf.qrcode', compact('mitra', 'qrCode'));

        return $pdf->download('QR_Code_' . str_replace(' ', '_', $mitra->nama_instansi) . '.pdf');
    }
}
