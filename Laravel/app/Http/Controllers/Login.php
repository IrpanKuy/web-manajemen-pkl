<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

use function Laravel\Prompts\error;

class Login extends Controller
{
    public function authenticate(Request $request)
    {


        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();
            if (Auth::user()->role == 'supervisors') {
                if (!Auth::user()->mitraIndustri()->exists()) {
                    return redirect()->route('login')->with('error', 'Instansi Belum diatur');
                }
                return redirect()->route('pengajuan-masuk.index');

            }
            elseif (Auth::user()->role == 'supervisors') {
                return redirect()->route('pendamping.instansi');

            }
        }

        return redirect()->route('login')->with('error', 'Email Atau Password Salah');
    }
}
