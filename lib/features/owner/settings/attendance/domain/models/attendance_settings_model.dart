import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../employee_dashboard/data/models/attendance_zone_model.dart';

/// Single source of truth for `salons/{salonId}/settings/attendance`.
///
/// Replaces the legacy split between `EtAttendanceSettings` (employee punch
/// pipeline) and the simpler `AttendanceSettingsModel` (zone-only screen).
/// All older field names are still read on parse and written on save so older
/// clients keep working during rollout.
class AttendanceSettingsModel {
  const AttendanceSettingsModel({
    required this.salonId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.allowedRadiusMeters,
    required this.locationRequired,
    required this.attendanceRequired,
    required this.punchInRequired,
    required this.punchOutRequired,
    required this.breaksEnabled,
    required this.maxPunchesPerDay,
    required this.maxBreaksPerDay,
    required this.lateGraceMinutes,
    required this.earlyExitGraceMinutes,
    required this.minimumShiftMinutes,
    required this.maximumShiftMinutes,
    required this.correctionRequestsEnabled,
    required this.requireCorrectionReason,
    required this.requireOwnerApprovalForCorrection,
    required this.maxCorrectionRequestsPerMonth,
    required this.allowedLateCountPerMonth,
    required this.allowedEarlyExitCountPerMonth,
    required this.allowedMissingCheckoutCountPerMonth,
    required this.autoCreateViolations,
    required this.missingCheckoutDeductionPercent,
    required this.absenceDeductionPercent,
    required this.lateDeductionPercent,
    required this.earlyExitDeductionPercent,
    required this.maxBreakMinutesPerDay,
    required this.correctionRequestMaxDaysBack,
    required this.missingCheckoutPenaltyMinutes,
    this.standardShiftStart,
    this.standardShiftEnd,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  final String salonId;

  // ----- Attendance zone -----
  final double? latitude;
  final double? longitude;
  final String? address;
  final int allowedRadiusMeters;
  final bool locationRequired;

  // ----- Punch rules -----
  final bool attendanceRequired;
  final bool punchInRequired;
  final bool punchOutRequired;
  final bool breaksEnabled;
  final int maxPunchesPerDay;
  final int maxBreaksPerDay;

  // ----- Grace and working time -----
  final int lateGraceMinutes;
  final int earlyExitGraceMinutes;
  final int minimumShiftMinutes;
  final int maximumShiftMinutes;

  // ----- Correction requests -----
  final bool correctionRequestsEnabled;
  final bool requireCorrectionReason;
  final bool requireOwnerApprovalForCorrection;
  final int maxCorrectionRequestsPerMonth;

  // ----- Monthly allowance counts -----
  final int allowedLateCountPerMonth;
  final int allowedEarlyExitCountPerMonth;
  final int allowedMissingCheckoutCountPerMonth;

  // ----- HR violation rules -----
  final bool autoCreateViolations;
  final int missingCheckoutDeductionPercent;
  final int absenceDeductionPercent;
  final int lateDeductionPercent;
  final int earlyExitDeductionPercent;

  // ----- Extended fields kept for OTL/payroll analysis (legacy) -----
  /// Total break minutes allowed per calendar day (sum of all breaks).
  final int maxBreakMinutesPerDay;

  /// Backward window for retroactive correction requests (days).
  final int correctionRequestMaxDaysBack;

  /// Assumed missing punch-out duration (minutes) for payroll preview and server reprocess.
  final int missingCheckoutPenaltyMinutes;

  /// `HH:mm` standard shift start used for late grace calculation.
  final String? standardShiftStart;

  /// `HH:mm` standard shift end used for early-exit grace calculation.
  final String? standardShiftEnd;

  // ----- Audit -----
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;

  // ---------------------------------------------------------------------------
  // Legacy aliases — read-only getters so existing punch / OTL code keeps
  // compiling without churn during migration.
  // ---------------------------------------------------------------------------

  bool get attendanceEnabled => attendanceRequired;
  bool get gpsRequired => locationRequired;
  double? get salonLatitude => latitude;
  double? get salonLongitude => longitude;
  String? get salonAddress => address;
  int get maxBreakCyclesPerDay => maxBreaksPerDay;
  int get graceLateMinutes => lateGraceMinutes;
  int get graceEarlyExitMinutes => earlyExitGraceMinutes;
  int get minWorkingMinutesPerDay => minimumShiftMinutes;
  int get maxWorkingMinutesPerDay => maximumShiftMinutes;
  int get monthlyLateAllowanceAfterGrace => allowedLateCountPerMonth;
  int get monthlyEarlyExitAllowanceAfterGrace => allowedEarlyExitCountPerMonth;
  bool get allowEmployeeCorrectionRequests => correctionRequestsEnabled;
  bool get requireReasonForCorrection => requireCorrectionReason;
  bool get deductMissingCheckout =>
      autoCreateViolations && missingCheckoutDeductionPercent > 0;
  bool get deductAbsence => autoCreateViolations && absenceDeductionPercent > 0;
  bool get deductLateAfterAllowance =>
      autoCreateViolations && lateDeductionPercent > 0;
  bool get deductEarlyExitAfterAllowance =>
      autoCreateViolations && earlyExitDeductionPercent > 0;

  bool get hasSalonLocationConfigured {
    final lat = latitude;
    final lng = longitude;
    return lat != null &&
        lng != null &&
        lat != 0 &&
        lng != 0 &&
        allowedRadiusMeters >= 10;
  }

  AttendanceZoneModel get zoneLegacy => AttendanceZoneModel(
    latitude: latitude ?? 0,
    longitude: longitude ?? 0,
    radiusMeters: allowedRadiusMeters.toDouble(),
    address: address ?? '',
  );

  // ---------------------------------------------------------------------------
  // Defaults
  // ---------------------------------------------------------------------------

  factory AttendanceSettingsModel.defaults(String salonId) {
    return AttendanceSettingsModel(
      salonId: salonId,
      latitude: null,
      longitude: null,
      address: null,
      allowedRadiusMeters: 20,
      locationRequired: true,
      attendanceRequired: true,
      punchInRequired: true,
      punchOutRequired: true,
      breaksEnabled: true,
      maxPunchesPerDay: 2,
      maxBreaksPerDay: 2,
      lateGraceMinutes: 10,
      earlyExitGraceMinutes: 10,
      minimumShiftMinutes: 60,
      maximumShiftMinutes: 720,
      correctionRequestsEnabled: true,
      requireCorrectionReason: true,
      requireOwnerApprovalForCorrection: true,
      maxCorrectionRequestsPerMonth: 3,
      allowedLateCountPerMonth: 0,
      allowedEarlyExitCountPerMonth: 0,
      allowedMissingCheckoutCountPerMonth: 0,
      autoCreateViolations: true,
      missingCheckoutDeductionPercent: 5,
      absenceDeductionPercent: 100,
      lateDeductionPercent: 5,
      earlyExitDeductionPercent: 5,
      maxBreakMinutesPerDay: 15,
      correctionRequestMaxDaysBack: 30,
      missingCheckoutPenaltyMinutes: 120,
      standardShiftStart: null,
      standardShiftEnd: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore parsing — accepts both new canonical keys and every legacy key.
  // ---------------------------------------------------------------------------

  factory AttendanceSettingsModel.fromFirestore(
    String salonId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    if (!doc.exists) {
      return AttendanceSettingsModel.defaults(salonId);
    }
    return AttendanceSettingsModel.fromMap(salonId, doc.data());
  }

  factory AttendanceSettingsModel.fromMap(
    String salonId,
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return AttendanceSettingsModel.defaults(salonId);
    }
    final defaults = AttendanceSettingsModel.defaults(salonId);

    final zoneMap = data['zone'] is Map
        ? Map<String, dynamic>.from(data['zone'] as Map)
        : null;
    final zoneLat = (zoneMap?['latitude'] as num?)?.toDouble();
    final zoneLng = (zoneMap?['longitude'] as num?)?.toDouble();
    final zoneRadius = (zoneMap?['radiusMeters'] as num?)?.toDouble();
    final zoneAddress = zoneMap?['address']?.toString();

    final lat =
        (data['latitude'] as num?)?.toDouble() ??
        (data['salonLatitude'] as num?)?.toDouble() ??
        zoneLat;
    final lng =
        (data['longitude'] as num?)?.toDouble() ??
        (data['salonLongitude'] as num?)?.toDouble() ??
        zoneLng;
    final address =
        data['address']?.toString() ??
        data['salonAddress']?.toString() ??
        zoneAddress;

    final radiusRaw =
        (data['allowedRadiusMeters'] as num?)?.toDouble() ??
        zoneRadius ??
        defaults.allowedRadiusMeters.toDouble();
    final radius = radiusRaw.clamp(10.0, 500.0).round();

    final locationRequired =
        (data['locationRequired'] as bool?) ??
        (data['gpsRequired'] as bool?) ??
        (data['requireInsideZoneForPunchIn'] as bool?) ??
        (data['requireInsideZoneForPunchOut'] as bool?) ??
        defaults.locationRequired;

    final attendanceRequired =
        (data['attendanceRequired'] as bool?) ??
        (data['attendanceEnabled'] as bool?) ??
        (data['enabled'] as bool?) ??
        defaults.attendanceRequired;

    final rawMaxBreaks = (data['maxBreaksPerDay'] as num?)?.toInt();
    final cycleCount = (data['maxBreakCyclesPerDay'] as num?)?.toInt();
    final maxBreaksPerDay =
        rawMaxBreaks ?? cycleCount ?? defaults.maxBreaksPerDay;

    final breaksEnabled =
        (data['breaksEnabled'] as bool?) ??
        (data['allowBreaks'] as bool?) ??
        (maxBreaksPerDay > 0);

    return AttendanceSettingsModel(
      salonId: salonId,
      latitude: lat,
      longitude: lng,
      address: address,
      allowedRadiusMeters: radius,
      locationRequired: locationRequired,
      attendanceRequired: attendanceRequired,
      punchInRequired:
          (data['punchInRequired'] as bool?) ?? defaults.punchInRequired,
      punchOutRequired:
          (data['punchOutRequired'] as bool?) ?? defaults.punchOutRequired,
      breaksEnabled: breaksEnabled,
      maxPunchesPerDay: 2,
      maxBreaksPerDay: maxBreaksPerDay,
      lateGraceMinutes:
          (data['lateGraceMinutes'] as num?)?.toInt() ??
          (data['graceLateMinutes'] as num?)?.toInt() ??
          defaults.lateGraceMinutes,
      earlyExitGraceMinutes:
          (data['earlyExitGraceMinutes'] as num?)?.toInt() ??
          (data['graceEarlyExitMinutes'] as num?)?.toInt() ??
          defaults.earlyExitGraceMinutes,
      minimumShiftMinutes:
          (data['minimumShiftMinutes'] as num?)?.toInt() ??
          (data['minWorkingMinutesPerDay'] as num?)?.toInt() ??
          defaults.minimumShiftMinutes,
      maximumShiftMinutes:
          (data['maximumShiftMinutes'] as num?)?.toInt() ??
          (data['maxWorkingMinutesPerDay'] as num?)?.toInt() ??
          defaults.maximumShiftMinutes,
      correctionRequestsEnabled:
          (data['correctionRequestsEnabled'] as bool?) ??
          (data['allowEmployeeCorrectionRequests'] as bool?) ??
          (data['allowCorrectionRequests'] as bool?) ??
          defaults.correctionRequestsEnabled,
      requireCorrectionReason:
          (data['requireCorrectionReason'] as bool?) ??
          (data['requireReasonForCorrection'] as bool?) ??
          defaults.requireCorrectionReason,
      requireOwnerApprovalForCorrection:
          (data['requireOwnerApprovalForCorrection'] as bool?) ??
          defaults.requireOwnerApprovalForCorrection,
      maxCorrectionRequestsPerMonth:
          (data['maxCorrectionRequestsPerMonth'] as num?)?.toInt() ??
          defaults.maxCorrectionRequestsPerMonth,
      allowedLateCountPerMonth:
          (data['allowedLateCountPerMonth'] as num?)?.toInt() ??
          (data['monthlyLateAllowanceAfterGrace'] as num?)?.toInt() ??
          defaults.allowedLateCountPerMonth,
      allowedEarlyExitCountPerMonth:
          (data['allowedEarlyExitCountPerMonth'] as num?)?.toInt() ??
          (data['monthlyEarlyExitAllowanceAfterGrace'] as num?)?.toInt() ??
          defaults.allowedEarlyExitCountPerMonth,
      allowedMissingCheckoutCountPerMonth:
          (data['allowedMissingCheckoutCountPerMonth'] as num?)?.toInt() ??
          defaults.allowedMissingCheckoutCountPerMonth,
      autoCreateViolations:
          (data['autoCreateViolations'] as bool?) ??
          ((data['deductMissingCheckout'] as bool?) ??
              (data['deductAbsence'] as bool?) ??
              defaults.autoCreateViolations),
      missingCheckoutDeductionPercent:
          (data['missingCheckoutDeductionPercent'] as num?)?.toInt() ??
          defaults.missingCheckoutDeductionPercent,
      absenceDeductionPercent:
          (data['absenceDeductionPercent'] as num?)?.toInt() ??
          defaults.absenceDeductionPercent,
      lateDeductionPercent:
          (data['lateDeductionPercent'] as num?)?.toInt() ??
          defaults.lateDeductionPercent,
      earlyExitDeductionPercent:
          (data['earlyExitDeductionPercent'] as num?)?.toInt() ??
          defaults.earlyExitDeductionPercent,
      maxBreakMinutesPerDay:
          (data['maxBreakMinutesPerDay'] as num?)?.toInt() ??
          defaults.maxBreakMinutesPerDay,
      correctionRequestMaxDaysBack:
          (data['correctionRequestMaxDaysBack'] as num?)?.toInt() ??
          defaults.correctionRequestMaxDaysBack,
      missingCheckoutPenaltyMinutes:
          (data['missingCheckoutPenaltyMinutes'] as num?)?.toInt() ??
          defaults.missingCheckoutPenaltyMinutes,
      standardShiftStart: data['standardShiftStart']?.toString(),
      standardShiftEnd: data['standardShiftEnd']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      updatedBy: data['updatedBy']?.toString(),
    );
  }

  /// Writes new canonical keys *and* every legacy key so older client builds
  /// (employee punch pipeline) keep reading the same data.
  Map<String, dynamic> toFirestoreMergeMap() {
    final radiusDouble = allowedRadiusMeters.toDouble();
    return {
      // Canonical (new) keys
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'allowedRadiusMeters': allowedRadiusMeters,
      'locationRequired': locationRequired,
      'attendanceRequired': attendanceRequired,
      'punchInRequired': punchInRequired,
      'punchOutRequired': punchOutRequired,
      'breaksEnabled': breaksEnabled,
      'maxPunchesPerDay': 2,
      'maxBreaksPerDay': maxBreaksPerDay,
      'lateGraceMinutes': lateGraceMinutes,
      'earlyExitGraceMinutes': earlyExitGraceMinutes,
      'minimumShiftMinutes': minimumShiftMinutes,
      'maximumShiftMinutes': maximumShiftMinutes,
      'correctionRequestsEnabled': correctionRequestsEnabled,
      'requireCorrectionReason': requireCorrectionReason,
      'requireOwnerApprovalForCorrection': requireOwnerApprovalForCorrection,
      'maxCorrectionRequestsPerMonth': maxCorrectionRequestsPerMonth,
      'allowedLateCountPerMonth': allowedLateCountPerMonth,
      'allowedEarlyExitCountPerMonth': allowedEarlyExitCountPerMonth,
      'allowedMissingCheckoutCountPerMonth':
          allowedMissingCheckoutCountPerMonth,
      'autoCreateViolations': autoCreateViolations,
      'missingCheckoutDeductionPercent': missingCheckoutDeductionPercent,
      'absenceDeductionPercent': absenceDeductionPercent,
      'lateDeductionPercent': lateDeductionPercent,
      'earlyExitDeductionPercent': earlyExitDeductionPercent,
      'maxBreakMinutesPerDay': maxBreakMinutesPerDay,
      'correctionRequestMaxDaysBack': correctionRequestMaxDaysBack,
      'missingCheckoutPenaltyMinutes': missingCheckoutPenaltyMinutes,
      'standardShiftStart': standardShiftStart,
      'standardShiftEnd': standardShiftEnd,

      // Legacy mirrors so older client builds (employee punch pipeline,
      // analytics, server functions) keep working during rollout.
      'salonLatitude': latitude,
      'salonLongitude': longitude,
      'salonAddress': address,
      'enabled': attendanceRequired,
      'attendanceEnabled': attendanceRequired,
      'gpsRequired': locationRequired,
      'requireInsideZoneForPunchIn': locationRequired && punchInRequired,
      'requireInsideZoneForPunchOut': locationRequired && punchOutRequired,
      'allowBreaks': breaksEnabled,
      'maxBreakCyclesPerDay': maxBreaksPerDay,
      'graceLateMinutes': lateGraceMinutes,
      'graceEarlyExitMinutes': earlyExitGraceMinutes,
      'minWorkingMinutesPerDay': minimumShiftMinutes,
      'maxWorkingMinutesPerDay': maximumShiftMinutes,
      'monthlyLateAllowanceAfterGrace': allowedLateCountPerMonth,
      'monthlyEarlyExitAllowanceAfterGrace': allowedEarlyExitCountPerMonth,
      'allowEmployeeCorrectionRequests': correctionRequestsEnabled,
      'allowCorrectionRequests': correctionRequestsEnabled,
      'requireReasonForCorrection': requireCorrectionReason,
      'deductMissingCheckout':
          autoCreateViolations && missingCheckoutDeductionPercent > 0,
      'deductAbsence': autoCreateViolations && absenceDeductionPercent > 0,
      'deductLateAfterAllowance':
          autoCreateViolations && lateDeductionPercent > 0,
      'deductEarlyExitAfterAllowance':
          autoCreateViolations && earlyExitDeductionPercent > 0,
      'zone': {
        'latitude': latitude ?? 0,
        'longitude': longitude ?? 0,
        'radiusMeters': radiusDouble,
        'address': address ?? '',
      },
    };
  }

  AttendanceSettingsModel copyWith({
    double? latitude,
    bool clearLatitude = false,
    double? longitude,
    bool clearLongitude = false,
    String? address,
    bool clearAddress = false,
    int? allowedRadiusMeters,
    bool? locationRequired,
    bool? attendanceRequired,
    bool? punchInRequired,
    bool? punchOutRequired,
    bool? breaksEnabled,
    int? maxPunchesPerDay,
    int? maxBreaksPerDay,
    int? lateGraceMinutes,
    int? earlyExitGraceMinutes,
    int? minimumShiftMinutes,
    int? maximumShiftMinutes,
    bool? correctionRequestsEnabled,
    bool? requireCorrectionReason,
    bool? requireOwnerApprovalForCorrection,
    int? maxCorrectionRequestsPerMonth,
    int? allowedLateCountPerMonth,
    int? allowedEarlyExitCountPerMonth,
    int? allowedMissingCheckoutCountPerMonth,
    bool? autoCreateViolations,
    int? missingCheckoutDeductionPercent,
    int? absenceDeductionPercent,
    int? lateDeductionPercent,
    int? earlyExitDeductionPercent,
    int? maxBreakMinutesPerDay,
    int? correctionRequestMaxDaysBack,
    int? missingCheckoutPenaltyMinutes,
    String? standardShiftStart,
    bool clearStandardShiftStart = false,
    String? standardShiftEnd,
    bool clearStandardShiftEnd = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return AttendanceSettingsModel(
      salonId: salonId,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
      address: clearAddress ? null : (address ?? this.address),
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
      locationRequired: locationRequired ?? this.locationRequired,
      attendanceRequired: attendanceRequired ?? this.attendanceRequired,
      punchInRequired: punchInRequired ?? this.punchInRequired,
      punchOutRequired: punchOutRequired ?? this.punchOutRequired,
      breaksEnabled: breaksEnabled ?? this.breaksEnabled,
      maxPunchesPerDay: maxPunchesPerDay ?? this.maxPunchesPerDay,
      maxBreaksPerDay: maxBreaksPerDay ?? this.maxBreaksPerDay,
      lateGraceMinutes: lateGraceMinutes ?? this.lateGraceMinutes,
      earlyExitGraceMinutes:
          earlyExitGraceMinutes ?? this.earlyExitGraceMinutes,
      minimumShiftMinutes: minimumShiftMinutes ?? this.minimumShiftMinutes,
      maximumShiftMinutes: maximumShiftMinutes ?? this.maximumShiftMinutes,
      correctionRequestsEnabled:
          correctionRequestsEnabled ?? this.correctionRequestsEnabled,
      requireCorrectionReason:
          requireCorrectionReason ?? this.requireCorrectionReason,
      requireOwnerApprovalForCorrection:
          requireOwnerApprovalForCorrection ??
          this.requireOwnerApprovalForCorrection,
      maxCorrectionRequestsPerMonth:
          maxCorrectionRequestsPerMonth ?? this.maxCorrectionRequestsPerMonth,
      allowedLateCountPerMonth:
          allowedLateCountPerMonth ?? this.allowedLateCountPerMonth,
      allowedEarlyExitCountPerMonth:
          allowedEarlyExitCountPerMonth ?? this.allowedEarlyExitCountPerMonth,
      allowedMissingCheckoutCountPerMonth:
          allowedMissingCheckoutCountPerMonth ??
          this.allowedMissingCheckoutCountPerMonth,
      autoCreateViolations: autoCreateViolations ?? this.autoCreateViolations,
      missingCheckoutDeductionPercent:
          missingCheckoutDeductionPercent ??
          this.missingCheckoutDeductionPercent,
      absenceDeductionPercent:
          absenceDeductionPercent ?? this.absenceDeductionPercent,
      lateDeductionPercent: lateDeductionPercent ?? this.lateDeductionPercent,
      earlyExitDeductionPercent:
          earlyExitDeductionPercent ?? this.earlyExitDeductionPercent,
      maxBreakMinutesPerDay:
          maxBreakMinutesPerDay ?? this.maxBreakMinutesPerDay,
      correctionRequestMaxDaysBack:
          correctionRequestMaxDaysBack ?? this.correctionRequestMaxDaysBack,
      missingCheckoutPenaltyMinutes:
          missingCheckoutPenaltyMinutes ??
          this.missingCheckoutPenaltyMinutes,
      standardShiftStart: clearStandardShiftStart
          ? null
          : (standardShiftStart ?? this.standardShiftStart),
      standardShiftEnd: clearStandardShiftEnd
          ? null
          : (standardShiftEnd ?? this.standardShiftEnd),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
