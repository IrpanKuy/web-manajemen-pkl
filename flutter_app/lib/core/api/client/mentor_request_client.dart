import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_app/data/models/response/mentor_request_response.dart';

part 'mentor_request_client.g.dart';

@RestApi()
abstract class MentorRequestClient {
  factory MentorRequestClient(Dio dio, {String baseUrl}) = _MentorRequestClient;

  @GET('/mentor-request')
  Future<MentorRequestPageResponse> getMentorRequestData();

  @POST('/mentor-request')
  Future<MentorRequestActionResponse> submitMentorRequest(
    @Field('pembimbing_baru_id') int pembimbingBaruId,
    @Field('alasan') String alasan,
  );

  @DELETE('/mentor-request/{id}')
  Future<MentorRequestActionResponse> cancelMentorRequest(@Path('id') int id);
}
