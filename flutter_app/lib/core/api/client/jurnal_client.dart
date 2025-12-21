import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'jurnal_client.g.dart';

@RestApi()
abstract class JurnalClient {
  factory JurnalClient(Dio dio, {String baseUrl}) = _JurnalClient;

  @GET("/jurnal")
  Future<Map<String, dynamic>> getJurnalList({
    @Query("month") int? month,
    @Query("year") int? year,
  });

  @GET("/jurnal/{id}")
  Future<Map<String, dynamic>> getJurnalDetail(@Path("id") int id);

  // Note: For file upload, use Dio directly with FormData
  // The createJurnal method in form uses Dio directly.
}
