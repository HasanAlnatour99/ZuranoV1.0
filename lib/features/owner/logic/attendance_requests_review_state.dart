import 'package:flutter/foundation.dart';

import '../../attendance/data/models/attendance_record.dart';
import '../../employee_dashboard/data/models/attendance_request_model.dart';
import '../../team_member_attendance/data/models/attendance_correction_request_model.dart';

/// Immutable UI snapshot for the Attendance Requests review screen.
///
/// The controller maps the Firestore stream of pending records plus owner
/// actions into this state. Widgets must never derive business logic from raw
/// collections.
@immutable
class AttendanceRequestsReviewState {
  const AttendanceRequestsReviewState({
    this.requests = const [],
    this.punchRequests = const [],
    this.correctionRequests = const [],
    this.isLoading = true,
    this.errorMessage,
    this.processingIds = const {},
    this.processingPunchRequestIds = const {},
    this.lastApprovedId,
    this.lastRejectedId,
    this.lastPunchApprovedId,
    this.lastPunchRejectedId,
  });

  /// Pending attendance records awaiting review, newest first.
  final List<AttendanceRecord> requests;

  /// Pending staff-submitted punch requests (`attendanceRequests`), newest first.
  final List<AttendanceRequestModel> punchRequests;

  /// Punch/absence correction requests (`attendanceCorrectionRequests`), pending only.
  final List<AttendanceCorrectionRequestModel> correctionRequests;

  /// `true` until the first stream snapshot arrives.
  final bool isLoading;

  /// Human-readable error (repository/stream failure) or `null`.
  final String? errorMessage;

  /// Record ids currently mid-approve or mid-reject. The UI disables their
  /// action buttons and shows a spinner while the set contains their id.
  final Set<String> processingIds;

  /// Punch request ids currently mid-approve or mid-reject.
  final Set<String> processingPunchRequestIds;

  /// Id of the most recently approved record, for one-shot snackbar feedback.
  final String? lastApprovedId;

  /// Id of the most recently rejected record, for one-shot snackbar feedback.
  final String? lastRejectedId;

  /// Id of the most recently approved punch request.
  final String? lastPunchApprovedId;

  /// Id of the most recently rejected punch request.
  final String? lastPunchRejectedId;

  bool get hasError => (errorMessage ?? '').isNotEmpty;

  bool get isEmpty =>
      !isLoading &&
      requests.isEmpty &&
      punchRequests.isEmpty &&
      correctionRequests.isEmpty &&
      !hasError;

  AttendanceRequestsReviewState copyWith({
    List<AttendanceRecord>? requests,
    List<AttendanceRequestModel>? punchRequests,
    List<AttendanceCorrectionRequestModel>? correctionRequests,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Set<String>? processingIds,
    Set<String>? processingPunchRequestIds,
    Object? lastApprovedId = _sentinel,
    Object? lastRejectedId = _sentinel,
    Object? lastPunchApprovedId = _sentinel,
    Object? lastPunchRejectedId = _sentinel,
  }) {
    return AttendanceRequestsReviewState(
      requests: requests ?? this.requests,
      punchRequests: punchRequests ?? this.punchRequests,
      correctionRequests: correctionRequests ?? this.correctionRequests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      processingIds: processingIds ?? this.processingIds,
      processingPunchRequestIds:
          processingPunchRequestIds ?? this.processingPunchRequestIds,
      lastApprovedId: identical(lastApprovedId, _sentinel)
          ? this.lastApprovedId
          : lastApprovedId as String?,
      lastRejectedId: identical(lastRejectedId, _sentinel)
          ? this.lastRejectedId
          : lastRejectedId as String?,
      lastPunchApprovedId: identical(lastPunchApprovedId, _sentinel)
          ? this.lastPunchApprovedId
          : lastPunchApprovedId as String?,
      lastPunchRejectedId: identical(lastPunchRejectedId, _sentinel)
          ? this.lastPunchRejectedId
          : lastPunchRejectedId as String?,
    );
  }
}

const Object _sentinel = Object();
