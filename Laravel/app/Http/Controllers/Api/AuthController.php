<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // 1. Validasi Input: Memastikan data yang dikirim Flutter sesuai format
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // 2. Proses Otentikasi: Laravel mengecek ke database
        // Jika email/password tidak cocok, kembalikan error 401
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }
        // 3. Generate Token: Jika cocok, buat token Sanctum
        $user = Auth::user();
        // 'auth_token' adalah nama token yang kita berikan
        $token = $user->createToken('auth_token')->plainTextToken;
        // 4. Return Response: Kirim JSON berisi token dan data user ke Flutter
        return response()->json([
            'success' => true,
            'message' => 'Login Berhasil',
            'data' => [
                'token' => $token, // Ini kunci penting untuk Flutter! 🔑
                'user' => $user
            ]
        ], 200);
    }
}