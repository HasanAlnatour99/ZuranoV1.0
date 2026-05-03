import { initializeApp } from "firebase-admin/app";

initializeApp();

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
  bookingCompleteService,
  bookingMarkArrived,
  bookingMarkNoShow,
  bookingStartService,
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
  applyAbsenceViolationsForEndedShifts,
  onAttendanceDayViolationAutomation,
} from "./attendanceViolationAutomation";

export {
  createSalonInAppNotification,
} from "./notifications/salonInAppNotificationService";
