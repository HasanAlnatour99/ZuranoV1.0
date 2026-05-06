import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/user_roles.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/zurano/zurano_empty_state.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../attendance/data/models/attendance_record.dart';
import '../../../employee_dashboard/data/models/attendance_request_model.dart';
import '../../../team_member_attendance/application/team_member_attendance_providers.dart';
import '../../../team_member_attendance/data/models/attendance_correction_request_model.dart';
import '../../../team_member_attendance/presentation/widgets/correction_review_sheet.dart';
import '../../logic/attendance_requests_review_controller.dart';
import '../../logic/attendance_requests_review_state.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// Owner / admin review queue for pending attendance requests.
///
/// Rendering-only — all business logic lives in
/// [attendanceRequestsReviewControllerProvider]. Each row hands the record
/// back to the controller for approve / reject.
class AttendanceRequestsReviewScreen extends ConsumerWidget {
  const AttendanceRequestsReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessionAsync = ref.watch(sessionUserProvider);

    ref.listen<AttendanceRequestsReviewState>(
      attendanceRequestsReviewControllerProvider,
      (previous, next) {
        final messenger = ScaffoldMessenger.of(context);
        if ((next.lastApprovedId != null &&
                next.lastApprovedId != previous?.lastApprovedId) ||
            (next.lastPunchApprovedId != null &&
                next.lastPunchApprovedId != previous?.lastPunchApprovedId)) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.attendanceReviewApprovedSnackbar)),
          );
          ref
              .read(attendanceRequestsReviewControllerProvider.notifier)
              .clearFeedback();
        }
        if ((next.lastRejectedId != null &&
                next.lastRejectedId != previous?.lastRejectedId) ||
            (next.lastPunchRejectedId != null &&
                next.lastPunchRejectedId != previous?.lastPunchRejectedId)) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.attendanceReviewRejectedSnackbar)),
          );
          ref
              .read(attendanceRequestsReviewControllerProvider.notifier)
              .clearFeedback();
        }
        if (next.hasError && next.errorMessage != previous?.errorMessage) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n.attendanceReviewErrorSnackbar(next.errorMessage ?? ''),
              ),
            ),
          );
          ref
              .read(attendanceRequestsReviewControllerProvider.notifier)
              .clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor: ZuranoTokens.background,
      appBar: AppBar(
        backgroundColor: ZuranoTokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppBarLeadingBack(),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: ZuranoTokens.primary),
        title: Text(
          l10n.attendanceReviewTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: ZuranoTokens.textDark,
            letterSpacing: -0.35,
          ),
        ),
      ),
      body: sessionAsync.when(
        loading: () => const Center(
          child: AppLoadingIndicator(size: 40, color: ZuranoTokens.primary),
        ),
        error: (_, _) => _UnavailableState(l10n: l10n),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          final allowed =
              user.role == UserRoles.owner || user.role == UserRoles.admin;
          final salonId = user.salonId?.trim() ?? '';
          if (!allowed || salonId.isEmpty) {
            return _UnavailableState(l10n: l10n);
          }
          return const _AttendanceRequestsReviewBody();
        },
      ),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppFadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: AppEmptyState(
            title: l10n.attendanceReviewTitle,
            message: l10n.genericError,
            icon: AppIcons.lock_outline,
          ),
        ),
      ),
    );
  }
}

class _AttendanceRequestsReviewBody extends ConsumerWidget {
  const _AttendanceRequestsReviewBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceRequestsReviewControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Center(
        child: AppLoadingIndicator(size: 40, color: ZuranoTokens.primary),
      );
    }

    if (state.hasError &&
        state.requests.isEmpty &&
        state.correctionRequests.isEmpty) {
      return AppFadeIn(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.attendanceReviewErrorTitle,
              message: state.errorMessage ?? l10n.genericError,
              icon: AppIcons.cloud_off_outlined,
              primaryActionLabel: l10n.commonRetry,
              onPrimaryAction: () {
                ref.invalidate(attendanceRequestsReviewControllerProvider);
              },
            ),
          ),
        ),
      );
    }

    if (state.requests.isEmpty &&
        state.punchRequests.isEmpty &&
        state.correctionRequests.isEmpty) {
      return AppFadeIn(
        child: RefreshIndicator(
          color: ZuranoTokens.primary,
          onRefresh: () async {
            ref.invalidate(pendingAttendanceRequestsStreamProvider);
            ref.invalidate(pendingAttendancePunchRequestsStreamProvider);
            ref.invalidate(pendingAttendanceCorrectionRequestsStreamProvider);
            ref.invalidate(attendanceRequestsReviewControllerProvider);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.large),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ZuranoEmptyState(
                      title: l10n.attendanceReviewEmptyTitle,
                      description: l10n.attendanceReviewEmptyMessage,
                      primaryLabel: '',
                      onPrimary: () {},
                      icon: AppIcons.verified_outlined,
                      showPrimaryButton: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return AppFadeIn(
      child: RefreshIndicator(
        color: ZuranoTokens.primary,
        onRefresh: () async {
          ref.invalidate(pendingAttendanceRequestsStreamProvider);
          ref.invalidate(pendingAttendancePunchRequestsStreamProvider);
          ref.invalidate(pendingAttendanceCorrectionRequestsStreamProvider);
          ref.invalidate(attendanceRequestsReviewControllerProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.large),
          children: [
            if (state.punchRequests.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.attendanceReviewTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                      color: ZuranoTokens.textDark,
                    ),
                  ),
                ),
              ),
              ...state.punchRequests.map((req) {
                final processing = state.processingPunchRequestIds.contains(
                  req.requestId,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: _PunchRequestRow(
                    request: req,
                    processing: processing,
                    onApprove: () => ref
                        .read(attendanceRequestsReviewControllerProvider.notifier)
                        .approvePunchRequest(req),
                    onReject: () async {
                      final reason = await _promptRejectionReason(context, l10n);
                      if (reason == null) return;
                      await ref
                          .read(
                            attendanceRequestsReviewControllerProvider.notifier,
                          )
                          .rejectPunchRequest(req, rejectionNote: reason);
                    },
                  ),
                );
              }),
              if (state.requests.isNotEmpty || state.correctionRequests.isNotEmpty)
                const SizedBox(height: AppSpacing.small),
            ],
            ...state.requests.map((record) {
              final processing = state.processingIds.contains(record.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: _AttendanceRequestRow(
                  record: record,
                  processing: processing,
                  onApprove: () => ref
                      .read(
                        attendanceRequestsReviewControllerProvider.notifier,
                      )
                      .approve(record),
                  onReject: () async {
                    final reason = await _promptRejectionReason(context, l10n);
                    if (reason == null) return;
                    await ref
                        .read(
                          attendanceRequestsReviewControllerProvider.notifier,
                        )
                        .reject(record, rejectionReason: reason);
                  },
                ),
              );
            }),
            if (state.correctionRequests.isNotEmpty) ...[
              if (state.requests.isNotEmpty)
                const SizedBox(height: AppSpacing.small),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.teamAttendanceCorrectionRequestsTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                      color: ZuranoTokens.textDark,
                    ),
                  ),
                ),
              ),
              ...state.correctionRequests.map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                  child: _CorrectionRequestReviewTile(
                    request: request,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<String?> _promptRejectionReason(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (dialogCtx) {
        final controller = TextEditingController();
        return Theme(
          data: Theme.of(dialogCtx).copyWith(
            colorScheme: Theme.of(dialogCtx).colorScheme.copyWith(
                  primary: ZuranoTokens.primary,
                ),
          ),
          child: AlertDialog(
            backgroundColor: ZuranoTokens.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
            ),
            title: Text(
              l10n.attendanceReviewRejectDialogTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: ZuranoTokens.textDark,
              ),
            ),
            content: TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: ZuranoTokens.textDark),
              decoration: InputDecoration(
                filled: true,
                fillColor: ZuranoTokens.inputFill,
                hintText: l10n.attendanceReviewRejectDialogHint,
                hintStyle: const TextStyle(color: ZuranoTokens.textGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
                  borderSide: const BorderSide(color: ZuranoTokens.sectionBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
                  borderSide: const BorderSide(color: ZuranoTokens.sectionBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
                  borderSide: const BorderSide(
                    color: ZuranoTokens.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(null),
                child: Text(
                  l10n.commonCancel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ZuranoTokens.textGray,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ZuranoTokens.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    ZuranoTokens.radiusButton,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      ZuranoTokens.radiusButton,
                    ),
                    onTap: () =>
                        Navigator.of(dialogCtx).pop(controller.text.trim()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Text(
                        l10n.attendanceReviewRejectConfirm,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return result;
  }
}

class _PunchRequestRow extends StatelessWidget {
  const _PunchRequestRow({
    required this.request,
    required this.processing,
    required this.onApprove,
    required this.onReject,
  });

  final AttendanceRequestModel request;
  final bool processing;
  final Future<void> Function() onApprove;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMMEEEEd(locale);
    final timeFmt = DateFormat.jm(locale);

    return _ZuranoPremiumReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ZuranoTokens.lightPurple,
                child: Text(
                  _initials(formatTeamMemberName(request.employeeName)),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ZuranoTokens.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName.trim().isEmpty
                          ? l10n.attendanceReviewUnknownEmployee
                          : formatTeamMemberName(request.employeeName),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: ZuranoTokens.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.attendanceReviewTypeGeneric,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZuranoTokens.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              _PendingBadge(label: l10n.attendanceReviewStatusPending),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          _InfoLine(
            icon: AppIcons.calendar_today_outlined,
            text: dateFmt.format(request.requestedDateTime.toLocal()),
          ),
          _InfoLine(
            icon: AppIcons.schedule_outlined,
            text: timeFmt.format(request.requestedDateTime.toLocal()),
          ),
          const SizedBox(height: AppSpacing.small),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: ZuranoTokens.searchFill,
              borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
              border: Border.all(color: ZuranoTokens.sectionBorder),
            ),
            child: Text(
              request.reason.trim().isEmpty
                  ? l10n.teamMemberAttendanceNoReason
                  : request.reason.trim(),
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: ZuranoTokens.textDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: processing ? null : onReject,
                  icon: const Icon(AppIcons.close_rounded, size: 18),
                  label: Text(l10n.attendanceReviewReject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZuranoPremiumUiColors.danger,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: ZuranoTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      ZuranoTokens.radiusButton,
                    ),
                    boxShadow: ZuranoTokens.fabGlow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                      onTap: processing ? null : onApprove,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (processing)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(
                                AppIcons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.attendanceReviewApprove,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.take(2).toString();
    return '${parts.first.characters.first}${parts[1].characters.first}';
  }
}

/// Zurano premium surface — matches Services / team attendance purple shell.
class _ZuranoPremiumReviewCard extends StatelessWidget {
  const _ZuranoPremiumReviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.softCardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _AttendanceRequestRow extends StatelessWidget {
  const _AttendanceRequestRow({
    required this.record,
    required this.processing,
    required this.onApprove,
    required this.onReject,
  });

  final AttendanceRecord record;
  final bool processing;
  final Future<bool> Function() onApprove;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMMEEEEd(locale);
    final timeFmt = DateFormat.jm(locale);
    final submittedAt = record.createdAt ?? record.updatedAt;

    return _ZuranoPremiumReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ZuranoTokens.lightPurple,
                child: Text(
                  _initials(formatTeamMemberName(record.employeeName)),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ZuranoTokens.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.employeeName.isEmpty
                          ? l10n.attendanceReviewUnknownEmployee
                          : formatTeamMemberName(record.employeeName),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: ZuranoTokens.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(l10n, record.status),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZuranoTokens.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              _PendingBadge(label: l10n.attendanceReviewStatusPending),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          _InfoLine(
            icon: AppIcons.calendar_today_outlined,
            text: dateFmt.format(record.workDate.toLocal()),
          ),
          if (record.checkInAt != null)
            _InfoLine(
              icon: AppIcons.login_outlined,
              text: l10n.attendanceReviewCheckInAt(
                timeFmt.format(record.checkInAt!.toLocal()),
              ),
            ),
          if (record.checkOutAt != null)
            _InfoLine(
              icon: AppIcons.logout_outlined,
              text: l10n.attendanceReviewCheckOutAt(
                timeFmt.format(record.checkOutAt!.toLocal()),
              ),
            ),
          if (submittedAt != null)
            _InfoLine(
              icon: AppIcons.schedule_outlined,
              text: l10n.attendanceReviewSubmittedAt(
                timeFmt.format(submittedAt.toLocal()),
              ),
            ),
          if ((record.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: ZuranoTokens.searchFill,
                borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
                border: Border.all(color: ZuranoTokens.sectionBorder),
              ),
              child: Text(
                record.notes!.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: ZuranoTokens.textDark,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: processing ? null : () async => onReject(),
                  icon: const Icon(AppIcons.close_rounded, size: 18),
                  label: Text(l10n.attendanceReviewReject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZuranoPremiumUiColors.danger,
                    side: const BorderSide(
                      color: Color(0xFFFECACA),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: ZuranoTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      ZuranoTokens.radiusButton,
                    ),
                    boxShadow: ZuranoTokens.fabGlow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                      onTap: processing ? null : () async => onApprove(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (processing)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(
                                AppIcons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.attendanceReviewApprove,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.take(2).toString();
    return '${parts.first.characters.first}${parts[1].characters.first}';
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'present':
        return l10n.attendanceReviewTypePresent;
      case 'absent':
        return l10n.attendanceReviewTypeAbsent;
      case 'leave':
        return l10n.attendanceReviewTypeLeave;
      default:
        return l10n.attendanceReviewTypeGeneric;
    }
  }
}

class _CorrectionRequestReviewTile extends ConsumerWidget {
  const _CorrectionRequestReviewTile({required this.request});

  final AttendanceCorrectionRequestModel request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim() ?? '';
    if (salonId.isEmpty) return const SizedBox.shrink();

    final localeTag = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat.jm(localeTag);
    final dateFormat = DateFormat.yMMMd(localeTag);
    final metaLine = _correctionMetaLine(
      context,
      request,
      dateFormat,
      timeFormat,
    );
    final typeLabel = _correctionTypeLabel(context, request);
    final args = TeamMemberAttendanceArgs(
      salonId: salonId,
      employeeId: request.employeeId,
    );

    void openSheet(CorrectionReviewIntent intent) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CorrectionReviewSheet(
          salonId: salonId,
          request: request,
          intent: intent,
          args: args,
        ),
      );
    }

    return _ZuranoPremiumReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ZuranoTokens.lightPurple,
                child: Text(
                  _correctionInitials(request.employeeName),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ZuranoTokens.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName.trim().isEmpty
                          ? l10n.attendanceReviewUnknownEmployee
                          : request.employeeName.trim(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: ZuranoTokens.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZuranoTokens.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              _PendingBadge(label: l10n.attendanceReviewStatusPending),
            ],
          ),
          if (metaLine != null) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              metaLine,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ZuranoTokens.textGray,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.medium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              color: ZuranoTokens.searchFill,
              borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
              border: Border.all(color: ZuranoTokens.sectionBorder),
            ),
            child: Text(
              request.reason.trim().isEmpty
                  ? l10n.teamMemberAttendanceNoReason
                  : request.reason.trim(),
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: ZuranoTokens.textDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openSheet(CorrectionReviewIntent.reject),
                  icon: const Icon(AppIcons.close_rounded, size: 18),
                  label: Text(l10n.teamMemberAttendanceReject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZuranoPremiumUiColors.danger,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: ZuranoTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      ZuranoTokens.radiusButton,
                    ),
                    boxShadow: ZuranoTokens.fabGlow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                      onTap: () => openSheet(CorrectionReviewIntent.approve),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              AppIcons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.teamMemberAttendanceApprove,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _correctionInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString();
    }
    return '${parts.first.characters.first}${parts[1].characters.first}';
  }
}

String _correctionTypeLabel(
  BuildContext context,
  AttendanceCorrectionRequestModel request,
) {
  final l10n = AppLocalizations.of(context)!;
  if (request.requestedPunchType.isNotEmpty) {
    return _correctionPunchTypeLabel(l10n, request.requestedPunchType);
  }
  return switch (request.requestType) {
    'missing_check_in' => l10n.teamMemberAttendanceRequestTypeMissingCheckIn,
    'missing_checkout' => l10n.teamMemberAttendanceRequestTypeMissingCheckout,
    'wrong_check_in' => l10n.teamMemberAttendanceRequestTypeWrongCheckIn,
    'wrong_check_out' => l10n.teamMemberAttendanceRequestTypeWrongCheckOut,
    'absence_correction' => l10n.teamMemberAttendanceRequestTypeAbsence,
    _ => l10n.teamMemberAttendanceRequestTypeGeneric,
  };
}

String _correctionPunchTypeLabel(AppLocalizations l10n, String punch) {
  if (punch == 'breakOut' || punch == 'breakIn') {
    return l10n.teamMemberAttendanceRequestTypeGeneric;
  }
  return switch (punch) {
    'punchIn' => l10n.teamMemberAttendanceRequestTypeMissingCheckIn,
    'punchOut' => l10n.teamMemberAttendanceRequestTypeMissingCheckout,
    _ => l10n.teamMemberAttendanceRequestTypeGeneric,
  };
}

String? _correctionMetaLine(
  BuildContext context,
  AttendanceCorrectionRequestModel request,
  DateFormat dateFormat,
  DateFormat timeFormat,
) {
  final l10n = AppLocalizations.of(context)!;
  if (request.requestedPunchTime != null) {
    final t = request.requestedPunchTime!.toLocal();
    return '${dateFormat.format(t)} · ${timeFormat.format(t)}';
  }
  if (request.attendanceDate.isNotEmpty) {
    final parsed = DateTime.tryParse(request.attendanceDate);
    if (parsed != null) {
      return dateFormat.format(parsed.toLocal());
    }
    return request.attendanceDate;
  }
  if (request.requestedCheckInAt != null ||
      request.requestedCheckOutAt != null) {
    final parts = <String>[];
    if (request.requestedCheckInAt != null) {
      parts.add(
        '${l10n.teamMemberAttendanceCheckInLabel}: '
        '${timeFormat.format(request.requestedCheckInAt!.toLocal())}',
      );
    }
    if (request.requestedCheckOutAt != null) {
      parts.add(
        '${l10n.teamMemberAttendanceCheckOutLabel}: '
        '${timeFormat.format(request.requestedCheckOutAt!.toLocal())}',
      );
    }
    return parts.join(' · ');
  }
  return null;
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: ZuranoTokens.lightPurple,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ZuranoTokens.secondary.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: ZuranoTokens.primary,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small / 2),
      child: Row(
        children: [
          Icon(icon, size: 17, color: ZuranoTokens.primary.withValues(alpha: 0.85)),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: ZuranoTokens.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
