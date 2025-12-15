import 'package:json_annotation/json_annotation.dart';

part 'absensi_request.g.dart';

@JsonSerializable()
class AbsensiRequest {
  @JsonKey(name: 'qr_value')
  final String qrValue;
  final double latitude;
  final double longitude;

  AbsensiRequest({
    required this.qrValue,
    required this.latitude,
    required this.longitude,
  });

  factory AbsensiRequest.fromJson(Map<String, dynamic> json) =>
      _$AbsensiRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AbsensiRequestToJson(this);
}
