import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/models/response/izin_response.dart';
import 'package:retrofit/retrofit.dart';

part 'izin_client.g.dart';

@RestApi()
abstract class IzinClient {
  factory IzinClient(Dio dio, {String baseUrl}) = _IzinClient;

  @GET("/izin")
  Future<IzinListResponse> getIzinList(
    @Query("month") int? month,
    @Query("year") int? year,
  );

  @POST("/izin")
  @MultiPart()
  Future<IzinActionResponse> submitIzin(
    @Part(name: "tgl_mulai") String tglMulai,
    @Part(name: "tgl_selesai") String tglSelesai,
    @Part(name: "keterangan") String keterangan,
    @Part(name: "bukti") File? bukti,
  );

  @DELETE("/izin/{id}")
  Future<IzinActionResponse> cancelIzin(@Path("id") int id);
}
