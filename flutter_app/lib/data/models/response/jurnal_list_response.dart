import 'package:json_annotation/json_annotation.dart';

part 'jurnal_list_response.g.dart';

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

@JsonSerializable()
class Jurnal {
  final int id;
  final String tanggal;
  final String judul;

  @JsonKey(defaultValue: '')
  final String deskripsi;

  @JsonKey(defaultValue: 'pending')
  final String status;

  Jurnal({
    required this.id,
    required this.tanggal,
    required this.judul,
    required this.deskripsi,
    required this.status,
  });

  factory Jurnal.fromJson(Map<String, dynamic> json) => _$JurnalFromJson(json);
  Map<String, dynamic> toJson() => _$JurnalToJson(this);
}

@JsonSerializable()
class JurnalSummary {
  @JsonKey(name: 'total_jurnal', defaultValue: 0)
  final int totalJurnal;

  JurnalSummary({required this.totalJurnal});

  factory JurnalSummary.fromJson(Map<String, dynamic> json) =>
      _$JurnalSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$JurnalSummaryToJson(this);
}
