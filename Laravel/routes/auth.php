<?php

use App\Http\Controllers\Login;
use App\Http\Controllers\Register;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::post('login', [Login::class, 'authenticate'])->name('login');
Route::post('register', [Register::class, 'store'])->name('register');
Route::post('/logout', function () {
    // 1. Hancurkan sesi otentikasi pengguna saat ini
    Auth::logout();

    return redirect()->route('login'); 
    
    // Catatan: Ganti 'login' dengan nama route login Anda jika berbeda.
})->name('logout');