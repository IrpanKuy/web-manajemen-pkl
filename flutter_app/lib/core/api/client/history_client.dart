import 'package:dio/dio.dart';
import 'package:flutter_app/data/models/response/absensi_list_response.dart';
import 'package:flutter_app/data/models/response/jurnal_list_response.dart';
import 'package:retrofit/retrofit.dart';

part 'history_client.g.dart';

@RestApi()
abstract class HistoryClient {
  factory HistoryClient(Dio dio, {String baseUrl}) = _HistoryClient;

  @GET("/absensi/history")
  Future<AbsensiHistoryResponse> getAbsensiHistory(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  @GET("/jurnal")
  Future<JurnalHistoryResponse> getJurnalHistory(
    @Query("month") int? month,
    @Query("year") int? year,
  );
}
