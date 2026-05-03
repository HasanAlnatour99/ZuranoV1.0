import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../../data/repositories/firestore_notification_repository.dart';
import '../../domain/repositories/notification_repository_contract.dart';

final roleNotificationRepositoryProvider =
    Provider<NotificationRepositoryContract>((ref) {
      return FirestoreNotificationRepository(
        firestore: ref.read(firestoreProvider),
      );
    });
