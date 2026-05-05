import 'package:flutter/foundation.dart';

import '../../attendance/data/models/attendance_record.dart';
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
    this.correctionRequests = const [],
    this.isLoading = true,
    this.errorMessage,
    this.processingIds = const {},
    this.lastApprovedId,
    this.lastRejectedId,
  });

  /// Pending attendance records awaiting review, newest first.
  final List<AttendanceRecord> requests;

  /// Punch/absence correction requests (`attendanceCorrectionRequests`), pending only.
  final List<AttendanceCorrectionRequestModel> correctionRequests;

  /// `true` until the first stream snapshot arrives.
  final bool isLoading;

  /// Human-readable error (repository/stream failure) or `null`.
  final String? errorMessage;

  /// Record ids currently mid-approve or mid-reject. The UI disables their
  /// action buttons and shows a spinner while the set contains their id.
  final Set<String> processingIds;

  /// Id of the most recently approved record, for one-shot snackbar feedback.
  final String? lastApprovedId;

  /// Id of the most recently rejected record, for one-shot snackbar feedback.
  final String? lastRejectedId;

  bool get hasError => (errorMessage ?? '').isNotEmpty;

  bool get isEmpty =>
      !isLoading &&
      requests.isEmpty &&
      correctionRequests.isEmpty &&
      !hasError;

  AttendanceRequestsReviewState copyWith({
    List<AttendanceRecord>? requests,
    List<AttendanceCorrectionRequestModel>? correctionRequests,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Set<String>? processingIds,
    Object? lastApprovedId = _sentinel,
    Object? lastRejectedId = _sentinel,
  }) {
    return AttendanceRequestsReviewState(
      requests: requests ?? this.requests,
      correctionRequests: correctionRequests ?? this.correctionRequests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      processingIds: processingIds ?? this.processingIds,
      lastApprovedId: identical(lastApprovedId, _sentinel)
          ? this.lastApprovedId
          : lastApprovedId as String?,
      lastRejectedId: identical(lastRejectedId, _sentinel)
          ? this.lastRejectedId
          : lastRejectedId as String?,
    );
  }
}

const Object _sentinel = Object();
