<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\HomePageDataController;
use App\Http\Controllers\Api\AbsensiController;
use App\Http\Controllers\Api\MitraController;
use App\Http\Controllers\Api\PengajuanMasukController;
use App\Http\Controllers\Api\PlacementController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Endpoint ini akan menerima method POST
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/homepage-data', [HomePageDataController::class, 'index']);
    Route::post('/absensi/scan', [AbsensiController::class, 'store']); // Scan Absen
    Route::get('/mitra', [MitraController::class, 'index']);      // List Mitra
    Route::get('/mitra/{id}', [MitraController::class, 'show']);  // Detail Mitra
    
    Route::post('/pengajuan-masuk', [PengajuanMasukController::class, 'store']); // Apply
    Route::get('/pengajuan-status', [PengajuanMasukController::class, 'getStatus']); // Latest Status
    Route::get('/pengajuan-history', [PengajuanMasukController::class, 'getHistory']); // List History
    
    Route::get('/placement/detail', [PlacementController::class, 'show']); // Active Placement Detail
    
    // History Routes
    Route::get('/absensi/history', [AbsensiController::class, 'history']);
    Route::get('/jurnal', [\App\Http\Controllers\Api\JurnalController::class, 'index']);
});
