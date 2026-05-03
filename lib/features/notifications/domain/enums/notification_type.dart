enum NotificationType {
  booking,
  attendance,
  payroll,
  sales,
  system,
  approval,
  violation,
  general;

  static NotificationType fromValue(String? value) {
    switch (value) {
      case 'booking':
        return NotificationType.booking;
      case 'attendance':
        return NotificationType.attendance;
      case 'payroll':
        return NotificationType.payroll;
      case 'sales':
        return NotificationType.sales;
      case 'system':
        return NotificationType.system;
      case 'approval':
        return NotificationType.approval;
      case 'violation':
        return NotificationType.violation;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  String get value {
    return name;
  }
}
