import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../data/employee_performance_scoring.dart';
import '../data/employee_today_performance_model.dart';
import '../data/employee_today_performance_repository.dart';

final employeeTodayPerformanceRepositoryProvider =
    Provider<EmployeeTodayPerformanceRepository>((ref) {
      return EmployeeTodayPerformanceRepository(ref.watch(firestoreProvider));
    });

/// Live today stats for the signed-in employee workspace (local calendar day).
final employeeTodayPerformanceProvider =
    StreamProvider.autoDispose<EmployeeTodayPerformanceModel>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<EmployeeTodayPerformanceModel>.value(
          EmployeeTodayPerformanceModel(
            employeeId: '',
            dateKey: '',
            servicesCount: 0,
            revenue: 0,
            commission: 0,
            dailyServicesTarget: 0,
            dailyRevenueTarget: 0,
            salesScore: 0,
            servicesScore: 0,
            attendanceScore: 0,
            ratingScore: 80,
            disciplineScore: 100,
            finalScore: 0,
            level: EmployeePerformanceLevel.low,
            averageRatingToday: null,
            violationsCount: 0,
          ),
        );
      }
      final day = DateTime.now();
      return ref
          .watch(employeeTodayPerformanceRepositoryProvider)
          .watchTodayPerformance(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            dayLocal: day,
          );
    });
