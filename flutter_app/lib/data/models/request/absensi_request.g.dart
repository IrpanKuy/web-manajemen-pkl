// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absensi_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsensiRequest _$AbsensiRequestFromJson(Map<String, dynamic> json) =>
    AbsensiRequest(
      qrValue: json['qr_value'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$AbsensiRequestToJson(AbsensiRequest instance) =>
    <String, dynamic>{
      'qr_value': instance.qrValue,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
