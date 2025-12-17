<?php

use App\Http\Controllers\approval\PengajuanMasukSiswaController;
use App\Http\Controllers\Instansi\MitraIndustriController;
use App\Http\Controllers\pembimbing\JurnalSiswaController;
use App\Http\Controllers\pembimbing\MentorRequestController;
use App\Http\Controllers\pembimbing\RekapAbsensiController;
use App\Http\Controllers\pendamping\DataSiswaController;
use App\Http\Controllers\pendamping\JurusanController;
use App\Http\Controllers\pendamping\manajemenRoleController;
use App\Http\Controllers\supervisor\AkunPembimbingController;
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
});

// route pembimbing
Route::prefix('pembimbing')->middleware(['HasAuth', 'HasPembimbing'])->group(function(){
    Route::resource('jurnal-siswa', JurnalSiswaController::class)->only(['index', 'update']);
    Route::resource('mentor-request', MentorRequestController::class)->only(['index', 'update']);
    Route::get('rekap-absensi', [RekapAbsensiController::class, 'index'])->name('rekap-absensi.index');
});

Route::get('/register', function () {
    return Inertia::render('register'); 
})->name('register');



require __DIR__ .'/auth.php';