import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

// Import model yang benar sesuai struktur foldermu
import '../../data/models/login_request.dart';
import '../../data/models/auth_response.dart';

part 'rest_client.g.dart'; // Hanya boleh ada SATU baris ini

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @POST("/login")
  // Perhatikan: Gunakan AuthResponse jika itu nama class di dalam file auth_response.dart
  Future<AuthResponse> login(@Body() LoginRequest request);
}
