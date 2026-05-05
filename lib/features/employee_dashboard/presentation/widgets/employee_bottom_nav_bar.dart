import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/ui/app_icons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';

/// Employee shell bottom navigation — same floating Zurano chrome as owner.
class EmployeeBottomNavBar extends StatelessWidget {
  const EmployeeBottomNavBar({super.key, required this.currentPath});

  final String currentPath;

  int get _index {
    if (currentPath == AppRoutes.employeeToday ||
        currentPath == AppRoutes.employeeDashboard) {
      return 0;
    }
    if (currentPath.startsWith(AppRoutes.employeeSales)) {
      return 1;
    }
    if (AppRoutes.isEmployeeAttendancePath(currentPath) ||
        currentPath == AppRoutes.employeeAttendanceCorrection ||
        currentPath == AppRoutes.employeeAttendanceCorrectionNested) {
      return 2;
    }
    if (AppRoutes.isEmployeePayrollPath(currentPath)) {
      return 3;
    }
    if (currentPath == AppRoutes.settings) {
      return 4;
    }
    return 0;
  }

  /// `0..3` for tab strip; off-strip routes (e.g. settings) use `-1` selection.
  int get _selectedSlotIndex => _index >= 0 && _index <= 3 ? _index : -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final slots = <ZuranoFloatingNavSlot>[
      ZuranoFloatingNavSlot(
        icon: AppIcons.calendar_today_outlined,
        selectedIcon: AppIcons.calendar_month_rounded,
        label: l10n.employeeBottomNavToday,
        onTap: () => context.go(AppRoutes.employeeToday),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.payments_outlined,
        selectedIcon: AppIcons.payments_rounded,
        label: l10n.employeeBottomNavSales,
        onTap: () => context.go(AppRoutes.employeeSales),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.schedule_outlined,
        selectedIcon: AppIcons.schedule_rounded,
        label: l10n.employeeBottomNavAttendance,
        onTap: () => context.go(AppRoutes.employeeAttendance),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: l10n.employeeBottomNavPayroll,
        onTap: () => context.go(AppRoutes.employeePayroll),
      ),
    ];

    return ZuranoFloatingBottomNav(
      slots: slots,
      selectedSlotIndex: _selectedSlotIndex,
    );
  }
}
