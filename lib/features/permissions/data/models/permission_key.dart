/// Fine-grained salon permission keys (Firestore map keys under `staff.permissions`).
///
/// Display strings come from ARB via [l10nKey].
enum PermissionKey {
  bookingsView('bookings.view', 'permissionGroupBookings'),
  bookingsManage('bookings.manage', 'permissionGroupBookings'),
  salesView('sales.view', 'permissionGroupSales'),
  salesManage('sales.manage', 'permissionGroupSales'),
  customersView('customers.view', 'permissionGroupCustomers'),
  customersManage('customers.manage', 'permissionGroupCustomers'),
  teamView('team.view', 'permissionGroupTeam'),
  teamManage('team.manage', 'permissionGroupTeam'),
  attendanceView('attendance.view', 'permissionGroupAttendance'),
  attendanceManage('attendance.manage', 'permissionGroupAttendance'),
  payrollView('payroll.view', 'permissionGroupPayroll'),
  payrollManage('payroll.manage', 'permissionGroupPayroll'),
  expensesView('expenses.view', 'permissionGroupExpenses'),
  expensesManage('expenses.manage', 'permissionGroupExpenses'),
  analyticsView('analytics.view', 'permissionGroupAnalytics'),
  settingsManage('settings.manage', 'permissionGroupSettings'),
  permissionsManage('permissions.manage', 'permissionGroupPermissions');

  const PermissionKey(this.firestoreKey, this.l10nGroupKey);

  /// Stored in Firestore `staff.permissions` map.
  final String firestoreKey;

  /// Key into ARB for the permission **group** heading (see app_en.arb).
  final String l10nGroupKey;

  static PermissionKey? parse(String? raw) {
    final k = raw?.trim() ?? '';
    if (k.isEmpty) return null;
    for (final e in PermissionKey.values) {
      if (e.firestoreKey == k) return e;
    }
    return null;
  }

  static Iterable<PermissionKey> get all => PermissionKey.values;
}
