import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';

/// Employee shell bottom navigation styled like owner bar.
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
    if (currentPath == AppRoutes.settings) {
      return 3;
    }
    if (AppRoutes.isEmployeePayrollPath(currentPath)) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    const rowVerticalPadding = 10.0;
    const rowMinHeight = 56.0;
    final barTotalHeight = rowMinHeight + (rowVerticalPadding * 2) + bottomPad;

    Widget tab({
      required int index,
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: _BottomNavItem(
          icon: icon,
          label: label,
          selected: _index == index,
          onTap: onTap,
        ),
      );
    }

    final today = tab(
      index: 0,
      icon: Icons.calendar_today_rounded,
      label: l10n.employeeBottomNavToday,
      onTap: () => context.go(AppRoutes.employeeToday),
    );
    final sales = tab(
      index: 1,
      icon: Icons.payments_outlined,
      label: l10n.employeeBottomNavSales,
      onTap: () => context.go(AppRoutes.employeeSales),
    );
    final attendance = tab(
      index: 2,
      icon: Icons.schedule_rounded,
      label: l10n.employeeBottomNavAttendance,
      onTap: () => context.go(AppRoutes.employeeAttendance),
    );
    final profile = tab(
      index: 3,
      icon: Icons.person_outline_rounded,
      label: l10n.employeeBottomNavProfile,
      onTap: () => context.push(AppRoutes.settings),
    );

    return SizedBox(
      height: barTotalHeight,
      child: Material(
        color: scheme.surfaceContainer,
        surfaceTintColor: scheme.surfaceContainer,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            rowVerticalPadding,
            8,
            rowVerticalPadding + bottomPad,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              today,
              sales,
              const SizedBox(width: 72),
              attendance,
              profile,
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final muted = scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 46;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? primary : muted, size: 20),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? primary : muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
