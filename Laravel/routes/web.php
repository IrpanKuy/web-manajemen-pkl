<?php

use App\Http\Controllers\approval\PengajuanMasukSiswaController;
use App\Http\Controllers\Instansi\MitraIndustriController;
use App\Http\Controllers\pembimbing\AbsensiHarianController;
use App\Http\Controllers\pembimbing\JurnalSiswaController;
use App\Http\Controllers\pembimbing\MentorRequestController;
use App\Http\Controllers\pembimbing\PengajuanIzinController;
use App\Http\Controllers\pembimbing\RekapAbsensiController;
use App\Http\Controllers\pembimbing\SiswaBimbinganController;
use App\Http\Controllers\pendamping\DataSiswaController;
use App\Http\Controllers\pendamping\JurusanController;
use App\Http\Controllers\pendamping\manajemenRoleController;
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
    Route::resource('mitra-industri', MitraIndustriController::class);
    Route::resource('manajemen-role', manajemenRoleController::class);
    Route::resource('jurusan', JurusanController::class);
    Route::resource('data-siswa', DataSiswaController::class);
    Route::get('/mitra-industri/{id}/download-qr', [MitraIndustriController::class, 'downloadQr'])->name('mitra-industri.download-qr');
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