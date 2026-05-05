import '../../../../l10n/app_localizations.dart';
import 'employee_performance_scoring.dart';

/// Balanced daily performance (0–100) with component scores for the employee workspace.
class EmployeeTodayPerformanceModel {
  const EmployeeTodayPerformanceModel({
    required this.employeeId,
    required this.dateKey,
    required this.servicesCount,
    required this.revenue,
    required this.commission,
    required this.dailyServicesTarget,
    required this.dailyRevenueTarget,
    required this.salesScore,
    required this.servicesScore,
    required this.attendanceScore,
    required this.ratingScore,
    required this.disciplineScore,
    required this.finalScore,
    required this.level,
    required this.averageRatingToday,
    required this.violationsCount,
  });

  final String employeeId;
  final String dateKey;

  final int servicesCount;
  final double revenue;
  final double commission;

  final int dailyServicesTarget;
  final double dailyRevenueTarget;

  final double salesScore;
  final double servicesScore;
  final double attendanceScore;
  final double ratingScore;
  final double disciplineScore;

  /// Weighted total 0–100.
  final double finalScore;
  final EmployeePerformanceLevel level;

  /// Average customer rating for today (1–5), or null if none.
  final double? averageRatingToday;

  final int violationsCount;

  String get finalScorePercentText =>
      '${finalScore.round().clamp(0, 100)}%';

  /// Progress bar 0–1 for the overall score.
  double get finalProgress => (finalScore / 100).clamp(0, 1);

  String levelLabel(AppLocalizations l10n) {
    switch (level) {
      case EmployeePerformanceLevel.excellent:
        return l10n.employeeTodayPerformanceLevelExcellent;
      case EmployeePerformanceLevel.great:
        return l10n.employeeTodayPerformanceLevelGreat;
      case EmployeePerformanceLevel.good:
        return l10n.employeeTodayPerformanceLevelGood;
      case EmployeePerformanceLevel.needsAttention:
        return l10n.employeeTodayPerformanceLevelNeedsAttention;
      case EmployeePerformanceLevel.low:
        return l10n.employeeTodayPerformanceLevelLow;
    }
  }

  String smartTip(AppLocalizations l10n) {
    switch (level) {
      case EmployeePerformanceLevel.excellent:
        return l10n.employeeTodayPerformanceTipExcellent;
      case EmployeePerformanceLevel.great:
        return l10n.employeeTodayPerformanceTipGreat;
      case EmployeePerformanceLevel.good:
        return l10n.employeeTodayPerformanceTipGood;
      case EmployeePerformanceLevel.needsAttention:
        return l10n.employeeTodayPerformanceTipNeedsAttention;
      case EmployeePerformanceLevel.low:
        return l10n.employeeTodayPerformanceTipLow;
    }
  }
}
