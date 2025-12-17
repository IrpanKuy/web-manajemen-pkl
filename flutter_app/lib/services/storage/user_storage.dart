import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/response/auth_response.dart'; // Import agar class User dikenali

class UserStorage {
  static const String _kUserKey = 'user_profile';

  // Simpan User
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Encode object User menjadi String JSON
    String userJson = jsonEncode(user.toJson());
    await prefs.setString(_kUserKey, userJson);
  }

  // Ambil User
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_kUserKey);
    if (userJson != null) {
      // Decode String JSON kembali menjadi object User
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Hapus User (Logout)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
  }
}
