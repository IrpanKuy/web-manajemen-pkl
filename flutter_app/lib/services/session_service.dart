import '../data/models/response/auth_response.dart';
import '../data/storage/token_storage.dart';
import '../data/storage/user_storage.dart';

class SessionService {
  final TokenStorage _tokenStorage = TokenStorage();
  final UserStorage _userStorage = UserStorage();

  // --- SAVE SESSION (Dipanggil saat Login Sukses) ---
  Future<void> saveSession(String token, User user) async {
    // Jalankan secara paralel agar cepat
    await Future.wait([
      _tokenStorage.saveToken(token),
      _userStorage.saveUser(user),
    ]);
  }

  // --- CLEAR SESSION (Dipanggil saat Logout) ---
  Future<void> logout() async {
    await Future.wait([
      _tokenStorage.deleteToken(),
      _userStorage.clearUser(),
    ]);
  }

  // --- CEK APAKAH LOGIN? ---
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  // --- GET CURRENT USER ---
  Future<User?> getCurrentUser() async {
    return await _userStorage.getUser();
  }
}
