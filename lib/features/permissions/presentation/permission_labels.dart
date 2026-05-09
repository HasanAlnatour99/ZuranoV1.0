import '../../../l10n/app_localizations.dart';
import '../data/models/permission_key.dart';

String permissionGroupLabel(AppLocalizations l10n, String l10nGroupKey) {
  switch (l10nGroupKey) {
    case 'permissionGroupBookings':
      return l10n.permissionGroupBookings;
    case 'permissionGroupSales':
      return l10n.permissionGroupSales;
    case 'permissionGroupCustomers':
      return l10n.permissionGroupCustomers;
    case 'permissionGroupTeam':
      return l10n.permissionGroupTeam;
    case 'permissionGroupAttendance':
      return l10n.permissionGroupAttendance;
    case 'permissionGroupPayroll':
      return l10n.permissionGroupPayroll;
    case 'permissionGroupExpenses':
      return l10n.permissionGroupExpenses;
    case 'permissionGroupAnalytics':
      return l10n.permissionGroupAnalytics;
    case 'permissionGroupSettings':
      return l10n.permissionGroupSettings;
    case 'permissionGroupPermissions':
      return l10n.permissionGroupPermissions;
    default:
      return l10n.permissionGroupSettings;
  }
}

String permissionTitle(AppLocalizations l10n, PermissionKey key) {
  switch (key) {
    case PermissionKey.bookingsView:
      return l10n.permissionBookingsViewTitle;
    case PermissionKey.bookingsManage:
      return l10n.permissionBookingsManageTitle;
    case PermissionKey.salesView:
      return l10n.permissionSalesViewTitle;
    case PermissionKey.salesManage:
      return l10n.permissionSalesManageTitle;
    case PermissionKey.customersView:
      return l10n.permissionCustomersViewTitle;
    case PermissionKey.customersManage:
      return l10n.permissionCustomersManageTitle;
    case PermissionKey.teamView:
      return l10n.permissionTeamViewTitle;
    case PermissionKey.teamManage:
      return l10n.permissionTeamManageTitle;
    case PermissionKey.attendanceView:
      return l10n.permissionAttendanceViewTitle;
    case PermissionKey.attendanceManage:
      return l10n.permissionAttendanceManageTitle;
    case PermissionKey.payrollView:
      return l10n.permissionPayrollViewTitle;
    case PermissionKey.payrollManage:
      return l10n.permissionPayrollManageTitle;
    case PermissionKey.expensesView:
      return l10n.permissionExpensesViewTitle;
    case PermissionKey.expensesManage:
      return l10n.permissionExpensesManageTitle;
    case PermissionKey.analyticsView:
      return l10n.permissionAnalyticsViewTitle;
    case PermissionKey.settingsManage:
      return l10n.permissionSettingsManageTitle;
    case PermissionKey.permissionsManage:
      return l10n.permissionPermissionsManageTitle;
  }
}

String permissionDescription(AppLocalizations l10n, PermissionKey key) {
  switch (key) {
    case PermissionKey.bookingsView:
      return l10n.permissionBookingsViewDescription;
    case PermissionKey.bookingsManage:
      return l10n.permissionBookingsManageDescription;
    case PermissionKey.salesView:
      return l10n.permissionSalesViewDescription;
    case PermissionKey.salesManage:
      return l10n.permissionSalesManageDescription;
    case PermissionKey.customersView:
      return l10n.permissionCustomersViewDescription;
    case PermissionKey.customersManage:
      return l10n.permissionCustomersManageDescription;
    case PermissionKey.teamView:
      return l10n.permissionTeamViewDescription;
    case PermissionKey.teamManage:
      return l10n.permissionTeamManageDescription;
    case PermissionKey.attendanceView:
      return l10n.permissionAttendanceViewDescription;
    case PermissionKey.attendanceManage:
      return l10n.permissionAttendanceManageDescription;
    case PermissionKey.payrollView:
      return l10n.permissionPayrollViewDescription;
    case PermissionKey.payrollManage:
      return l10n.permissionPayrollManageDescription;
    case PermissionKey.expensesView:
      return l10n.permissionExpensesViewDescription;
    case PermissionKey.expensesManage:
      return l10n.permissionExpensesManageDescription;
    case PermissionKey.analyticsView:
      return l10n.permissionAnalyticsViewDescription;
    case PermissionKey.settingsManage:
      return l10n.permissionSettingsManageDescription;
    case PermissionKey.permissionsManage:
      return l10n.permissionPermissionsManageDescription;
  }
}
