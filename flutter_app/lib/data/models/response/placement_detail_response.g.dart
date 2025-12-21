// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placement_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlacementDetailResponse _$PlacementDetailResponseFromJson(
        Map<String, dynamic> json) =>
    PlacementDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : PlacementDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlacementDetailResponseToJson(
        PlacementDetailResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

PlacementDetailData _$PlacementDetailDataFromJson(Map<String, dynamic> json) =>
    PlacementDetailData(
      id: (json['id'] as num?)?.toInt(),
      profileSiswaId: (json['profile_siswa_id'] as num?)?.toInt(),
      mitraIndustriId: (json['mitra_industri_id'] as num?)?.toInt(),
      pembimbingId: (json['pembimbing_id'] as num?)?.toInt(),
      status: json['status'] as String?,
      tglMulai: json['tgl_mulai'] as String?,
      tglSelesai: json['tgl_selesai'] as String?,
      mitra: json['mitra'] == null
          ? null
          : PlacementMitraData.fromJson(json['mitra'] as Map<String, dynamic>),
      pembimbing: json['pembimbing'] == null
          ? null
          : PlacementPembimbingData.fromJson(
              json['pembimbing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlacementDetailDataToJson(
        PlacementDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile_siswa_id': instance.profileSiswaId,
      'mitra_industri_id': instance.mitraIndustriId,
      'pembimbing_id': instance.pembimbingId,
      'status': instance.status,
      'tgl_mulai': instance.tglMulai,
      'tgl_selesai': instance.tglSelesai,
      'mitra': instance.mitra,
      'pembimbing': instance.pembimbing,
    };

PlacementMitraData _$PlacementMitraDataFromJson(Map<String, dynamic> json) =>
    PlacementMitraData(
      id: (json['id'] as num?)?.toInt(),
      namaInstansi: json['nama_instansi'] as String?,
      deskripsi: json['deskripsi'] as String?,
      bidangUsaha: json['bidang_usaha'] as String?,
      kuota: (json['kuota'] as num?)?.toInt(),
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
      radiusMeter: (json['radius_meter'] as num?)?.toInt(),
      alamat: json['alamat'] == null
          ? null
          : AlamatModel.fromJson(json['alamat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlacementMitraDataToJson(PlacementMitraData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nama_instansi': instance.namaInstansi,
      'deskripsi': instance.deskripsi,
      'bidang_usaha': instance.bidangUsaha,
      'kuota': instance.kuota,
      'jam_masuk': instance.jamMasuk,
      'jam_pulang': instance.jamPulang,
      'radius_meter': instance.radiusMeter,
      'alamat': instance.alamat,
    };

PlacementPembimbingData _$PlacementPembimbingDataFromJson(
        Map<String, dynamic> json) =>
    PlacementPembimbingData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$PlacementPembimbingDataToJson(
        PlacementPembimbingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };
