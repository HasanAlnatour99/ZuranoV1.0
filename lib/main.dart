import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/supabase/supabase_bootstrap.dart';
import 'features/notifications/logic/fcm_registration_service.dart';
import 'firebase_options.dart';
import 'providers/app_settings_providers.dart';

/// True for `flutter run` (debug/profile). False for `flutter run --release` / store builds.
///
/// **Callable enforcement:** Cloud Functions such as [salonStaffCreateWithAuth] use
/// `enforceAppCheck: true`. Without a valid App Check token, HTTPS callables return **403**
/// (e.g. *App attestation failed*). Register platform debug tokens under Firebase Console →
/// App Check → your app → *Manage debug tokens* when using debug providers below.
///
/// **Web release:** set `--dart-define=FIREBASE_APP_CHECK_WEB_RECAPTCHA_KEY=<reCAPTCHA Enterprise site key>`
/// from the same console; non-release web uses [WebDebugProvider] (console token from browser logs).
const bool _kDartVmProduct = bool.fromEnvironment('dart.vm.product');

/// Runs in parallel with prefs/migration to shorten cold start before [runApp].
Future<void> _activateAppCheckForStartup() async {
  try {
    final useAttestationDebugProviders = !_kDartVmProduct;
    const webRecaptchaSiteKey = String.fromEnvironment(
      'FIREBASE_APP_CHECK_WEB_RECAPTCHA_KEY',
      defaultValue: '',
    );

    await FirebaseAppCheck.instance
        .activate(
          providerAndroid: useAttestationDebugProviders
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
          providerApple: useAttestationDebugProviders
              ? const AppleDebugProvider()
              : const AppleDeviceCheckProvider(),
          providerWeb: kIsWeb
              ? (useAttestationDebugProviders
                    ? WebDebugProvider()
                    : (webRecaptchaSiteKey.isNotEmpty
                          ? ReCaptchaEnterpriseProvider(webRecaptchaSiteKey)
                          : WebDebugProvider()))
              : null,
        )
        .timeout(
          useAttestationDebugProviders
              ? const Duration(seconds: 8)
              : const Duration(seconds: 12),
        );

    // Prime token after native bridge settles (reduces flaky "Too many attempts" on
    // Android emulators when callables run immediately after cold start).
    if (useAttestationDebugProviders &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      try {
        await FirebaseAppCheck.instance.getToken();
      } catch (e) {
        debugPrint(
          'AppCheck Android debug: first getToken failed ($e). '
          'If callables return Unauthenticated, add this emulator’s debug token: '
          'Firebase Console → App Check → your Android app → Manage debug tokens. '
          'Find the token in logcat, e.g. `adb logcat | grep -i "app check"` or '
          '`adb logcat -s FirebaseAppCheck:V`.',
        );
      }
    }
  } catch (error, stackTrace) {
    debugPrint('AppCheck activation failed: $error\n$stackTrace');
  }
}

Future<void> _migrateOnboardingPrefs(SharedPreferences prefs) async {
  const v1 = 'onboarding_install_migration_v1';
  if (prefs.getBool(v1) != true) {
    // Legacy `locale_code` (app locale) must not skip the language onboarding step.
    // Only seed `selected_language_code` when missing so the picker can default.
    if (prefs.containsKey('locale_code')) {
      final lc = prefs.getString('locale_code');
      final hasSelected = prefs.getString('selected_language_code');
      if (lc != null &&
          lc.isNotEmpty &&
          (hasSelected == null || hasSelected.trim().isEmpty)) {
        await prefs.setString(
          'selected_language_code',
          lc.startsWith('ar') ? 'ar' : 'en',
        );
      }
    }
    final legacyDone =
        (prefs.getBool('onboarding_language_completed') ?? false) &&
        (prefs.getBool('onboarding_country_completed') ?? false);
    if (legacyDone) {
      await prefs.setBool('onboarding_welcome_completed', true);
    }
    await prefs.setBool(v1, true);
  }

  // One-time repair: v1 used to set `onboarding_language_completed` from `locale_code` alone,
  // which skipped the language screen and opened country first.
  const v2 = 'onboarding_install_migration_v2_language_first';
  if (prefs.getBool(v2) != true) {
    final langDone = prefs.getBool('onboarding_language_completed') ?? false;
    final sel = prefs.getString('selected_language_code');
    if (langDone && (sel == null || sel.trim().isEmpty)) {
      await prefs.setBool('onboarding_language_completed', false);
    }
    await prefs.setBool(v2, true);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseBootstrap.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kFirebasePushMessagingEnabled) {
    await FirebaseMessaging.instance.setAutoInitEnabled(false);
  } else {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  // Overlap App Check with prefs I/O; await before runApp so first callable has a token.
  // See [_activateAppCheckForStartup] doc: enforced callables need a registered debug token in dev.
  final appCheckFuture = _activateAppCheckForStartup();
  final prefs = await SharedPreferences.getInstance();
  await _migrateOnboardingPrefs(prefs);
  await appCheckFuture;
  if (!_kDartVmProduct) {
    debugPrint(
      'AppCheck: non-release build — using debug-friendly attestation providers '
      '(register debug tokens in Firebase Console → App Check). '
      'Callables with enforceAppCheck require a valid token.',
    );
  }

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const BarberShopApp(),
      ),
    ),
  );
}
