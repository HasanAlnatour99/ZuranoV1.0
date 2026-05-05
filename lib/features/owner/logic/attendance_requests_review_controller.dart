import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/attendance_approval.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/salon_streams_provider.dart';
import '../../../providers/session_provider.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../../team_member_attendance/data/models/attendance_correction_request_model.dart';
import '../../users/data/models/app_user.dart';
import 'attendance_requests_review_state.dart';

/// Owner / admin controller for the Attendance Requests review queue.
///
/// Subscribes to [pendingAttendanceRequestsStreamProvider] for the live list,
/// and exposes `approve` / `reject` actions that delegate to the repository.
/// All Firestore writes go through [AttendanceRepository.approveAttendance] so
/// the status + metadata update atomically.
class AttendanceRequestsReviewController
    extends Notifier<AttendanceRequestsReviewState> {
  ProviderSubscription<AsyncValue<List<AttendanceRecord>>>? _attendanceSub;
  ProviderSubscription<AsyncValue<List<AttendanceCorrectionRequestModel>>>?
  _correctionsSub;

  @override
  AttendanceRequestsReviewState build() {
    _attendanceSub?.close();
    _correctionsSub?.close();
    // Do not use fireImmediately: true — the listener runs synchronously during
    // build() before [Notifier.state] exists, which throws "uninitialized provider".
    void onStreamUpdate() {
      state = _mergeSnapshot(
        ref.read(pendingAttendanceRequestsStreamProvider),
        ref.read(pendingAttendanceCorrectionRequestsStreamProvider),
        state,
      );
    }

    _attendanceSub = ref.listen<AsyncValue<List<AttendanceRecord>>>(
      pendingAttendanceRequestsStreamProvider,
      (_, _) => onStreamUpdate(),
      fireImmediately: false,
    );
    _correctionsSub = ref.listen<AsyncValue<List<AttendanceCorrectionRequestModel>>>(
      pendingAttendanceCorrectionRequestsStreamProvider,
      (_, _) => onStreamUpdate(),
      fireImmediately: false,
    );
    ref.onDispose(() {
      _attendanceSub?.close();
      _attendanceSub = null;
      _correctionsSub?.close();
      _correctionsSub = null;
    });
    return _mergeSnapshot(
      ref.read(pendingAttendanceRequestsStreamProvider),
      ref.read(pendingAttendanceCorrectionRequestsStreamProvider),
      const AttendanceRequestsReviewState(),
    );
  }

  /// Maps both salon streams onto [current] without reading [Notifier.state]
  /// (required for the initial build before state is mounted).
  static AttendanceRequestsReviewState _mergeSnapshot(
    AsyncValue<List<AttendanceRecord>> attendance,
    AsyncValue<List<AttendanceCorrectionRequestModel>> corrections,
    AttendanceRequestsReviewState current,
  ) {
    final loading = (attendance.isLoading && !attendance.hasValue) ||
        (corrections.isLoading && !corrections.hasValue);

    List<AttendanceRecord> nextRequests = current.requests;
    if (attendance.hasValue) {
      nextRequests = attendance.requireValue;
    }

    List<AttendanceCorrectionRequestModel> nextCorrections =
        current.correctionRequests;
    if (corrections.hasValue) {
      nextCorrections = corrections.requireValue;
    }

    final visibleIds = nextRequests.map((r) => r.id).toSet();
    final stillProcessing =
        current.processingIds.where(visibleIds.contains).toSet();

    String? err;
    if (nextRequests.isEmpty &&
        nextCorrections.isEmpty &&
        attendance.hasError &&
        !attendance.hasValue) {
      err = attendance.error.toString();
    } else if (nextRequests.isEmpty &&
        nextCorrections.isEmpty &&
        corrections.hasError &&
        !corrections.hasValue) {
      err = corrections.error.toString();
    }

    return current.copyWith(
      requests: nextRequests,
      correctionRequests: nextCorrections,
      isLoading: loading,
      errorMessage: err,
      processingIds: stillProcessing,
    );
  }

  Future<bool> approve(AttendanceRecord record) {
    return _review(
      record: record,
      approvalStatus: AttendanceApprovalStatuses.approved,
    );
  }

  Future<bool> reject(AttendanceRecord record, {String? rejectionReason}) {
    return _review(
      record: record,
      approvalStatus: AttendanceApprovalStatuses.rejected,
      rejectionReason: rejectionReason,
    );
  }

  Future<bool> _review({
    required AttendanceRecord record,
    required String approvalStatus,
    String? rejectionReason,
  }) async {
    if (record.id.isEmpty) return false;
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null || user.uid.isEmpty) {
      state = state.copyWith(errorMessage: 'Not signed in.');
      return false;
    }
    final salonId = user.salonId ?? '';
    if (salonId.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing salonId on session.');
      return false;
    }

    if (state.processingIds.contains(record.id)) return false;

    state = state.copyWith(
      processingIds: {...state.processingIds, record.id},
      errorMessage: null,
    );

    try {
      await ref
          .read(attendanceRepositoryProvider)
          .approveAttendance(
            salonId: salonId,
            attendanceId: record.id,
            approvedByUid: user.uid,
            approvedByName: _displayName(user),
            approvalStatus: approvalStatus,
            rejectionReason: rejectionReason,
          );

      final remaining = {...state.processingIds}..remove(record.id);
      state = state.copyWith(
        processingIds: remaining,
        lastApprovedId: approvalStatus == AttendanceApprovalStatuses.approved
            ? record.id
            : null,
        lastRejectedId: approvalStatus == AttendanceApprovalStatuses.rejected
            ? record.id
            : null,
      );
      return true;
    } catch (error) {
      final remaining = {...state.processingIds}..remove(record.id);
      state = state.copyWith(
        processingIds: remaining,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void clearFeedback() {
    if (state.lastApprovedId == null && state.lastRejectedId == null) return;
    state = state.copyWith(lastApprovedId: null, lastRejectedId: null);
  }

  void clearError() {
    if (!state.hasError) return;
    state = state.copyWith(errorMessage: null);
  }

  String? _displayName(AppUser user) {
    final name = user.name.trim();
    return name.isEmpty ? null : name;
  }
}

final attendanceRequestsReviewControllerProvider =
    NotifierProvider<
      AttendanceRequestsReviewController,
      AttendanceRequestsReviewState
    >(AttendanceRequestsReviewController.new);
