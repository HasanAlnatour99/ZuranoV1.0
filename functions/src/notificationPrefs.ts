import type { NotificationEventType, NotificationPrefs } from "./notificationTypes";

export const defaultNotificationPrefs = (): NotificationPrefs => ({
  pushEnabled: true,
  bookingReminders: true,
  bookingChanges: true,
  payrollAlerts: true,
  violationAlerts: true,
  marketingEnabled: false,
  attendanceAlerts: true,
  approvalAlerts: true,
  systemAlerts: true,
});

export function mergeNotificationPrefs(raw: unknown): NotificationPrefs {
  const d = defaultNotificationPrefs();
  if (!raw || typeof raw !== "object") {
    return d;
  }
  const m = raw as Record<string, unknown>;
  return {
    pushEnabled: typeof m.pushEnabled === "boolean" ? m.pushEnabled : d.pushEnabled,
    bookingReminders: typeof m.bookingReminders === "boolean"
      ? m.bookingReminders
      : d.bookingReminders,
    bookingChanges: typeof m.bookingChanges === "boolean"
      ? m.bookingChanges
      : d.bookingChanges,
    payrollAlerts: typeof m.payrollAlerts === "boolean"
      ? m.payrollAlerts
      : d.payrollAlerts,
    violationAlerts: typeof m.violationAlerts === "boolean"
      ? m.violationAlerts
      : d.violationAlerts,
    marketingEnabled: typeof m.marketingEnabled === "boolean"
      ? m.marketingEnabled
      : d.marketingEnabled,
    attendanceAlerts: typeof m.attendanceAlerts === "boolean"
      ? m.attendanceAlerts
      : d.attendanceAlerts,
    approvalAlerts: typeof m.approvalAlerts === "boolean"
      ? m.approvalAlerts
      : d.approvalAlerts,
    systemAlerts: typeof m.systemAlerts === "boolean" ? m.systemAlerts : d.systemAlerts,
  };
}

/**
 * Salon doc `salons/{salonId}/notificationSettings/{uid}` (Flutter keys) overrides
 * merged user prefs when each field is present as boolean.
 *
 * Mapping:
 * - `booking` → bookingChanges + bookingReminders (single toggle in UI)
 * - `attendance` → attendanceAlerts
 * - `payroll` → payrollAlerts
 * - `approvals` → approvalAlerts
 * - `system` → systemAlerts (services, expense/sale summaries, digest notifications)
 * - `pushEnabled` → pushEnabled
 */
export function applySalonNotificationSettings(
  base: NotificationPrefs,
  salonRaw: Record<string, unknown> | undefined,
): NotificationPrefs {
  if (!salonRaw || typeof salonRaw !== "object") {
    return base;
  }
  const out: NotificationPrefs = { ...base };
  if (typeof salonRaw.booking === "boolean") {
    out.bookingChanges = salonRaw.booking;
    out.bookingReminders = salonRaw.booking;
  }
  if (typeof salonRaw.attendance === "boolean") {
    out.attendanceAlerts = salonRaw.attendance;
  }
  if (typeof salonRaw.payroll === "boolean") {
    out.payrollAlerts = salonRaw.payroll;
  }
  if (typeof salonRaw.approvals === "boolean") {
    out.approvalAlerts = salonRaw.approvals;
  }
  if (typeof salonRaw.system === "boolean") {
    out.systemAlerts = salonRaw.system;
  }
  if (typeof salonRaw.pushEnabled === "boolean") {
    out.pushEnabled = salonRaw.pushEnabled;
  }
  return out;
}

/** Category gates (ignores pushEnabled — use for in-app and as part of push check). */
export function allowsCategoryForEvent(
  prefs: NotificationPrefs,
  eventType: NotificationEventType,
): boolean {
  switch (eventType) {
    case "booking_reminder":
      return prefs.bookingReminders;
    case "booking_cancelled":
    case "booking_rescheduled":
    case "booking_confirmed":
    case "new_booking_assigned":
    case "booking_completed":
      return prefs.bookingChanges;
    case "violation_created":
    case "no_show_recorded":
      return prefs.violationAlerts;
    case "payroll_generated":
    case "payroll_ready":
      return prefs.payrollAlerts;
    case "expense_added":
    case "sale_recorded":
    case "service_created":
    case "service_updated":
    case "service_deleted":
    case "daily_summary":
    case "monthly_summary":
      return prefs.systemAlerts;
    case "attendance_check_in":
    case "attendance_late":
      return prefs.attendanceAlerts;
    case "attendance_correction_requested":
      return prefs.approvalAlerts;
    case "employee_created":
    case "employee_reactivated":
    case "employee_frozen":
      return prefs.systemAlerts;
    default:
      return true;
  }
}

export function allowsPushForEvent(
  prefs: NotificationPrefs,
  eventType: NotificationEventType,
): boolean {
  return prefs.pushEnabled && allowsCategoryForEvent(prefs, eventType);
}
