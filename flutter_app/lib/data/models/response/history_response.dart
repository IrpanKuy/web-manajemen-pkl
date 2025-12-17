import 'package:flutter_app/data/models/response/rekap_absensi_response.dart';
import 'package:flutter_app/data/models/response/jurnal_list_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'history_response.g.dart';

@JsonSerializable()
class AbsensiHistoryResponse {
  final bool success;

  @JsonKey(defaultValue: [])
  final List<Absensi> data;

  final AbsensiSummary? summary;

  AbsensiHistoryResponse({
    required this.success,
    required this.data,
    this.summary,
  });

  factory AbsensiHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$AbsensiHistoryResponseFromJson(json);
}

@JsonSerializable()
class JurnalHistoryResponse {
  final bool success;

  @JsonKey(defaultValue: [])
  final List<Jurnal> data;

  final JurnalSummary? summary;

  JurnalHistoryResponse({
    required this.success,
    required this.data,
    this.summary,
  });

  factory JurnalHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$JurnalHistoryResponseFromJson(json);
}
