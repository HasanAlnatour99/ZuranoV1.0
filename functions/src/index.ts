import { getApps, initializeApp } from "firebase-admin/app";

if (!getApps().length) {
  initializeApp();
}

export { bookingCancel, bookingCreate, bookingReschedule } from "./bookingCallables";
export { getCustomerAvailability } from "./customer/getCustomerAvailability";
export { createCustomerBooking } from "./customer/createCustomerBooking";
export { lookupCustomerBookings } from "./customer/lookupCustomerBookings";
export { getCustomerBookingDetails } from "./customer/getCustomerBookingDetails";
export { cancelCustomerBooking } from "./customer/cancelCustomerBooking";
export { rescheduleCustomerBooking } from "./customer/rescheduleCustomerBooking";
export { submitCustomerFeedback } from "./customer/submitCustomerFeedback";
export {
  backfillPublicTeamForSalon,
  onEmployeeWriteSyncPublicTeamMember,
} from "./publicTeamMirror";
export {
  backfillPublicServicesForSalon,
  onServiceWriteSyncPublicService,
} from "./publicServiceMirror";
export {
  onSalonWriteSyncPublicSalon,
} from "./publicSalonMirror";
export {
  bookingCompleteService,
  bookingMarkArrived,
  bookingMarkNoShow,
  bookingStartService,
  updateBookingStatus,
  completeBookingAndCreateSale,
  violationReview,
} from "./bookingOperationsCallables";
export { bookingDayBusyMask } from "./bookingDayBusyMask";
export { refreshBarberMetricsHourly } from "./barberMetricsScheduled";
export { refreshWeeklyInsights } from "./weeklyInsightsScheduled";
export {
  registerDeviceToken,
  unregisterDeviceToken,
  updateNotificationPreferences,
} from "./notificationCallables";
export {
  onBookingUpdatedNotification,
  onExpenseCreatedNotification,
  onPayrollCreatedNotification,
  onSaleRecordedOwnerNotification,
  onViolationCreatedNotification,
} from "./notificationFirestoreTriggers";
export {
  onAttendanceCorrectionRequestCreatedNotification,
  onAttendanceRecordUpdatedNotification,
  onSalonEmployeeWrittenNotification,
  onSalonServiceWrittenNotification,
} from "./notificationExtendedFirestoreTriggers";
export {
  onAttendanceCorrectionRequestUpdatedEmployeeInbox,
  onAttendanceRequestUpdatedEmployeeInbox,
} from "./employeeNotificationTriggers";
export { sendDailyOwnerSummaries, sendMonthlyOwnerSummaries } from "./notificationSummaryScheduler";
export { sendUpcomingBookingReminders } from "./notificationScheduler";
export { salonStaffCreateWithAuth } from "./staffProvisioningCallables";
export { resolveStaffLoginEmail } from "./staffLoginCallables";
export { generateAttendancePolicyReadable } from "./attendancePolicyCallable";
export { reprocessAttendanceForEmployeeDate } from "./attendance/reprocessAttendance";
export {
  approvePayslip,
  generateMonthlyPayroll,
  generatePayslipSummary,
  markPayslipPaid,
} from "./payrollCallables";
export {
  approveAttendanceViolation,
  calculateAttendanceViolationsForPeriod,
  postAttendanceViolationsToPayroll,
  waiveAttendanceViolation,
} from "./attendance/attendancePayrollDeductionsCallables";
export {
  applyAbsenceViolationsForEndedShifts,
  onAttendanceDayViolationAutomation,
} from "./attendanceViolationAutomation";

export {
  createSalonInAppNotification,
} from "./notifications/salonInAppNotificationService";

export {
  generateMonthlyAnalytics,
} from "./analytics/analyticsCallables";

export {
  generateOwnerDashboardSnapshot,
} from "./dashboard/dashboardCallables";

export {
  assignRolePresetToStaff,
  bootstrapSalonStaffForOwner,
  createRolePreset,
  provisionSalonStaffMember,
  setStaffActiveStatus,
  syncUserClaimsForStaff,
  updateRolePreset,
  updateStaffPermissions,
} from "./permissions/permissionsCallables";

export {
  syncSalonSearchIndex,
  syncServiceSearchIndex,
  syncEmployeeSearchIndex,
} from "./customerSearchIndex";

export {
  auditSalonExpenseWrite,
  auditSalonSettingsWrite,
} from "./audit/salonAuditTriggers";

export {
  requestReportExport,
  generatePayslipPdf,
  getExportDownloadUrl,
} from "./reports/reportCallables";
