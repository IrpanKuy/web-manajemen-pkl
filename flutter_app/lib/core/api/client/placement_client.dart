import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_app/data/models/response/placement_detail_response.dart';

part 'placement_client.g.dart';

@RestApi()
abstract class PlacementClient {
  factory PlacementClient(Dio dio, {String baseUrl}) = _PlacementClient;

  @GET("/placement/detail")
  Future<PlacementDetailResponse> getPlacementDetail();
}
