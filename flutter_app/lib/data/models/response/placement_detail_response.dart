import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_app/data/models/response/mitra_response.dart';

part 'placement_detail_response.g.dart';

@JsonSerializable()
class PlacementDetailResponse {
  final bool success;
  final String? message;
  final PlacementDetailData? data;

  PlacementDetailResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory PlacementDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$PlacementDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementDetailResponseToJson(this);
}

@JsonSerializable()
class PlacementDetailData {
  final int? id;

  @JsonKey(name: 'profile_siswa_id')
  final int? profileSiswaId;

  @JsonKey(name: 'mitra_industri_id')
  final int? mitraIndustriId;

  @JsonKey(name: 'pembimbing_id')
  final int? pembimbingId;

  final String? status;

  @JsonKey(name: 'tgl_mulai')
  final String? tglMulai;

  @JsonKey(name: 'tgl_selesai')
  final String? tglSelesai;

  final PlacementMitraData? mitra;
  final PlacementPembimbingData? pembimbing;

  PlacementDetailData({
    this.id,
    this.profileSiswaId,
    this.mitraIndustriId,
    this.pembimbingId,
    this.status,
    this.tglMulai,
    this.tglSelesai,
    this.mitra,
    this.pembimbing,
  });

  factory PlacementDetailData.fromJson(Map<String, dynamic> json) =>
      _$PlacementDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementDetailDataToJson(this);
}

@JsonSerializable()
class PlacementMitraData {
  final int? id;

  @JsonKey(name: 'nama_instansi')
  final String? namaInstansi;

  final String? deskripsi;

  @JsonKey(name: 'bidang_usaha')
  final String? bidangUsaha;

  final int? kuota;

  @JsonKey(name: 'jam_masuk')
  final String? jamMasuk;

  @JsonKey(name: 'jam_pulang')
  final String? jamPulang;

  @JsonKey(name: 'radius_meter')
  final int? radiusMeter;

  final AlamatModel? alamat;

  PlacementMitraData({
    this.id,
    this.namaInstansi,
    this.deskripsi,
    this.bidangUsaha,
    this.kuota,
    this.jamMasuk,
    this.jamPulang,
    this.radiusMeter,
    this.alamat,
  });

  factory PlacementMitraData.fromJson(Map<String, dynamic> json) =>
      _$PlacementMitraDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementMitraDataToJson(this);
}

@JsonSerializable()
class PlacementPembimbingData {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;

  PlacementPembimbingData({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory PlacementPembimbingData.fromJson(Map<String, dynamic> json) =>
      _$PlacementPembimbingDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlacementPembimbingDataToJson(this);
}
