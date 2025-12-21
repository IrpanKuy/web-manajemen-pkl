// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_request_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorRequestPageResponse _$MentorRequestPageResponseFromJson(
        Map<String, dynamic> json) =>
    MentorRequestPageResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : MentorRequestPageData.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MentorRequestPageResponseToJson(
        MentorRequestPageResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

MentorRequestPageData _$MentorRequestPageDataFromJson(
        Map<String, dynamic> json) =>
    MentorRequestPageData(
      currentPembimbing: json['current_pembimbing'] == null
          ? null
          : PembimbingInfo.fromJson(
              json['current_pembimbing'] as Map<String, dynamic>),
      mitra: json['mitra'] == null
          ? null
          : MitraInfo.fromJson(json['mitra'] as Map<String, dynamic>),
      otherMentors: (json['other_mentors'] as List<dynamic>?)
          ?.map((e) => PembimbingInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingRequest: json['pending_request'] == null
          ? null
          : PendingRequestInfo.fromJson(
              json['pending_request'] as Map<String, dynamic>),
      canChangeMentor: json['can_change_mentor'] as bool? ?? false,
      hasPendingJurnal: json['has_pending_jurnal'] as bool? ?? false,
    );

Map<String, dynamic> _$MentorRequestPageDataToJson(
        MentorRequestPageData instance) =>
    <String, dynamic>{
      'current_pembimbing': instance.currentPembimbing,
      'mitra': instance.mitra,
      'other_mentors': instance.otherMentors,
      'pending_request': instance.pendingRequest,
      'can_change_mentor': instance.canChangeMentor,
      'has_pending_jurnal': instance.hasPendingJurnal,
    };

PembimbingInfo _$PembimbingInfoFromJson(Map<String, dynamic> json) =>
    PembimbingInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$PembimbingInfoToJson(PembimbingInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

MitraInfo _$MitraInfoFromJson(Map<String, dynamic> json) => MitraInfo(
      id: (json['id'] as num).toInt(),
      nama: json['nama'] as String?,
    );

Map<String, dynamic> _$MitraInfoToJson(MitraInfo instance) => <String, dynamic>{
      'id': instance.id,
      'nama': instance.nama,
    };

PendingRequestInfo _$PendingRequestInfoFromJson(Map<String, dynamic> json) =>
    PendingRequestInfo(
      id: (json['id'] as num).toInt(),
      alasan: json['alasan'] as String?,
      status: json['status'] as String?,
      pembimbingLama: json['pembimbing_lama'] == null
          ? null
          : PembimbingInfo.fromJson(
              json['pembimbing_lama'] as Map<String, dynamic>),
      pembimbingBaru: json['pembimbing_baru'] == null
          ? null
          : PembimbingInfo.fromJson(
              json['pembimbing_baru'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PendingRequestInfoToJson(PendingRequestInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alasan': instance.alasan,
      'status': instance.status,
      'pembimbing_lama': instance.pembimbingLama,
      'pembimbing_baru': instance.pembimbingBaru,
      'created_at': instance.createdAt,
    };

MentorRequestActionResponse _$MentorRequestActionResponseFromJson(
        Map<String, dynamic> json) =>
    MentorRequestActionResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MentorRequestActionResponseToJson(
        MentorRequestActionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
