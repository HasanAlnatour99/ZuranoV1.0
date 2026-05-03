import 'package:cloud_firestore/cloud_firestore.dart';

class EtAttendanceDay {
  const EtAttendanceDay({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.dateKey,
    required this.date,
    required this.status,
    required this.totalPunches,
    required this.totalBreaks,
    required this.workedMinutes,
    required this.breakMinutes,
    required this.lateMinutes,
    required this.earlyExitMinutes,
    required this.isLateAfterGrace,
    required this.isEarlyExitAfterGrace,
    required this.isInsideZone,
    this.lastLatitude,
    this.lastLongitude,
    this.lastDistanceFromSalon,
    this.firstPunchInAt,
    this.lastPunchOutAt,
    required this.hasMissingPunch,
    required this.hasPendingCorrectionRequest,
    required this.punchSequence,
    this.exceededBreakMinutes,
    this.hasBreakViolation,
    this.payrollImpactStatus,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String salonId;
  final String employeeId;
  final String employeeName;
  final String dateKey;
  final DateTime date;
  final String status;
  final int totalPunches;
  final int totalBreaks;
  final int workedMinutes;
  final int breakMinutes;
  final int lateMinutes;
  final int earlyExitMinutes;
  final bool isLateAfterGrace;
  final bool isEarlyExitAfterGrace;
  final bool isInsideZone;
  final double? lastLatitude;
  final double? lastLongitude;
  final double? lastDistanceFromSalon;
  final DateTime? firstPunchInAt;
  final DateTime? lastPunchOutAt;
  final bool hasMissingPunch;
  final bool hasPendingCorrectionRequest;

  /// Punch type names in order (`punchIn`, `breakOut`, …) for atomic validation.
  final List<String> punchSequence;

  /// Cumulative exceeded break minutes (salon policy) for this calendar day.
  final int? exceededBreakMinutes;

  /// True when at least one break return created an [EXCEEDED_BREAK_TIME] path.
  final bool? hasBreakViolation;

  /// Optional HR flag (e.g. PENDING_PROCESSING) for payroll pipelines.
  final String? payrollImpactStatus;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EtAttendanceDay.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    DateTime? ts(String k) => (d[k] as Timestamp?)?.toDate();
    final seq = d['punchSequence'];
    final sequence = seq is List
        ? seq.map((e) => e.toString()).toList(growable: false)
        : <String>[];

    return EtAttendanceDay(
      id: doc.id,
      salonId: d['salonId']?.toString() ?? '',
      employeeId: d['employeeId']?.toString() ?? '',
      employeeName: d['employeeName']?.toString() ?? '',
      dateKey: d['dateKey']?.toString() ?? '',
      date: ts('date') ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: d['status']?.toString() ?? 'notStarted',
      totalPunches: (d['totalPunches'] as num?)?.toInt() ?? sequence.length,
      totalBreaks: (d['totalBreaks'] as num?)?.toInt() ?? 0,
      workedMinutes: (d['workedMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (d['breakMinutes'] as num?)?.toInt() ?? 0,
      lateMinutes: (d['lateMinutes'] as num?)?.toInt() ?? 0,
      earlyExitMinutes: (d['earlyExitMinutes'] as num?)?.toInt() ?? 0,
      isLateAfterGrace: d['isLateAfterGrace'] == true,
      isEarlyExitAfterGrace: d['isEarlyExitAfterGrace'] == true,
      isInsideZone: d['isInsideZone'] == true,
      lastLatitude: (d['lastLatitude'] as num?)?.toDouble(),
      lastLongitude: (d['lastLongitude'] as num?)?.toDouble(),
      lastDistanceFromSalon: (d['lastDistanceFromSalon'] as num?)?.toDouble(),
      firstPunchInAt: ts('firstPunchInAt'),
      lastPunchOutAt: ts('lastPunchOutAt'),
      hasMissingPunch: d['hasMissingPunch'] == true,
      hasPendingCorrectionRequest: d['hasPendingCorrectionRequest'] == true,
      punchSequence: sequence,
      exceededBreakMinutes: (d['exceededBreakMinutes'] as num?)?.toInt(),
      hasBreakViolation: d['hasBreakViolation'] is bool
          ? d['hasBreakViolation'] as bool
          : null,
      payrollImpactStatus: d['payrollImpactStatus']?.toString(),
      createdAt: ts('createdAt'),
      updatedAt: ts('updatedAt'),
    );
  }
}
