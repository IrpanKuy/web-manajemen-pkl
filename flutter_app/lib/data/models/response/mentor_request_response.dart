import 'package:json_annotation/json_annotation.dart';

part 'mentor_request_response.g.dart';

@JsonSerializable()
class MentorRequestPageResponse {
  final bool success;
  final String? message;
  final MentorRequestPageData? data;

  MentorRequestPageResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory MentorRequestPageResponse.fromJson(Map<String, dynamic> json) =>
      _$MentorRequestPageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MentorRequestPageResponseToJson(this);
}

@JsonSerializable()
class MentorRequestPageData {
  @JsonKey(name: 'current_pembimbing')
  final PembimbingInfo? currentPembimbing;

  final MitraInfo? mitra;

  @JsonKey(name: 'other_mentors')
  final List<PembimbingInfo>? otherMentors;

  @JsonKey(name: 'pending_request')
  final PendingRequestInfo? pendingRequest;

  @JsonKey(name: 'can_change_mentor')
  final bool canChangeMentor;

  @JsonKey(name: 'has_pending_jurnal')
  final bool hasPendingJurnal;

  MentorRequestPageData({
    this.currentPembimbing,
    this.mitra,
    this.otherMentors,
    this.pendingRequest,
    this.canChangeMentor = false,
    this.hasPendingJurnal = false,
  });

  factory MentorRequestPageData.fromJson(Map<String, dynamic> json) =>
      _$MentorRequestPageDataFromJson(json);
  Map<String, dynamic> toJson() => _$MentorRequestPageDataToJson(this);
}

@JsonSerializable()
class PembimbingInfo {
  final int id;
  final String? name;
  final String? email;

  PembimbingInfo({
    required this.id,
    this.name,
    this.email,
  });

  factory PembimbingInfo.fromJson(Map<String, dynamic> json) =>
      _$PembimbingInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PembimbingInfoToJson(this);
}

@JsonSerializable()
class MitraInfo {
  final int id;
  final String? nama;

  MitraInfo({
    required this.id,
    this.nama,
  });

  factory MitraInfo.fromJson(Map<String, dynamic> json) =>
      _$MitraInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MitraInfoToJson(this);
}

@JsonSerializable()
class PendingRequestInfo {
  final int id;
  final String? alasan;
  final String? status;

  @JsonKey(name: 'pembimbing_lama')
  final PembimbingInfo? pembimbingLama;

  @JsonKey(name: 'pembimbing_baru')
  final PembimbingInfo? pembimbingBaru;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  PendingRequestInfo({
    required this.id,
    this.alasan,
    this.status,
    this.pembimbingLama,
    this.pembimbingBaru,
    this.createdAt,
  });

  factory PendingRequestInfo.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PendingRequestInfoToJson(this);
}

@JsonSerializable()
class MentorRequestActionResponse {
  final bool success;
  final String? message;

  MentorRequestActionResponse({
    required this.success,
    this.message,
  });

  factory MentorRequestActionResponse.fromJson(Map<String, dynamic> json) =>
      _$MentorRequestActionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MentorRequestActionResponseToJson(this);
}
