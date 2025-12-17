import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _kAuthTokenKey = 'auth_token';

// Menggunakan nama class TokenStorage sesuai domain (Auth/Data/Storage)
class TokenStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Menyimpan Token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _kAuthTokenKey, value: token);
      print('Token berhasil disimpan.');
    } catch (e) {
      print('Gagal menyimpan token: $e');
    }
  }

  // Mengambil Token
  Future<String?> readToken() async {
    try {
      final token = await _secureStorage.read(key: _kAuthTokenKey);
      return token;
    } catch (e) {
      print('Gagal membaca token: $e');
      return null;
    }
  }

  // Menghapus Token (Logout)
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _kAuthTokenKey);
      print('Token berhasil dihapus.');
    } catch (e) {
      print('Gagal menghapus token: $e');
    }
  }
}
