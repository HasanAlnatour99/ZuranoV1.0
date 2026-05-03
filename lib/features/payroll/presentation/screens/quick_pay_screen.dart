import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/keyboard_safe_form_scaffold.dart';
import '../../../../features/money/presentation/widgets/premium_finance_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/salon_streams_provider.dart'
    show employeesStreamProvider;
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../employees/data/models/employee.dart';
import '../../data/payroll_constants.dart';
import '../../domain/effective_payroll_period.dart';
import '../../logic/payroll_dashboard_providers.dart';
import '../../logic/quickpay_controller.dart';
import '../widgets/payroll_month_selector.dart';
import '../widgets/payroll_week_selector.dart';
import '../widgets/payroll_result_line_tile.dart';
import '../widgets/payroll_section_card.dart';
import '../widgets/payroll_summary_card.dart';
import '../widgets/quick_pay_staff_picker.dart';

Future<bool> _confirmQuickPayRollback(
  BuildContext context,
  AppLocalizations l10n,
  Future<bool> Function() onRollback,
) async {
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
  if (ok != true || !context.mounted) return false;
  return onRollback();
}

String _quickPayRunStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case PayrollRunStatuses.draft:
      return l10n.payrollStatusDraft;
    case PayrollRunStatuses.approved:
      return l10n.payrollStatusApproved;
    case PayrollRunStatuses.paid:
      return l10n.payrollStatusPaid;
    case PayrollRunStatuses.rolledBack:
      return l10n.payrollStatusRolledBack;
    default:
      return status;
  }
}

class QuickPayScreen extends ConsumerWidget {
  const QuickPayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(quickPayControllerProvider);
    final controller = ref.read(quickPayControllerProvider.notifier);
    final employeesAsync = ref.watch(employeesStreamProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppPageHeader(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ZuranoPremiumUiColors.background,
        foregroundColor: ZuranoPremiumUiColors.textPrimary,
        fallbackLocation: AppRoutes.ownerPayroll,
        title: Text(
          l10n.payrollQuickPayTitle,
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
            padding: const EdgeInsets.all(24),
            child: AppEmptyState(
              title: l10n.payrollQuickPayTitle,
              message: l10n.payrollGenericError,
              icon: AppIcons.flash_on_rounded,
            ),
          ),
        ),
        data: (employees) {
          final eligibleEmployees = employees
              .where(
                (employee) =>
                    employee.role != UserRoles.owner && employee.isActive,
              )
              .toList(growable: false);

          Employee? selectedEmployee;
          for (final e in eligibleEmployees) {
            if (e.id == state.selectedEmployeeId) {
              selectedEmployee = e;
              break;
            }
          }
          final salonCadence = ref.watch(payrollHubSalonCadenceProvider);
          final effectiveQuickPayCadence = effectivePayrollPeriodFor(
            salonDefaultPayrollPeriod: salonCadence,
            employeePayrollPeriodOverride: selectedEmployee?.payrollPeriodOverride,
          );
          final quickPayUsesWeeklySelector =
              effectiveQuickPayCadence == SalonPayrollPeriods.weekly;

          return AppMotionPlayback(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.viewInsetsOf(context).bottom +
                    118 +
                    kKeyboardSafePaddingExtra,
              ),
              children: [
                Text(
                  l10n.ownerPayrollFinanceBreadcrumb,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ZuranoPremiumUiColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.payrollQuickPayScreenSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                AppEntranceMotion(
                  motionId: 'quickpay-setup',
                  child: PremiumFinanceCard(
                    zuranoPremiumStyle: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.payrollQuickPaySetupCardTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ZuranoPremiumUiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        QuickPayStaffSelectorTile(
                          l10n: l10n,
                          employees: eligibleEmployees,
                          selectedId: state.selectedEmployeeId,
                          enabled: eligibleEmployees.isNotEmpty,
                          onTap: eligibleEmployees.isEmpty
                              ? () {}
                              : () => showQuickPayStaffPickerSheet(
                                    context: context,
                                    l10n: l10n,
                                    employees: eligibleEmployees,
                                    selectedId: state.selectedEmployeeId,
                                    onEmployeeSelected: (id) {
                                      Employee? picked;
                                      for (final e in eligibleEmployees) {
                                        if (e.id == id) {
                                          picked = e;
                                          break;
                                        }
                                      }
                                      controller.selectEmployee(
                                        id,
                                        payrollPeriodOverride:
                                            picked?.payrollPeriodOverride,
                                      );
                                    },
                                  ),
                        ),
                        if (eligibleEmployees.isEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.payrollQuickPayStaffEmpty,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.payrollFieldPayrollPeriod,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: ZuranoPremiumUiColors.textPrimary,
                                ),
                              ),
                            ),
                            if (quickPayUsesWeeklySelector)
                              PayrollWeekSelector(
                                weekYear: state.isoWeekYear,
                                weekNumber: state.isoWeekNumber,
                                onChanged: controller.selectIsoWeek,
                              )
                            else
                              PayrollMonthSelector(
                                selectedMonth: state.period,
                                onChanged: controller.selectPeriod,
                              ),
                          ],
                        ),
                        if (state.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            state.error == 'missing'
                                ? l10n.payrollQuickPayValidation
                                : state.error!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AppPrimaryButton(
                          label: l10n.payrollActionCalculate,
                          isLoading: state.isBusy,
                          onPressed: controller.calculate,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (state.bundle == null)
                  AppEntranceMotion(
                    motionId: 'quickpay-empty',
                    index: 1,
                    child: _QuickPayStatementEmptyState(
                      title: l10n.payrollQuickPayStatementEmptyTitle,
                      message: l10n.payrollQuickPayStatementEmptySubtitle,
                    ),
                  )
                else
                  AppEntranceMotion(
                    motionId: 'quickpay-statement',
                    index: 1,
                    child: _QuickPayStatement(
                      currencyCode: currencyCode,
                      onApprove: controller.approve,
                      onPay: controller.pay,
                      onRollback:
                          state.savedRunId == null ||
                                  !PayrollRunStatuses.canRollback(
                                    state.bundle!.run.status,
                                  )
                              ? null
                              : () => _confirmQuickPayRollback(
                                    context,
                                    l10n,
                                    controller.rollback,
                                  ),
                      onOpenPayslip: state.savedRunId == null
                          ? null
                          : () {
                              context.push(
                                AppRoutes.payrollPayslip(
                                  state.savedRunId!,
                                  state
                                      .bundle!
                                      .employeeStatements
                                      .first
                                      .employee
                                      .id,
                                ),
                              );
                            },
                      state: state,
                      statusLabel: _quickPayRunStatusLabel(
                        l10n,
                        state.bundle!.run.status,
                      ),
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

class _QuickPayStatement extends StatelessWidget {
  const _QuickPayStatement({
    required this.currencyCode,
    required this.onApprove,
    required this.onPay,
    required this.state,
    required this.statusLabel,
    this.onRollback,
    this.onOpenPayslip,
  });

  final String currencyCode;
  final Future<String?> Function() onApprove;
  final Future<String?> Function() onPay;
  final Future<bool> Function()? onRollback;
  final VoidCallback? onOpenPayslip;
  final QuickPayState state;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statement = state.bundle!.employeeStatements.first;
    final earnings = statement.results
        .where(
          (result) =>
              result.classification == PayrollElementClassifications.earning,
        )
        .toList(growable: false);
    final deductions = statement.results
        .where(
          (result) =>
              result.classification == PayrollElementClassifications.deduction,
        )
        .toList(growable: false);

    return PremiumFinanceCard(
      zuranoPremiumStyle: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.payrollQuickPayStatementCardTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.payrollQuickPayRunStatusLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ZuranoPremiumUiColors.softPurple,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ZuranoPremiumUiColors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PayrollSummaryCard(
                  label: l10n.payrollSummaryEarnings,
                  value: statement.totalEarnings,
                  currencyCode: currencyCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PayrollSummaryCard(
                  label: l10n.payrollSummaryDeductions,
                  value: statement.totalDeductions,
                  currencyCode: currencyCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PayrollSummaryCard(
            label: l10n.payrollSummaryNetPay,
            value: statement.netPay,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: 20),
          PayrollSectionCard(
            title: l10n.payrollSectionEarnings,
            child: Column(
              children: [
                for (final result in earnings)
                  PayrollResultLineTile(
                    result: result,
                    currencyCode: currencyCode,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PayrollSectionCard(
            title: l10n.payrollSectionDeductions,
            child: deductions.isEmpty
                ? Text(l10n.payrollSectionEmpty)
                : Column(
                    children: [
                      for (final result in deductions)
                        PayrollResultLineTile(
                          result: result,
                          currencyCode: currencyCode,
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: l10n.payrollActionApprove,
            type: AppButtonType.secondary,
            isLoading: state.isBusy,
            onPressed: state.isBusy
                ? null
                : () async {
                    await onApprove();
                  },
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: l10n.payrollActionPay,
            isLoading: state.isBusy,
            onPressed: state.isBusy
                ? null
                : () async {
                    await onPay();
                  },
          ),
          if (onRollback != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: state.isBusy
                  ? null
                  : () async {
                      await onRollback!();
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuranoPremiumUiColors.textPrimary,
                side: const BorderSide(color: ZuranoPremiumUiColors.border),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(l10n.payrollActionRollback),
            ),
          ],
          if (onOpenPayslip != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: state.isBusy ? null : onOpenPayslip,
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuranoPremiumUiColors.primaryPurple,
                side: const BorderSide(
                  color: ZuranoPremiumUiColors.primaryPurple,
                ),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(l10n.payrollPayslipTitle),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty Quick Pay statement — premium Zurano-style stacked “slips” (no generic SVG).
class _QuickPayStatementEmptyState extends StatelessWidget {
  const _QuickPayStatementEmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: '$title. $message',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickPayEmptyStatementHero()
                .animate()
                .fadeIn(
                  duration: AppMotion.effectiveDuration(
                    context,
                    AppMotion.short,
                  ),
                )
                .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: AppMotion.effectiveDuration(
                    context,
                    AppMotion.short,
                  ),
                  curve: AppMotion.entranceCurve,
                ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPayEmptyStatementHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final backDx = isRtl ? 12.0 : -12.0;
    final frontDx = isRtl ? -10.0 : 10.0;
    final backAngle = isRtl ? 0.11 : -0.11;
    final frontAngle = isRtl ? -0.09 : 0.09;

    return Center(
      child: SizedBox(
        width: 124,
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(backDx, 8),
              child: Transform.rotate(
                angle: backAngle,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: ZuranoTokens.lightPurple,
                    border: Border.all(color: ZuranoTokens.border),
                    boxShadow: ZuranoTokens.softCardShadow,
                  ),
                  child: const SizedBox(width: 72, height: 88),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(frontDx, -4),
              child: Transform.rotate(
                angle: frontAngle,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: ZuranoTokens.primaryGradient,
                    boxShadow: ZuranoTokens.fabGlow,
                  ),
                  child: const SizedBox(
                    width: 76,
                    height: 92,
                    child: Center(
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
