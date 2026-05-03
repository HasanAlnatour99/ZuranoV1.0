import 'dart:convert';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/user_roles.dart';
import '../../users/data/models/app_user.dart';

Map<String, dynamic> stringifyDataMap(Map<String, dynamic> raw) {
  return raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
}

/// Decodes local notification tap payloads (JSON map or legacy path / keyword).
///
/// Supports JSON (`{"routeName":...}`) and legacy single-string paths or keywords.
Map<String, dynamic> decodeNotificationLaunchPayload(String? payload) {
  if (payload == null || payload.isEmpty) {
    return const <String, dynamic>{};
  }
  final trimmed = payload.trim();
  if (trimmed.startsWith('{')) {
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
    } catch (_) {
      // Fall through to legacy formats.
    }
  }
  if (trimmed.startsWith('/')) {
    return <String, dynamic>{'routeName': trimmed};
  }
  if (trimmed.isNotEmpty) {
    return <String, dynamic>{'route': trimmed};
  }
  return const <String, dynamic>{};
}

/// Maps FCM / local-notification `data` to [GoRouter] navigation.
///
/// Backend sends absolute paths in **`routeName`** (see Cloud Functions
/// `resolveSalonNotificationRoute`). **`route`** is a legacy keyword
/// (`booking`, `payroll`, …) kept for older payloads.
void navigateForNotificationPayload({
  required GoRouter router,
  required Map<String, dynamic> data,
  required AppUser? session,
}) {
  if (session == null) {
    return;
  }

  final role = session.role.trim();

  final routeName = _trim(data['routeName']);
  if (routeName.isNotEmpty) {
    final path = _refinePathFromData(routeName, data);
    if (!_allowsPathForRole(path, role)) {
      return;
    }
    router.go(path);
    return;
  }

  final legacy = _trim(data['route']);
  if (legacy.isEmpty) {
    return;
  }

  final path = _pathFromLegacyRouteKeyword(legacy, data, role);
  if (path == null || path.isEmpty) {
    return;
  }
  if (!_allowsPathForRole(path, role)) {
    return;
  }
  router.go(path);
}

String _trim(Object? v) => v?.toString().trim() ?? '';

/// Prefer detail URLs when [routeName] matches a list route and ids are present.
String _refinePathFromData(String routeName, Map<String, dynamic> data) {
  if (routeName == AppRoutes.ownerSales) {
    final saleId = _saleIdFromData(data);
    if (saleId.isNotEmpty) {
      return AppRoutes.ownerSaleDetails(saleId);
    }
  }
  if (routeName.startsWith('/bookings/')) {
    final rest = routeName.substring('/bookings/'.length).trim();
    if (rest.isNotEmpty && !rest.contains('/')) {
      // No registered `/bookings/:id` owner screen — match prior MVP behavior.
      return AppRoutes.ownerOverview;
    }
  }
  return routeName;
}

String _saleIdFromData(Map<String, dynamic> data) {
  final entityType = _trim(data['entityType']);
  final fromEntity =
      entityType == 'sale' ? _trim(data['entityId']) : '';
  if (fromEntity.isNotEmpty) {
    return fromEntity;
  }
  return _trim(data['saleId']);
}

String? _pathFromLegacyRouteKeyword(
  String legacy,
  Map<String, dynamic> data,
  String role,
) {
  final salonId = _trim(data['salonId']);
  final bookingId = _trim(data['bookingId']);
  final eventType = _trim(data['type']);

  switch (legacy) {
    case 'booking':
      if (role == UserRoles.customer &&
          salonId.isNotEmpty &&
          bookingId.isNotEmpty) {
        return AppRoutes.customerBookingDetailsPath(salonId, bookingId);
      }
      if (bookingId.isNotEmpty) {
        return AppRoutes.ownerOverview;
      }
      return null;
    case 'payroll':
      if (eventType == 'payroll_ready') {
        return AppRoutes.employeePayroll;
      }
      if (eventType == 'payroll_generated') {
        return AppRoutes.ownerPayroll;
      }
      if (UserRoles.isStaffRole(role)) {
        return AppRoutes.employeePayroll;
      }
      return AppRoutes.ownerPayroll;
    case 'violation':
      if (UserRoles.isStaffRole(role)) {
        return AppRoutes.employeeToday;
      }
      return AppRoutes.ownerSettingsHrViolations;
    case 'expense':
      return AppRoutes.ownerExpenses;
    case 'sale':
      return AppRoutes.ownerSales;
    case 'service':
      return AppRoutes.ownerServices;
    case 'employee':
      return AppRoutes.ownerTeam;
    case 'summary':
      return AppRoutes.ownerOverview;
    case 'attendance':
      if (UserRoles.isStaffRole(role)) {
        return AppRoutes.employeeToday;
      }
      return AppRoutes.ownerOverview;
    case 'approval':
      return AppRoutes.attendanceRequestsReview;
    default:
      return null;
  }
}

bool _allowsPathForRole(String path, String role) {
  final p = path.trim();
  if (p.isEmpty) {
    return false;
  }

  if (p.startsWith('/customer/') || p == AppRoutes.customerHome) {
    return role == UserRoles.customer;
  }

  if (p.startsWith('/employee/')) {
    return UserRoles.isStaffRole(role);
  }

  final ownerLike = role == UserRoles.owner || role == UserRoles.admin;
  if (ownerLike) {
    if (p.startsWith('/owner') ||
        p.startsWith('/bookings') ||
        p == AppRoutes.ownerOverview ||
        p == AppRoutes.attendanceRequestsReview ||
        p.startsWith('/owner-')) {
      return true;
    }
    return false;
  }

  return false;
}
