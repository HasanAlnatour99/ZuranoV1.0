import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Firebase + App Check bootstrap for the main isolate.
///
/// [initializeCore] must complete before [activateAppCheck] (enforced by call order
/// in [main]).
///
/// **Local debug:** [kDebugMode] uses [AndroidProvider.debug] and [AppleProvider.debug].
/// Register the device debug token from Xcode / `flutter run` logs in Firebase Console
/// → App Check → your app → Manage debug tokens. Tokens are never hardcoded here.
///
/// **Release:** Play Integrity (Android) and App Attest with Device Check fallback (iOS).
///
/// **Web:** optional `FIREBASE_APP_CHECK_WEB_RECAPTCHA_KEY` for release; debug web uses
/// [WebDebugProvider].
final class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// Minimal init for background isolates (e.g. FCM). Does not activate App Check.
  static Future<void> initializeAppOnly() async {
    await initializeCore();
  }

  /// [Firebase.initializeApp] only. Call before [FirebaseMessaging] on the UI isolate.
  static Future<void> initializeCore() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  static Future<void> activateAppCheck() async {
    try {
      const webRecaptchaSiteKey = String.fromEnvironment(
        'FIREBASE_APP_CHECK_WEB_RECAPTCHA_KEY',
        defaultValue: '',
      );

      // ignore: deprecated_member_use
      final androidProvider = kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity;
      // ignore: deprecated_member_use
      final appleProvider = kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttestWithDeviceCheckFallback;

      if (!kReleaseMode) {
        debugPrint(
          'AppCheck: selected providers — ${_describeSelection(
            androidProvider,
            appleProvider,
            webRecaptchaSiteKey,
          )}',
        );
      }

      await FirebaseAppCheck.instance
          .activate(
            // ignore: deprecated_member_use
            androidProvider: androidProvider,
            // ignore: deprecated_member_use
            appleProvider: appleProvider,
            providerWeb: kIsWeb
                ? (kDebugMode
                      ? WebDebugProvider()
                      : (webRecaptchaSiteKey.isNotEmpty
                            ? ReCaptchaEnterpriseProvider(webRecaptchaSiteKey)
                            : WebDebugProvider()))
                : null,
          )
          .timeout(
            kReleaseMode ? const Duration(seconds: 12) : const Duration(seconds: 8),
          );

      if (kDebugMode && !kIsWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        try {
          await FirebaseAppCheck.instance.getToken();
        } catch (e) {
          debugPrint(
            'AppCheck: first getToken failed ($e). '
            'Register this device\'s debug token: Firebase Console → App Check → '
            'your app → Manage debug tokens, then restart.',
          );
        }
      }
    } catch (error, stackTrace) {
      debugPrint('AppCheck activation failed: $error\n$stackTrace');
    }
  }

  static String _describeSelection(
    AndroidProvider android,
    AppleProvider apple,
    String webRecaptchaSiteKey,
  ) {
    if (kIsWeb) {
      if (kDebugMode) return 'web=WebDebugProvider';
      return webRecaptchaSiteKey.isNotEmpty
          ? 'web=ReCaptchaEnterpriseProvider'
          : 'web=WebDebugProvider(fallback, no site key)';
    }
    return 'android=$android, apple=$apple';
  }
}
