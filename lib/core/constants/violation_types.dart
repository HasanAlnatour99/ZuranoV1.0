abstract final class ViolationTypes {
  static const barberLate = 'barber_late';
  static const barberNoShow = 'barber_no_show';

  /// Break session exceeded [AttendanceSettingsModel.maxBreakMinutesPerDay]
  /// allowance for that session (see employee break return flow).
  static const exceededBreakTime = 'EXCEEDED_BREAK_TIME';
}

abstract final class ViolationStatuses {
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const applied = 'applied';
}

abstract final class ViolationSourceTypes {
  static const booking = 'booking';

  /// System / employee attendance punch pipeline (break return).
  static const attendanceBreak = 'ATTENDANCE_BREAK';
}
