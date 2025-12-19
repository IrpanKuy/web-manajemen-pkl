<?php

namespace App\Http\Controllers\Instansi;

use App\Http\Controllers\Controller;
use App\Models\Instansi\MitraIndustri;
use App\Models\Pendamping\Jurusan;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Barryvdh\DomPDF\Facade\Pdf;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

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
     * Menampilkan detail mitra dengan semua pembimbing dan siswa.
     */
    public function detail($id)
    {
        $mitra = MitraIndustri::with([
            'alamat',
            'pendamping:id,name,email,phone',
            'supervisor:id,name,email,phone',
            'placements' => function ($query) {
                $query->with([
                    'siswa.user:id,name,email,phone',
                    'siswa.jurusan:id,nama_jurusan',
                    'pembimbing:id,name,email,phone'
                ])->where('status', 'berjalan');
            }
        ])->findOrFail($id);

        // Get unique pembimbings from placements
        $pembimbings = $mitra->placements
            ->pluck('pembimbing')
            ->filter()
            ->unique('id')
            ->values();

        // Get all siswa from placements
        $siswas = $mitra->placements
            ->map(function ($placement) {
                return [
                    'id' => $placement->siswa->id ?? null,
                    'name' => $placement->siswa->user->name ?? 'N/A',
                    'email' => $placement->siswa->user->email ?? '-',
                    'phone' => $placement->siswa->user->phone ?? '-',
                    'jurusan' => $placement->siswa->jurusan->nama_jurusan ?? '-',
                    'pembimbing' => $placement->pembimbing->name ?? '-',
                    'tgl_mulai' => $placement->tgl_mulai,
                    'tgl_selesai' => $placement->tgl_selesai,
                    'status' => $placement->status,
                ];
            });

        return Inertia::render('pendamping/MitraIndustri/detail', [
            'mitra' => $mitra,
            'pembimbings' => $pembimbings,
            'siswas' => $siswas,
        ]);
    }

    /**
     * Halaman Tambah Mitra
     */
    public function create()
    {
        return Inertia::render('pendamping/MitraIndustri/create', [
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(), 
            'listPendampings' => User::pendamping()->select('id', 'name')->get(),
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
            'nama_instansi' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'bidang_usaha' => 'required|string|max:255',
            'jam_masuk' => 'required',
            'jam_pulang' => 'required',
            'kuota' => 'required|integer|min:1',
            'jurusan_ids' => 'required|array',
            'jurusan_ids.*' => 'exists:jurusans,id',
            'tanggal_masuk' => 'required|date',

            // Validasi Alamat
            'profinsi' => 'required|string',
            'kabupaten' => 'required|string',
            'kecamatan' => 'required|string',
            'kode_pos' => 'required|numeric',
            'detail_alamat' => 'required|string',
            'radius_meter' => 'required|integer|min:10',
            
            // Validasi Koordinat
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            
            // Supervisor (always create new)
            'supervisor_name' => 'required|string|max:255',
            'supervisor_email' => 'required|email|unique:users,email',
            'supervisor_phone' => 'nullable|string|max:20',
            'supervisor_password' => 'required|string|min:8',
        ]);
        
        $mitra = DB::transaction(function () use ($request) {
            // Create new supervisor
            $supervisor = User::create([
                'name' => $request->supervisor_name,
                'email' => $request->supervisor_email,
                'phone' => $request->supervisor_phone,
                'password' => \Illuminate\Support\Facades\Hash::make($request->supervisor_password),
                'role' => 'supervisors',
                'is_active' => true,
            ]);

            // 1. Simpan Data Mitra
            $mitra = MitraIndustri::create([
                'pendamping_id' => $request->pendamping_id,
                'supervisors_id' => $supervisor->id,
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
            $mitra->alamat()->create([
                'profinsi' => $request->profinsi,
                'kabupaten' => $request->kabupaten,
                'kecamatan' => $request->kecamatan,
                'kode_pos' => $request->kode_pos,
                'detail_alamat' => $request->detail_alamat,
                'radius_meter' => $request->radius_meter,
                'location' => DB::raw("ST_SetSRID(ST_MakePoint({$request->longitude}, {$request->latitude}), 4326)")
            ]);

            return $mitra;
        });
        
        return redirect()->route('mitra-industri.index')
            ->with('success', 'Mitra Industri berhasil ditambahkan.')
            ->with('download_qr_id', $mitra->id);
    }

    /**
     * Halaman Edit Mitra
     */
    public function edit($id)
    {
        // Load alamat dengan konversi lat/long + supervisor
        $mitraIndustri = MitraIndustri::with([
            'alamat' => function ($query) {
                $query->selectRaw("
                    *, 
                    ST_Y(location::geometry) as latitude, 
                    ST_X(location::geometry) as longitude
                ");
            },
            'supervisor:id,name,email,phone'
        ])->findOrFail($id);

        return Inertia::render('pendamping/MitraIndustri/edit', [
            'mitra' => $mitraIndustri,
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(), 
            'listPendampings' => User::pendamping()->select('id', 'name')->get(),
        ]);
    }

    /**
     * Update Data Mitra & Alamat & Supervisor
     */
    public function update(Request $request, $id)
    {
        $mitraIndustri = MitraIndustri::with('supervisor')->findOrFail($id);
        
        // Build validation rules
        $rules = [
            // Validasi Mitra
            'pendamping_id' => 'required',
            'nama_instansi' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'bidang_usaha' => 'required|string|max:255',
            'jam_masuk' => 'required',
            'jam_pulang' => 'required',
            'kuota' => 'required|integer|min:1',
            'jurusan_ids' => 'required|array',
            'jurusan_ids.*' => 'exists:jurusans,id',
            'tanggal_masuk' => 'required|date',

            // Validasi Alamat
            'profinsi' => 'required|string',
            'kabupaten' => 'required|string',
            'kecamatan' => 'required|string',
            'kode_pos' => 'required|numeric',
            'detail_alamat' => 'required|string',
            'radius_meter' => 'required|integer|min:10',
            
            // Validasi Koordinat
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            
            // Supervisor validation
            'supervisor_name' => 'required|string|max:255',
            'supervisor_phone' => 'nullable|string|max:20',
            'supervisor_password' => 'nullable|string|min:8', // Optional on edit
        ];

        // Email validation - ignore current supervisor's email
        if ($mitraIndustri->supervisor) {
            $rules['supervisor_email'] = [
                'required', 
                'email', 
                \Illuminate\Validation\Rule::unique('users', 'email')->ignore($mitraIndustri->supervisor->id)
            ];
        } else {
            $rules['supervisor_email'] = 'required|email|unique:users,email';
        }

        $request->validate($rules);

        DB::transaction(function () use ($request, $mitraIndustri) {
            // Update or create supervisor
            if ($mitraIndustri->supervisor) {
                $supervisorData = [
                    'name' => $request->supervisor_name,
                    'email' => $request->supervisor_email,
                    'phone' => $request->supervisor_phone,
                ];
                
                // Only update password if provided
                if ($request->filled('supervisor_password')) {
                    $supervisorData['password'] = \Illuminate\Support\Facades\Hash::make($request->supervisor_password);
                }
                
                $mitraIndustri->supervisor->update($supervisorData);
            } else {
                // Create new supervisor if not exists
                $supervisor = User::create([
                    'name' => $request->supervisor_name,
                    'email' => $request->supervisor_email,
                    'phone' => $request->supervisor_phone,
                    'password' => \Illuminate\Support\Facades\Hash::make($request->supervisor_password ?? 'password123'),
                    'role' => 'supervisors',
                    'is_active' => true,
                ]);
                $mitraIndustri->supervisors_id = $supervisor->id;
            }

            // 1. Update Mitra
            $mitraIndustri->update([
                'pendamping_id' => $request->pendamping_id,
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

    public function downloadQr($id)
    {
        $mitra = MitraIndustri::findOrFail($id);
        
        // Pastikan qr_value ada, jika tidak generate baru (untuk data lama)
        if (!$mitra->qr_value) {
            $mitra->qr_value = (string) \Illuminate\Support\Str::uuid();
            $mitra->save();
        }

        // Generate QR Code sebagai Base64 image
        $qrCode = base64_encode(QrCode::format('svg')->size(300)->generate($mitra->qr_value));

        // Load View PDF
        $pdf = Pdf::loadView('pdf.qrcode', compact('mitra', 'qrCode'));

        return $pdf->download('QR_Code_' . str_replace(' ', '_', $mitra->nama_instansi) . '.pdf');
    }
}