import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/enums/notification_role_scope.dart';
import '../../domain/repositories/notification_repository_contract.dart';
import '../models/app_notification_model.dart';

class FirestoreNotificationRepository
    implements NotificationRepositoryContract {
  FirestoreNotificationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String salonId) {
    return _firestore.collection(FirestorePaths.salonNotifications(salonId));
  }

  /// Firebase Auth inbox key (production rules expect `recipientUserId` match).
  String _recipientAuthUid({
    required NotificationRoleScope scope,
    String? userId,
    String? customerId,
  }) {
    switch (scope) {
      case NotificationRoleScope.customer:
        return customerId?.trim() ?? '';
      case NotificationRoleScope.ownerAdmin:
      case NotificationRoleScope.employee:
        return userId?.trim() ?? '';
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications({
    required String salonId,
    required NotificationRoleScope scope,
    String? userId,
    String? employeeId,
    String? customerId,
    String? customerPhoneNormalized,
    bool unreadOnly = false,
  }) {
    final rid = _recipientAuthUid(
      scope: scope,
      userId: userId,
      customerId: customerId,
    );
    if (rid.isEmpty) {
      return Stream<List<AppNotification>>.value(const <AppNotification>[]);
    }

    final base = _collection(salonId)
        .where('status', isEqualTo: 'active')
        .where('recipientUserId', isEqualTo: rid)
        .orderBy('createdAt', descending: true)
        .limit(50);

    return base.snapshots().map((snapshot) {
      final items = snapshot.docs
          .map(AppNotificationModel.fromFirestore)
          .toList();
      if (!unreadOnly) {
        return items;
      }
      return items.where((item) => item.isUnreadFor(rid)).toList();
    });
  }

  @override
  Stream<int> watchUnreadCount({
    required String salonId,
    required NotificationRoleScope scope,
    String? readerId,
    String? userId,
    String? employeeId,
    String? customerId,
    String? customerPhoneNormalized,
  }) {
    return watchNotifications(
      salonId: salonId,
      scope: scope,
      userId: userId,
      employeeId: employeeId,
      customerId: customerId,
      customerPhoneNormalized: customerPhoneNormalized,
      unreadOnly: false,
    ).map((items) {
      final inboxUid = _recipientAuthUid(
        scope: scope,
        userId: userId,
        customerId: customerId,
      );
      return items.where((item) => item.isUnreadFor(inboxUid)).length;
    });
  }

  @override
  Future<void> markAsRead({
    required String salonId,
    required String notificationId,
    required String readerId,
  }) async {
    if (readerId.trim().isEmpty) {
      return;
    }
    await _collection(salonId).doc(notificationId).set({
      'isRead': true,
      'readBy.$readerId': true,
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markAllAsRead({
    required String salonId,
    required NotificationRoleScope scope,
    required String readerId,
    String? userId,
    String? employeeId,
    String? customerId,
    String? customerPhoneNormalized,
  }) async {
    final items = await watchNotifications(
      salonId: salonId,
      scope: scope,
      userId: userId,
      employeeId: employeeId,
      customerId: customerId,
      customerPhoneNormalized: customerPhoneNormalized,
    ).first;

    final batch = _firestore.batch();
    for (final item in items.where((n) => n.isUnreadFor(readerId))) {
      final doc = _collection(salonId).doc(item.id);
      batch.set(doc, {
        'isRead': true,
        'readBy.$readerId': true,
        'readAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<void> createNotification({required AppNotification notification}) async {
    final model = AppNotificationModel.fromEntity(notification);
    await _collection(
      notification.salonId,
    ).doc(notification.id).set(model.toFirestore(), SetOptions(merge: true));
  }
}
