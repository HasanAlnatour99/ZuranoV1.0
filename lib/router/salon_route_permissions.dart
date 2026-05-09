import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_routes.dart';
import '../core/constants/user_roles.dart';
import '../core/session/app_session_status.dart';
import '../features/permissions/application/permissions_providers.dart';
import '../features/permissions/data/models/permission_key.dart';
import '../features/permissions/data/permissions_repository.dart';
import '../providers/session_provider.dart';

/// When non-owner salon staff open owner-workspace URLs, require a matching
/// coarse permission (Firestore `salons/{salonId}/staff/{uid}.permissions`).
///
/// Returns `null` when navigation should proceed, or [AppRoutes.accessDenied].
bool _isActivityCenterPath(String location) {
  return location == AppRoutes.ownerActivityCenter ||
      location.startsWith('${AppRoutes.ownerActivityCenter}/');
}

bool _isReportsCenterPath(String location) {
  return location == AppRoutes.ownerReportsCenter ||
      location.startsWith('${AppRoutes.ownerReportsCenter}/');
}

bool _canAccessReportsCenter(Ref ref) {
  final session = ref.read(appSessionBootstrapProvider);
  if (session.status != AppSessionStatus.ready || session.user == null) {
    return false;
  }
  final user = session.user!;
  if (user.role.trim() == UserRoles.owner) return true;

  final staffAsync = ref.read(currentSalonStaffPermissionProvider);
  if (staffAsync.isLoading || staffAsync.isRefreshing) return false;
  final staff = staffAsync.asData?.value;

  const keys = <PermissionKey>[
    PermissionKey.salesView,
    PermissionKey.payrollView,
    PermissionKey.attendanceView,
    PermissionKey.expensesView,
    PermissionKey.permissionsManage,
    PermissionKey.settingsManage,
  ];
  for (final k in keys) {
    if (PermissionsRepository.resolvePermission(
          user: user,
          staff: staff,
          permissionFirestoreKey: k.firestoreKey,
        )) {
      return true;
    }
  }
  return false;
}

bool _canReadActivityAudit(Ref ref) {
  final session = ref.read(appSessionBootstrapProvider);
  if (session.status != AppSessionStatus.ready || session.user == null) {
    return false;
  }
  final user = session.user!;
  if (user.role.trim() == UserRoles.owner) return true;

  final staffAsync = ref.read(currentSalonStaffPermissionProvider);
  if (staffAsync.isLoading || staffAsync.isRefreshing) return false;
  final staff = staffAsync.asData?.value;

  const keys = <PermissionKey>[
    PermissionKey.analyticsView,
    PermissionKey.settingsManage,
    PermissionKey.permissionsManage,
  ];
  for (final k in keys) {
    if (PermissionsRepository.resolvePermission(
          user: user,
          staff: staff,
          permissionFirestoreKey: k.firestoreKey,
        )) {
      return true;
    }
  }
  return false;
}

String? salonRoutePermissionRedirect(Ref ref, String location) {
  if (location == AppRoutes.accessDenied) return null;

  final session = ref.read(appSessionBootstrapProvider);
  if (session.status != AppSessionStatus.ready || session.user == null) {
    return null;
  }
  final user = session.user!;
  final role = user.role.trim();
  if (role == UserRoles.owner) return null;

  if (_isActivityCenterPath(location)) {
    return _canReadActivityAudit(ref) ? null : AppRoutes.accessDenied;
  }

  if (_isReportsCenterPath(location)) {
    return _canAccessReportsCenter(ref) ? null : AppRoutes.accessDenied;
  }

  final required = requiredPermissionForOwnerRoute(location);
  if (required == null) return null;

  final staffAsync = ref.read(currentSalonStaffPermissionProvider);
  if (staffAsync.isLoading || staffAsync.isRefreshing) return null;

  final staff = staffAsync.asData?.value;
  final ok = PermissionsRepository.resolvePermission(
    user: user,
    staff: staff,
    permissionFirestoreKey: required.firestoreKey,
  );
  return ok ? null : AppRoutes.accessDenied;
}

/// Best-effort mapping from route path to the minimum permission needed.
PermissionKey? requiredPermissionForOwnerRoute(String location) {
  if (location == AppRoutes.ownerOverview ||
      location == AppRoutes.ownerDashboard ||
      location == AppRoutes.ownerBentoDashboard ||
      location == AppRoutes.ownerDashboardAssistant) {
    return null;
  }

  if (location == AppRoutes.ownerAnalytics ||
      location == AppRoutes.ownerDashboardV2) {
    return PermissionKey.analyticsView;
  }

  if (location == AppRoutes.ownerBookings ||
      location.startsWith('${AppRoutes.ownerBookings}/')) {
    return PermissionKey.bookingsView;
  }

  if (location == AppRoutes.bookingsNew) {
    return PermissionKey.bookingsManage;
  }

  if (location == AppRoutes.ownerMoney) {
    return PermissionKey.salesView;
  }

  if (location == AppRoutes.ownerSales ||
      location.startsWith('${AppRoutes.ownerSales}/') ||
      location == AppRoutes.ownerAddSale) {
    return PermissionKey.salesView;
  }

  if (location == AppRoutes.ownerExpenses ||
      location.startsWith('${AppRoutes.ownerExpenses}/')) {
    return PermissionKey.expensesView;
  }

  if (location == AppRoutes.ownerPayroll ||
      location.startsWith('${AppRoutes.ownerPayroll}/') ||
      location.startsWith('${AppRoutes.payrollPayslipBase}/')) {
    return PermissionKey.payrollView;
  }

  if (location == AppRoutes.customers ||
      location.startsWith('${AppRoutes.customers}/') ||
      location == AppRoutes.ownerCustomers ||
      location.startsWith('${AppRoutes.ownerCustomers}/')) {
    return PermissionKey.customersView;
  }

  if (location == AppRoutes.ownerTeam ||
      location == AppRoutes.ownerTeamStack ||
      location == AppRoutes.ownerAddTeamMember ||
      location == AppRoutes.ownerServices ||
      location.startsWith('${AppRoutes.ownerTeamMemberDetailsBase}/')) {
    return PermissionKey.teamView;
  }

  if (location == AppRoutes.attendanceRequestsReview ||
      location == AppRoutes.attendanceRequestsAdmin ||
      location == AppRoutes.salonAttendanceZoneSettings ||
      location == AppRoutes.ownerAttendanceSettings ||
      location.startsWith('${AppRoutes.ownerAttendanceSettings}/') ||
      location.startsWith(AppRoutes.ownerSettingsHrViolations)) {
    return PermissionKey.attendanceView;
  }

  if (location.startsWith(AppRoutes.ownerSettings)) {
    if (location.startsWith(AppRoutes.ownerStaffPermissions)) {
      return PermissionKey.permissionsManage;
    }
    return PermissionKey.settingsManage;
  }

  return null;
}
