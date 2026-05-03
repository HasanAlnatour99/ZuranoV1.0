import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/team_member_attendance_providers.dart';
import '../../data/models/attendance_correction_request_model.dart';
import 'correction_review_sheet.dart';

class AttendanceCorrectionRequestsCard extends StatelessWidget {
  const AttendanceCorrectionRequestsCard({
    super.key,
    required this.requests,
    required this.salonId,
    required this.canManageAttendance,
    required this.args,
  });

  final List<AttendanceCorrectionRequestModel> requests;
  final String salonId;
  final bool canManageAttendance;
  final TeamMemberAttendanceArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pending = requests.where((r) => r.status == 'pending').toList();
    final visibleRequests = pending.isNotEmpty
        ? pending
        : requests.take(3).toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.sectionShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: ZuranoTokens.lightPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: ZuranoTokens.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.teamMemberAttendanceCorrectionsTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: ZuranoTokens.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (visibleRequests.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EmptyState(
                    title: l10n.teamMemberAttendanceCorrectionEmptyTitle,
                    subtitle: l10n.teamMemberAttendanceCorrectionEmptySubtitle,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                children: visibleRequests
                    .map(
                      (request) => _RequestTile(
                        request: request,
                        canManageAttendance: canManageAttendance,
                        salonId: salonId,
                        args: args,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.canManageAttendance,
    required this.salonId,
    required this.args,
  });

  final AttendanceCorrectionRequestModel request;
  final bool canManageAttendance;
  final String salonId;
  final TeamMemberAttendanceArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPending = request.status == 'pending';
    final localeTag = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat.jm(localeTag);
    final dateFormat = DateFormat.yMMMd(localeTag);

    final metaLine = _requestMetaLine(
      context,
      request,
      dateFormat,
      timeFormat,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZuranoTokens.searchFill,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.history_toggle_off_rounded,
                color: ZuranoTokens.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _requestTypeLabel(context, request),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ZuranoTokens.textDark,
                        height: 1.25,
                      ),
                    ),
                    if (metaLine != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        metaLine,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ZuranoTokens.textGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.reason.isEmpty
                ? l10n.teamMemberAttendanceNoReason
                : request.reason,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 13,
              color: ZuranoTokens.textGray,
              height: 1.4,
            ),
          ),
          if (isPending && canManageAttendance) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ZuranoTokens.radiusButton,
                        ),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CorrectionReviewSheet(
                          salonId: salonId,
                          request: request,
                          intent: CorrectionReviewIntent.reject,
                          args: args,
                        ),
                      );
                    },
                    child: Text(l10n.teamMemberAttendanceReject),
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
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => CorrectionReviewSheet(
                              salonId: salonId,
                              request: request,
                              intent: CorrectionReviewIntent.approve,
                              args: args,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              l10n.teamMemberAttendanceApprove,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _requestTypeLabel(
    BuildContext context,
    AttendanceCorrectionRequestModel request,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (request.requestedPunchType.isNotEmpty) {
      return _punchTypeLabel(l10n, request.requestedPunchType);
    }
    return switch (request.requestType) {
      'missing_check_in' => l10n.teamMemberAttendanceRequestTypeMissingCheckIn,
      'missing_checkout' =>
        l10n.teamMemberAttendanceRequestTypeMissingCheckout,
      'wrong_check_in' => l10n.teamMemberAttendanceRequestTypeWrongCheckIn,
      'wrong_check_out' => l10n.teamMemberAttendanceRequestTypeWrongCheckOut,
      'absence_correction' => l10n.teamMemberAttendanceRequestTypeAbsence,
      _ => l10n.teamMemberAttendanceRequestTypeGeneric,
    };
  }

  static String _punchTypeLabel(AppLocalizations l10n, String punch) {
    if (punch == 'breakOut' || punch == 'breakIn') {
      return l10n.teamMemberAttendanceRequestTypeGeneric;
    }
    return switch (punch) {
      'punchIn' => l10n.teamMemberAttendanceRequestTypeMissingCheckIn,
      'punchOut' => l10n.teamMemberAttendanceRequestTypeMissingCheckout,
      _ => l10n.teamMemberAttendanceRequestTypeGeneric,
    };
  }

  static String? _requestMetaLine(
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
          '${l10n.teamMemberAttendanceCheckInLabel}: ${timeFormat.format(request.requestedCheckInAt!.toLocal())}',
        );
      }
      if (request.requestedCheckOutAt != null) {
        parts.add(
          '${l10n.teamMemberAttendanceCheckOutLabel}: ${timeFormat.format(request.requestedCheckOutAt!.toLocal())}',
        );
      }
      return parts.join(' · ');
    }
    return null;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (status) {
      'approved' => l10n.teamMemberAttendanceStatusApproved,
      'rejected' => l10n.teamMemberAttendanceStatusRejected,
      'pending' => l10n.teamMemberAttendanceStatusPending,
      _ => status,
    };

    final color = switch (status) {
      'approved' => const Color(0xFF16A34A),
      'rejected' => const Color(0xFFDC2626),
      'pending' => const Color(0xFFF59E0B),
      _ => ZuranoTokens.textGray,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.assignment_turned_in_rounded,
          color: ZuranoTokens.primary.withValues(alpha: 0.45),
          size: 42,
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: ZuranoTokens.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: ZuranoTokens.textGray,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
