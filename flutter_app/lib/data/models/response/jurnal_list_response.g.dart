// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jurnal_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

Map<String, dynamic> _$JurnalHistoryResponseToJson(
        JurnalHistoryResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'summary': instance.summary,
    };

Jurnal _$JurnalFromJson(Map<String, dynamic> json) => Jurnal(
      id: (json['id'] as num).toInt(),
      tanggal: json['tanggal'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$JurnalToJson(Jurnal instance) => <String, dynamic>{
      'id': instance.id,
      'tanggal': instance.tanggal,
      'judul': instance.judul,
      'deskripsi': instance.deskripsi,
      'status': instance.status,
    };

JurnalSummary _$JurnalSummaryFromJson(Map<String, dynamic> json) =>
    JurnalSummary(
      totalJurnal: (json['total_jurnal'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$JurnalSummaryToJson(JurnalSummary instance) =>
    <String, dynamic>{
      'total_jurnal': instance.totalJurnal,
    };
