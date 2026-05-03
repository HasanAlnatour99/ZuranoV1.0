import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/payroll_period_constants.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../data/models/payroll_run_model.dart';
import '../../data/payroll_constants.dart';
import '../../logic/payroll_dashboard_providers.dart';
import 'payroll_status_chip.dart';

/// Zurano premium payroll transaction history for run review.
/// Approved (unpaid) runs open Pay / Rollback actions. Draft and rolled-back runs are hidden.
class PayrollRunReviewHistorySection extends ConsumerStatefulWidget {
  const PayrollRunReviewHistorySection({super.key});

  static const int _maxItems = 14;

  @override
  ConsumerState<PayrollRunReviewHistorySection> createState() =>
      _PayrollRunReviewHistorySectionState();
}

class _PayrollRunReviewHistorySectionState
    extends ConsumerState<PayrollRunReviewHistorySection> {
  String? _busyRunId;

  Future<void> _showApprovedRunSheet(PayrollRunModel run) async {
    final context = this.context;
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ZuranoPremiumUiColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ZuranoPremiumUiColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.payrollHistoryApprovedSheetTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                  color: ZuranoPremiumUiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.payrollHistoryApprovedSheetBody,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _markRunPaid(run);
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
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _confirmAndRollbackRun(run);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.payrollActionRollback),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markRunPaid(PayrollRunModel run) async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim();
    final uid = session?.uid;
    if (salonId == null ||
        salonId.isEmpty ||
        uid == null ||
        uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payrollRunValidation)),
        );
      }
      return;
    }

    setState(() => _busyRunId = run.id);
    final result = await ref.read(payrollRunUseCaseProvider).payApprovedRun(
      salonId: salonId,
      runId: run.id,
      paidBy: uid,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busyRunId = null);

    result.match(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.userMessage)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payrollHistoryMarkedPaidSnack)),
        );
      },
    );
  }

  Future<void> _confirmAndRollbackRun(PayrollRunModel run) async {
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
    if (ok != true || !mounted) {
      return;
    }

    final session = ref.read(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim();
    if (salonId == null || salonId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payrollRunValidation)),
        );
      }
      return;
    }

    setState(() => _busyRunId = run.id);
    final result = await ref.read(payrollRunUseCaseProvider).rollback(
      salonId: salonId,
      runId: run.id,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busyRunId = null);

    result.match(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.userMessage)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.payrollHistoryRollbackSnack)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final runsAsync = ref.watch(payrollRunsStreamProvider);

    return runsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: AppLoadingIndicator(size: 36)),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.payrollGenericError,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: ZuranoPremiumUiColors.textSecondary,
          ),
        ),
      ),
      data: (runs) {
        final sorted = runs
            .where(
              (r) =>
                  r.status != PayrollRunStatuses.rolledBack &&
                  r.status != PayrollRunStatuses.draft,
            )
            .toList(growable: false);
        sorted.sort((a, b) {
          final ad =
              a.updatedAt ??
              a.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bd =
              b.updatedAt ??
              b.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
        final items = sorted.take(PayrollRunReviewHistorySection._maxItems).toList(
              growable: false,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: ZuranoPremiumUiColors.primaryPurple.withValues(
                      alpha: 0.12,
                    ),
                    border: Border.all(
                      color: ZuranoPremiumUiColors.border,
                    ),
                  ),
                  child: Icon(
                    AppIcons.receipt_long_outlined,
                    size: 22,
                    color: ZuranoPremiumUiColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.payrollRunReviewHistoryTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.35,
                          color: ZuranoPremiumUiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.payrollRunReviewHistorySubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.payrollRunReviewHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
              )
            else
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                AppEntranceMotion(
                  motionId: 'payroll-history-${items[i].id}-$i',
                  index: i,
                  duration: const Duration(milliseconds: 220),
                  slideOffset: 8,
                  child: _PayrollHistoryTransactionTile(
                    run: items[i],
                    currencyCode: currencyCode,
                    locale: locale,
                    l10n: l10n,
                    actionBusy: _busyRunId == items[i].id,
                    onTap: items[i].status == PayrollRunStatuses.approved
                        ? () => _showApprovedRunSheet(items[i])
                        : null,
                  ),
                ),
              ],
          ],
        );
      },
    );
  }
}

class _PayrollHistoryTransactionTile extends StatelessWidget {
  const _PayrollHistoryTransactionTile({
    required this.run,
    required this.currencyCode,
    required this.locale,
    required this.l10n,
    this.onTap,
    this.actionBusy = false,
  });

  final PayrollRunModel run;
  final String currencyCode;
  final Locale locale;
  final AppLocalizations l10n;
  final VoidCallback? onTap;
  final bool actionBusy;

  String _periodLine() {
    if (run.periodGranularity == PayrollRunPeriodGranularities.weekly &&
        run.isoWeekYear > 0 &&
        run.isoWeekNumber > 0) {
      return l10n.payrollIsoWeekShortLabel(
        run.isoWeekYear,
        run.isoWeekNumber.toString().padLeft(2, '0'),
      );
    }
    return DateFormat.yMMMM(
      locale.toString(),
    ).format(DateTime(run.year, run.month));
  }

  String _titleLine() {
    if (run.employeeName?.trim().isNotEmpty == true) {
      return formatTeamMemberName(run.employeeName);
    }
    return l10n.payrollRunGroupLabel(run.employeeCount);
  }

  @override
  Widget build(BuildContext context) {
    final quick = run.isQuickPay;
    final accent = quick
        ? ZuranoPremiumUiColors.deepPurple
        : ZuranoPremiumUiColors.primaryPurple;
    final accentSoft = quick
        ? ZuranoPremiumUiColors.softPurple
        : ZuranoPremiumUiColors.softPurple;
    final interactive = onTap != null;

    final inner = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: accent.withValues(alpha: 0.14),
          ),
          child: Icon(
            quick ? AppIcons.flash_on_rounded : AppIcons.payments_outlined,
            size: 20,
            color: accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleLine(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: ZuranoPremiumUiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _periodLine(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PayrollStatusChip(status: run.status),
            const SizedBox(height: 8),
            Text(
              formatAppMoney(run.netPay, currencyCode, locale),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.25,
                color: ZuranoPremiumUiColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );

    final shell = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentSoft.withValues(alpha: 0.35),
        border: Border.all(color: ZuranoPremiumUiColors.border),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
              child: inner,
            ),
            if (actionBusy)
              Positioned.fill(
                child: ColoredBox(
                  color: ZuranoPremiumUiColors.background.withValues(
                    alpha: 0.55,
                  ),
                  child: const Center(
                    child: AppLoadingIndicator(size: 32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!interactive) {
      return shell;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: actionBusy ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: shell,
      ),
    );
  }
}
