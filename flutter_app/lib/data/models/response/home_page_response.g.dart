// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_page_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomePageResponse _$HomePageResponseFromJson(Map<String, dynamic> json) =>
    HomePageResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : HomePageData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomePageResponseToJson(HomePageResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
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
      status: json['status'] as bool,
      namaInstansi: json['nama_instansi'] as String?,
      pembimbing: json['pembimbing'] as String?,
    );

Map<String, dynamic> _$PenempatanDataToJson(PenempatanData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'nama_instansi': instance.namaInstansi,
      'pembimbing': instance.pembimbing,
    };

AbsensiData _$AbsensiDataFromJson(Map<String, dynamic> json) => AbsensiData(
      status: json['status'] as String?,
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
      statusKehadiran: json['status_kehadiran'] as String?,
    );

Map<String, dynamic> _$AbsensiDataToJson(AbsensiData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'jam_masuk': instance.jamMasuk,
      'jam_pulang': instance.jamPulang,
      'status_kehadiran': instance.statusKehadiran,
    };

JurnalData _$JurnalDataFromJson(Map<String, dynamic> json) => JurnalData(
      status: json['status'] as String?,
    );

Map<String, dynamic> _$JurnalDataToJson(JurnalData instance) =>
    <String, dynamic>{
      'status': instance.status,
    };
