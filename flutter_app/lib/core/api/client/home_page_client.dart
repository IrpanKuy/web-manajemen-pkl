import 'package:flutter_app/data/models/response/home_page_response.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'home_page_client.g.dart';

@RestApi()
abstract class HomePageClient {
  factory HomePageClient(Dio dio, {String baseUrl}) = _HomePageClient;

  @GET("/homepage-data")
  Future<HomePageResponse> getHomePageData();
}
