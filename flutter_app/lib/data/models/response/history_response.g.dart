// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_response.dart';

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

JurnalHistoryResponse _$JurnalHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    JurnalHistoryResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Jurnal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] == null
          ? null
          : JurnalSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

// Map<String, dynamic> _$JurnalHistoryResponseToJson(
//         JurnalHistoryResponse instance) =>
//     <String, dynamic>{
//       'success': instance.success,
//       'data': instance.data,
//       'summary': instance.summary,
//     };
