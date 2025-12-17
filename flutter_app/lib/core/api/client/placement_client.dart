import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'placement_client.g.dart';

@RestApi()
abstract class PlacementClient {
  factory PlacementClient(Dio dio, {String baseUrl}) = _PlacementClient;

  @GET("/placement/detail")
  Future<PlacementResponse> getPlacementDetail();
}

class PlacementResponse {
  final bool success;
  final String? message;
  final dynamic data;

  PlacementResponse({required this.success, this.message, this.data});

  factory PlacementResponse.fromJson(Map<String, dynamic> json) {
    return PlacementResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
    );
  }
}
