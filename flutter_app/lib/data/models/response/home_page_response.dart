import 'package:json_annotation/json_annotation.dart';

part 'home_page_response.g.dart';

@JsonSerializable()
class HomePageResponse {
  final bool success;
  final String message;
  final HomePageData? data;

  HomePageResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory HomePageResponse.fromJson(Map<String, dynamic> json) =>
      _$HomePageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HomePageResponseToJson(this);
}

@JsonSerializable()
class HomePageData {
  final PenempatanData? penempatan;
  final AbsensiData? absensi;
  final JurnalData? jurnal;

  HomePageData({
    this.penempatan,
    this.absensi,
    this.jurnal,
  });

  factory HomePageData.fromJson(Map<String, dynamic> json) =>
      _$HomePageDataFromJson(json);

  Map<String, dynamic> toJson() => _$HomePageDataToJson(this);
}

@JsonSerializable()
class PenempatanData {
  final bool status;
  @JsonKey(name: 'nama_instansi')
  final String? namaInstansi;
  final String? pembimbing;

  PenempatanData({
    required this.status,
    this.namaInstansi,
    this.pembimbing,
  });

  factory PenempatanData.fromJson(Map<String, dynamic> json) =>
      _$PenempatanDataFromJson(json);

  Map<String, dynamic> toJson() => _$PenempatanDataToJson(this);
}

@JsonSerializable()
class AbsensiData {
  final String? status;
  @JsonKey(name: 'jam_masuk')
  final String? jamMasuk;
  @JsonKey(name: 'jam_pulang')
  final String? jamPulang;
  @JsonKey(name: 'status_kehadiran')
  final String? statusKehadiran;

  AbsensiData({
    this.status,
    this.jamMasuk,
    this.jamPulang,
    this.statusKehadiran,
  });

  factory AbsensiData.fromJson(Map<String, dynamic> json) =>
      _$AbsensiDataFromJson(json);

  Map<String, dynamic> toJson() => _$AbsensiDataToJson(this);
}

@JsonSerializable()
class JurnalData {
  final String? status;

  JurnalData({
    this.status,
  });

  factory JurnalData.fromJson(Map<String, dynamic> json) =>
      _$JurnalDataFromJson(json);

  Map<String, dynamic> toJson() => _$JurnalDataToJson(this);
}
