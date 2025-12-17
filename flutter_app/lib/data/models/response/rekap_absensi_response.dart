import 'package:json_annotation/json_annotation.dart';

part 'rekap_absensi_response.g.dart';

@JsonSerializable()
class Absensi {
  final int id;
  final String tanggal;

  @JsonKey(name: 'jam_masuk')
  final String? jamMasuk;

  @JsonKey(name: 'jam_pulang')
  final String? jamPulang;

  @JsonKey(name: 'status_kehadiran', defaultValue: 'pending')
  final String statusKehadiran; // hadir, telat, izin, sakit, alpha, pending

  Absensi({
    required this.id,
    required this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    required this.statusKehadiran,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) =>
      _$AbsensiFromJson(json);
  Map<String, dynamic> toJson() => _$AbsensiToJson(this);
}

@JsonSerializable()
class AbsensiSummary {
  @JsonKey(defaultValue: 0)
  final int hadir;

  @JsonKey(defaultValue: 0)
  final int telat;

  @JsonKey(defaultValue: 0)
  final int sakit;

  @JsonKey(defaultValue: 0)
  final int izin;

  @JsonKey(defaultValue: 0)
  final int alpha;

  @JsonKey(name: 'total_hadir_count', defaultValue: 0)
  final int totalHadirCount;

  AbsensiSummary({
    required this.hadir,
    required this.telat,
    required this.sakit,
    required this.izin,
    required this.alpha,
    required this.totalHadirCount,
  });

  factory AbsensiSummary.fromJson(Map<String, dynamic> json) =>
      _$AbsensiSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$AbsensiSummaryToJson(this);
}
