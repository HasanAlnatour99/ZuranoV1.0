import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/payroll_status_localized.dart';
import '../../../../core/formatting/staff_role_localized.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/luxury_kpi_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employees/data/models/employee.dart';
import '../../../../providers/app_settings_providers.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart'
    show
        employeesStreamProvider,
        expensesStreamProvider,
        payrollStreamProvider,
        salesStreamProvider,
        sessionSalonStreamProvider;
import '../../logic/owner_money_period.dart';
import '../../logic/owner_money_recognition.dart';
import '../../../services/presentation/screens/services_screen.dart';
import 'add_barber_sheet.dart';
import 'team_member_profile_card.dart';
import '../../../sales/data/models/sale.dart';
import '../../../../core/formatting/sale_payment_method_localized.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// Opens the same create/edit team member form as the Team screen ([AddBarberSheet]).
Future<void> showOwnerTeamMemberSheet(
  BuildContext context, {
  required String salonId,
  Employee? existing,
}) {
  return showAddBarberSheet(context, salonId: salonId, existing: existing);
}

class OwnerTeamModule extends ConsumerWidget {
  const OwnerTeamModule({super.key, required this.salonId});

  final String salonId;

  Future<void> _showMemberSheet(BuildContext context, {Employee? existing}) {
    return showOwnerTeamMemberSheet(
      context,
      salonId: salonId,
      existing: existing,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('❌ OLD Team screen rendering');
    }
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final employeesAsync = ref.watch(employeesStreamProvider);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large,
            96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.ownerTeamTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.small),
              Text(
                l10n.ownerTeamSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              employeesAsync.when(
                loading: () => const TeamListSkeleton(),
                error: (_, _) => Text(l10n.genericError),
                data: (list) {
                  if (list.isEmpty) {
                    return AppEmptyState(
                      title: l10n.ownerTeamTitle,
                      message: l10n.ownerTeamSubtitle,
                      icon: AppIcons.groups_outlined,
                      primaryActionLabel: l10n.ownerAddMember,
                      onPrimaryAction: () => _showMemberSheet(context),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final gap = AppSpacing.medium;
                      final wide = constraints.maxWidth >= 640;
                      if (wide) {
                        final w = (constraints.maxWidth - gap) / 2;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (var i = 0; i < list.length; i++)
                              SizedBox(
                                width: w,
                                child: TeamMemberProfileCard(
                                  employee: list[i],
                                  colorIndex: i,
                                  roleLabel: localizedStaffRole(
                                    l10n,
                                    list[i].role,
                                  ),
                                  statusLabel: list[i].isActive
                                      ? l10n.ownerTeamCardStatusActive
                                      : l10n.ownerTeamCardStatusInactive,
                                  onSelected: (action) async {
                                    final repo = ref.read(
                                      employeeRepositoryProvider,
                                    );
                                    if (action == 'edit') {
                                      await _showMemberSheet(
                                        context,
                                        existing: list[i],
                                      );
                                    } else if (action == 'toggle') {
                                      await repo.setEmployeeActiveState(
                                        salonId: salonId,
                                        employeeId: list[i].id,
                                        isActive: !list[i].isActive,
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < list.length; i++) ...[
                            if (i > 0) SizedBox(height: gap),
                            TeamMemberProfileCard(
                              employee: list[i],
                              colorIndex: i,
                              roleLabel: localizedStaffRole(l10n, list[i].role),
                              statusLabel: list[i].isActive
                                  ? l10n.ownerTeamCardStatusActive
                                  : l10n.ownerTeamCardStatusInactive,
                              onSelected: (action) async {
                                final repo = ref.read(
                                  employeeRepositoryProvider,
                                );
                                if (action == 'edit') {
                                  await _showMemberSheet(
                                    context,
                                    existing: list[i],
                                  );
                                } else if (action == 'toggle') {
                                  await repo.setEmployeeActiveState(
                                    salonId: salonId,
                                    employeeId: list[i].id,
                                    isActive: !list[i].isActive,
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        PositionedDirectional(
          end: AppSpacing.large,
          bottom: AppSpacing.large,
          child: FloatingActionButton(
            heroTag: 'owner_team_member_add_fab',
            onPressed: () => _showMemberSheet(context),
            child: const Icon(AppIcons.add),
          ),
        ),
      ],
    );
  }
}

class OwnerServicesModule extends ConsumerWidget {
  const OwnerServicesModule({super.key, required this.salonId});

  final String salonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ServicesScreen(salonId: salonId);
  }
}

class OwnerMoneyModule extends ConsumerStatefulWidget {
  const OwnerMoneyModule({super.key});

  @override
  ConsumerState<OwnerMoneyModule> createState() => _OwnerMoneyModuleState();
}

class _OwnerMoneyModuleState extends ConsumerState<OwnerMoneyModule> {
  OwnerMoneyPeriodKind _period = OwnerMoneyPeriodKind.month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final payrollAsync = ref.watch(payrollStreamProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);
    final salesAsync = ref.watch(salesStreamProvider);
    final salonAsync = ref.watch(sessionSalonStreamProvider);
    final recognition = ref.watch(ownerMoneyRecognitionModeProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final now = DateTime.now();
    final localeTag = locale.toString();
    final saleDateFmt = DateFormat.yMMMd(localeTag);
    final saleTimeFmt = DateFormat.jm(localeTag);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.large,
            AppSpacing.small,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.ownerMoneyTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.ownerMoneySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.medium)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          sliver: SliverToBoxAdapter(
            child: Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                ChoiceChip(
                  label: Text(l10n.ownerMoneyPeriodToday),
                  selected: _period == OwnerMoneyPeriodKind.today,
                  onSelected: (_) =>
                      setState(() => _period = OwnerMoneyPeriodKind.today),
                ),
                ChoiceChip(
                  label: Text(l10n.ownerMoneyPeriodMonth),
                  selected: _period == OwnerMoneyPeriodKind.month,
                  onSelected: (_) =>
                      setState(() => _period = OwnerMoneyPeriodKind.month),
                ),
                ChoiceChip(
                  label: Text(l10n.ownerMoneyPeriodCustomSoon),
                  selected: false,
                  onSelected: null,
                ),
                ChoiceChip(
                  label: Text(l10n.ownerMoneyRecognitionOperational),
                  selected:
                      recognition == OwnerMoneyRecognitionMode.operational,
                  onSelected: (_) => ref
                      .read(ownerMoneyRecognitionModeProvider.notifier)
                      .setMode(OwnerMoneyRecognitionMode.operational),
                ),
                ChoiceChip(
                  label: Text(l10n.ownerMoneyRecognitionCash),
                  selected: recognition == OwnerMoneyRecognitionMode.cash,
                  onSelected: (_) => ref
                      .read(ownerMoneyRecognitionModeProvider.notifier)
                      .setMode(OwnerMoneyRecognitionMode.cash),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.medium)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          sliver: SliverToBoxAdapter(
            child: salesAsync.when(
              loading: () => const MoneyDashboardSkeleton(),
              error: (_, _) => Text(l10n.genericError),
              data: (sales) {
                return payrollAsync.when(
                  loading: () => const MoneyDashboardSkeleton(),
                  error: (_, _) => Text(l10n.genericError),
                  data: (payroll) {
                    return expensesAsync.when(
                      loading: () => const MoneyDashboardSkeleton(),
                      error: (_, _) => Text(l10n.genericError),
                      data: (expenses) {
                        return salonAsync.when(
                          loading: () => const MoneyDashboardSkeleton(),
                          error: (_, _) => Text(l10n.genericError),
                          data: (salon) {
                            final totalSales = OwnerMoneyAggregation.sumSales(
                              sales,
                              recognition,
                              _period,
                              now,
                            );
                            final totalPayroll =
                                OwnerMoneyAggregation.sumPayroll(
                                  payroll,
                                  recognition,
                                  _period,
                                  now,
                                );
                            final totalExpenses =
                                OwnerMoneyAggregation.sumExpenses(
                                  expenses,
                                  recognition,
                                  _period,
                                  now,
                                );
                            final net =
                                totalSales - totalPayroll - totalExpenses;
                            final payrollRows = payroll
                                .where(
                                  (p) => OwnerMoneyAggregation.payrollInPeriod(
                                    p,
                                    recognition,
                                    _period,
                                    now,
                                  ),
                                )
                                .toList();
                            final expenseRows = expenses
                                .where(
                                  (e) => OwnerMoneyAggregation.expenseInPeriod(
                                    e,
                                    recognition,
                                    _period,
                                    now,
                                  ),
                                )
                                .toList();
                            final saleRows =
                                sales
                                    .where(
                                      (s) => OwnerMoneyAggregation.saleInPeriod(
                                        s,
                                        recognition,
                                        _period,
                                        now,
                                      ),
                                    )
                                    .toList()
                                  ..sort(
                                    (a, b) => b.soldAt.compareTo(a.soldAt),
                                  );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LuxuryKpiCard(
                                  label: l10n.ownerMoneyTotalSales,
                                  value: formatAppMoney(
                                    totalSales,
                                    currencyCode,
                                    locale,
                                  ),
                                  icon: AppIcons.point_of_sale_outlined,
                                ),
                                const SizedBox(height: AppSpacing.small),
                                LuxuryKpiCard(
                                  label: l10n.ownerMoneyTotalPayroll,
                                  value: formatAppMoney(
                                    totalPayroll,
                                    currencyCode,
                                    locale,
                                  ),
                                  icon: AppIcons.payments_outlined,
                                ),
                                const SizedBox(height: AppSpacing.small),
                                LuxuryKpiCard(
                                  label: l10n.ownerMoneyTotalExpenses,
                                  value: formatAppMoney(
                                    totalExpenses,
                                    currencyCode,
                                    locale,
                                  ),
                                  icon: AppIcons.receipt_long_outlined,
                                ),
                                const SizedBox(height: AppSpacing.small),
                                LuxuryKpiCard(
                                  label: l10n.ownerMoneyNetResult,
                                  value: formatAppMoney(
                                    net,
                                    currencyCode,
                                    locale,
                                  ),
                                  icon: AppIcons.account_balance_outlined,
                                ),
                                const SizedBox(height: AppSpacing.medium),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: FilledButton.tonalIcon(
                                    onPressed: () =>
                                        context.push(AppRoutes.ownerSalesAdd),
                                    icon: const Icon(
                                      AppIcons.add_shopping_cart_outlined,
                                    ),
                                    label: Text(l10n.ownerAddSaleOpen),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.large),
                                Text(
                                  l10n.ownerMoneySalesSection,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                if (saleRows.isEmpty)
                                  AppEmptyState(
                                    title: l10n.ownerMoneySalesEmptyTitle,
                                    message: l10n.ownerMoneyEmptySales,
                                    icon: AppIcons.point_of_sale_outlined,
                                  )
                                else
                                  ...saleRows.map(
                                    (Sale s) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.small,
                                      ),
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                            s.lineItems.isNotEmpty
                                                ? s.lineItems.first.serviceName
                                                : (s.serviceNames.isEmpty
                                                      ? '—'
                                                      : s.serviceNames.join(
                                                          ', ',
                                                        )),
                                          ),
                                          subtitle: Text(
                                            '${formatTeamMemberName(s.employeeName)} · ${localizedSalePaymentMethod(l10n, s.paymentMethod)} · ${saleDateFmt.format(s.soldAt.toLocal())} ${saleTimeFmt.format(s.soldAt.toLocal())}',
                                          ),
                                          trailing: Text(
                                            formatAppMoney(
                                              s.total,
                                              currencyCode,
                                              locale,
                                            ),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.large),
                                Text(
                                  l10n.ownerMoneyPayrollSection,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                if (payrollRows.isEmpty)
                                  AppEmptyState(
                                    title: l10n.ownerMoneyPayrollEmptyTitle,
                                    message: l10n.ownerMoneyEmptyPayroll,
                                    icon: AppIcons.payments_outlined,
                                  )
                                else
                                  ...payrollRows.map(
                                    (p) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.small,
                                      ),
                                      child: Card(
                                        child: ExpansionTile(
                                          title: TeamMemberNameText(p.employeeName),
                                          subtitle: Text(
                                            '${p.year}-${p.month.toString().padLeft(2, '0')} · ${localizedPayrollStatus(l10n, p.status)}',
                                          ),
                                          trailing: Text(
                                            formatAppMoney(
                                              p.netAmount,
                                              currencyCode,
                                              locale,
                                            ),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          children: [
                                            if (p.deductionLines.isNotEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      AppSpacing.large,
                                                      0,
                                                      AppSpacing.large,
                                                      AppSpacing.medium,
                                                    ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerStart,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        l10n.payrollDeductionViolations,
                                                        style: theme
                                                            .textTheme
                                                            .labelLarge,
                                                      ),
                                                      const SizedBox(
                                                        height:
                                                            AppSpacing.small,
                                                      ),
                                                      ...p.deductionLines.map(
                                                        (line) => Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                bottom: 4,
                                                              ),
                                                          child: Text(
                                                            '${line.label ?? line.kind} · ${formatAppMoney(line.amount, currencyCode, locale)}',
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.large),
                                Text(
                                  l10n.ownerMoneyExpensesSection,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                if (expenseRows.isEmpty)
                                  AppEmptyState(
                                    title: l10n.ownerMoneyExpensesEmptyTitle,
                                    message: l10n.ownerMoneyEmptyExpenses,
                                    icon: AppIcons.receipt_long_outlined,
                                  )
                                else
                                  ...expenseRows.map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.small,
                                      ),
                                      child: Card(
                                        child: ListTile(
                                          title: Text(e.title),
                                          subtitle: Text(
                                            '${e.category} · ${e.incurredAt.toLocal()}',
                                          ),
                                          trailing: Text(
                                            formatAppMoney(
                                              e.amount,
                                              currencyCode,
                                              locale,
                                            ),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
      ],
    );
  }
}

class TeamListSkeleton extends StatelessWidget {
  const TeamListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.medium),
          child: AppSkeletonBlock(height: 160),
        ),
      ),
    );
  }
}

class MoneyDashboardSkeleton extends StatelessWidget {
  const MoneyDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSkeletonBlock(height: 100),
        const SizedBox(height: AppSpacing.small),
        const AppSkeletonBlock(height: 100),
        const SizedBox(height: AppSpacing.small),
        const AppSkeletonBlock(height: 100),
        const SizedBox(height: AppSpacing.small),
        const AppSkeletonBlock(height: 100),
        const SizedBox(height: AppSpacing.medium),
        const AppSkeletonBlock(height: 48, width: 160),
        const SizedBox(height: AppSpacing.large),
        const AppSkeletonBlock(height: 24, width: 200),
        const SizedBox(height: AppSpacing.medium),
        const AppSkeletonBlock(height: 80),
        const SizedBox(height: AppSpacing.small),
        const AppSkeletonBlock(height: 80),
      ],
    );
  }
}
