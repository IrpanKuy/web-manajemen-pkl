import 'package:json_annotation/json_annotation.dart';

part 'absensi_response.g.dart';

@JsonSerializable()
class AbsensiResponse {
  final bool success;
  final String message;
  final String? distance;
  // Bisa tambahkan data lain jika perlu

  AbsensiResponse({
    required this.success,
    required this.message,
    this.distance,
  });

  factory AbsensiResponse.fromJson(Map<String, dynamic> json) =>
      _$AbsensiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AbsensiResponseToJson(this);
}
