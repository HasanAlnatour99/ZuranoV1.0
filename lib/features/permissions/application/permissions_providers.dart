import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/permission_key.dart';
import '../data/models/role_preset_model.dart';
import '../data/models/staff_permission_model.dart';
import '../data/permissions_repository.dart';

final currentSalonStaffPermissionProvider =
    StreamProvider.autoDispose<StaffPermissionModel?>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  final uid = user?.uid ?? '';
  if (salonId.isEmpty || uid.isEmpty) {
    return Stream.value(null);
  }
  return ref.read(permissionsRepositoryProvider).watchStaffPermission(
        salonId,
        uid,
      );
});

/// Staff permission row for any salon member (owner UI).
final staffPermissionForUidProvider =
    StreamProvider.family.autoDispose<StaffPermissionModel?, String>((ref, uid) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  final id = uid.trim();
  if (salonId.isEmpty || id.isEmpty) {
    return Stream.value(null);
  }
  return ref.read(permissionsRepositoryProvider).watchStaffPermission(
        salonId,
        id,
      );
});

final staffPermissionsListProvider =
    StreamProvider.autoDispose<List<StaffPermissionModel>>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(const []);
  return ref.read(permissionsRepositoryProvider).watchStaffPermissions(salonId);
});

final rolePresetsProvider =
    StreamProvider.autoDispose<List<RolePresetModel>>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) return Stream.value(const []);
  return ref.read(permissionsRepositoryProvider).watchRolePresets(salonId);
});

/// Whether the current user has [permission] for the active salon (UI gate).
final hasSalonPermissionProvider =
    Provider.family<bool, PermissionKey>((ref, permission) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final staffAsync = ref.watch(currentSalonStaffPermissionProvider);
  final staff = staffAsync.asData?.value;
  return PermissionsRepository.resolvePermission(
    user: user,
    staff: staff,
    permissionFirestoreKey: permission.firestoreKey,
  );
});
