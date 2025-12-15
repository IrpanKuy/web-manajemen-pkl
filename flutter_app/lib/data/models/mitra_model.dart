import 'package:json_annotation/json_annotation.dart';

part 'mitra_model.g.dart';

@JsonSerializable()
class MitraModel {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'nama_instansi')
  final String namaInstansi;
  
  @JsonKey(name: 'deskripsi')
  final String? deskripsi;
  
  @JsonKey(name: 'bidang_usaha')
  final String? bidangUsaha;
  
  @JsonKey(name: 'kuota')
  final int? kuota;
  
  @JsonKey(name: 'jam_masuk')
  final String? jamMasuk;
  
  @JsonKey(name: 'jam_pulang')
  final String? jamPulang;

  @JsonKey(name: 'alamat')
  final AlamatModel? alamat;

  MitraModel({
    required this.id,
    required this.namaInstansi,
    this.deskripsi,
    this.bidangUsaha,
    this.kuota,
    this.jamMasuk,
    this.jamPulang,
    this.alamat,
  });

  factory MitraModel.fromJson(Map<String, dynamic> json) =>
      _$MitraModelFromJson(json);

  Map<String, dynamic> toJson() => _$MitraModelToJson(this);
}

@JsonSerializable()
class AlamatModel {
  @JsonKey(name: 'detail_alamat')
  final String? detailAlamat;
  
  @JsonKey(name: 'kabupaten')
  final String? kabupaten;
  
  @JsonKey(name: 'location')
  final String? location; // Assuming Point(lat, lng) returned as string or we parse it

  AlamatModel({
    this.detailAlamat,
    this.kabupaten,
    this.location,
  });

  factory AlamatModel.fromJson(Map<String, dynamic> json) =>
      _$AlamatModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlamatModelToJson(this);
}

// Response Wrapper for List
@JsonSerializable()
class MitraListResponse {
  final bool success;
  final String message;
  final List<MitraModel>? data;

  MitraListResponse({required this.success, required this.message, this.data});

  factory MitraListResponse.fromJson(Map<String, dynamic> json) =>
      _$MitraListResponseFromJson(json);
}

// Response Wrapper for Detail
@JsonSerializable()
class MitraDetailResponse {
  final bool success;
  final String message;
  final MitraModel? data;

  MitraDetailResponse({required this.success, required this.message, this.data});

  factory MitraDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MitraDetailResponseFromJson(json);
}
