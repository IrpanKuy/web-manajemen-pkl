import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final bool success;
  // ⬆️ menandakan request sukses true/false dari backend

  final String message;
  // ⬆️ pesan dari backend: "Login Berhasil" / error lain

  final AuthData? data;
  // ⬆️ isi utama response (token + user) ada di dalam "data"

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  // ⬇️ convert JSON → AuthResponse (dipakai Retrofit)
  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  // ⬇️ convert AuthResponse → JSON
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthData {
  final String? token;
  // ⬆️ token login dari Sanctum → ada di "data.token"

  final User? user;
  // ⬆️ detail user (id, name, email, role)

  AuthData({this.token, this.user});

  // convert JSON → AuthData
  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);

  // convert AuthData → JSON
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class User {
  final int id;
  // ⬆️ user id dari database

  final String name;
  // ⬆️ nama user

  final String email;
  // ⬆️ email untuk login

  final String role;
  // ⬆️ pengguna: siswa / pendamping / supervisors / pembimbing

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // convert JSON → User
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // convert User → JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
