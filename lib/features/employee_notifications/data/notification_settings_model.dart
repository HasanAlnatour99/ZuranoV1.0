import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore: `users/{uid}/notificationSettings/main`
class NotificationSettingsModel {
  const NotificationSettingsModel({
    required this.bookingUpdates,
    required this.attendanceUpdates,
    required this.payrollUpdates,
    required this.approvalRequests,
    required this.systemAlerts,
    required this.pushNotifications,
  });

  final bool bookingUpdates;
  final bool attendanceUpdates;
  final bool payrollUpdates;
  final bool approvalRequests;
  final bool systemAlerts;
  final bool pushNotifications;

  static NotificationSettingsModel defaults() => const NotificationSettingsModel(
        bookingUpdates: true,
        attendanceUpdates: true,
        payrollUpdates: true,
        approvalRequests: true,
        systemAlerts: true,
        pushNotifications: true,
      );

  factory NotificationSettingsModel.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return NotificationSettingsModel.defaults();
    }
    return NotificationSettingsModel(
      bookingUpdates: map['bookingUpdates'] != false,
      attendanceUpdates: map['attendanceUpdates'] != false,
      payrollUpdates: map['payrollUpdates'] != false,
      approvalRequests: map['approvalRequests'] != false,
      systemAlerts: map['systemAlerts'] != false,
      pushNotifications: map['pushNotifications'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingUpdates': bookingUpdates,
      'attendanceUpdates': attendanceUpdates,
      'payrollUpdates': payrollUpdates,
      'approvalRequests': approvalRequests,
      'systemAlerts': systemAlerts,
      'pushNotifications': pushNotifications,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  NotificationSettingsModel copyWith({
    bool? bookingUpdates,
    bool? attendanceUpdates,
    bool? payrollUpdates,
    bool? approvalRequests,
    bool? systemAlerts,
    bool? pushNotifications,
  }) {
    return NotificationSettingsModel(
      bookingUpdates: bookingUpdates ?? this.bookingUpdates,
      attendanceUpdates: attendanceUpdates ?? this.attendanceUpdates,
      payrollUpdates: payrollUpdates ?? this.payrollUpdates,
      approvalRequests: approvalRequests ?? this.approvalRequests,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}
