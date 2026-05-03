import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/keyboard_safe_form_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/salon_streams_provider.dart'
    show employeesStreamProvider, salesStreamProvider;
import '../../../employees/data/models/employee.dart';
import '../../data/models/sale.dart';
import '../../domain/sales_filter.dart';
import '../../domain/sales_summary_model.dart';
import '../../domain/sales_vs_expenses_point.dart';
import '../../logic/sales_dashboard_providers.dart';
import '../widgets/floating_add_sale_button.dart';
import '../widgets/recent_sales_card.dart';
import '../widgets/sales_error_card.dart';
import '../widgets/sales_hero_summary_card.dart';
import '../widgets/sales_insights_strip.dart';
import '../widgets/sales_period_chips.dart';
import '../widgets/sales_pos_header.dart';
import '../widgets/sales_skeleton_blocks.dart';
import '../widgets/sales_vs_expenses_chart.dart';
import '../../../../core/formatting/sale_payment_method_localized.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../../providers/money_currency_providers.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key, this.initialBarberId});

  final String? initialBarberId;

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(salesFiltersProvider.notifier)
          .initialize(barberId: widget.initialBarberId);
    });
  }

  Map<SalesFilter, String> _filterLabels(AppLocalizations l10n) => {
    SalesFilter.today: l10n.salesDateToday,
    SalesFilter.thisWeek: l10n.salesDateThisWeek,
    SalesFilter.thisMonth: l10n.salesDateThisMonth,
    SalesFilter.custom: l10n.salesDateCustom,
  };

  String _comparisonLine(SalesFilterState f, Locale locale) {
    final now = DateTime.now();
    final fmt = DateFormat.MMMd(locale.toString());
    switch (f.datePreset) {
      case SalesFilter.custom:
        if (f.customRange != null) {
          return '↑ — ${fmt.format(f.customRange!.start)} – ${fmt.format(f.customRange!.end)}';
        }
        return '↑ —';
      case SalesFilter.today:
        return '↑ — ${fmt.format(DateUtils.dateOnly(now))}';
      case SalesFilter.thisWeek:
        final today = DateUtils.dateOnly(now);
        final start = today.subtract(
          Duration(days: today.weekday - DateTime.monday),
        );
        final end = start.add(const Duration(days: 6));
        return '↑ — ${fmt.format(start)} – ${fmt.format(end)}';
      case SalesFilter.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return '↑ — ${fmt.format(start)} – ${fmt.format(end)}';
    }
  }

  String _chartPeriodLabel(
    SalesFilterState f,
    Locale locale,
    AppLocalizations l10n,
  ) {
    final labels = _filterLabels(l10n);
    if (f.datePreset == SalesFilter.custom && f.customRange != null) {
      final fmt = DateFormat.MMMd(locale.toString());
      return '${fmt.format(f.customRange!.start)} – ${fmt.format(f.customRange!.end)}';
    }
    return labels[f.datePreset] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final filters = ref.watch(salesFiltersProvider);
    final salesRoot = ref.watch(salesStreamProvider);
    final summaryAsync = ref.watch(salesSummaryModelProvider);
    final chartAsync = ref.watch(salesVsExpensesSeriesProvider);
    final recentAsync = ref.watch(recentFilteredSalesProvider);
    final paymentMethods = ref.watch(salesPaymentMethodOptionsProvider);

    final filterLabels = _filterLabels(l10n);

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SalesPosHeader(
                    title: l10n.salesScreenTitle,
                    subtitle: l10n.salesScreenSubtitle,
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_month_rounded),
                      tooltip: l10n.salesDateCustom,
                      onPressed: () async {
                        ref
                            .read(salesFiltersProvider.notifier)
                            .setDatePreset(SalesFilter.custom);
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          initialDateRange: filters.customRange,
                        );
                        if (context.mounted) {
                          ref
                              .read(salesFiltersProvider.notifier)
                              .setCustomRange(picked);
                        }
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: SalesPeriodChips(
                          selected: filters.datePreset,
                          labels: filterLabels,
                          onChanged: (preset) async {
                            ref
                                .read(salesFiltersProvider.notifier)
                                .setDatePreset(preset);
                            if (preset == SalesFilter.custom) {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now(),
                                initialDateRange: filters.customRange,
                              );
                              if (context.mounted) {
                                ref
                                    .read(salesFiltersProvider.notifier)
                                    .setCustomRange(picked);
                              }
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          onPressed: () =>
                              _showSalesFiltersSheet(context, paymentMethods),
                          icon: Badge(
                            isLabelVisible:
                                filters.paymentMethod != null ||
                                filters.barberId != null,
                            smallSize: 8,
                            child: Icon(AppIcons.tune_rounded, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (filters.datePreset == SalesFilter.custom &&
                    filters.customRange != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.salesScreenCustomRange(
                          DateFormat.yMMMd(
                            locale.toString(),
                          ).format(filters.customRange!.start),
                          DateFormat.yMMMd(
                            locale.toString(),
                          ).format(filters.customRange!.end),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                if (salesRoot.isLoading)
                  SliverToBoxAdapter(
                    child: Column(
                      children: const [
                        SalesSummarySkeleton(),
                        SalesChartSkeleton(),
                        RecentSalesSkeleton(),
                      ],
                    ),
                  )
                else if (salesRoot.hasError)
                  SliverToBoxAdapter(
                    child: SalesErrorCard(
                      message: l10n.salesScreenErrorMessage,
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: summaryAsync.when(
                      loading: () => const SalesSummarySkeleton(),
                      error: (e, _) => SalesErrorCard(message: '$e'),
                      data: (SalesSummaryModel summary) => SalesHeroSummaryCard(
                        summary: summary,
                        currencyCode: currencyCode,
                        locale: locale,
                        totalSalesLabel: l10n.salesHeroTotalSalesLabel,
                        comparisonLine: _comparisonLine(filters, locale),
                        metricTransactionsLabel:
                            l10n.salesScreenTransactionCount,
                        metricAvgTicketLabel: l10n.salesScreenAverageTicket,
                        metricTopBarberLabel: l10n.salesScreenTopBarber,
                        metricTopServiceLabel: l10n.salesScreenTopService,
                        emptyMetric: l10n.salesScreenValuePending,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: chartAsync.when(
                      loading: () => const SalesChartSkeleton(),
                      error: (e, _) => SalesErrorCard(message: '$e'),
                      data: (List<SalesVsExpensesPoint> points) =>
                          SalesVsExpensesChart(
                            points: points,
                            title: l10n.salesChartSalesVsExpenses,
                            periodLabel: _chartPeriodLabel(
                              filters,
                              locale,
                              l10n,
                            ),
                            salesLegend: l10n.salesChartLegendSales,
                            expensesLegend: l10n.salesChartLegendExpenses,
                            currencyCode: currencyCode,
                            locale: locale,
                          ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SalesInsightsStrip(
                      topServicesTitle: l10n.salesScreenTopServicesTitle,
                      topServicesSubtitle: l10n.salesInsightTopServicesSubtitle,
                      topServicesHelper: l10n.salesInsightHelperTopServices,
                      topServicesAction: l10n.salesInsightActionAddServices,
                      barberTitle: l10n.salesScreenBarberRankingTitle,
                      barberSubtitle: l10n.salesInsightBarberSubtitle,
                      barberHelper: l10n.salesInsightHelperBarber,
                      barberAction: l10n.salesInsightActionAddSales,
                      paymentTitle: l10n.salesInsightPaymentMixTitle,
                      paymentSubtitle: l10n.salesInsightPaymentSubtitle,
                      paymentHelper: l10n.salesInsightHelperPayment,
                      paymentAction: l10n.salesInsightActionAddSales,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: recentAsync.when(
                      loading: () => const RecentSalesSkeleton(),
                      error: (e, _) => SalesErrorCard(message: '$e'),
                      data: (List<Sale> sales) => RecentSalesCard(
                        sales: sales,
                        currencyCode: currencyCode,
                        locale: locale,
                        title: l10n.salesRecentCardTitle,
                        viewAllLabel: l10n.expensesScreenViewAll,
                        emptyTitle: l10n.salesRecentEmptyTitle,
                        emptyMessage: l10n.salesRecentEmptyBody,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: bottomInset + 16,
              child: FloatingAddSaleButton(
                label: l10n.salesScreenAddSale,
                onPressed: () async {
                  debugPrint(
                    '[SalesScreen] Add sale button clicked -> /sales/add',
                  );
                  final employeeId = filters.barberId?.trim();
                  final target = employeeId != null && employeeId.isNotEmpty
                      ? AppRoutes.addSalePrefill(employeeId: employeeId)
                      : AppRoutes.ownerSalesAdd;
                  final result = await context.push<bool>(target);
                  if (!context.mounted) return;
                  if (result == true) {
                    ref.invalidate(salesStreamProvider);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showSalesFiltersSheet(
  BuildContext context,
  List<String> paymentMethods,
) {
  final l10n = AppLocalizations.of(context)!;
  return showAppModalBottomSheet<void>(
    context: context,
    expand: false,
    builder: (modalContext) {
      return Consumer(
        builder: (context, ref, _) {
          final filters = ref.watch(salesFiltersProvider);
          final employees =
              ref.watch(employeesStreamProvider).asData?.value ??
              const <Employee>[];
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          return KeyboardSafeModalFormScroll(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + kKeyboardSafePaddingExtra,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.salesScreenFiltersSheetTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(modalContext).maybePop(),
                      icon: Icon(AppIcons.close_rounded),
                      tooltip: MaterialLocalizations.of(
                        modalContext,
                      ).closeButtonTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.addSalePaymentMethodField,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SheetFilterChip(
                        label: l10n.salesScreenAllPayments,
                        selected: filters.paymentMethod == null,
                        onTap: () => ref
                            .read(salesFiltersProvider.notifier)
                            .setPaymentMethod(null),
                      ),
                      const SizedBox(width: 8),
                      for (final option in paymentMethods) ...[
                        _SheetFilterChip(
                          label: localizedSalePaymentMethod(l10n, option),
                          selected: filters.paymentMethod == option,
                          onTap: () => ref
                              .read(salesFiltersProvider.notifier)
                              .setPaymentMethod(
                                filters.paymentMethod == option ? null : option,
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppSelectField<String?>(
                  label: l10n.salesScreenBarberFilter,
                  value: filters.barberId,
                  onChanged: (value) {
                    ref.read(salesFiltersProvider.notifier).setBarberId(value);
                  },
                  options: [
                    AppSelectOption<String?>(
                      value: null,
                      label: l10n.salesScreenAllBarbers,
                    ),
                    ...employees
                        .where((employee) => employee.isActive)
                        .map(
                          (employee) => AppSelectOption<String?>(
                            value: employee.id,
                            label: formatTeamMemberName(employee.name),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SheetFilterChip extends StatelessWidget {
  const _SheetFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
