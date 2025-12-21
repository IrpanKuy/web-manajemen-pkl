<?php

namespace App\Http\Controllers\pendamping;

use App\Http\Controllers\Controller;
use App\Models\Pendamping\Jurusan;
use App\Models\User;
use App\Exports\SiswaExport;
use App\Imports\SiswaImport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Maatwebsite\Excel\Facades\Excel;

class DataSiswaController extends Controller
{
    public function index()
    {
        // Scope 'siswa' otomatis load relasi profile & jurusan
        $siswas = User::siswa()
            ->latest()
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('pendamping/data-siswa', [
            'siswas' => $siswas,
            'jurusans' => Jurusan::select('id', 'nama_jurusan')->get(),
        ]);
    }

    public function create()
    {
    }

    public function store(Request $request)
    {
        $request->validate([
            // Validasi Data User
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => 'nullable|string|max:20',
            // Validasi Data Profil Siswa
            'nisn' => 'required|string|unique:profile_siswas,nisn',
            'jurusan_id' => 'required|exists:jurusans,id',
            'is_active' => 'boolean',
        ]);

        DB::transaction(function () use ($request) {
            // A. Create User
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'role' => 'siswa', // Hardcode role siswa
                'is_active' => $request->is_active,
            ]);

            // B. Create Profil Siswa
            $user->siswas()->create([
                'nisn' => $request->nisn,
                'jurusan_id' => $request->jurusan_id,
            ]);
        });

        return redirect()->route('data-siswa.index')->with('success', 'Siswa berhasil ditambahkan.');
    }

    public function edit(User $user)
    {
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => ['required', 'email', Rule::unique('users')->ignore($request->id)],
            'phone' => 'nullable|string|max:20',
            'password' => 'nullable|string|min:8',
            // Validasi Profil (Ignore NISN milik sendiri saat update)
            'nisn' => ['required'],
            'jurusan_id' => 'required|exists:jurusans,id',
            'is_active' => 'boolean',
        ]);

        DB::transaction(function () use ($request, $id) {
            // Cari user
            $siswa = User::findOrFail($id);

            // 1. Siapkan array data User dasar
            $userData = [
                'name'  => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'is_active' => $request->is_active,
            ];

            // 2. Cek Password: Jika diisi, tambahkan ke dalam array $userData
            if ($request->filled('password')) {
                $userData['password'] = Hash::make($request->password);
            }

            // 3. Eksekusi Update User (Hanya 1 kali query database) ✨
            $siswa->update($userData);

            // 4. Update Profil Siswa
            // Catatan: Ini asumsinya data profile SUDAH ADA sebelumnya.
            $siswa->siswas()->update([
                'nisn'       => $request->nisn,
                'jurusan_id' => $request->jurusan_id,
            ]);
        });

        return redirect()->route('data-siswa.index')->with('success', 'Data Siswa diperbarui.');
    }

    public function destroy($id)
    {
        User::findOrFail($id)->delete();
        return redirect()->route('data-siswa.index')->with('success', 'Siswa dihapus.');
    }

    /**
     * Export data siswa ke Excel
     */
    public function export(Request $request)
    {
        $search = $request->get('search');
        $jurusanId = $request->get('jurusan_id');
        
        $filename = 'data-siswa-' . date('Y-m-d-His') . '.xlsx';
        
        return Excel::download(new SiswaExport($search, $jurusanId), $filename);
    }

    /**
     * Import data siswa dari Excel
     */
    public function import(Request $request)
    {
        $request->validate([
            'file' => 'required|mimes:xlsx,xls|max:2048',
        ], [
            'file.required' => 'File Excel harus diupload',
            'file.mimes' => 'File harus berformat Excel (.xlsx atau .xls)',
            'file.max' => 'Ukuran file maksimal 2MB',
        ]);

        $import = new SiswaImport();
        Excel::import($import, $request->file('file'));

        if (count($import->errors) > 0) {
            return redirect()->back()->with('error', implode('<br>', $import->errors));
        }

        return redirect()->route('data-siswa.index')
            ->with('success', "Berhasil mengimport {$import->successCount} data siswa.");
    }

    /**
     * Download template import Excel
     */
    public function downloadTemplate()
    {
        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        // Set headers
        $headers = ['nama', 'email', 'no_hp', 'nisn', 'jurusan_id', 'password'];
        $sheet->fromArray($headers, null, 'A1');
        
        // Style header row
        $sheet->getStyle('A1:F1')->applyFromArray([
            'font' => [
                'bold' => true,
                'color' => ['argb' => 'FFFFFFFF'],
            ],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['argb' => 'FF4A60AA'],
            ],
        ]);
        
        // Add sample data
        $sampleData = [
            ['Ahmad Fauzi', 'ahmad@siswa.com', '081234567890', '1234567890', '1', 'password123'],
            ['Budi Santoso', 'budi@siswa.com', '089876543210', '0987654321', '2', ''],
        ];
        $sheet->fromArray($sampleData, null, 'A2');
        
        // Add instructions in new sheet
        $instructionSheet = $spreadsheet->createSheet();
        $instructionSheet->setTitle('Petunjuk');
        $instructionSheet->setCellValue('A1', 'PETUNJUK PENGISIAN:');
        $instructionSheet->setCellValue('A2', '1. Kolom nama, email, nisn, jurusan_id WAJIB diisi');
        $instructionSheet->setCellValue('A3', '2. Kolom no_hp dan password OPTIONAL');
        $instructionSheet->setCellValue('A4', '3. Jika password kosong, akan menggunakan default: password123');
        $instructionSheet->setCellValue('A5', '4. jurusan_id adalah ID jurusan (lihat daftar jurusan di aplikasi)');
        $instructionSheet->setCellValue('A6', '5. Hapus baris contoh data sebelum import');
        
        // Auto size columns
        foreach (range('A', 'F') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }
        
        // Create writer and output
        $writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);
        $filename = 'template-import-siswa.xlsx';
        
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $filename . '"');
        header('Cache-Control: max-age=0');
        
        $writer->save('php://output');
        exit;
    }
}