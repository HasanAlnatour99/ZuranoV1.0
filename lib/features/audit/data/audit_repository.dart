import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/core/firestore/firestore_write_payload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/audit_log_model.dart';

class AuditRepository {
  AuditRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _auditCol(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonActivityCenterAuditLogs(salonId));
  }

  /// Primary timeline stream; optional Firestore filters when indexes exist.
  Stream<List<AuditLogModel>> watchAuditLogs({
    required String salonId,
    String? module,
    String? actorUid,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 150,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    Query<Map<String, dynamic>> q = _auditCol(salonId);
    if (module != null && module.trim().isNotEmpty) {
      q = q.where('module', isEqualTo: module.trim());
    }
    if (actorUid != null && actorUid.trim().isNotEmpty) {
      q = q.where('actorUid', isEqualTo: actorUid.trim());
    }
    if (startDate != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
      q = q.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }
    q = q.orderBy('createdAt', descending: true).limit(limit);
    return q.snapshots().map(
          (s) => s.docs.map(AuditLogModel.fromFirestore).toList(),
        );
  }

  /// Plain descending list when composite indexes are missing (fallback).
  Stream<List<AuditLogModel>> watchAuditLogsSimple({
    required String salonId,
    int limit = 200,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _auditCol(salonId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(AuditLogModel.fromFirestore).toList());
  }

  Stream<AuditLogModel?> watchAuditLogDetails(String salonId, String auditId) {
    FirestoreWritePayload.assertSalonId(salonId);
    final id = auditId.trim();
    if (id.isEmpty) return Stream.value(null);
    return _auditCol(salonId).doc(id).snapshots().map((d) {
      if (!d.exists) return null;
      return AuditLogModel.fromFirestore(d);
    });
  }
}
