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

  final SiswaData? siswas;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.siswas,
  });

  // convert JSON → User
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // convert User → JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class SiswaData {
  final JurusanData? jurusan;

  SiswaData({
    this.jurusan,
  });

  // convert JSON → SiswaData
  factory SiswaData.fromJson(Map<String, dynamic> json) =>
      _$SiswaDataFromJson(json);

  // convert SiswaData → JSON
  Map<String, dynamic> toJson() => _$SiswaDataToJson(this);
}

@JsonSerializable()
class JurusanData {
  final int id;
  @JsonKey(name: 'nama_jurusan')
  final String namaJurusan;

  JurusanData({
    required this.id,
    required this.namaJurusan,
  });

  // convert JSON → JurusanData
  factory JurusanData.fromJson(Map<String, dynamic> json) =>
      _$JurusanDataFromJson(json);

  // convert JurusanData → JSON
  Map<String, dynamic> toJson() => _$JurusanDataToJson(this);
}
