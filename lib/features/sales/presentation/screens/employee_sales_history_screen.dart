import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../providers/employee_sales_providers.dart';
import '../widgets/employee_sale_list_row.dart';

enum _EmployeeSalesHistoryScope { thisWeek, thisMonth, custom }

/// Full sales list with period filters (from Sales tab “View all”).
class EmployeeSalesHistoryScreen extends ConsumerStatefulWidget {
  const EmployeeSalesHistoryScreen({super.key});

  @override
  ConsumerState<EmployeeSalesHistoryScreen> createState() =>
      _EmployeeSalesHistoryScreenState();
}

class _EmployeeSalesHistoryScreenState
    extends ConsumerState<EmployeeSalesHistoryScreen> {
  _EmployeeSalesHistoryScope _scope = _EmployeeSalesHistoryScope.thisWeek;
  DateTime? _customFrom;
  DateTime? _customTo;

  EmployeeSalesHistoryRangeKey _rangeKeyForNow() {
    final now = DateTime.now();
    switch (_scope) {
      case _EmployeeSalesHistoryScope.thisWeek:
        final (m, s) = employeeSalesHistoryWeekBounds(now);
        return EmployeeSalesHistoryRangeKey(fromDay: m, toDay: s);
      case _EmployeeSalesHistoryScope.thisMonth:
        final (a, b) = employeeSalesHistoryCalendarMonthBounds(now);
        return EmployeeSalesHistoryRangeKey(fromDay: a, toDay: b);
      case _EmployeeSalesHistoryScope.custom:
        final from = _customFrom;
        final to = _customTo;
        if (from != null && to != null) {
          var a = DateTime(from.year, from.month, from.day);
          var b = DateTime(to.year, to.month, to.day);
          if (a.isAfter(b)) {
            final t = a;
            a = b;
            b = t;
          }
          return EmployeeSalesHistoryRangeKey(fromDay: a, toDay: b);
        }
        final (a, b) = employeeSalesHistoryCalendarMonthBounds(now);
        return EmployeeSalesHistoryRangeKey(fromDay: a, toDay: b);
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initial = isFrom
        ? (_customFrom ?? _customTo ?? now)
        : (_customTo ?? _customFrom ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: isFrom
          ? l10n.employeeAttendanceCustomRangeFrom
          : l10n.employeeAttendanceCustomRangeTo,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _customFrom = picked;
      } else {
        _customTo = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final localeTag = locale.toString();
    final chipFmt = DateFormat.yMMMd(localeTag);
    final rangeKey = _rangeKeyForNow();

    final salesAsync = ref.watch(
      employeeSalesHistoryRangeProvider(rangeKey),
    );
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final timeFmt = DateFormat.jm(localeTag);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF111827),
        title: Text(
          l10n.employeeSalesHistoryScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeeSalesHistoryRangeProvider(rangeKey));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<_EmployeeSalesHistoryScope>(
                      segments: [
                        ButtonSegment(
                          value: _EmployeeSalesHistoryScope.thisWeek,
                          label: Text(l10n.employeeAttendanceFilterThisWeek),
                        ),
                        ButtonSegment(
                          value: _EmployeeSalesHistoryScope.thisMonth,
                          label: Text(l10n.employeeAttendanceFilterThisMonth),
                        ),
                        ButtonSegment(
                          value: _EmployeeSalesHistoryScope.custom,
                          label: Text(l10n.employeeAttendanceFilterCustom),
                        ),
                      ],
                      selected: {_scope},
                      onSelectionChanged: (next) {
                        final v = next.first;
                        setState(() {
                          _scope = v;
                          if (v == _EmployeeSalesHistoryScope.custom &&
                              (_customFrom == null || _customTo == null)) {
                            final n = DateTime.now();
                            final (a, b) =
                                employeeSalesHistoryCalendarMonthBounds(n);
                            _customFrom = a;
                            _customTo = b;
                          }
                        });
                      },
                    ),
                    if (_scope == _EmployeeSalesHistoryScope.custom) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickDate(isFrom: true),
                              child: Text(
                                _customFrom == null
                                    ? l10n.employeeAttendanceCustomRangeFrom
                                    : chipFmt.format(_customFrom!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickDate(isFrom: false),
                              child: Text(
                                _customTo == null
                                    ? l10n.employeeAttendanceCustomRangeTo
                                    : chipFmt.format(_customTo!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            salesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('$e', textAlign: TextAlign.center)),
                ),
              ),
              data: (sales) {
                if (sales.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.employeeSalesHistoryEmptyForRange,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFF837A98),
                                  ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, i) {
                      final s = sales[i];
                      return EmployeeSaleListRow(
                        sale: s,
                        currencyCode: currencyCode,
                        locale: locale,
                        timeFmt: timeFmt,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
