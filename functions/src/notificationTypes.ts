/** Aligns with Flutter / Firestore `users/{uid}/notifications` and FCM data payloads. */
export type NotificationEventType =
  | "booking_confirmed"
  | "booking_reminder"
  | "booking_cancelled"
  | "booking_rescheduled"
  | "booking_completed"
  | "new_booking_assigned"
  | "violation_created"
  | "no_show_recorded"
  | "payroll_generated"
  | "payroll_ready"
  | "expense_added"
  | "sale_recorded"
  | "attendance_check_in"
  | "attendance_late"
  | "attendance_correction_requested"
  | "service_created"
  | "service_updated"
  | "service_deleted"
  | "employee_created"
  | "employee_reactivated"
  | "employee_frozen"
  | "daily_summary"
  | "monthly_summary";

export type NotificationChannel = "push" | "in_app";

export type ActorRole =
  | "customer"
  | "barber"
  | "owner"
  | "admin"
  | "system";

export type NotificationPrefs = {
  pushEnabled: boolean;
  bookingReminders: boolean;
  bookingChanges: boolean;
  payrollAlerts: boolean;
  violationAlerts: boolean;
  marketingEnabled: boolean;
  /** Salon toggle `attendance` → merged from `salons/.../notificationSettings/{uid}`. */
  attendanceAlerts: boolean;
  /** Salon toggle `approvals` (corrections, approvals). */
  approvalAlerts: boolean;
  /** Salon toggle `system` (expenses, sales, services, summaries). */
  systemAlerts: boolean;
};

export type SendNotificationInput = {
  userId: string;
  eventType: NotificationEventType;
  dedupeKey: string;
  title: string;
  body: string;
  data: Record<string, string>;
  actorRole: ActorRole;
  salonId?: string;
  bookingId?: string;
  employeeId?: string;
  payrollId?: string;
  violationId?: string;
  expenseId?: string;
  saleId?: string;
  /** `salons/{salonId}/attendance/{attendanceId}` document id. */
  attendanceId?: string;
  serviceId?: string;
};
