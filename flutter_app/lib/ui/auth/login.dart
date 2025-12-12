import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/core/api/rest_client.dart';
import 'package:flutter_app/data/models/login_request.dart';
import 'package:flutter_app/data/storage/token_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controller untuk inputan (opsional jika nanti mau dipakai)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late RestClient _client;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isLoading = false;

  // State untuk melihat password
  bool _isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    final dio = DioClient().dio;
    _client = RestClient(dio);
  }

  Future<void> _doLogin() async {
    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
          email: _emailController.text, password: _passwordController.text);

      final response = await _client.login(request);

      if (mounted) {
        if (response.token != null) {
          await _tokenStorage.saveToken(response.token!);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Berhasil!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login gagal!')),
          );
        }
      }
    } on DioException catch (e) {
      String errorMessage = "Terjadi kesalahan";
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? "Login Gagal";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. LOGO SEKOLAH
                Container(
                  height: 120, // Sesuaikan tinggi logo
                  width: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo-mutu.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. TEKS SELAMAT DATANG
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A), // Warna biru tua (sesuaikan tema)
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan login untuk melanjutkan',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 40),

                // 3. FORM INPUT
                // Input Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Email',
                    hintText: 'masukkan email anda',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E3A8A),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Input Password
                TextField(
                  controller: _passwordController,
                  obscureText:
                      !_isPasswordVisible, // Sembunyikan/tampilkan teks
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Password',
                    hintText: 'masukkan password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1E3A8A),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Lupa Password (Opsional)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Aksi lupa password
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. TOMBOL LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A), // Warna tombol
                      foregroundColor: Colors.white, // Warna teks
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'MASUK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Footer (Opsional)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke register
                      },
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
