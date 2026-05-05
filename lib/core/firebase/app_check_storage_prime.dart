import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Refreshes the App Check token before Firebase Storage uploads when enforcement
/// is enabled. Without a valid token (common with [AndroidDebugProvider] until the
/// debug token is registered), uploads return **403 Permission denied**.
///
/// Retries with backoff to mitigate emulator **Too many attempts** after returning
/// from the camera/gallery activity.
Future<void> primeAppCheckTokenBeforeStorageUpload() async {
  if (kIsWeb) return;

  final backoffMs = <int>[0, 250, 600, 1200];
  for (var i = 0; i < backoffMs.length; i++) {
    final delay = backoffMs[i];
    if (delay > 0) {
      await Future<void>.delayed(Duration(milliseconds: delay));
    }
    try {
      await FirebaseAppCheck.instance.getToken(i > 0);
      return;
    } catch (e) {
      if (i == backoffMs.length - 1 && kDebugMode) {
        debugPrint(
          'AppCheck: could not refresh token before Storage upload ($e). '
          'Receipt uploads may fail with 403 until the debug token is registered '
          '(Firebase Console → App Check → Android app → Manage debug tokens).',
        );
      }
    }
  }
}
