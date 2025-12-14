import 'package:dio/dio.dart';
import '../../data/storage/token_storage.dart';
import '../../services/session_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage();
  final SessionService _sessionService = SessionService();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 1. Ambil token
      final token = await _tokenStorage.readToken();

      // --- DEBUGGING: CEK DI TERMINAL ---
      print("🔍 [AuthInterceptor] Cek Token...");

      if (token != null && token.isNotEmpty) {
        // 2. Tempel token jika ada
        options.headers['Authorization'] = 'Bearer $token';
        print("✅ [AuthInterceptor] Token ditemukan: $token");
        print(
            "✅ [AuthInterceptor] Header dipasang: ${options.headers['Authorization']}");
      } else {
        // Token kosong
        print("⚠️ [AuthInterceptor] Token NULL atau KOSONG!");
      }
    } catch (e) {
      print("❌ [AuthInterceptor] Error saat baca token: $e");
    }

    // 3. PENTING: Lanjut kirim request (Panggil ini di akhir setelah await selesai)
    // Jangan pakai super.onRequest(options, handler) kalau di dalam async
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("❌ [AuthInterceptor] Error Response: ${err.response?.statusCode}");

    if (err.response?.statusCode == 401) {
      print("⚠️ [AuthInterceptor] 401 Detected - Logout paksa");
      _sessionService.logout();
    }
    handler.next(err);
  }
}
