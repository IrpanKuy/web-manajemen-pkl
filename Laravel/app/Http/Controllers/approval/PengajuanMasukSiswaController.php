<?php

namespace App\Http\Controllers\approval;

use App\Http\Controllers\Controller;
use App\Models\Approval\PengajuanMasukSiswa;
use App\Models\Instansi\MitraIndustri;
use App\Models\Instansi\PklPlacement;
use Carbon\CarbonImmutable;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class PengajuanMasukSiswaController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $id = Auth::user()->id;
        $mitra = MitraIndustri::where('supervisors_id', $id)->select('id', 'kuota')->first();
        $pengajuanMasukSiswa = PengajuanMasukSiswa::where('mitra_industri_id', $mitra->id)->with(['siswa.user', 'siswa.jurusan'])->latest()->get();
        return Inertia::render('supervisors/pengajuan-masuk', [
            'pengajuanMasukSiswa' => $pengajuanMasukSiswa,
            'mitra' => $mitra
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
    public function store(PengajuanMasukSiswa $pengajuan)
    {
        $tglMulai = CarbonImmutable::parse($pengajuan->mitra->tanggal_masuk);
        $tglSelesai = $tglMulai->addMonth($pengajuan->durasi);

        PklPlacement::create([
            'profile_siswa_id' => $pengajuan->profile_siswa_id,
            'mitra_industri_id' => $pengajuan->mitra_industri_id,
            'tgl_mulai' => $tglMulai,
            'tgl_selesai' => $tglSelesai,
            'status' => 'pending'
        ]);
    }

    /**
     * Display the specified resource.
     */
    public function show(PengajuanMasukSiswa $pengajuanMasukSiswa)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(PengajuanMasukSiswa $pengajuanMasukSiswa)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id) {
    $pengajuan = PengajuanMasukSiswa::findOrFail($id);
    // dd($pengajuan);
    
    // jika ditolak
    if ($request->alasan_penolakan) {
        $pengajuan->update([
            'status' => $request->status,
            'alasan_penolakan' => $request->alasan_penolakan
        ]);

        return redirect()->route('pengajuan-masuk.index')->with('success', 'Berhasil Menolak siswa');
    }
    $id = Auth::user()->id;
    $mitra = MitraIndustri::where('supervisors_id', $id)->select('id', 'kuota')->first();
    $jumlahSiswaPkl = PklPlacement::where('mitra_industri_id', $mitra->id)->count();

    if ($jumlahSiswaPkl === $mitra->kuota) {
        return redirect()->route('pengajuan-masuk.index')->with('error', 'Kuota Penuh, tidak dapat menerima siswa');
    }
    $pengajuan->update([
            'status' => $request->status,
        ]);
    $this->store($pengajuan);

    return redirect()->route('pengajuan-masuk.index')->with('success', 'Berhasil menerima siswa');
}

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(PengajuanMasukSiswa $pengajuanMasukSiswa)
    {
        //
    }
}
