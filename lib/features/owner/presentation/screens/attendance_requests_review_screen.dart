import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/user_roles.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../attendance/data/models/attendance_record.dart';
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
        if (next.lastApprovedId != null &&
            next.lastApprovedId != previous?.lastApprovedId) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.attendanceReviewApprovedSnackbar)),
          );
          ref
              .read(attendanceRequestsReviewControllerProvider.notifier)
              .clearFeedback();
        }
        if (next.lastRejectedId != null &&
            next.lastRejectedId != previous?.lastRejectedId) {
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
      appBar: AppBar(
        leading: const AppBarLeadingBack(),
        automaticallyImplyLeading: false,
        title: Text(l10n.attendanceReviewTitle),
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 40)),
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
      return const Center(child: AppLoadingIndicator(size: 40));
    }

    if (state.hasError && state.requests.isEmpty) {
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

    if (state.requests.isEmpty) {
      return AppFadeIn(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.attendanceReviewEmptyTitle,
              message: l10n.attendanceReviewEmptyMessage,
              icon: AppIcons.verified_outlined,
            ),
          ),
        ),
      );
    }

    return AppFadeIn(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingAttendanceRequestsStreamProvider);
          ref.invalidate(attendanceRequestsReviewControllerProvider);
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.large),
          itemCount: state.requests.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.medium),
          itemBuilder: (context, index) {
            final record = state.requests[index];
            final processing = state.processingIds.contains(record.id);
            return _AttendanceRequestRow(
              record: record,
              processing: processing,
              onApprove: () => ref
                  .read(attendanceRequestsReviewControllerProvider.notifier)
                  .approve(record),
              onReject: () async {
                final reason = await _promptRejectionReason(context, l10n);
                if (reason == null) return;
                await ref
                    .read(attendanceRequestsReviewControllerProvider.notifier)
                    .reject(record, rejectionReason: reason);
              },
            );
          },
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
        return AlertDialog(
          title: Text(l10n.attendanceReviewRejectDialogTitle),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.attendanceReviewRejectDialogHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogCtx).pop(controller.text.trim()),
              child: Text(l10n.attendanceReviewRejectConfirm),
            ),
          ],
        );
      },
    );
    return result;
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMMEEEEd(locale);
    final timeFmt = DateFormat.jm(locale);
    final submittedAt = record.createdAt ?? record.updatedAt;

    return AppSurfaceCard(
      borderRadius: AppRadius.large,
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primary.withValues(alpha: 0.14),
                child: Text(
                  _initials(formatTeamMemberName(record.employeeName)),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small / 2),
                    Text(
                      _statusLabel(l10n, record.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                record.notes!.trim(),
                style: theme.textTheme.bodyMedium,
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
                    foregroundColor: scheme.error,
                    side: BorderSide(
                      color: scheme.error.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.small,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: FilledButton.icon(
                  onPressed: processing ? null : () async => onApprove(),
                  icon: processing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(AppIcons.check_rounded, size: 18),
                  label: Text(l10n.attendanceReviewApprove),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.small,
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

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.small / 2,
      ),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small / 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
