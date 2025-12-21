// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absensi_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsensiHistoryResponse _$AbsensiHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    AbsensiHistoryResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Absensi.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] == null
          ? null
          : AbsensiSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

// Map<String, dynamic> _$AbsensiHistoryResponseToJson(
//         AbsensiHistoryResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'data': instance.data,
//       'summary': instance.summary,
//     };

Absensi _$AbsensiFromJson(Map<String, dynamic> json) => Absensi(
      id: (json['id'] as num).toInt(),
      tanggal: json['tanggal'] as String,
      jamMasuk: json['jam_masuk'] as String?,
      jamPulang: json['jam_pulang'] as String?,
      statusKehadiran: json['status_kehadiran'] as String? ?? 'pending',
    );

Map<String, dynamic> _$AbsensiToJson(Absensi instance) => <String, dynamic>{
      'id': instance.id,
      'tanggal': instance.tanggal,
      'jam_masuk': instance.jamMasuk,
      'jam_pulang': instance.jamPulang,
      'status_kehadiran': instance.statusKehadiran,
    };

AbsensiSummary _$AbsensiSummaryFromJson(Map<String, dynamic> json) =>
    AbsensiSummary(
      hadir: (json['hadir'] as num?)?.toInt() ?? 0,
      telat: (json['telat'] as num?)?.toInt() ?? 0,
      sakit: (json['sakit'] as num?)?.toInt() ?? 0,
      izin: (json['izin'] as num?)?.toInt() ?? 0,
      alpha: (json['alpha'] as num?)?.toInt() ?? 0,
      totalHadirCount: (json['total_hadir_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AbsensiSummaryToJson(AbsensiSummary instance) =>
    <String, dynamic>{
      'hadir': instance.hadir,
      'telat': instance.telat,
      'sakit': instance.sakit,
      'izin': instance.izin,
      'alpha': instance.alpha,
      'total_hadir_count': instance.totalHadirCount,
    };
