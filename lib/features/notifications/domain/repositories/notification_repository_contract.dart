import '../entities/app_notification.dart';
import '../enums/notification_role_scope.dart';

abstract class NotificationRepositoryContract {
  Stream<List<AppNotification>> watchNotifications({
    required String salonId,
    required NotificationRoleScope scope,
    String? userId,
    String? employeeId,
    String? customerId,
    String? customerPhoneNormalized,
    bool unreadOnly = false,
  });

  Stream<int> watchUnreadCount({
    required String salonId,
    required NotificationRoleScope scope,
    String? readerId,
    String? userId,
    String? employeeId,
    String? customerId,
    String? customerPhoneNormalized,
  });

  Future<void> markAsRead({
    required String salonId,
    required String notificationId,
    required String readerId,
  });

  Future<void> markAllAsRead({
    required String salonId,
    required NotificationRoleScope scope,
    required String readerId,
    String? userId,
    String? employeeId,
    String? customerId,
    String? customerPhoneNormalized,
  });

  Future<void> createNotification({required AppNotification notification});
}
