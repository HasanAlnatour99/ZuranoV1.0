import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/supabase/supabase_bootstrap.dart';
import 'features/notifications/logic/fcm_registration_service.dart';
import 'providers/app_settings_providers.dart';

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
  await FirebaseBootstrap.initializeAppOnly();
}

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _installStartupErrorHandlers();
    _logStartupStep('widgets_binding_initialized');

    _logStartupStep('supabase_init_begin');
    await SupabaseBootstrap.initialize();
    _logStartupStep('supabase_init_complete');

    _logStartupStep('firebase_init_begin');
    await FirebaseBootstrap.initializeCore();
    _logStartupStep('firebase_init_complete');

    _logStartupStep('app_check_init_begin');
    await FirebaseBootstrap.activateAppCheck();
    _logStartupStep('app_check_init_complete');

    if (!kFirebasePushMessagingEnabled) {
      _logStartupStep('firebase_messaging_disabled');
    } else {
      _logStartupStep('firebase_messaging_background_handler_register_begin');
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _logStartupStep('firebase_messaging_background_handler_register_complete');
    }

    _logStartupStep('shared_preferences_begin');
    final prefs = await SharedPreferences.getInstance();
    await _migrateOnboardingPrefs(prefs);
    _logStartupStep('shared_preferences_complete');

    _logStartupStep('run_app_begin');
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
    _logStartupStep('run_app_complete');
  }, (error, stackTrace) {
    _logStartupError('run_zoned_guarded', error, stackTrace);
  });
}

void _installStartupErrorHandlers() {
  FlutterError.onError = (details) {
    _logStartupError(
      'flutter_error',
      details.exception,
      details.stack ?? StackTrace.current,
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _logStartupError('platform_dispatcher_error', error, stackTrace);
    return true;
  };
}

void _logStartupStep(String step) {
  debugPrint('[APP_BOOT] $step');
}

void _logStartupError(String source, Object error, StackTrace stackTrace) {
  debugPrint('[APP_BOOT][ERROR][$source] $error');
  debugPrintStack(stackTrace: stackTrace);
}
