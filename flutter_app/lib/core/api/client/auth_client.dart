import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../../data/models/request/login_request.dart';
import '../../../data/models/response/auth_response.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  @POST("/login")
  Future<AuthResponse> login(@Body() LoginRequest request);

  // Bisa tambah register atau forgot-password di sini
}
