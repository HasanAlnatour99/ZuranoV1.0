import '../../../core/constants/notification_event_types.dart';
import 'enums/notification_type.dart';

/// Maps Firestore `type` / [NotificationEventTypes] strings to UI [NotificationType].
NotificationType notificationCategoryForStoredType(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return NotificationType.general;
  }
  final v = raw.trim();

  switch (v) {
    case 'booking':
    case 'booking_confirmed':
    case 'booking_reminder':
    case 'new_booking_assigned':
    case 'booking_cancelled':
    case 'booking_rescheduled':
    case 'booking_completed':
    case 'no_show_recorded':
      return NotificationType.booking;
    case 'attendance':
    case NotificationEventTypes.attendanceCheckIn:
    case NotificationEventTypes.attendanceCheckOut:
    case NotificationEventTypes.attendanceLate:
    case NotificationEventTypes.attendanceMissingCheckout:
    case NotificationEventTypes.attendanceCorrectionRequested:
    case NotificationEventTypes.attendanceCorrectionApproved:
    case NotificationEventTypes.attendanceCorrectionRejected:
      return NotificationType.attendance;
    case 'payroll':
    case 'payroll_generated':
    case NotificationEventTypes.payrollReady:
    case NotificationEventTypes.payslipReady:
    case NotificationEventTypes.bonusAdded:
    case NotificationEventTypes.deductionAdded:
    case NotificationEventTypes.salaryPaid:
      return NotificationType.payroll;
    case 'sales':
    case NotificationEventTypes.saleRecorded:
    case NotificationEventTypes.serviceCreated:
    case NotificationEventTypes.serviceUpdated:
    case NotificationEventTypes.serviceDeleted:
      return NotificationType.sales;
    case 'system':
    case NotificationEventTypes.dailySummary:
    case NotificationEventTypes.monthlySummary:
    case NotificationEventTypes.expenseAdded:
      return NotificationType.system;
    case 'approval':
      return NotificationType.approval;
    case 'violation':
    case 'violation_created':
      return NotificationType.violation;
    case NotificationEventTypes.employeeCreated:
    case NotificationEventTypes.employeeFrozen:
    case NotificationEventTypes.employeeReactivated:
    case NotificationEventTypes.permissionChanged:
    case NotificationEventTypes.commissionChanged:
      return NotificationType.general;
    default:
      if (v.startsWith('attendance')) return NotificationType.attendance;
      if (v.contains('payroll') || v.contains('payslip') || v.contains('salary')) {
        return NotificationType.payroll;
      }
      if (v.startsWith('service_')) return NotificationType.sales;
      if (v.contains('expense') || v.contains('summary')) {
        return NotificationType.system;
      }
      return NotificationType.general;
  }
}
