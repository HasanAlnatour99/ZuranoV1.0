import 'package:barber_shop_app/core/constants/app_routes.dart';
import 'package:barber_shop_app/features/permissions/data/models/permission_key.dart';
import 'package:barber_shop_app/features/permissions/data/models/staff_permission_model.dart';
import 'package:barber_shop_app/features/permissions/data/permissions_repository.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:barber_shop_app/router/salon_route_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('requiredPermissionForOwnerRoute', () {
    test('maps analytics routes', () {
      expect(
        requiredPermissionForOwnerRoute(AppRoutes.ownerAnalytics),
        PermissionKey.analyticsView,
      );
      expect(
        requiredPermissionForOwnerRoute(AppRoutes.ownerDashboardV2),
        PermissionKey.analyticsView,
      );
    });

    test('allows overview shell without extra permission', () {
      expect(requiredPermissionForOwnerRoute(AppRoutes.ownerOverview), isNull);
    });

    test('maps payroll subtree', () {
      expect(
        requiredPermissionForOwnerRoute(AppRoutes.ownerPayroll),
        PermissionKey.payrollView,
      );
      expect(
        requiredPermissionForOwnerRoute(
          '${AppRoutes.payrollPayslipBase}/x/y',
        ),
        PermissionKey.payrollView,
      );
    });
  });

  group('PermissionsRepository.resolvePermission', () {
    test('owner profile always allowed', () {
      final user = _user(role: 'owner');
      expect(
        PermissionsRepository.resolvePermission(
          user: user,
          staff: null,
          permissionFirestoreKey: PermissionKey.payrollView.firestoreKey,
        ),
        isTrue,
      );
    });

    test('inactive staff denied', () {
      final user = _user(role: 'admin');
      final staff = _staff(isActive: false, permissions: {
        PermissionKey.payrollView.firestoreKey: true,
      });
      expect(
        PermissionsRepository.resolvePermission(
          user: user,
          staff: staff,
          permissionFirestoreKey: PermissionKey.payrollView.firestoreKey,
        ),
        isFalse,
      );
    });

    test('respects permission map', () {
      final user = _user(role: 'admin');
      final staff = _staff(isActive: true, permissions: {
        PermissionKey.payrollView.firestoreKey: false,
      });
      expect(
        PermissionsRepository.resolvePermission(
          user: user,
          staff: staff,
          permissionFirestoreKey: PermissionKey.payrollView.firestoreKey,
        ),
        isFalse,
      );
    });
  });
}

AppUser _user({required String role}) {
  return AppUser(
    uid: 'u1',
    email: 'a@b.c',
    name: 'Test',
    role: role,
  );
}

StaffPermissionModel _staff({
  required bool isActive,
  required Map<String, bool> permissions,
}) {
  return StaffPermissionModel(
    uid: 'u1',
    salonId: 's1',
    displayName: 'T',
    email: 'a@b.c',
    phone: null,
    role: 'admin',
    roleId: 'custom',
    permissions: permissions,
    isActive: isActive,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    invitedBy: null,
  );
}
