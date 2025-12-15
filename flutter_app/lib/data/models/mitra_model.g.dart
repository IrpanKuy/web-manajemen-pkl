// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mitra_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MitraModel _$MitraModelFromJson(Map<String, dynamic> json) => MitraModel(
      id: (json['id'] as num).toInt(),
      namaInstansi: json['nama_instansi'] as String,
      deskripsi: json['deskripsi'] as String?,
      bidangUsaha: json['bidang_usaha'] as String?,
      kuota: (json['kuota'] as num?)?.toInt(),
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
      alamat: json['alamat'] == null
          ? null
          : AlamatModel.fromJson(json['alamat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MitraModelToJson(MitraModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama_instansi': instance.namaInstansi,
      'deskripsi': instance.deskripsi,
      'bidang_usaha': instance.bidangUsaha,
      'kuota': instance.kuota,
      'jam_masuk': instance.jamMasuk,
      'jam_pulang': instance.jamPulang,
      'alamat': instance.alamat,
    };

AlamatModel _$AlamatModelFromJson(Map<String, dynamic> json) => AlamatModel(
      detailAlamat: json['detail_alamat'] as String?,
      kabupaten: json['kabupaten'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$AlamatModelToJson(AlamatModel instance) =>
    <String, dynamic>{
      'detail_alamat': instance.detailAlamat,
      'kabupaten': instance.kabupaten,
      'location': instance.location,
    };

MitraListResponse _$MitraListResponseFromJson(Map<String, dynamic> json) =>
    MitraListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MitraModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MitraListResponseToJson(MitraListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

MitraDetailResponse _$MitraDetailResponseFromJson(Map<String, dynamic> json) =>
    MitraDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : MitraModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MitraDetailResponseToJson(
        MitraDetailResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
