<?php

use App\Http\Controllers\Login;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::post('login', [Login::class, 'authenticate'])->name('login');
Route::post('/logout', function () {
    // 1. Hancurkan sesi otentikasi pengguna saat ini
    Auth::logout();

    return redirect()->route('login'); 
    
    // Catatan: Ganti 'login' dengan nama route login Anda jika berbeda.
})->name('logout');