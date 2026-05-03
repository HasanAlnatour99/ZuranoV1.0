import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../../employee_today/data/attendance_exception.dart';
import '../../../employee_today/providers/employee_today_providers.dart';
import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../application/team_member_attendance_providers.dart';
import '../../data/models/attendance_correction_request_model.dart';

enum CorrectionReviewIntent { approve, reject }

class CorrectionReviewSheet extends ConsumerStatefulWidget {
  const CorrectionReviewSheet({
    super.key,
    required this.salonId,
    required this.request,
    required this.args,
    required this.intent,
  });

  final String salonId;
  final AttendanceCorrectionRequestModel request;
  final TeamMemberAttendanceArgs args;
  final CorrectionReviewIntent intent;

  @override
  ConsumerState<CorrectionReviewSheet> createState() =>
      _CorrectionReviewSheetState();
}

class _CorrectionReviewSheetState extends ConsumerState<CorrectionReviewSheet> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool approved) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context)!;
    final nav = Navigator.of(context);
    final auth = ref.read(firebaseAuthProvider).currentUser;
    if (auth == null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.teamAttendanceMarkError)),
      );
      return;
    }

    final reviewerName = switch (ref.read(sessionUserProvider)) {
      AsyncData(:final value)
          when value != null && value.name.trim().isNotEmpty =>
        value.name.trim(),
      _ => auth.displayName?.trim().isNotEmpty == true
          ? auth.displayName!.trim()
          : (auth.email ?? 'Reviewer'),
    };

    setState(() => _submitting = true);
    try {
      final repo = ref.read(employeeTodayAttendanceRepositoryProvider);
      final note = _noteController.text.trim();
      if (approved) {
        await repo.approveCorrectionRequest(
          salonId: widget.salonId,
          requestId: widget.request.id,
          reviewerId: auth.uid,
          reviewerName: reviewerName,
          reviewNote: note.isEmpty ? null : note,
        );
      } else {
        await repo.rejectCorrectionRequest(
          salonId: widget.salonId,
          requestId: widget.request.id,
          reviewerId: auth.uid,
          reviewerName: reviewerName,
          reason: note.isEmpty ? l10n.teamMemberAttendanceNoReason : note,
        );
      }

      ref.invalidate(attendanceCorrectionRequestsProvider(widget.args));
      ref.invalidate(todayAttendanceProvider(widget.args));
      ref.invalidate(recentAttendanceProvider(widget.args));
      ref.invalidate(teamMemberFullAttendanceHistoryProvider(widget.args));
      ref.invalidate(attendanceSummaryProvider(widget.args));

      if (mounted) {
        nav.pop();
        showAppSuccessSnackBar(
          context,
          approved
              ? l10n.teamMemberAttendanceCorrectionApproved
              : l10n.teamMemberAttendanceCorrectionRejected,
        );
      }
    } on AttendanceException catch (e) {
      if (mounted) {
        messenger?.showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        messenger?.showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final approved = widget.intent == CorrectionReviewIntent.approve;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: TeamMemberProfileColors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  approved
                      ? l10n.teamMemberAttendanceReviewApproveTitle
                      : l10n.teamMemberAttendanceReviewRejectTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.request.reason.isEmpty
                      ? l10n.teamMemberAttendanceNoReason
                      : widget.request.reason,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TeamMemberProfileColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.teamMemberAttendanceReviewNoteLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: approved
                        ? TeamMemberProfileColors.primary
                        : const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitting ? null : () => _submit(approved),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          approved
                              ? l10n.teamMemberAttendanceReviewConfirmApprove
                              : l10n.teamMemberAttendanceReviewConfirmReject,
                        ),
                ),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
