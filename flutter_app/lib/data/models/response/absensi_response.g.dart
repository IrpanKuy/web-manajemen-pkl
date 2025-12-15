// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absensi_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AbsensiResponse _$AbsensiResponseFromJson(Map<String, dynamic> json) =>
    AbsensiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      distance: json['distance'] as String?,
    );

Map<String, dynamic> _$AbsensiResponseToJson(AbsensiResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'distance': instance.distance,
    };
