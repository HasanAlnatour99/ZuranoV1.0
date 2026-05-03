/// Owner/admin adjustment flow status (maps to Firestore `status` values).
enum AdjustmentAttendanceStatus {
  present,
  late,
  absent,
  dayOff,
}

extension AdjustmentAttendanceStatusX on AdjustmentAttendanceStatus {
  String get apiValue => switch (this) {
    AdjustmentAttendanceStatus.present => 'present',
    AdjustmentAttendanceStatus.late => 'late',
    AdjustmentAttendanceStatus.absent => 'absent',
    AdjustmentAttendanceStatus.dayOff => 'dayOff',
  };
}

AdjustmentAttendanceStatus? adjustmentAttendanceStatusFromApi(String? raw) {
  final s = raw?.trim().toLowerCase() ?? '';
  switch (s) {
    case 'present':
    case 'manual':
    case 'incomplete':
      return AdjustmentAttendanceStatus.present;
    case 'late':
      return AdjustmentAttendanceStatus.late;
    case 'absent':
      return AdjustmentAttendanceStatus.absent;
    case 'dayoff':
    case 'day_off':
      return AdjustmentAttendanceStatus.dayOff;
    default:
      return null;
  }
}
