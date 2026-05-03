/// Canonical notification `type` / `eventType` strings (Cloud Functions + Firestore).
/// Maps to [NotificationType] for UI via [notificationCategoryForEventType].
abstract final class NotificationEventTypes {
  static const attendanceCheckIn = 'attendance_check_in';
  static const attendanceCheckOut = 'attendance_check_out';
  static const attendanceLate = 'attendance_late';
  static const attendanceMissingCheckout = 'attendance_missing_checkout';
  static const attendanceCorrectionRequested = 'attendance_correction_requested';
  static const attendanceCorrectionApproved = 'attendance_correction_approved';
  static const attendanceCorrectionRejected = 'attendance_correction_rejected';

  static const serviceCreated = 'service_created';
  static const serviceUpdated = 'service_updated';
  static const serviceDeleted = 'service_deleted';

  static const payrollReady = 'payroll_ready';
  static const payslipReady = 'payslip_ready';
  static const bonusAdded = 'bonus_added';
  static const deductionAdded = 'deduction_added';
  static const salaryPaid = 'salary_paid';

  static const employeeCreated = 'employee_created';
  static const employeeFrozen = 'employee_frozen';
  static const employeeReactivated = 'employee_reactivated';
  static const permissionChanged = 'permission_changed';
  static const commissionChanged = 'commission_changed';

  static const dailySummary = 'daily_summary';
  static const monthlySummary = 'monthly_summary';
  static const expenseAdded = 'expense_added';
  static const saleRecorded = 'sale_recorded';
}
