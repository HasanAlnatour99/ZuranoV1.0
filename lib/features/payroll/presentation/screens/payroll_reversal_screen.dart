import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../../features/money/presentation/widgets/premium_finance_card.dart';
import '../../data/payroll_constants.dart';
import '../../data/models/payroll_result_model.dart';
import '../../data/models/payroll_run_model.dart';
import '../../domain/payroll_run_totals.dart';
import '../../logic/payroll_dashboard_providers.dart';
import '../../logic/payroll_reversal_providers.dart';

enum _PayrollReversalScope { wholeRun, oneMember }

class PayrollReversalScreen extends ConsumerStatefulWidget {
  const PayrollReversalScreen({super.key});

  @override
  ConsumerState<PayrollReversalScreen> createState() =>
      _PayrollReversalScreenState();
}

class _PayrollReversalScreenState extends ConsumerState<PayrollReversalScreen> {
  PayrollRunModel? _selectedRun;
  _PayrollReversalScope _scope = _PayrollReversalScope.wholeRun;
  String? _selectedEmployeeId;
  bool _busy = false;
  bool _pendingRunAutoPick = false;

  List<PayrollRunModel> _reversibleRuns(List<PayrollRunModel> all) {
    final list = all
        .where((r) => PayrollRunStatuses.canRollback(r.status))
        .toList(growable: false);
    list.sort((a, b) {
      final ad =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return list;
  }

  Future<void> _submit(AppLocalizations loc, String salonId) async {
    final run = _selectedRun;
    if (run == null || _busy) return;

    final runId = run.id.trim();
    if (runId.isEmpty) return;

    final rows =
        await ref.read(payrollReversalRunResultsProvider(runId).future);
    if (!mounted) return;

    final distinct = distinctEmployeeIdsForRun(rows, run.employeeIds);
    final usePartial =
        _scope == _PayrollReversalScope.oneMember &&
        distinct.length > 1 &&
        (_selectedEmployeeId?.trim().isNotEmpty ?? false);

    if (usePartial) {
      final emp = _selectedEmployeeId!.trim();
      String displayName = emp;
      for (final r in rows) {
        if (r.employeeId.trim() == emp) {
          final n = r.employeeName.trim();
          if (n.isNotEmpty) {
            displayName = formatTeamMemberName(n);
            break;
          }
        }
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(loc.payrollReversalConfirmTitle),
          content: Text(
            loc.payrollReversalConfirmOneMemberMessage(displayName),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: ZuranoPremiumUiColors.textSecondary,
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ZuranoPremiumUiColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.payrollReversalTitle),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      setState(() => _busy = true);
      final result = await ref.read(payrollRunUseCaseProvider).rollbackPartial(
            salonId: salonId,
            runId: runId,
            employeeId: emp,
          );
      if (!context.mounted) return;
      setState(() => _busy = false);
      result.match(
        (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.userMessage)),
        ),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.payrollReversalSuccess)),
          );
          context.pop();
        },
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.payrollReversalConfirmTitle),
        content: Text(loc.payrollReversalConfirmWholeRunMessage),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: ZuranoPremiumUiColors.textSecondary,
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: ZuranoPremiumUiColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.payrollReversalTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _busy = true);
    final result = await ref
        .read(payrollRunUseCaseProvider)
        .rollback(salonId: salonId, runId: runId);
    if (!context.mounted) return;
    setState(() => _busy = false);
    result.match(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.userMessage)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.payrollReversalSuccess)),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final session = ref.watch(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim() ?? '';
    final runsAsync = ref.watch(payrollRunsStreamProvider);

    final runId = _selectedRun?.id.trim() ?? '';
    final resultsAsync = runId.isEmpty
        ? const AsyncValue<List<PayrollResultModel>>.data([])
        : ref.watch(payrollReversalRunResultsProvider(runId));

    final selectedRun = _selectedRun;
    final partialData = resultsAsync.when(
      data: (rows) {
        if (selectedRun == null) {
          return (
            canPartial: false,
            memberChoices: const <MapEntry<String, String>>[],
          );
        }
        final ids = distinctEmployeeIdsForRun(rows, selectedRun.employeeIds);
        final can = ids.length > 1;
        final choices = <MapEntry<String, String>>[];
        for (final id in ids) {
          final fromRow = primaryEmployeeNameFromResults(rows, id);
          final label = fromRow != null && fromRow.trim().isNotEmpty
              ? formatTeamMemberName(fromRow)
              : id;
          choices.add(MapEntry(id, label));
        }
        return (canPartial: can, memberChoices: choices);
      },
      loading: () => (
        canPartial: false,
        memberChoices: const <MapEntry<String, String>>[],
      ),
      error: (_, _) => (
        canPartial: false,
        memberChoices: const <MapEntry<String, String>>[],
      ),
    );

    final canPartial = partialData.canPartial;
    final distinctEmployees = partialData.memberChoices;

    final partialImpossibleNow = resultsAsync.hasValue &&
        selectedRun != null &&
        !canPartial &&
        _scope == _PayrollReversalScope.oneMember;
    if (partialImpossibleNow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _scope = _PayrollReversalScope.wholeRun);
      });
    }

    return Scaffold(
      backgroundColor: ZuranoPremiumUiColors.background,
      appBar: AppPageHeader(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ZuranoPremiumUiColors.background,
        foregroundColor: ZuranoPremiumUiColors.textPrimary,
        fallbackLocation: AppRoutes.ownerPayroll,
        title: Text(
          l10n.payrollReversalScreenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: ZuranoPremiumUiColors.textPrimary,
          ),
        ),
      ),
      body: runsAsync.when(
        loading: () =>
            const Center(child: AppLoadingIndicator(size: 36)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.payrollGenericError,
              style: const TextStyle(color: ZuranoPremiumUiColors.textSecondary),
            ),
          ),
        ),
        data: (allRuns) {
          final runs = _reversibleRuns(allRuns);
          final selectionInvalid = _selectedRun != null &&
              !runs.any((r) => r.id == _selectedRun!.id);
          final needsSync = (runs.isEmpty && _selectedRun != null) ||
              (runs.isNotEmpty &&
                  (_selectedRun == null || selectionInvalid));
          if (needsSync && !_pendingRunAutoPick) {
            _pendingRunAutoPick = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pendingRunAutoPick = false;
              if (!mounted) return;
              final freshAll =
                  ref.read(payrollRunsStreamProvider).value ?? const [];
              final freshRuns = _reversibleRuns(freshAll);
              if (freshRuns.isEmpty) {
                if (_selectedRun != null ||
                    (_selectedEmployeeId?.isNotEmpty ?? false)) {
                  setState(() {
                    _selectedRun = null;
                    _selectedEmployeeId = null;
                  });
                }
                return;
              }
              final currentValid = _selectedRun != null &&
                  freshRuns.any((r) => r.id == _selectedRun!.id);
              if (currentValid) return;
              setState(() {
                _selectedRun = freshRuns.first;
                _selectedEmployeeId = null;
              });
            });
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                l10n.payrollReversalScreenSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              PremiumFinanceCard(
                zuranoPremiumStyle: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.payrollReversalSelectRunHint,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ZuranoPremiumUiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (runs.isEmpty)
                      Text(
                        l10n.payrollReversalNoRunsMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      )
                    else
                      DropdownButtonFormField<PayrollRunModel>(
                        isExpanded: true,
                        // ignore: deprecated_member_use
                        value: _selectedRun != null &&
                                runs.any((r) => r.id == _selectedRun!.id)
                            ? runs.firstWhere((r) => r.id == _selectedRun!.id)
                            : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ZuranoPremiumUiColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ZuranoPremiumUiColors.border,
                            ),
                          ),
                        ),
                        hint: Text(l10n.payrollReversalSelectRunHint),
                        items: runs
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(
                                  _runLabel(r, l10n, locale, currencyCode),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _selectedRun = v;
                            _selectedEmployeeId = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
              if (_selectedRun != null) ...[
                const SizedBox(height: 16),
                PremiumFinanceCard(
                  zuranoPremiumStyle: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.payrollFieldEmployee,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ZuranoPremiumUiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<_PayrollReversalScope>(
                        segments: [
                          ButtonSegment(
                            value: _PayrollReversalScope.wholeRun,
                            label: Text(l10n.payrollReversalScopeWholeRun),
                            icon: const Icon(AppIcons.groups_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: _PayrollReversalScope.oneMember,
                            enabled: canPartial,
                            label: Text(l10n.payrollReversalScopeOneMember),
                            icon: const Icon(
                              AppIcons.person_outline_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                        selected: {_scope},
                        onSelectionChanged: (s) {
                          if (!canPartial &&
                              s.first == _PayrollReversalScope.oneMember) {
                            return;
                          }
                          setState(() {
                            _scope = s.first;
                            if (_scope == _PayrollReversalScope.wholeRun) {
                              _selectedEmployeeId = null;
                            }
                          });
                        },
                        emptySelectionAllowed: false,
                        multiSelectionEnabled: false,
                      ),
                      if (!canPartial &&
                          _selectedRun != null &&
                          resultsAsync.hasValue) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.payrollReversalPartialUnavailableHint,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: ZuranoPremiumUiColors.textSecondary,
                          ),
                        ),
                      ],
                      if (_scope == _PayrollReversalScope.oneMember &&
                          canPartial) ...[
                        const SizedBox(height: 12),
                        resultsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: AppLoadingIndicator(size: 28),
                            ),
                          ),
                          error: (_, _) => Text(l10n.payrollGenericError),
                          data: (_) => DropdownButtonFormField<String>(
                            isExpanded: true,
                            // ignore: deprecated_member_use
                            value:
                                _selectedEmployeeId != null &&
                                    distinctEmployees.any(
                                      (e) => e.key == _selectedEmployeeId,
                                    )
                                ? _selectedEmployeeId
                                : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: ZuranoPremiumUiColors.cardBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: ZuranoPremiumUiColors.border,
                                ),
                              ),
                            ),
                            hint: Text(l10n.payrollReversalSelectMemberHint),
                            items: distinctEmployees
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedEmployeeId = v),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _busy ||
                          salonId.isEmpty ||
                          _selectedRun == null ||
                          (_scope == _PayrollReversalScope.oneMember &&
                              canPartial &&
                              (_selectedEmployeeId == null ||
                                  _selectedEmployeeId!.trim().isEmpty))
                      ? null
                      : () => _submit(l10n, salonId),
                  style: FilledButton.styleFrom(
                    backgroundColor: ZuranoPremiumUiColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.payrollReversalTitle),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _runLabel(
    PayrollRunModel r,
    AppLocalizations l10n,
    Locale locale,
    String currencyCode,
  ) {
    final period = DateFormat.yMMMM(locale.toString()).format(
      DateTime(r.year, r.month),
    );
    final name = r.employeeName?.trim().isNotEmpty == true
        ? formatTeamMemberName(r.employeeName)
        : l10n.payrollRunGroupLabel(r.employeeCount);
    final money = formatAppMoney(r.netPay, currencyCode, locale);
    return '$name · $period · $money';
  }
}
