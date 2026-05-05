import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../data/employee_notification_model.dart';
import '../data/employee_notifications_repository.dart';
import '../data/notification_settings_model.dart';

final employeeNotificationsRepositoryProvider =
    Provider<EmployeeNotificationsRepository>((ref) {
  return EmployeeNotificationsRepository(firestore: ref.read(firestoreProvider));
});

final employeeNotificationSettingsProvider =
    StreamProvider.family<NotificationSettingsModel, String>((ref, uid) {
  return ref
      .read(employeeNotificationsRepositoryProvider)
      .watchSettings(uid);
});

final employeeNotificationsListProvider =
    StreamProvider.family<List<EmployeeNotificationModel>, String>((ref, uid) {
  return ref.read(employeeNotificationsRepositoryProvider).watchNotifications(uid);
});

final employeeNotificationUnreadCountProvider =
    StreamProvider.family<int, String>((ref, uid) {
  return ref
      .read(employeeNotificationsRepositoryProvider)
      .watchNotifications(uid)
      .map((list) => list.where((e) => e.isUnread).length);
});
