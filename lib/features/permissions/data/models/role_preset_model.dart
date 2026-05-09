import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';

/// `salons/{salonId}/roles/{roleId}` — reusable permission bundles.
class RolePresetModel {
  const RolePresetModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String salonId;
  final String name;
  final String description;
  final Map<String, bool> permissions;
  final bool isSystem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RolePresetModel.fromFirestore(
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
    return RolePresetModel(
      id: doc.id,
      salonId: looseStringFromJson(d['salonId']),
      name: looseStringFromJson(d['name']),
      description: looseStringFromJson(d['description']),
      permissions: permissions,
      isSystem: trueBoolFromJson(d['isSystem']),
      createdAt: FirestoreSerializers.dateTime(d['createdAt']),
      updatedAt: FirestoreSerializers.dateTime(d['updatedAt']),
    );
  }
}
