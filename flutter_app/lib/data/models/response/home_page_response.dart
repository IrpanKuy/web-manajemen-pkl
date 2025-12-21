import 'package:json_annotation/json_annotation.dart';

part 'home_page_response.g.dart';

@JsonSerializable()
class HomePageResponse {
  final bool success;
  final String message;
  final String statusAbsensi;
  final HomePageData? data;

  HomePageResponse({
    required this.success,
    required this.message,
    required this.statusAbsensi,
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
  final String? status;
  final PembimbingData? pembimbing;
  @JsonKey(name: 'tgl_mulai')
  final String? tglMulai;
  @JsonKey(name: 'tgl_selesai')
  final String? tglSelesai;
  final MitraData? mitra;

  PenempatanData({
    required this.status,
    this.pembimbing,
    this.tglMulai,
    this.tglSelesai,
    this.mitra,
  });

  factory PenempatanData.fromJson(Map<String, dynamic> json) =>
      _$PenempatanDataFromJson(json);

  Map<String, dynamic> toJson() => _$PenempatanDataToJson(this);
}

@JsonSerializable()
class PembimbingData {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  PembimbingData({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory PembimbingData.fromJson(Map<String, dynamic> json) =>
      _$PembimbingDataFromJson(json);

  Map<String, dynamic> toJson() => _$PembimbingDataToJson(this);
}

@JsonSerializable()
class MitraData {
  @JsonKey(name: 'nama_instansi')
  final String? namaInstansi;
  @JsonKey(name: 'jam_masuk')
  final String? jamMasuk;
  @JsonKey(name: 'jam_pulang')
  final String? jamPulang;

  MitraData({
    required this.namaInstansi,
    this.jamMasuk,
    this.jamPulang,
  });

  factory MitraData.fromJson(Map<String, dynamic> json) =>
      _$MitraDataFromJson(json);

  Map<String, dynamic> toJson() => _$MitraDataToJson(this);
}

@JsonSerializable()
class AbsensiData {
  @JsonKey(name: 'jam_masuk')
  final String? jamMasuk;
  @JsonKey(name: 'jam_pulang')
  final String? jamPulang;

  AbsensiData({
    this.jamMasuk,
    this.jamPulang,
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
