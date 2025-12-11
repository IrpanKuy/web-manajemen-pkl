import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  // <--- NAMA INI HARUS SAMA dengan yang dipanggil di RestClient
  final String message;
  final String? token;

  AuthResponse({required this.message, this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
