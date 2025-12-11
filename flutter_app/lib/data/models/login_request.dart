import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart'; // <--- Pastikan nama ini sama dengan nama file .dart nya

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  // Retrofit butuh ini untuk mengirim data (Request Body)
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
