import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore/firestore_paths.dart';
import 'employee_notification_model.dart';
import 'notification_settings_model.dart';

class EmployeeNotificationsRepository {
  EmployeeNotificationsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _settingsRef(String uid) {
    return _firestore.doc(FirestorePaths.userNotificationSettingsMainPath(uid));
  }

  CollectionReference<Map<String, dynamic>> _notificationsRef(String uid) {
    return _firestore.collection(FirestorePaths.userNotificationsPath(uid));
  }

  Stream<NotificationSettingsModel> watchSettings(String uid) {
    return _settingsRef(uid).snapshots().map(
          (doc) => NotificationSettingsModel.fromMap(doc.data()),
        );
  }

  Future<void> updateSettings(
    String uid,
    NotificationSettingsModel settings,
  ) {
    return _settingsRef(uid).set(settings.toMap(), SetOptions(merge: true));
  }

  Stream<List<EmployeeNotificationModel>> watchNotifications(String uid) {
    return _notificationsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(EmployeeNotificationModel.fromDoc)
              .toList(growable: false),
        );
  }

  Future<void> markAsRead(String uid, String notificationId) {
    return _notificationsRef(uid).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notificationsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final batch = _firestore.batch();
    var n = 0;
    for (final doc in snapshot.docs) {
      final item = EmployeeNotificationModel.fromDoc(doc);
      if (!item.isUnread) {
        continue;
      }
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      n++;
    }
    if (n == 0) {
      return;
    }
    await batch.commit();
  }
}
