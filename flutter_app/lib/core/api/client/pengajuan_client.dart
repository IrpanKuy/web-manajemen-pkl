import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'pengajuan_client.g.dart';

@RestApi()
abstract class PengajuanClient {
  factory PengajuanClient(Dio dio, {String baseUrl}) = _PengajuanClient;

  @POST("/pengajuan-masuk")
  @MultiPart()
  Future<dynamic> postPengajuan({
    @Part(name: "mitra_id") required int mitraId,
    @Part(name: "durasi") required int durasi,
    @Part(name: "deskripsi") required String deskripsi,
    @Part(name: "cv") File? cv,
  });

  @GET("/pengajuan-status")
  Future<StatusLamaranResponse> getStatus();
}

class StatusLamaranResponse {
  final bool success;
  final dynamic data; // Start with dynamic, refine later

  StatusLamaranResponse({required this.success, this.data});

  // Basic serialization
  factory StatusLamaranResponse.fromJson(Map<String, dynamic> json) {
    return StatusLamaranResponse(
      success: json['success'] ?? false,
      data: json['data'],
    );
  }
}
