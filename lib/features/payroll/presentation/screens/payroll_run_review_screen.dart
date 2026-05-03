import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/effective_payroll_period.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../features/money/presentation/widgets/premium_finance_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/salon_streams_provider.dart'
    show employeesStreamProvider;
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../data/payroll_calculation_service.dart';
import '../../data/payroll_constants.dart';
import '../../logic/payroll_dashboard_providers.dart';
import '../../logic/payroll_run_review_controller.dart';
import '../widgets/payroll_month_selector.dart';
import '../widgets/payroll_calendar_range_selector.dart';
import '../widgets/payroll_run_review_history_section.dart';
import '../widgets/payroll_result_line_tile.dart';
import '../widgets/payroll_section_card.dart';
import '../widgets/payroll_status_chip.dart';
import 'payslip_screen.dart';

Widget _runReviewGridCell(Widget child) {
  return Padding(
    padding: const EdgeInsetsDirectional.all(12),
    child: Align(
      alignment: AlignmentDirectional.topStart,
      child: child,
    ),
  );
}

class _RunReviewKpiMini extends StatelessWidget {
  const _RunReviewKpiMini({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
    required this.iconSoft,
  });

  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color iconColor;
  final Color iconSoft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconSoft.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
        ),
        Text(
          trend,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: ZuranoPremiumUiColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class PayrollRunReviewScreen extends ConsumerWidget {
  const PayrollRunReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(payrollRunReviewControllerProvider);
    final controller = ref.read(payrollRunReviewControllerProvider.notifier);
    final employeesAsync = ref.watch(employeesStreamProvider);
    final salonPayrollDefault = ref.watch(payrollHubSalonCadenceProvider);

    ref.listen(payrollRunsStreamProvider, (previous, next) {
      next.whenData((runs) {
        Future.microtask(() {
          ref
              .read(payrollRunReviewControllerProvider.notifier)
              .maybeRestoreDraft(runs);
        });
      });
    });

    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      appBar: AppPageHeader(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ZuranoPremiumUiColors.background,
        foregroundColor: ZuranoPremiumUiColors.textPrimary,
        fallbackLocation: AppRoutes.ownerPayroll,
        title: Text(
          l10n.payrollRunReviewTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: ZuranoPremiumUiColors.textPrimary,
          ),
        ),
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 36)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.payrollRunReviewTitle,
              message: l10n.payrollGenericError,
              icon: AppIcons.event_note_rounded,
              centerContent: true,
            ),
          ),
        ),
        data: (employees) {
          final eligible = employees
              .where(
                (employee) =>
                    employee.role != UserRoles.owner && employee.isActive,
              )
              .where((e) => e.isPayrollEnabled)
              .where(
                (e) =>
                    effectivePayrollPeriodFor(
                      salonDefaultPayrollPeriod: salonPayrollDefault,
                      employeePayrollPeriodOverride: e.payrollPeriodOverride,
                    ) ==
                    SalonPayrollPeriods.normalize(state.runCadence),
              )
              .toList(growable: false);

          Future<void> pickWeeklyStart() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(
                state.weeklyRangeStartUtc.year,
                state.weeklyRangeStartUtc.month,
                state.weeklyRangeStartUtc.day,
              ),
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 2, 12, 31),
              helpText: l10n.payrollRunWeeklyStartLabel,
            );
            if (!context.mounted || picked == null) {
              return;
            }
            controller.setWeeklyRangeStartUtc(picked);
          }

          Future<void> pickWeeklyEnd() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(
                state.weeklyRangeEndUtc.year,
                state.weeklyRangeEndUtc.month,
                state.weeklyRangeEndUtc.day,
              ),
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 2, 12, 31),
              helpText: l10n.payrollRunWeeklyEndLabel,
            );
            if (!context.mounted || picked == null) {
              return;
            }
            controller.setWeeklyRangeEndUtc(picked);
          }

          return AppMotionPlayback(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 118),
              children: [
                Text(
                  l10n.ownerPayrollRunReviewBreadcrumb,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ZuranoPremiumUiColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                AppEntranceMotion(
                  motionId: 'payroll-run-review-config',
                  child: PremiumFinanceCard(
                    zuranoPremiumStyle: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.payrollRunReviewConfigureSectionTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ZuranoPremiumUiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.payrollRunReviewEngineHint,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.payrollRunReviewCadenceLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(
                                value: SalonPayrollPeriods.monthly,
                                label: Text(l10n.payrollRunReviewCadenceMonthly),
                              ),
                              ButtonSegment<String>(
                                value: SalonPayrollPeriods.weekly,
                                label: Text(l10n.payrollRunReviewCadenceWeekly),
                              ),
                            ],
                            selected: {state.runCadence},
                            onSelectionChanged: (next) {
                              if (next.isEmpty) {
                                return;
                              }
                              controller.setRunCadence(next.first);
                            },
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor:
                                  ZuranoPremiumUiColors.primaryPurple,
                              selectedForegroundColor: Colors.white,
                              foregroundColor:
                                  ZuranoPremiumUiColors.textPrimary,
                              side: const BorderSide(
                                color: ZuranoPremiumUiColors.border,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (state.runCadence == SalonPayrollPeriods.monthly)
                          PayrollMonthSelector(
                            selectedMonth: state.period,
                            onChanged: controller.selectPeriod,
                          )
                        else
                          PayrollCalendarRangeSelector(
                            rangeStartUtc: state.weeklyRangeStartUtc,
                            rangeEndUtc: state.weeklyRangeEndUtc,
                            onPickStart: pickWeeklyStart,
                            onPickEnd: pickWeeklyEnd,
                          ),
                        if (eligible.isEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.payrollRunNoMatchingStaffForCadence,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: ZuranoPremiumUiColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          l10n.payrollRunEmployeesLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              label: Text(l10n.payrollRunAllMatchingStaff),
                              selected: state.selectedEmployeeIds.isEmpty,
                              onSelected: (_) =>
                                  controller.clearEmployeeFilter(),
                              selectedColor: ZuranoPremiumUiColors.softPurple,
                              checkmarkColor: ZuranoPremiumUiColors.primaryPurple,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: state.selectedEmployeeIds.isEmpty
                                    ? ZuranoPremiumUiColors.primaryPurple
                                    : ZuranoPremiumUiColors.textPrimary,
                              ),
                              side: BorderSide(
                                color: ZuranoPremiumUiColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            for (final employee in eligible)
                              FilterChip(
                                label: TeamMemberNameText(employee.name),
                                selected: state.selectedEmployeeIds.contains(
                                  employee.id,
                                ),
                                onSelected: (_) =>
                                    controller.toggleEmployee(employee.id),
                                selectedColor:
                                    ZuranoPremiumUiColors.softPurple,
                                checkmarkColor:
                                    ZuranoPremiumUiColors.primaryPurple,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: state.selectedEmployeeIds
                                          .contains(employee.id)
                                      ? ZuranoPremiumUiColors.primaryPurple
                                      : ZuranoPremiumUiColors.textPrimary,
                                ),
                                side: BorderSide(
                                  color: ZuranoPremiumUiColors.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                          ],
                        ),
                        if (state.error != null) ...[
                          const SizedBox(height: AppSpacing.medium),
                          Text(
                            state.error == 'missing'
                                ? l10n.payrollRunValidation
                                : state.error == 'week_range'
                                ? l10n.payrollRunWeeklyRangeInvalid
                                : state.error!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.medium),
                        AppPrimaryButton(
                          label: l10n.payrollActionCalculate,
                          isLoading: state.isBusy,
                          isDisabled: eligible.isEmpty,
                          onPressed: controller.calculate,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppFadeThroughSwitcher(
                  transitionKey: state.bundle == null
                      ? 'run-review-history'
                      : 'run-review-content',
                  child: state.bundle == null
                      ? PremiumFinanceCard(
                          zuranoPremiumStyle: true,
                          key: const ValueKey<String>('run-review-history'),
                          child: const PayrollRunReviewHistorySection(),
                        )
                      : _RunReviewContent(
                          key: const ValueKey<String>('run-review-content'),
                          state: state,
                          onApprove: controller.approve,
                          onPay: controller.pay,
                          onRollback: state.savedRunId == null
                              ? null
                              : controller.rollback,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RunReviewContent extends ConsumerWidget {
  const _RunReviewContent({
    super.key,
    required this.state,
    required this.onApprove,
    required this.onPay,
    this.onRollback,
  });

  final PayrollRunReviewState state;
  final Future<String?> Function() onApprove;
  final Future<String?> Function() onPay;
  final Future<bool> Function()? onRollback;

  static Future<void> _confirmRollback(
    BuildContext context,
    Future<bool> Function() onRollback,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.payrollRollbackConfirmTitle),
        content: Text(l10n.payrollRollbackConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.payrollRollbackConfirmAction),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await onRollback();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final bundle = state.bundle!;
    final run = bundle.run;
    final status = run.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.savedRunId != null) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: PayrollStatusChip(status: status),
          ),
          const SizedBox(height: 12),
        ],
        AppEntranceMotion(
          motionId: 'run-review-kpi-strip',
          child: PremiumFinanceCard(
            zuranoPremiumStyle: true,
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: ZuranoPremiumUiColors.border),
                verticalInside: BorderSide(color: ZuranoPremiumUiColors.border),
              ),
              defaultColumnWidth: const FlexColumnWidth(1),
              children: [
                TableRow(
                  children: [
                    _runReviewGridCell(
                      _RunReviewKpiMini(
                        label: l10n.payrollSummaryNetPay,
                        value: formatAppMoney(
                          run.netPay,
                          currencyCode,
                          locale,
                        ),
                        trend: l10n.payrollDashboardKpiTrendLabel,
                        icon: AppIcons.account_balance_wallet_outlined,
                        iconColor: ZuranoPremiumUiColors.primaryPurple,
                        iconSoft: ZuranoPremiumUiColors.softPurple,
                      ),
                    ),
                    _runReviewGridCell(
                      _RunReviewKpiMini(
                        label: l10n.payrollSummaryEarnings,
                        value: formatAppMoney(
                          run.totalEarnings,
                          currencyCode,
                          locale,
                        ),
                        trend: l10n.payrollDashboardKpiTrendLabel,
                        icon: AppIcons.trending_up_rounded,
                        iconColor: ZuranoPremiumUiColors.deepPurple,
                        iconSoft: ZuranoPremiumUiColors.softPurple,
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _runReviewGridCell(
                      _RunReviewKpiMini(
                        label: l10n.payrollSummaryDeductions,
                        value: formatAppMoney(
                          run.totalDeductions,
                          currencyCode,
                          locale,
                        ),
                        trend: l10n.payrollDashboardKpiTrendLabel,
                        icon: AppIcons.trending_down_rounded,
                        iconColor: ZuranoPremiumUiColors.danger,
                        iconSoft: ZuranoPremiumUiColors.dangerSoft,
                      ),
                    ),
                    _runReviewGridCell(
                      _RunReviewKpiMini(
                        label: l10n.payrollRunEmployeesLabel,
                        value: '${run.employeeCount}',
                        trend: l10n.payrollRunReviewKpiHeadcountTrend,
                        icon: AppIcons.group_outlined,
                        iconColor: ZuranoPremiumUiColors.primaryPurple,
                        iconSoft: ZuranoPremiumUiColors.softPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.payrollRunReviewTeamPreviewTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: ZuranoPremiumUiColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < bundle.employeeStatements.length; i++) ...[
          AppEntranceMotion(
            motionId:
                'run-review-statement-${bundle.employeeStatements[i].employee.id}',
            index: i,
            slideOffset: 8,
            child: _EmployeeStatementExpandableCard(
              statement: bundle.employeeStatements[i],
              currencyCode: currencyCode,
              locale: locale,
              savedRunId: state.savedRunId,
            ),
          ),
          const SizedBox(height: 12),
        ],
        PremiumFinanceCard(
          zuranoPremiumStyle: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.payrollRunReviewWorkflowTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ZuranoPremiumUiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.payrollRunReviewWorkflowSubtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              if (status == PayrollRunStatuses.paid)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.payrollRunReviewStatusPaidHint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ZuranoPremiumUiColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              if (status == PayrollRunStatuses.rolledBack)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.payrollRunReviewStatusRolledBackHint,
                    style: const TextStyle(
                      fontSize: 13,
                      color: ZuranoPremiumUiColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              if (status == PayrollRunStatuses.draft) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: state.isBusy
                        ? null
                        : () async {
                            await onApprove();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: ZuranoPremiumUiColors.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.payrollActionApprove),
                  ),
                ),
              ],
              if (status == PayrollRunStatuses.approved) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: state.isBusy
                        ? null
                        : () async {
                            await onPay();
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: ZuranoPremiumUiColors.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.payrollActionPay),
                  ),
                ),
              ],
              if (onRollback != null &&
                  PayrollRunStatuses.canRollback(status)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: state.isBusy
                        ? null
                        : () => _confirmRollback(context, onRollback!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.payrollActionRollback),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmployeeStatementExpandableCard extends StatelessWidget {
  const _EmployeeStatementExpandableCard({
    required this.statement,
    required this.currencyCode,
    required this.locale,
    this.savedRunId,
  });

  final PayrollEmployeeStatement statement;
  final String currencyCode;
  final Locale locale;
  final String? savedRunId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final earnings = statement.results
        .where(
          (r) => r.classification == PayrollElementClassifications.earning,
        )
        .toList(growable: false);
    final deductions = statement.results
        .where(
          (r) => r.classification == PayrollElementClassifications.deduction,
        )
        .toList(growable: false);
    final information = statement.results
        .where(
          (r) =>
              r.classification == PayrollElementClassifications.information,
        )
        .toList(growable: false);

    final netFormatted = formatAppMoney(
      statement.netPay,
      currencyCode,
      locale,
    );
    final summaryLine = l10n.payrollRunEmployeeSummary(
      statement.results.length,
      netFormatted,
    );

    return PremiumFinanceCard(
      zuranoPremiumStyle: true,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsetsDirectional.only(
              start: 20,
              end: 12,
              top: 4,
              bottom: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            collapsedBackgroundColor: ZuranoPremiumUiColors.lightSurface,
            backgroundColor: ZuranoPremiumUiColors.lightSurface,
            title: TeamMemberNameText(
              statement.employee.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ZuranoPremiumUiColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summaryLine,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        netFormatted,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ZuranoPremiumUiColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.payrollSummaryEarnings}: ${formatAppMoney(statement.totalEarnings, currencyCode, locale)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${l10n.payrollSummaryDeductions}: ${formatAppMoney(statement.totalDeductions, currencyCode, locale)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
              PayrollSectionCard(
                title: l10n.payrollSectionEarnings,
                expandable: true,
                child: Column(
                  children: [
                    for (final result in earnings)
                      PayrollResultLineTile(
                        result: result,
                        currencyCode: currencyCode,
                        useZuranoPremiumPalette: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              PayrollSectionCard(
                title: l10n.payrollSectionDeductions,
                expandable: true,
                child: deductions.isEmpty
                    ? Text(
                        l10n.payrollSectionEmpty,
                        style: const TextStyle(
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      )
                    : Column(
                        children: [
                          for (final result in deductions)
                            PayrollResultLineTile(
                              result: result,
                              currencyCode: currencyCode,
                              useZuranoPremiumPalette: true,
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 10),
              PayrollSectionCard(
                title: l10n.payrollSectionInformation,
                expandable: true,
                child: information.isEmpty
                    ? Text(
                        l10n.payrollSectionEmpty,
                        style: const TextStyle(
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      )
                    : Column(
                        children: [
                          for (final result in information)
                            PayrollResultLineTile(
                              result: result,
                              currencyCode: currencyCode,
                              showMeta: false,
                              useZuranoPremiumPalette: true,
                            ),
                        ],
                      ),
              ),
              if (savedRunId != null) ...[
                const SizedBox(height: 12),
                AppOpenContainerRoute(
                  closedBuilder: (context, openContainer) => Material(
                    color: ZuranoPremiumUiColors.softPurple,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: openContainer,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.receipt_long_outlined,
                              color: ZuranoPremiumUiColors.primaryPurple,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.payrollRunReviewViewPayslip,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ZuranoPremiumUiColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: ZuranoPremiumUiColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  openBuilder: (context, _) => PayslipScreen(
                    runId: savedRunId!,
                    employeeId: statement.employee.id,
                    employeeName: formatTeamMemberName(statement.employee.name),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
