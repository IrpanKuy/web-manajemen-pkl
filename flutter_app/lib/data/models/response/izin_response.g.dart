// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'izin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Izin _$IzinFromJson(Map<String, dynamic> json) => Izin(
      id: (json['id'] as num).toInt(),
      tglMulai: json['tgl_mulai'] as String,
      tglSelesai: json['tgl_selesai'] as String,
      durasiHari: (json['durasi_hari'] as num?)?.toInt() ?? 1,
      keterangan: json['keterangan'] as String? ?? '',
      buktiPath: json['bukti_path'] as String?,
      status: json['status'] as String? ?? 'pending',
      komentar: json['komentar'] as String?,
    );

Map<String, dynamic> _$IzinToJson(Izin instance) => <String, dynamic>{
      'id': instance.id,
      'tgl_mulai': instance.tglMulai,
      'tgl_selesai': instance.tglSelesai,
      'durasi_hari': instance.durasiHari,
      'keterangan': instance.keterangan,
      'bukti_path': instance.buktiPath,
      'status': instance.status,
      'komentar': instance.komentar,
    };

IzinListResponse _$IzinListResponseFromJson(Map<String, dynamic> json) =>
    IzinListResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Izin.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$IzinListResponseToJson(IzinListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

IzinActionResponse _$IzinActionResponseFromJson(Map<String, dynamic> json) =>
    IzinActionResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Izin.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IzinActionResponseToJson(IzinActionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
