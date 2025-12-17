// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomePageResponse _$HomePageResponseFromJson(Map<String, dynamic> json) =>
    HomePageResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      statusAbsensi: json['statusAbsensi'] as String,
      data: json['data'] == null
          ? null
          : HomePageData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomePageResponseToJson(HomePageResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'statusAbsensi': instance.statusAbsensi,
      'data': instance.data,
    };

HomePageData _$HomePageDataFromJson(Map<String, dynamic> json) => HomePageData(
      penempatan: json['penempatan'] == null
          ? null
          : PenempatanData.fromJson(json['penempatan'] as Map<String, dynamic>),
      absensi: json['absensi'] == null
          ? null
          : AbsensiData.fromJson(json['absensi'] as Map<String, dynamic>),
      jurnal: json['jurnal'] == null
          ? null
          : JurnalData.fromJson(json['jurnal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomePageDataToJson(HomePageData instance) =>
    <String, dynamic>{
      'penempatan': instance.penempatan,
      'absensi': instance.absensi,
      'jurnal': instance.jurnal,
    };

PenempatanData _$PenempatanDataFromJson(Map<String, dynamic> json) =>
    PenempatanData(
      status: json['status'] as String?,
      pembimbing: json['pembimbing'] as String?,
      tglMulai: json['tgl_mulai'] as String?,
      tglSelesai: json['tgl_selesai'] as String?,
      mitra: json['mitra'] == null
          ? null
          : MitraData.fromJson(json['mitra'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PenempatanDataToJson(PenempatanData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'pembimbing': instance.pembimbing,
      'tgl_mulai': instance.tglMulai,
      'tgl_selesai': instance.tglSelesai,
      'mitra': instance.mitra,
    };

MitraData _$MitraDataFromJson(Map<String, dynamic> json) => MitraData(
      namaInstansi: json['nama_instansi'] as String?,
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
    );

Map<String, dynamic> _$MitraDataToJson(MitraData instance) => <String, dynamic>{
      'nama_instansi': instance.namaInstansi,
      'jam_masuk': instance.jamMasuk,
      'jam_pulang': instance.jamPulang,
    };

AbsensiData _$AbsensiDataFromJson(Map<String, dynamic> json) => AbsensiData(
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
    );

Map<String, dynamic> _$AbsensiDataToJson(AbsensiData instance) =>
    <String, dynamic>{
      'jam_masuk': instance.jamMasuk,
      'jam_pulang': instance.jamPulang,
    };

JurnalData _$JurnalDataFromJson(Map<String, dynamic> json) => JurnalData(
      status: json['status'] as String?,
    );

Map<String, dynamic> _$JurnalDataToJson(JurnalData instance) =>
    <String, dynamic>{
      'status': instance.status,
    };
