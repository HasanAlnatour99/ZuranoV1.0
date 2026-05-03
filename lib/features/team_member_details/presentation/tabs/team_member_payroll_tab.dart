import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/firebase_error_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../payroll/application/payroll_providers.dart';
import '../../../payroll/domain/payroll_adjustment_not_found.dart';
import '../../../payroll/domain/models/payroll_adjustment.dart';
import '../../../payroll/domain/models/payroll_status.dart';
import '../../../payroll/domain/models/team_member_payroll_summary.dart';
import '../widgets/payroll/payroll_adjustment_bottom_sheet.dart';
import '../widgets/payroll/payroll_edit_element_bottom_sheet.dart';
import '../widgets/payroll/payroll_breakdown_card.dart';
import '../widgets/payroll/payroll_error_state.dart';
import '../widgets/payroll/payroll_history_error_card.dart';
import '../widgets/payroll/payroll_history_section.dart';
import '../widgets/payroll/payroll_history_skeleton.dart';
import '../widgets/payroll/payroll_locked_banner.dart';
import '../widgets/payroll/payroll_month_selector.dart';
import '../widgets/payroll/payroll_quick_actions_row.dart';
import '../widgets/payroll/payroll_tab_skeleton.dart';
import '../widgets/payroll/payroll_summary_hero_card.dart';

class TeamMemberPayrollTab extends ConsumerStatefulWidget {
  const TeamMemberPayrollTab({
    super.key,
    required this.salonId,
    required this.employeeId,
  });

  final String salonId;
  final String employeeId;

  @override
  ConsumerState<TeamMemberPayrollTab> createState() =>
      _TeamMemberPayrollTabState();
}

class _TeamMemberPayrollTabState extends ConsumerState<TeamMemberPayrollTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _payrollLockedFullMessage(
    AppLocalizations l10n,
    TeamMemberPayrollSummary summary,
  ) {
    final String detail;
    if (!summary.employeeActive) {
      detail = l10n.employeeInactivePayrollMessage;
    } else if (summary.status == PayrollStatus.paid) {
      detail = l10n.payrollPaidLockedMessage;
    } else {
      detail = l10n.payrollPayslipGeneratedLockedMessage;
    }
    return '${l10n.payrollLocked}: $detail';
  }

  void _showFloatingPayrollSnackBar(BuildContext context, String message) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final snackBarBottomMargin = 96 + bottomSafe;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(24, 0, 24, snackBarBottomMargin),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          duration: const Duration(seconds: 2),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final params = TeamMemberPayrollParams(
      salonId: widget.salonId,
      employeeId: widget.employeeId,
    );
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(teamMemberPayrollSummaryProvider(params));
    final historyAsync = ref.watch(teamMemberPayrollHistoryProvider(params));

    return summaryAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const PayrollTabSkeleton(),
      error: (error, _) => PayrollErrorState(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(teamMemberPayrollSummaryProvider(params));
          ref.invalidate(teamMemberPayrollHistoryProvider(params));
        },
      ),
      data: (summary) {
        final payrollLocked = !summary.canEditPayroll;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PayrollMonthSelector(
                selectedMonthKey: summary.monthKey,
                onPrevious: () => ref
                    .read(currentPayrollMonthProvider.notifier)
                    .previousMonth(),
                onNext: () =>
                    ref.read(currentPayrollMonthProvider.notifier).nextMonth(),
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        ...previousChildren,
                        ?currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.08),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: payrollLocked
                      ? PayrollLockedBanner(
                          key: const ValueKey<String>('locked-payroll-banner'),
                          message: _payrollLockedFullMessage(l10n, summary),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey<String>('empty-payroll-banner'),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              PayrollSummaryHeroCard(summary: summary),
              const SizedBox(height: 16),
              PayrollQuickActionsRow(
                editingEnabled: summary.canEditPayroll,
                reverseEnabled: summary.employeeActive,
                onAddBonus: () => showPayrollAdjustmentBottomSheet(
                  context: context,
                  ref: ref,
                  salonId: widget.salonId,
                  employeeId: widget.employeeId,
                  monthKey: summary.monthKey,
                  type: PayrollAdjustmentType.bonus,
                ),
                onAddDeduction: () => showPayrollAdjustmentBottomSheet(
                  context: context,
                  ref: ref,
                  salonId: widget.salonId,
                  employeeId: widget.employeeId,
                  monthKey: summary.monthKey,
                  type: PayrollAdjustmentType.deduction,
                ),
                onGeneratePayslip: () async {
                  await ref
                      .read(payrollActionControllerProvider.notifier)
                      .generatePayslip(
                        salonId: widget.salonId,
                        employeeId: widget.employeeId,
                      );
                  if (!context.mounted) return;
                  ref.invalidate(teamMemberPayrollSummaryProvider(params));
                  ref.invalidate(teamMemberPayrollHistoryProvider(params));
                  _showFloatingPayrollSnackBar(
                    context,
                    l10n.payslipGeneratedSuccessfully,
                  );
                },
                onReverseLastPayrollMonth: () async {
                  final shouldReverse = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.reverseLastPayrollMonthTitle),
                      content: Text(l10n.reverseLastPayrollMonthMessage),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: Text(l10n.keepElement),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: Text(l10n.reverseLastPayrollMonth),
                        ),
                      ],
                    ),
                  );
                  if (shouldReverse != true) return;
                  await ref
                      .read(payrollActionControllerProvider.notifier)
                      .reverseLatestPayrollMonth(
                        salonId: widget.salonId,
                        employeeId: widget.employeeId,
                      );
                  if (!context.mounted) return;
                  ref.invalidate(teamMemberPayrollSummaryProvider(params));
                  ref.invalidate(teamMemberPayrollHistoryProvider(params));
                  _showFloatingPayrollSnackBar(
                    context,
                    l10n.reversePayrollMonthSuccess,
                  );
                },
              ),
              const SizedBox(height: 16),
              PayrollBreakdownCard(
                summary: summary,
                onDeleteBonusElement: (name) =>
                    _deletePayrollElement(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      params: params,
                      summary: summary,
                      type: PayrollAdjustmentType.bonus,
                      name: name,
                    ),
                onDeleteDeductionElement: (name) =>
                    _deletePayrollElement(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      params: params,
                      summary: summary,
                      type: PayrollAdjustmentType.deduction,
                      name: name,
                    ),
                onEditBonusElement: summary.canEditPayroll
                    ? (PayrollNamedAmount item) =>
                          showPayrollEditElementBottomSheet(
                            context: context,
                            ref: ref,
                            salonId: widget.salonId,
                            employeeId: widget.employeeId,
                            monthKey: summary.monthKey,
                            type: PayrollAdjustmentType.bonus,
                            item: item,
                          )
                    : null,
                onEditDeductionElement: summary.canEditPayroll
                    ? (PayrollNamedAmount item) =>
                          showPayrollEditElementBottomSheet(
                            context: context,
                            ref: ref,
                            salonId: widget.salonId,
                            employeeId: widget.employeeId,
                            monthKey: summary.monthKey,
                            type: PayrollAdjustmentType.deduction,
                            item: item,
                          )
                    : null,
              ),
              const SizedBox(height: 16),
              historyAsync.when(
                skipLoadingOnReload: true,
                skipLoadingOnRefresh: true,
                loading: () => const PayrollHistorySkeleton(),
                error: (error, _) => PayrollHistoryErrorCard(
                  onRetry: () =>
                      ref.invalidate(teamMemberPayrollHistoryProvider(params)),
                ),
                data: (records) => PayrollHistorySection(
                  records: records,
                  currencyCode: summary.currencyCode,
                  onGenerateFirstPayslip: null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePayrollElement({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required TeamMemberPayrollParams params,
    required TeamMemberPayrollSummary summary,
    required PayrollAdjustmentType type,
    required String name,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deletePayrollElementTitle),
        content: Text(l10n.deletePayrollElementMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepElement),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteElement),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    try {
      await ref.read(payrollActionControllerProvider.notifier).removeAdjustmentElement(
        salonId: params.salonId,
        employeeId: params.employeeId,
        monthKey: summary.monthKey,
        type: type,
        reason: name,
      );
    } on PayrollAdjustmentNotFound {
      if (!context.mounted) return;
      _showFloatingPayrollSnackBar(
        context,
        l10n.payrollAdjustmentDeleteNoneMatched,
      );
      return;
    } catch (e) {
      if (!context.mounted) return;
      _showFloatingPayrollSnackBar(
        context,
        FirebaseErrorMessage.fromException(e),
      );
      return;
    }
    if (!context.mounted) return;
    ref.invalidate(teamMemberPayrollSummaryProvider(params));
    ref.invalidate(teamMemberPayrollHistoryProvider(params));
    _showFloatingPayrollSnackBar(context, l10n.payrollElementDeleted);
  }
}
