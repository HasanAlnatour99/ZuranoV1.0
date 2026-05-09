import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_serializers.dart';

/// `salons/{salonId}/auditLogs/{auditId}` — immutable activity row.
class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.salonId,
    required this.actionType,
    required this.module,
    required this.actorUid,
    required this.actorName,
    required this.actorRole,
    required this.targetType,
    required this.targetId,
    required this.targetLabel,
    required this.summary,
    required this.before,
    required this.after,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String salonId;
  final String actionType;
  final String module;
  final String actorUid;
  final String actorName;
  final String actorRole;
  final String? targetType;
  final String? targetId;
  final String? targetLabel;
  final String summary;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  factory AuditLogModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? <String, dynamic>{};
    return AuditLogModel(
      id: doc.id,
      salonId: looseStringFromJson(d['salonId']),
      actionType: looseStringFromJson(d['actionType']),
      module: looseStringFromJson(d['module']),
      actorUid: looseStringFromJson(d['actorUid']),
      actorName: looseStringFromJson(d['actorName']),
      actorRole: looseStringFromJson(d['actorRole']),
      targetType: nullableLooseStringFromJson(d['targetType']),
      targetId: nullableLooseStringFromJson(d['targetId']),
      targetLabel: nullableLooseStringFromJson(d['targetLabel']),
      summary: looseStringFromJson(d['summary']),
      before: _mapFromJson(d['before']),
      after: _mapFromJson(d['after']),
      metadata: _mapFromJson(d['metadata']),
      createdAt: FirestoreSerializers.dateTime(d['createdAt']),
    );
  }

  static Map<String, dynamic> _mapFromJson(Object? raw) {
    if (raw is Map) {
      final out = <String, dynamic>{};
      for (final e in raw.entries) {
        final k = e.key?.toString() ?? '';
        if (k.isEmpty) continue;
        out[k] = e.value;
      }
      return out;
    }
    return {};
  }
}
