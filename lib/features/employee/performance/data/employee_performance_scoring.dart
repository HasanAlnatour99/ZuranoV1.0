import '../../../employee_today/data/models/et_attendance_day.dart';

/// Band derived from the weighted final score (0–100).
enum EmployeePerformanceLevel {
  excellent,
  great,
  good,
  needsAttention,
  low,
}

/// Optional Firestore `employees.{performanceWeights}` — values as whole percents (e.g. 35).
class EmployeePerformanceWeights {
  const EmployeePerformanceWeights({
    required this.sales,
    required this.services,
    required this.attendance,
    required this.rating,
    required this.discipline,
  });

  final double sales;
  final double services;
  final double attendance;
  final double rating;
  final double discipline;

  static const EmployeePerformanceWeights defaults =
      EmployeePerformanceWeights(
        sales: 0.35,
        services: 0.25,
        attendance: 0.25,
        rating: 0.10,
        discipline: 0.05,
      );

  /// Parses `{ sales: 35, services: 25, ... }` (percents) into fractions summing ~1.
  static EmployeePerformanceWeights fromFirestore(Object? raw) {
    if (raw is! Map) return defaults;
    final m = raw.cast<Object?, Object?>();
    double p(String k, int fallbackPct) {
      final v = m[k];
      if (v is num) return v.toDouble();
      return fallbackPct.toDouble();
    }

    final s = p('sales', 35);
    final sv = p('services', 25);
    final a = p('attendance', 25);
    final r = p('rating', 10);
    final d = p('discipline', 5);
    final sum = s + sv + a + r + d;
    if (sum <= 0) return defaults;
    return EmployeePerformanceWeights(
      sales: s / sum,
      services: sv / sum,
      attendance: a / sum,
      rating: r / sum,
      discipline: d / sum,
    );
  }
}

double clampPercent(double x) => x.clamp(0.0, 100.0);

double salesScoreComponent({
  required double revenue,
  required double dailyRevenueTarget,
}) {
  if (dailyRevenueTarget <= 0) return 100;
  return clampPercent(revenue / dailyRevenueTarget * 100);
}

double servicesScoreComponent({
  required int servicesCount,
  required int dailyServicesTarget,
}) {
  if (dailyServicesTarget <= 0) return 100;
  return clampPercent(servicesCount / dailyServicesTarget * 100);
}

/// OTL-style day row from `attendanceDays`.
double attendanceScoreComponent(EtAttendanceDay? day) {
  if (day == null) return 0;

  final status = day.status;
  double base;
  switch (status) {
    case 'checkedOut':
      base = 100;
      break;
    case 'checkedIn':
    case 'backFromBreak':
      base = 70;
      break;
    case 'onBreak':
      base = 80;
      break;
    case 'notStarted':
      base = 0;
      break;
    case 'incomplete':
      base = 70;
      break;
    default:
      base = 50;
  }

  var score = base;
  if (day.isLateAfterGrace) score -= 20;
  if (day.hasMissingPunch) score -= 30;
  final hasFix =
      day.lastLatitude != null ||
      day.lastLongitude != null ||
      (day.lastDistanceFromSalon != null && day.lastDistanceFromSalon! > 0);
  if (hasFix && !day.isInsideZone) score -= 20;
  return clampPercent(score);
}

/// Reviews scored 0–5 → component 0–100; [neutralWhenEmpty] when no reviews today.
double ratingScoreComponent({
  required List<double> ratingsToday,
  double neutralWhenEmpty = 80,
}) {
  if (ratingsToday.isEmpty) return clampPercent(neutralWhenEmpty);
  final sum = ratingsToday.fold<double>(0, (a, b) => a + b);
  final avg = sum / ratingsToday.length;
  return clampPercent(avg / 5 * 100);
}

double disciplineScoreComponent(int violationsTodayCount) {
  final n = violationsTodayCount;
  if (n <= 0) return 100;
  if (n == 1) return 70;
  if (n == 2) return 40;
  return 0;
}

double weightedFinalScore({
  required double salesScore,
  required double servicesScore,
  required double attendanceScore,
  required double ratingScore,
  required double disciplineScore,
  required EmployeePerformanceWeights w,
}) {
  return clampPercent(
    salesScore * w.sales +
        servicesScore * w.services +
        attendanceScore * w.attendance +
        ratingScore * w.rating +
        disciplineScore * w.discipline,
  );
}

EmployeePerformanceLevel levelFromFinalScore(double finalScore) {
  if (finalScore >= 90) return EmployeePerformanceLevel.excellent;
  if (finalScore >= 75) return EmployeePerformanceLevel.great;
  if (finalScore >= 60) return EmployeePerformanceLevel.good;
  if (finalScore >= 40) return EmployeePerformanceLevel.needsAttention;
  return EmployeePerformanceLevel.low;
}
