import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firestore/firestore_paths.dart';

class FcmService {
  FcmService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
  }) : _messaging = messaging,
       _firestore = firestore;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  Future<void> requestPermission() async {
    if (kIsWeb) return;
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Stream<String> onTokenRefresh() {
    return _messaging.onTokenRefresh;
  }

  Stream<RemoteMessage> onForegroundMessage() {
    return FirebaseMessaging.onMessage;
  }

  Stream<RemoteMessage> onNotificationTap() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  Future<void> saveDeviceToken({required String uid, String? salonId}) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    final payload = <String, dynamic>{
      'token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('${FirestorePaths.user(uid)}/deviceTokens')
        .doc(token)
        .set(payload, SetOptions(merge: true));

    if (salonId != null && salonId.trim().isNotEmpty) {
      await _firestore
          .collection(
            '${FirestorePaths.salon(salonId)}/users/$uid/deviceTokens',
          )
          .doc(token)
          .set(payload, SetOptions(merge: true));
    }
  }
}
