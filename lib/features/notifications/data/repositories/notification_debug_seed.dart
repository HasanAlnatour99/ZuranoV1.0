import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_paths.dart';

class NotificationDebugSeed {
  NotificationDebugSeed({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<void> seed(String salonId) async {
    final col = _firestore.collection(
      FirestorePaths.salonNotifications(salonId),
    );
    final samples = <Map<String, dynamic>>[
      {
        'title': 'New booking request',
        'body': 'A new booking was submitted for this afternoon.',
        'type': 'booking',
        'targetRole': 'owner_admin',
        'actionRoute': '/owner/bookings',
      },
      {
        'title': 'Attendance correction submitted',
        'body': "Ahmed requested a correction for yesterday's checkout.",
        'type': 'attendance',
        'targetRole': 'owner_admin',
        'actionRoute': '/owner/attendance-requests',
      },
      {
        'title': 'Payroll payslip ready',
        'body': 'Your monthly payslip is now available.',
        'type': 'payroll',
        'targetRole': 'employee',
        'actionRoute': '/employee/payroll',
      },
      {
        'title': 'Sale recorded',
        'body': 'A new sale was recorded successfully.',
        'type': 'sales',
        'targetRole': 'all',
        'actionRoute': '/owner-sales',
      },
      {
        'title': 'Missing checkout violation',
        'body': 'One shift ended without checkout confirmation.',
        'type': 'violation',
        'targetRole': 'owner_admin',
      },
      {
        'title': 'System update',
        'body': 'Notification center is now available for all roles.',
        'type': 'system',
        'targetRole': 'all',
      },
    ];

    final batch = _firestore.batch();
    for (final sample in samples) {
      final ref = col.doc();
      batch.set(ref, {
        'id': ref.id,
        'salonId': salonId,
        'title': sample['title'],
        'body': sample['body'],
        'type': sample['type'],
        'targetRole': sample['targetRole'],
        'targetUserId': null,
        'targetEmployeeId': null,
        'targetCustomerId': null,
        'customerPhoneNormalized': null,
        'isRead': false,
        'readBy': <String, bool>{},
        'actionRoute': sample['actionRoute'],
        'actionParams': null,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': null,
        'priority': 'normal',
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
