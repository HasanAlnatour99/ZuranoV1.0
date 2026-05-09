import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/features/audit/data/models/audit_log_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuditLogModel parses salon audit document', () async {
    final fs = FakeFirebaseFirestore();
    const salonId = 'salon_test';
    const auditId = 'audit_1';
    await fs
        .collection('salons')
        .doc(salonId)
        .collection(FirestorePaths.activityCenterAuditLogs)
        .doc(auditId)
        .set({
      'salonId': salonId,
      'actionType': 'bookings.confirmed',
      'module': 'bookings',
      'actorUid': 'u1',
      'actorName': 'Sam',
      'actorRole': 'owner',
      'targetType': 'booking',
      'targetId': 'b1',
      'targetLabel': 'Haircut',
      'summary': 'Confirmed booking',
      'before': <String, dynamic>{'status': 'pending'},
      'after': <String, dynamic>{'status': 'confirmed'},
      'metadata': <String, dynamic>{'source': 'owner_app'},
      'createdAt': DateTime.utc(2026, 5, 9, 12, 0),
    });

    final snap = await fs
        .collection('salons')
        .doc(salonId)
        .collection(FirestorePaths.activityCenterAuditLogs)
        .doc(auditId)
        .get();

    final m = AuditLogModel.fromFirestore(snap);
    expect(m.id, auditId);
    expect(m.module, 'bookings');
    expect(m.before['status'], 'pending');
    expect(m.after['status'], 'confirmed');
    expect(m.metadata['source'], 'owner_app');
  });
}
