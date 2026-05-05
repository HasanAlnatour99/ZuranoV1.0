import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/attendance_approval.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/salon_streams_provider.dart';
import '../../../providers/session_provider.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../../employee_dashboard/data/models/attendance_request_model.dart';
import '../../employee_dashboard/domain/enums/attendance_request_status.dart';
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
  ProviderSubscription<AsyncValue<List<AttendanceRequestModel>>>? _punchSub;
  ProviderSubscription<AsyncValue<List<AttendanceCorrectionRequestModel>>>?
  _correctionsSub;

  @override
  AttendanceRequestsReviewState build() {
    _attendanceSub?.close();
    _punchSub?.close();
    _correctionsSub?.close();
    // Do not use fireImmediately: true — the listener runs synchronously during
    // build() before [Notifier.state] exists, which throws "uninitialized provider".
    void onStreamUpdate() {
      state = _mergeSnapshot(
        ref.read(pendingAttendanceRequestsStreamProvider),
        ref.read(pendingAttendancePunchRequestsStreamProvider),
        ref.read(pendingAttendanceCorrectionRequestsStreamProvider),
        state,
      );
    }

    _attendanceSub = ref.listen<AsyncValue<List<AttendanceRecord>>>(
      pendingAttendanceRequestsStreamProvider,
      (_, _) => onStreamUpdate(),
      fireImmediately: false,
    );
    _punchSub = ref.listen<AsyncValue<List<AttendanceRequestModel>>>(
      pendingAttendancePunchRequestsStreamProvider,
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
      _punchSub?.close();
      _punchSub = null;
      _correctionsSub?.close();
      _correctionsSub = null;
    });
    return _mergeSnapshot(
      ref.read(pendingAttendanceRequestsStreamProvider),
      ref.read(pendingAttendancePunchRequestsStreamProvider),
      ref.read(pendingAttendanceCorrectionRequestsStreamProvider),
      const AttendanceRequestsReviewState(),
    );
  }

  /// Maps both salon streams onto [current] without reading [Notifier.state]
  /// (required for the initial build before state is mounted).
  static AttendanceRequestsReviewState _mergeSnapshot(
    AsyncValue<List<AttendanceRecord>> attendance,
    AsyncValue<List<AttendanceRequestModel>> punchRequests,
    AsyncValue<List<AttendanceCorrectionRequestModel>> corrections,
    AttendanceRequestsReviewState current,
  ) {
    final loading = (attendance.isLoading && !attendance.hasValue) ||
        (punchRequests.isLoading && !punchRequests.hasValue) ||
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

    List<AttendanceRequestModel> nextPunchRequests = current.punchRequests;
    if (punchRequests.hasValue) {
      nextPunchRequests = punchRequests.requireValue;
    }

    final visibleIds = nextRequests.map((r) => r.id).toSet();
    final stillProcessing =
        current.processingIds.where(visibleIds.contains).toSet();

    final visiblePunchIds = nextPunchRequests.map((r) => r.requestId).toSet();
    final stillProcessingPunch = current.processingPunchRequestIds
        .where(visiblePunchIds.contains)
        .toSet();

    String? err;
    if (nextRequests.isEmpty &&
        nextPunchRequests.isEmpty &&
        nextCorrections.isEmpty &&
        attendance.hasError &&
        !attendance.hasValue) {
      err = attendance.error.toString();
    } else if (nextRequests.isEmpty &&
        nextPunchRequests.isEmpty &&
        nextCorrections.isEmpty &&
        punchRequests.hasError &&
        !punchRequests.hasValue) {
      err = punchRequests.error.toString();
    } else if (nextRequests.isEmpty &&
        nextPunchRequests.isEmpty &&
        nextCorrections.isEmpty &&
        corrections.hasError &&
        !corrections.hasValue) {
      err = corrections.error.toString();
    }

    return current.copyWith(
      requests: nextRequests,
      punchRequests: nextPunchRequests,
      correctionRequests: nextCorrections,
      isLoading: loading,
      errorMessage: err,
      processingIds: stillProcessing,
      processingPunchRequestIds: stillProcessingPunch,
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

  Future<bool> approvePunchRequest(AttendanceRequestModel request) {
    return _reviewPunch(request: request, approved: true);
  }

  Future<bool> rejectPunchRequest(
    AttendanceRequestModel request, {
    String? rejectionNote,
  }) {
    return _reviewPunch(
      request: request,
      approved: false,
      rejectionNote: rejectionNote,
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

  Future<bool> _reviewPunch({
    required AttendanceRequestModel request,
    required bool approved,
    String? rejectionNote,
  }) async {
    if (request.requestId.isEmpty) return false;
    if (request.status != AttendanceRequestStatuses.pending) return false;

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

    if (state.processingPunchRequestIds.contains(request.requestId)) {
      return false;
    }

    state = state.copyWith(
      processingPunchRequestIds: {
        ...state.processingPunchRequestIds,
        request.requestId,
      },
      errorMessage: null,
    );

    try {
      if (approved) {
        await ref
            .read(attendanceRequestsAdminRepositoryProvider)
            .approveRequest(
              salonId: salonId,
              requestId: request.requestId,
              reviewerUid: user.uid,
              reviewerName: _displayName(user) ?? user.uid,
            );
      } else {
        await ref
            .read(attendanceRequestsAdminRepositoryProvider)
            .rejectRequest(
              salonId: salonId,
              requestId: request.requestId,
              reviewerUid: user.uid,
              reviewerName: _displayName(user) ?? user.uid,
              reviewNote: rejectionNote?.trim(),
            );
      }

      final remaining = {...state.processingPunchRequestIds}
        ..remove(request.requestId);
      state = state.copyWith(
        processingPunchRequestIds: remaining,
        lastPunchApprovedId: approved ? request.requestId : null,
        lastPunchRejectedId: approved ? null : request.requestId,
      );
      return true;
    } catch (error) {
      final remaining = {...state.processingPunchRequestIds}
        ..remove(request.requestId);
      state = state.copyWith(
        processingPunchRequestIds: remaining,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void clearFeedback() {
    if (state.lastApprovedId == null &&
        state.lastRejectedId == null &&
        state.lastPunchApprovedId == null &&
        state.lastPunchRejectedId == null) {
      return;
    }
    state = state.copyWith(
      lastApprovedId: null,
      lastRejectedId: null,
      lastPunchApprovedId: null,
      lastPunchRejectedId: null,
    );
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
