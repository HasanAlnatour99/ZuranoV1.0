import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/attendance_approval.dart';
import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    @JsonKey(fromJson: looseStringFromJson) required String id,
    @JsonKey(fromJson: looseStringFromJson) required String salonId,
    @JsonKey(fromJson: looseStringFromJson) required String employeeId,
    @JsonKey(fromJson: looseStringFromJson) required String employeeName,
    @JsonKey(
      fromJson: firestoreDateTimeFromJson,
      toJson: firestoreDateTimeToJson,
    )
    required DateTime workDate,
    @Default('') @JsonKey(fromJson: looseStringFromJson) String dateKey,
    @JsonKey(fromJson: _statusFromJson) required String status,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? checkInAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? checkOutAt,
    @Default(0) @JsonKey(fromJson: looseIntFromJson) int minutesLate,
    @Default(false) @JsonKey(fromJson: falseBoolFromJson) bool needsCorrection,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? notes,
    @Default(AttendanceApprovalStatuses.pending)
    @JsonKey(fromJson: _approvalStatusFromJson)
    String approvalStatus,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? approvedByUid,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? approvedByName,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? approvedAt,
    @JsonKey(fromJson: nullableLooseStringFromJson) String? rejectionReason,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? createdAt,
    @JsonKey(
      fromJson: nullableFirestoreDateTimeFromJson,
      toJson: nullableFirestoreDateTimeToJson,
    )
    DateTime? updatedAt,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(_normalizedAttendanceJson(json));

  static String _dateKeyFor(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

Map<String, dynamic> _normalizedAttendanceJson(Map<String, dynamic> json) {
  final workDate =
      FirestoreSerializers.dateTime(json['workDate']) ??
      DateTime.fromMillisecondsSinceEpoch(0);
  final normalized = Map<String, dynamic>.from(json);
  normalized['workDate'] = workDate;
  normalized['dateKey'] =
      FirestoreSerializers.string(json['dateKey']) ??
      AttendanceRecord._dateKeyFor(workDate);
  return normalized;
}

String _statusFromJson(Object? value) =>
    nullableLooseStringFromJson(value) ?? 'present';

String _approvalStatusFromJson(Object? value) =>
    nullableLooseStringFromJson(value) ?? AttendanceApprovalStatuses.pending;

/// Owner metrics: on break still counts as on the floor / working.
extension AttendanceRecordWorkingSession on AttendanceRecord {
  static const String statusOnBreak = 'onBreak';

  bool get countsAsWorkingOnSalon =>
      checkInAt != null && (checkOutAt == null || status == statusOnBreak);
}
