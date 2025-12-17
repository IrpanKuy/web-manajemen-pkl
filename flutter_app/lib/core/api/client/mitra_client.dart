import 'package:dio/dio.dart';
import 'package:flutter_app/data/models/response/mitra_response.dart';
import 'package:retrofit/retrofit.dart';

part 'mitra_client.g.dart';

@RestApi()
abstract class MitraClient {
  factory MitraClient(Dio dio, {String baseUrl}) = _MitraClient;

  @GET("/mitra")
  Future<MitraListResponse> getMitras({
    @Query("search") String? search,
  });

  @GET("/mitra/{id}")
  Future<MitraDetailResponse> getMitraDetail(@Path("id") int id);
}
