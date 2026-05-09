import 'package:barber_shop_app/core/constants/user_roles.dart';
import 'package:barber_shop_app/core/firebase/cloud_functions_region.dart';
import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/core/firestore/firestore_write_payload.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'models/role_preset_model.dart';
import 'models/staff_permission_model.dart';

class PermissionsRepository {
  PermissionsRepository({
    required FirebaseFirestore firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore,
       _functions = functions ?? appCloudFunctions();

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _staff(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonStaffCollection(salonId));
  }

  CollectionReference<Map<String, dynamic>> _roles(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonRolesCollection(salonId));
  }

  Stream<List<StaffPermissionModel>> watchStaffPermissions(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _staff(salonId).snapshots().map(
          (s) => s.docs.map(StaffPermissionModel.fromFirestore).toList(),
        );
  }

  Stream<StaffPermissionModel?> watchStaffPermission(String salonId, String uid) {
    FirestoreWritePayload.assertSalonId(salonId);
    final id = uid.trim();
    if (id.isEmpty) return Stream.value(null);
    return _staff(salonId).doc(id).snapshots().map((d) {
      if (!d.exists) return null;
      return StaffPermissionModel.fromFirestore(d);
    });
  }

  Stream<List<RolePresetModel>> watchRolePresets(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _roles(salonId).snapshots().map(
          (s) => s.docs.map(RolePresetModel.fromFirestore).toList(),
        );
  }

  Future<void> bootstrapSalonStaffForOwner(String salonId) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('bootstrapSalonStaffForOwner');
    await callable.call({'salonId': salonId});
  }

  Future<void> updateStaffPermissions({
    required String salonId,
    required String targetUid,
    required Map<String, bool> permissions,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('updateStaffPermissions');
    await callable.call({
      'salonId': salonId,
      'targetUid': targetUid,
      'permissions': permissions,
    });
  }

  Future<void> assignRolePresetToStaff({
    required String salonId,
    required String targetUid,
    required String roleId,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('assignRolePresetToStaff');
    await callable.call({
      'salonId': salonId,
      'targetUid': targetUid,
      'roleId': roleId,
    });
  }

  Future<void> createRolePreset({
    required String salonId,
    required String name,
    required String description,
    required Map<String, bool> permissions,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('createRolePreset');
    await callable.call({
      'salonId': salonId,
      'name': name,
      'description': description,
      'permissions': permissions,
    });
  }

  Future<void> updateRolePreset({
    required String salonId,
    required String roleId,
    required Map<String, bool> permissions,
    String? name,
    String? description,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('updateRolePreset');
    final payload = <String, dynamic>{
      'salonId': salonId,
      'roleId': roleId,
      'permissions': permissions,
    };
    if (name != null) payload['name'] = name;
    if (description != null) payload['description'] = description;
    await callable.call(payload);
  }

  Future<void> setStaffActiveStatus({
    required String salonId,
    required String targetUid,
    required bool isActive,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('setStaffActiveStatus');
    await callable.call({
      'salonId': salonId,
      'targetUid': targetUid,
      'isActive': isActive,
    });
  }

  Future<void> syncUserClaimsForStaff({
    required String salonId,
    required String targetUid,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('syncUserClaimsForStaff');
    await callable.call({
      'salonId': salonId,
      'targetUid': targetUid,
    });
  }

  /// Pure helper for tests / UI.
  static bool resolvePermission({
    AppUser? user,
    required StaffPermissionModel? staff,
    required String permissionFirestoreKey,
  }) {
    if (user == null) return false;
    if (user.role == UserRoles.owner) return true;
    if (staff == null) {
      return user.role == UserRoles.admin;
    }
    if (!staff.isActive) return false;
    if (staff.role == 'owner') return true;
    return staff.permissionTrue(permissionFirestoreKey);
  }
}
