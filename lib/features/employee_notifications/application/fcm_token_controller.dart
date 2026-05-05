import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/firestore/firestore_write_payload.dart';

/// Optional client-side mirror of the FCM token on `users/{uid}.fcmTokens`
/// (the [registerDeviceToken] Cloud Function also records tokens).
///
/// Call [recordCurrentToken] after permission is granted; [App] already
/// registers via [FcmRegistrationService] on session changes.
class FcmTokenController {
  FcmTokenController({
    required FirebaseFirestore firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore,
        _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  Future<void> recordCurrentToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final permission = await _messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await _mergeToken(user.uid, token);
  }

  Future<void> _mergeToken(String uid, String token) {
    return _firestore.doc('users/$uid').set(
          FirestoreWritePayload.withServerTimestampForUpdate({
            'fcmTokens': {token: true},
          }),
          SetOptions(merge: true),
        );
  }
}
