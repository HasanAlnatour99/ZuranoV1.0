import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/employee_sales_period.dart';
import '../providers/employee_sales_period_notifier.dart';

class EmployeeSalesPeriodSelector extends ConsumerWidget {
  const EmployeeSalesPeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(employeeSalesPeriodProvider);
    final notifier = ref.read(employeeSalesPeriodProvider.notifier);

    const segmentTextStyle = TextStyle(
      fontSize: 11.5,
      height: 1.15,
      fontWeight: FontWeight.w600,
    );

    Text segmentLabel(String text) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: segmentTextStyle,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SegmentedButton<EmployeeSalesPeriod>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: EmployeeSalesPeriod.today,
            label: segmentLabel(l10n.salesDateToday),
          ),
          ButtonSegment(
            value: EmployeeSalesPeriod.week,
            label: segmentLabel(l10n.teamMemberSalesFilterThisWeek),
          ),
          ButtonSegment(
            value: EmployeeSalesPeriod.month,
            label: segmentLabel(l10n.teamMemberSalesFilterThisMonth),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (s) => notifier.setPeriod(s.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const WidgetStatePropertyAll(segmentTextStyle),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF5B21B6);
            }
            return Colors.grey.shade600;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFF4ECFF);
            }
            return Colors.white;
          }),
        ),
      ),
    );
  }
}
