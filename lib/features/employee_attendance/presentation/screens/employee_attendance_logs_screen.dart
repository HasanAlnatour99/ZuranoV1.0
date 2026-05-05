import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/employee_attendance_providers.dart';
import '../widgets/attendance_details_bottom_sheet.dart';
import '../widgets/attendance_timeline_row.dart';

enum _EmployeeAttendanceLogsScope { thisWeek, thisMonth, custom }

/// Full attendance list with period filters (from Attendance tab “View all”).
class EmployeeAttendanceLogsScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceLogsScreen({super.key});

  @override
  ConsumerState<EmployeeAttendanceLogsScreen> createState() =>
      _EmployeeAttendanceLogsScreenState();
}

class _EmployeeAttendanceLogsScreenState
    extends ConsumerState<EmployeeAttendanceLogsScreen> {
  _EmployeeAttendanceLogsScope _scope = _EmployeeAttendanceLogsScope.thisWeek;
  DateTime? _customFrom;
  DateTime? _customTo;

  EmployeeAttendanceDateRangeKey _rangeKeyForNow() {
    final now = DateTime.now();
    switch (_scope) {
      case _EmployeeAttendanceLogsScope.thisWeek:
        final (m, s) = employeeAttendanceWeekBounds(now);
        return EmployeeAttendanceDateRangeKey(fromDay: m, toDay: s);
      case _EmployeeAttendanceLogsScope.thisMonth:
        final (a, b) = employeeAttendanceCalendarMonthBounds(now);
        return EmployeeAttendanceDateRangeKey(fromDay: a, toDay: b);
      case _EmployeeAttendanceLogsScope.custom:
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
          return EmployeeAttendanceDateRangeKey(fromDay: a, toDay: b);
        }
        final (a, b) = employeeAttendanceCalendarMonthBounds(now);
        return EmployeeAttendanceDateRangeKey(fromDay: a, toDay: b);
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
    final localeTag = Localizations.localeOf(context).toString();
    final chipFmt = DateFormat.yMMMd(localeTag);
    final rangeKey = _rangeKeyForNow();

    final historyAsync = ref.watch(
      employeeAttendanceHistoryRangeProvider(rangeKey),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1D1233),
        title: Text(
          l10n.employeeAttendanceLogsScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employeeAttendanceHistoryRangeProvider(rangeKey));
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
                    SegmentedButton<_EmployeeAttendanceLogsScope>(
                      segments: [
                        ButtonSegment(
                          value: _EmployeeAttendanceLogsScope.thisWeek,
                          label: Text(l10n.employeeAttendanceFilterThisWeek),
                        ),
                        ButtonSegment(
                          value: _EmployeeAttendanceLogsScope.thisMonth,
                          label: Text(l10n.employeeAttendanceFilterThisMonth),
                        ),
                        ButtonSegment(
                          value: _EmployeeAttendanceLogsScope.custom,
                          label: Text(l10n.employeeAttendanceFilterCustom),
                        ),
                      ],
                      selected: {_scope},
                      onSelectionChanged: (next) {
                        final v = next.first;
                        setState(() {
                          _scope = v;
                          if (v == _EmployeeAttendanceLogsScope.custom &&
                              (_customFrom == null || _customTo == null)) {
                            final n = DateTime.now();
                            final (a, b) =
                                employeeAttendanceCalendarMonthBounds(n);
                            _customFrom = a;
                            _customTo = b;
                          }
                        });
                      },
                    ),
                    if (_scope == _EmployeeAttendanceLogsScope.custom) ...[
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
            historyAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('$e', textAlign: TextAlign.center)),
                ),
              ),
              data: (records) {
                if (records.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.employeeAttendanceLogsEmptyForRange,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    itemCount: records.length,
                    itemBuilder: (context, i) {
                      final r = records[i];
                      return AttendanceTimelineRow(
                        record: r,
                        isFirst: i == 0,
                        isLast: i == records.length - 1,
                        onTap: () => showAttendanceDetailsBottomSheet(context, r),
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
