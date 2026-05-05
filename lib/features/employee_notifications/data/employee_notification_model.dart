import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore/firestore_serializers.dart';

/// In-app row: `users/{uid}/notifications/{notificationId}`.
class EmployeeNotificationModel {
  const EmployeeNotificationModel({
    required this.id,
    required this.salonId,
    this.employeeId,
    required this.recipientUid,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.readAt,
    this.sourceCollection,
    this.sourceId,
    this.route,
    this.actionLabel,
    this.metadata = const {},
  });

  final String id;
  final String salonId;
  final String? employeeId;
  final String recipientUid;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String? sourceCollection;
  final String? sourceId;
  final String? route;
  final String? actionLabel;
  final Map<String, dynamic> metadata;

  /// Legacy rows used [status] == `unread` / `read` before [isRead] was added.
  bool get isUnread {
    if (isRead) {
      return false;
    }
    return true;
  }

  factory EmployeeNotificationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final json = doc.data() ?? {};
    final legacyStatus = FirestoreSerializers.string(json['status']);
    final explicitRead = json['isRead'];
    final resolvedRead = explicitRead is bool
        ? explicitRead
        : (legacyStatus == 'read');

    final metaRaw = json['metadata'];
    final metadata = metaRaw is Map<String, dynamic>
        ? Map<String, dynamic>.from(metaRaw)
        : (metaRaw is Map
            ? Map<String, dynamic>.from(
                metaRaw.map((k, v) => MapEntry(k.toString(), v)),
              )
            : <String, dynamic>{});

    return EmployeeNotificationModel(
      id: FirestoreSerializers.string(json['id']) ?? doc.id,
      salonId: FirestoreSerializers.string(json['salonId']) ?? '',
      employeeId: FirestoreSerializers.string(json['employeeId']),
      recipientUid: FirestoreSerializers.string(json['recipientUid']) ?? '',
      type: FirestoreSerializers.string(json['type']) ?? 'system_alerts',
      title: FirestoreSerializers.string(json['title']) ?? '',
      body: FirestoreSerializers.string(json['body']) ?? '',
      isRead: resolvedRead,
      createdAt: FirestoreSerializers.dateTime(json['createdAt']),
      readAt: FirestoreSerializers.dateTime(json['readAt']),
      sourceCollection: FirestoreSerializers.string(json['sourceCollection']),
      sourceId: FirestoreSerializers.string(json['sourceId']),
      route: FirestoreSerializers.string(json['route']),
      actionLabel: FirestoreSerializers.string(json['actionLabel']),
      metadata: metadata,
    );
  }
}
