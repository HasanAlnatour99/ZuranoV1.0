import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/navigation/zurano_swipe_shell.dart';
import '../../../employee_today/presentation/screens/employee_today_screen.dart';
import '../../../payroll/presentation/screens/employee_payroll_screen.dart';
import 'employee_attendance_screen.dart';
import 'employee_sales_screen.dart';

class EmployeeMainSwipeShellScreen extends StatelessWidget {
  const EmployeeMainSwipeShellScreen({super.key, required this.currentPath});

  final String currentPath;

  static const List<String> _tabPaths = <String>[
    AppRoutes.employeeToday,
    AppRoutes.employeeSales,
    AppRoutes.employeeAttendance,
    AppRoutes.employeePayroll,
  ];

  int get _currentIndex {
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
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    void goToIndex(int index) {
      final target = _tabPaths[index];
      if (target == currentPath) {
        return;
      }
      context.go(target);
    }

    return ZuranoSwipeShell(
      pages: const <Widget>[
        EmployeeTodayScreen(),
        EmployeeSalesScreen(),
        EmployeeAttendanceScreen(),
        EmployeePayrollScreen(),
      ],
      currentIndex: _currentIndex,
      onIndexChanged: goToIndex,
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }
}
