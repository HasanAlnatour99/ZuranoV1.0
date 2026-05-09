import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';

/// `salons/{salonId}/staff/{uid}` — salon-scoped RBAC row (doc id = Firebase Auth uid).
class StaffPermissionModel {
  const StaffPermissionModel({
    required this.uid,
    required this.salonId,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.role,
    required this.roleId,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.invitedBy,
  });

  final String uid;
  final String salonId;
  final String displayName;
  final String email;
  final String? phone;
  final String role;
  final String roleId;
  final Map<String, bool> permissions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? invitedBy;

  bool permissionTrue(String key) => permissions[key] == true;

  factory StaffPermissionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? <String, dynamic>{};
    final permRaw = d['permissions'];
    final permissions = <String, bool>{};
    if (permRaw is Map) {
      for (final e in permRaw.entries) {
        final k = e.key?.toString() ?? '';
        if (k.isEmpty) continue;
        permissions[k] = e.value == true;
      }
    }
    return StaffPermissionModel(
      uid: looseStringFromJson(d['uid']).isNotEmpty
          ? looseStringFromJson(d['uid'])
          : doc.id,
      salonId: looseStringFromJson(d['salonId']),
      displayName: looseStringFromJson(d['displayName']),
      email: looseStringFromJson(d['email']),
      phone: nullableLooseStringFromJson(d['phone']),
      role: looseStringFromJson(d['role']),
      roleId: looseStringFromJson(d['roleId']),
      permissions: permissions,
      isActive: trueBoolFromJson(d['isActive']),
      createdAt: FirestoreSerializers.dateTime(d['createdAt']),
      updatedAt: FirestoreSerializers.dateTime(d['updatedAt']),
      invitedBy: nullableLooseStringFromJson(d['invitedBy']),
    );
  }
}
