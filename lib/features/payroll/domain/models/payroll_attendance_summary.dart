import 'package:cloud_firestore/cloud_firestore.dart';

/// `salons/{salonId}/payrollPeriods/{yyyyMM}/employeeSummaries/{employeeId}`.
class PayrollAttendanceSummary {
  const PayrollAttendanceSummary({
    required this.salonId,
    required this.employeeId,
    required this.period,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.dayOffDays,
    required this.totalLateMinutes,
    required this.totalEarlyExitMinutes,
    required this.totalMissingCheckoutMinutes,
    required this.totalWorkedMinutes,
    required this.totalDeductionMinutes,
    required this.recalculatedAt,
  });

  final String salonId;
  final String employeeId;
  final String period;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int dayOffDays;
  final int totalLateMinutes;
  final int totalEarlyExitMinutes;
  final int totalMissingCheckoutMinutes;
  final int totalWorkedMinutes;
  final int totalDeductionMinutes;
  final DateTime? recalculatedAt;

  factory PayrollAttendanceSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    DateTime? ra;
    final r = d['recalculatedAt'];
    if (r is Timestamp) {
      ra = r.toDate();
    }
    return PayrollAttendanceSummary(
      salonId: d['salonId']?.toString() ?? '',
      employeeId: d['employeeId']?.toString() ?? '',
      period: d['period']?.toString() ?? '',
      presentDays: (d['presentDays'] as num?)?.toInt() ?? 0,
      absentDays: (d['absentDays'] as num?)?.toInt() ?? 0,
      lateDays: (d['lateDays'] as num?)?.toInt() ?? 0,
      dayOffDays: (d['dayOffDays'] as num?)?.toInt() ?? 0,
      totalLateMinutes: (d['totalLateMinutes'] as num?)?.toInt() ?? 0,
      totalEarlyExitMinutes: (d['totalEarlyExitMinutes'] as num?)?.toInt() ?? 0,
      totalMissingCheckoutMinutes:
          (d['totalMissingCheckoutMinutes'] as num?)?.toInt() ?? 0,
      totalWorkedMinutes: (d['totalWorkedMinutes'] as num?)?.toInt() ?? 0,
      totalDeductionMinutes:
          (d['totalDeductionMinutes'] as num?)?.toInt() ?? 0,
      recalculatedAt: ra,
    );
  }
}
