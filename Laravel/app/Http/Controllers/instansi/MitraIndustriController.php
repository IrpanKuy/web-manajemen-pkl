<?php

namespace App\Http\Controllers\Instansi;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Pendamping\Jurusan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class MitraIndustriController extends Controller
{
    /**
     * Menampilkan daftar mitra industri beserta alamatnya.
     */
    public function index()
    {
        // Eager Load alamat, tapi kita perlu memecah 'location' jadi lat/long
        // agar bisa dibaca Frontend (misal untuk marker peta)
        $mitras = MitraIndustri::with(['alamat:id,mitra_industri_id,kecamatan', 'pendamping:id,name', 'supervisor:id,name'])
        ->withCount('placements')
        ->latest()
        ->paginate(10)
        ->withQueryString();
        // dd($mitras);

        return Inertia::render('pendamping/MitraIndustri/show', [
            'mitras' => $mitras,
            'listPendampings' => User::pendamping()->select('id', 'name')->get(),
            'listSupervisors' => User::supervisors()->select('id', 'name')->get(),
        ]);
    }

    /**
     * Halaman Tambah Mitra
     */
    public function create()
    {
        // 1. Tentukan ID Supervisor yang SUDAH DITUGASKAN
        // Ambil semua ID yang sudah ada di kolom 'supervisors_id'
        $assignedSupervisorIds = MitraIndustri::pluck('supervisors_id')
            ->filter() // Filter untuk menghapus nilai null (Supervisor yang belum ditugaskan)
            ->unique(); // Pastikan ID yang didapat unik
        
        // 2. Query User: Ambil SEMUA user role 'supervisors' 
        // LALU kecualikan yang ID-nya sudah ada di $assignedSupervisorIds
        $availableSupervisors = User::where('role', 'supervisors')
            ->whereNotIn('id', $assignedSupervisorIds)
            ->get(['id', 'name']); // Ambil hanya ID dan Name
        // dd($availableSupervisors);
        
        // dd(User::pendamping()->get());
        return Inertia::render('pendamping/MitraIndustri/create', [
            // Kirim data jurusan untuk checkbox/multiselect
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(), 
            'listPendampings' => User::pendamping()->select('id', 'name')->get(),
            'listSupervisors' => $availableSupervisors,
        ]);
    }

    /**
     * Simpan Data ke 2 Tabel + Convert LatLong ke PostGIS
     */
    public function store(Request $request)
    {
        $request->validate([
            // Validasi Mitra
            'pendamping_id' => 'required',
            'supervisors_id' => 'required',
            'nama_instansi' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'bidang_usaha' => 'required|string|max:255',
            'jam_masuk' => 'required',
            'jam_pulang' => 'required',
            'kuota' => 'required|integer|min:1',
            'jurusan_ids' => 'required|array', // Array ID Jurusan
            'jurusan_ids.*' => 'exists:jurusans,id',
            'tanggal_masuk' => 'required|date',

            // Validasi Alamat
            'profinsi' => 'required|string',
            'kabupaten' => 'required|string',
            'kecamatan' => 'required|string',
            'kode_pos' => 'required|numeric',
            'detail_alamat' => 'required|string',
            'radius_meter' => 'required|integer|min:10',
            
            // Validasi Koordinat (Input dari Maps Frontend)
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
        ]);

        
            

        DB::transaction(function () use ($request) {
            // 1. Simpan Data Mitra
            $mitra = MitraIndustri::create([
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

            // 2. Simpan Alamat dengan Konversi PostGIS
            // Rumus: ST_SetSRID(ST_MakePoint(Longitude, Latitude), 4326)
            $mitra->alamat()->create([
                'profinsi' => $request->profinsi,
                'kabupaten' => $request->kabupaten,
                'kecamatan' => $request->kecamatan,
                'kode_pos' => $request->kode_pos,
                'detail_alamat' => $request->detail_alamat,
                'radius_meter' => $request->radius_meter,
                'location' => DB::raw("ST_SetSRID(ST_MakePoint({$request->longitude}, {$request->latitude}), 4326)")
            ]);
        });
        
        return redirect()->route('mitra-industri.index')
            ->with('success', 'Mitra Industri berhasil ditambahkan.');
    }

    /**
     * Halaman Edit Mitra
     */
    public function edit($id)
    {
        // Load alamat dengan konversi lat/long agar bisa muncul di Peta Edit
       $mitraIndustri = MitraIndustri::with(['alamat' => function ($query) {
        $query->selectRaw("
            *, 
            ST_Y(location::geometry) as latitude, 
            ST_X(location::geometry) as longitude
        ");
    }])->findOrFail($id);
        return Inertia::render('pendamping/MitraIndustri/edit', [
            'mitra' => $mitraIndustri,
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(), 
            'listPendampings' => User::pendamping()->select('id', 'name')->get(),
            'listSupervisors' => User::supervisors()->select('id', 'name')->get(),
        ]);
    }

    /**
     * Update Data Mitra & Alamat
     */
    public function update(Request $request, $id)
    {
        $mitraIndustri = MitraIndustri::findOrFail($id);
        $request->validate([
            // Validasi Mitra
            'pendamping_id' => 'required',
            'supervisors_id' => 'required',
            'nama_instansi' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'bidang_usaha' => 'required|string|max:255',
            'jam_masuk' => 'required',
            'jam_pulang' => 'required',
            'kuota' => 'required|integer|min:1',
            'jurusan_ids' => 'required|array', // Array ID Jurusan
            'jurusan_ids.*' => 'exists:jurusans,id',
            'tanggal_masuk' => 'required|date',

            // Validasi Alamat
            'profinsi' => 'required|string',
            'kabupaten' => 'required|string',
            'kecamatan' => 'required|string',
            'kode_pos' => 'required|numeric',
            'detail_alamat' => 'required|string',
            'radius_meter' => 'required|integer|min:10',
            
            // Validasi Koordinat (Input dari Maps Frontend)
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
        ]);

        DB::transaction(function () use ($request, $mitraIndustri) {
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

            // 2. Update Alamat & Lokasi
            $mitraIndustri->alamat()->update([
                'profinsi' => $request->profinsi,
                'kabupaten' => $request->kabupaten,
                'kecamatan' => $request->kecamatan,
                'kode_pos' => $request->kode_pos,
                'detail_alamat' => $request->detail_alamat,
                'radius_meter' => $request->radius_meter,
                'location' => DB::raw("ST_SetSRID(ST_MakePoint({$request->longitude}, {$request->latitude}), 4326)")
            ]);
        });

        return redirect()->route('mitra-industri.index')
            ->with('success', 'Data Mitra Industri diperbarui.');
    }

    /**
     * Hapus Mitra (Cascade delete akan menghapus alamat otomatis)
     */
    public function destroy($id)
{
    MitraIndustri::findOrFail($id)->delete();

    return redirect()->back()->with('success', 'Mitra Industri dihapus.');
}
}