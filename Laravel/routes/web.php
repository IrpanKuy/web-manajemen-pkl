<?php

use App\Http\Controllers\approval\PengajuanMasukSiswaController;
use App\Http\Controllers\approval\PengajuanPengeluaranController;
use App\Http\Controllers\Instansi\MitraIndustriController;
use App\Http\Controllers\pembimbing\AbsensiHarianController;
use App\Http\Controllers\pembimbing\JurnalSiswaController;
use App\Http\Controllers\pembimbing\MentorRequestController;
use App\Http\Controllers\pembimbing\PengajuanIzinController;
use App\Http\Controllers\pembimbing\RekapAbsensiController;
use App\Http\Controllers\pembimbing\SiswaBimbinganController;
use App\Http\Controllers\pendamping\DashboardController;
use App\Http\Controllers\pendamping\DataSiswaController;
use App\Http\Controllers\pendamping\JurusanController;
use App\Http\Controllers\pendamping\LaporanBulananController;
use App\Http\Controllers\pendamping\LaporanHarianController;
use App\Http\Controllers\pendamping\LaporanMingguanController;
use App\Http\Controllers\pendamping\manajemenRoleController;
use App\Http\Controllers\pendamping\RekapIzinController;
use App\Http\Controllers\pendamping\RekapJurnalController;
use App\Http\Controllers\pendamping\PenempatanSiswaController;
use App\Http\Controllers\pendamping\PengajuanPengeluaranSiswaController;
use App\Http\Controllers\supervisor\AkunPembimbingController;
use App\Http\Controllers\supervisor\DataAbsensiBulananController;
use App\Http\Controllers\supervisor\DataAbsensiHarianController;
use App\Http\Controllers\supervisor\DataIzinController;
use App\Http\Controllers\supervisor\DataJurnalController;
use App\Http\Controllers\supervisor\DataSiswaPklController;
use App\Http\Controllers\supervisor\profileInstansiController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use PhpParser\Builder\Function_;

Route::get('/welcome', function () {
    return Inertia::render('welcome'); 
})->name('welcome');

Route::get('/login', function () {
    return Inertia::render('login'); 
})->name('login');
// route pendamping
Route::prefix('pendamping')->middleware(['HasAuth', 'HasPendamping'])->group(function(){
    Route::get('dashboard', [DashboardController::class, 'index'])->name('pendamping.dashboard');
    Route::resource('mitra-industri', MitraIndustriController::class);
    Route::get('/mitra-industri/{id}/download-qr', [MitraIndustriController::class, 'downloadQr'])->name('mitra-industri.download-qr');
    Route::get('/mitra-industri/{id}/detail', [MitraIndustriController::class, 'detail'])->name('mitra-industri.detail');
    Route::resource('jurusan', JurusanController::class);
    Route::resource('data-siswa', DataSiswaController::class);
    
    // Manajemen Role - Only for Admin
    Route::resource('manajemen-role', manajemenRoleController::class)->middleware('IsAdmin');
    
    // Laporan Absensi
    Route::get('laporan-harian', [LaporanHarianController::class, 'index'])->name('laporan-harian.index');
    Route::get('laporan-mingguan', [LaporanMingguanController::class, 'index'])->name('laporan-mingguan.index');
    Route::get('laporan-bulanan', [LaporanBulananController::class, 'index'])->name('laporan-bulanan.index');
    
    // Rekap Data
    Route::get('rekap-jurnal', [RekapJurnalController::class, 'index'])->name('rekap-jurnal.index');
    Route::get('rekap-izin', [RekapIzinController::class, 'index'])->name('rekap-izin.index');
    
    // Penempatan Siswa
    Route::get('penempatan-siswa', [PenempatanSiswaController::class, 'index'])->name('penempatan-siswa.index');
    Route::get('penempatan-siswa/{id}', [PenempatanSiswaController::class, 'show'])->name('penempatan-siswa.show');
    
    // Pengajuan Pengeluaran Siswa
    Route::get('pengajuan-pengeluaran', [PengajuanPengeluaranSiswaController::class, 'index'])->name('pengajuan-pengeluaran.index');
    Route::post('pengajuan-pengeluaran/{id}/approve', [PengajuanPengeluaranSiswaController::class, 'approve'])->name('pengajuan-pengeluaran.approve');
    Route::post('pengajuan-pengeluaran/{id}/reject', [PengajuanPengeluaranSiswaController::class, 'reject'])->name('pengajuan-pengeluaran.reject');
});

// route supervisor
Route::prefix('supervisors')->middleware(['HasAuth', 'HasSupervisors'])->group(function(){
    Route::resource('pengajuan-masuk', PengajuanMasukSiswaController::class);
    Route::resource('akun-pembimbing', AkunPembimbingController::class);
    Route::resource('profile-instansi', profileInstansiController::class);
    Route::get('/download-qrcode', [profileInstansiController::class, 'downloadQrCode'])->name('profile-instansi.downloadQrCode');
    
    // Read-only data pages
    Route::get('data-siswa-pkl', [DataSiswaPklController::class, 'index'])->name('data-siswa-pkl.index');
    Route::get('data-izin', [DataIzinController::class, 'index'])->name('data-izin.index');
    Route::get('data-jurnal', [DataJurnalController::class, 'index'])->name('data-jurnal.index');
    Route::get('data-absensi-harian', [DataAbsensiHarianController::class, 'index'])->name('data-absensi-harian.index');
    Route::get('data-absensi-bulanan', [DataAbsensiBulananController::class, 'index'])->name('data-absensi-bulanan.index');
    
    // Pengajuan Pengeluaran
    Route::post('pengajuan-pengeluaran', [PengajuanPengeluaranController::class, 'store'])->name('pengajuan-pengeluaran.store');
});

// route pembimbing
Route::prefix('pembimbing')->middleware(['HasAuth', 'HasPembimbing'])->group(function(){
    Route::resource('siswa-bimbingan', SiswaBimbinganController::class)->only(['index', 'show']);
    Route::resource('jurnal-siswa', JurnalSiswaController::class)->only(['index', 'update']);
    Route::resource('mentor-request', MentorRequestController::class)->only(['index', 'update']);
    Route::resource('pengajuan-izin', PengajuanIzinController::class)->only(['index', 'update']);
    Route::get('absensi-harian', [AbsensiHarianController::class, 'index'])->name('absensi-harian.index');
    Route::get('rekap-absensi', [RekapAbsensiController::class, 'index'])->name('rekap-absensi.index');
});

Route::get('/register', function () {
    return Inertia::render('register'); 
})->name('register');



require __DIR__ .'/auth.php';