enum NotificationRoleScope { customer, employee, ownerAdmin }

enum NotificationTargetRole {
  owner,
  admin,
  ownerAdmin,
  employee,
  customer,
  all;

  static NotificationTargetRole fromValue(String? value) {
    switch (value) {
      case 'owner':
        return NotificationTargetRole.owner;
      case 'admin':
        return NotificationTargetRole.admin;
      case 'owner_admin':
        return NotificationTargetRole.ownerAdmin;
      case 'employee':
        return NotificationTargetRole.employee;
      case 'customer':
        return NotificationTargetRole.customer;
      case 'all':
      default:
        return NotificationTargetRole.all;
    }
  }

  String get value {
    switch (this) {
      case NotificationTargetRole.owner:
        return 'owner';
      case NotificationTargetRole.admin:
        return 'admin';
      case NotificationTargetRole.ownerAdmin:
        return 'owner_admin';
      case NotificationTargetRole.employee:
        return 'employee';
      case NotificationTargetRole.customer:
        return 'customer';
      case NotificationTargetRole.all:
        return 'all';
    }
  }
}
