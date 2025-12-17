import 'package:json_annotation/json_annotation.dart';

part 'izin_response.g.dart';

@JsonSerializable()
class Izin {
  final int id;

  @JsonKey(name: 'tgl_mulai')
  final String tglMulai;

  @JsonKey(name: 'tgl_selesai')
  final String tglSelesai;

  @JsonKey(name: 'durasi_hari', defaultValue: 1)
  final int durasiHari;

  @JsonKey(defaultValue: '')
  final String keterangan;

  @JsonKey(name: 'bukti_path')
  final String? buktiPath;

  @JsonKey(defaultValue: 'pending')
  final String status; // pending, approved, rejected

  final String? komentar;

  Izin({
    required this.id,
    required this.tglMulai,
    required this.tglSelesai,
    required this.durasiHari,
    required this.keterangan,
    this.buktiPath,
    required this.status,
    this.komentar,
  });

  factory Izin.fromJson(Map<String, dynamic> json) => _$IzinFromJson(json);
  Map<String, dynamic> toJson() => _$IzinToJson(this);
}

@JsonSerializable()
class IzinListResponse {
  final bool success;

  @JsonKey(defaultValue: [])
  final List<Izin> data;

  IzinListResponse({
    required this.success,
    required this.data,
  });

  factory IzinListResponse.fromJson(Map<String, dynamic> json) =>
      _$IzinListResponseFromJson(json);
}

@JsonSerializable()
class IzinActionResponse {
  final bool success;
  final String? message;
  final Izin? data;

  IzinActionResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory IzinActionResponse.fromJson(Map<String, dynamic> json) =>
      _$IzinActionResponseFromJson(json);
}
