import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/salon_streams_provider.dart'
    show expensesStreamProvider;
import '../providers/expense_providers.dart';
import '../widgets/add_expense_bottom_button.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/expense_date_range_selector.dart';
import '../widgets/expense_filters_tile.dart';
import '../widgets/expense_header.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/expenses_error_view.dart';
import '../widgets/expenses_loading_view.dart';
import '../widgets/recent_expenses_card.dart';
import '../../../../providers/money_currency_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonId = ref.watch(currentSalonIdProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (salonId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.expensesScreenSalonMissing,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      );
    }

    final expensesAsync = ref.watch(expensesStreamProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            expensesAsync.when(
              loading: () => const ExpensesLoadingView(),
              error: (error, _) => ExpensesErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(expensesStreamProvider),
              ),
              data: (_) => _ExpensesBody(
                currencyCode: currencyCode,
                onViewAllCategories: () =>
                    _showCategoryBreakdownSheet(context, ref),
                onViewAllRecent: () =>
                    _showRecentExpensesSheet(context, ref, currencyCode),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: bottomInset + 16,
              child: AddExpenseBottomButton(
                onPressed: () => context.pushNamed(AppRouteNames.addExpense),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensesBody extends ConsumerWidget {
  const _ExpensesBody({
    required this.currencyCode,
    required this.onViewAllCategories,
    required this.onViewAllRecent,
  });

  final String currencyCode;
  final VoidCallback onViewAllCategories;
  final VoidCallback onViewAllRecent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(expensesSummaryProvider);
    final breakdownAsync = ref.watch(expenseCategoryBreakdownUiRowsProvider);
    final recentAsync = ref.watch(recentFilteredExpensesProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ExpenseHeader(
                onReportTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.expensesScreenReportComingSoon,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              summaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (Object? error, StackTrace stackTrace) =>
                    const SizedBox.shrink(),
                data: (summary) => ExpenseSummaryCard(
                  summary: summary,
                  currencyCode: currencyCode,
                ),
              ),
              const SizedBox(height: 20),
              const ExpenseDateRangeSelector(),
              const SizedBox(height: 16),
              const ExpenseFiltersTile(),
              const SizedBox(height: 20),
              breakdownAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (Object? error, StackTrace stackTrace) =>
                    const SizedBox.shrink(),
                data: (rows) {
                  final total =
                      ref
                          .read(filteredExpensesProvider)
                          .asData
                          ?.value
                          .fold<double>(0, (s, e) => s + e.amount) ??
                      0;
                  return CategoryBreakdownCard(
                    rows: rows,
                    totalAmount: total,
                    currencyCode: currencyCode,
                    onViewAll: rows.isEmpty ? null : onViewAllCategories,
                  );
                },
              ),
              const SizedBox(height: 20),
              recentAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (Object? error, StackTrace stackTrace) =>
                    const SizedBox.shrink(),
                data: (list) => RecentExpensesCard(
                  expenses: list,
                  currencyCode: currencyCode,
                  onViewAll: list.isEmpty ? null : onViewAllRecent,
                  // TODO: Navigate to expense details when route exists.
                  onExpenseTap: null,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

Future<void> _showCategoryBreakdownSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context);
  final currencyCode = ref.read(sessionSalonMoneyCurrencyCodeProvider);
  final rows =
      ref.read(expenseCategoryBreakdownUiRowsProvider).asData?.value ?? [];
  final total =
      ref
          .read(filteredExpensesProvider)
          .asData
          ?.value
          .fold<double>(0, (s, e) => s + e.amount) ??
      0;

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.expensesScreenBreakdownTitle,
            style: Theme.of(
              ctx,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            formatAppMoney(total, currencyCode, locale),
            style: Theme.of(ctx).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final r in rows)
            ListTile(
              title: Text(
                r.categoryLabel.trim().isEmpty
                    ? l10n.moneyDashboardUncategorized
                    : r.categoryLabel,
              ),
              subtitle: Text('${r.percentOfTotal.round()}%'),
              trailing: Text(
                formatAppMoney(r.amount, currencyCode, locale),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<void> _showRecentExpensesSheet(
  BuildContext context,
  WidgetRef ref,
  String currencyCode,
) async {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context);
  final list = ref.read(filteredExpensesProvider).asData?.value ?? [];

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.expensesScreenRecentTitle,
            style: Theme.of(
              ctx,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final e in list.take(20))
            ListTile(
              title: Text(
                e.title.trim().isEmpty
                    ? l10n.expensesScreenUnknownExpense
                    : e.title,
              ),
              subtitle: Text(
                DateFormat.yMMMd(
                  locale.toString(),
                ).format(e.incurredAt.toLocal()),
              ),
              trailing: Text(
                formatAppMoney(e.amount, currencyCode, locale),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    ),
  );
}
