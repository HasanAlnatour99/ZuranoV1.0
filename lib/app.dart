import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/notifications/logic/fcm_registration_service.dart';
import 'features/notifications/logic/notification_router.dart';
import 'features/users/data/models/app_user.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_settings_providers.dart' show appLocalePreferenceProvider;
import 'providers/notification_providers.dart';
import 'providers/session_provider.dart';
import 'router/app_router.dart';

class BarberShopApp extends ConsumerStatefulWidget {
  const BarberShopApp({super.key});

  @override
  ConsumerState<BarberShopApp> createState() => _BarberShopAppState();
}

class _BarberShopAppState extends ConsumerState<BarberShopApp> {
  bool _fcmListenersAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapFcm());
  }

  Future<void> _bootstrapFcm() async {
    if (!kFirebasePushMessagingEnabled) {
      return;
    }
    final fcm = ref.read(fcmRegistrationServiceProvider);
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await fcm.initializeLocalNotifications(
      onNotificationTap: _navigateFromNotificationData,
    );
    await fcm.requestPermissionIfSupported();

    if (!_fcmListenersAttached) {
      _fcmListenersAttached = true;
      FirebaseMessaging.onMessage.listen(fcm.showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final user = ref.read(sessionUserProvider).asData?.value;
        if (user == null) {
          return;
        }
        final locale = ref.read(appLocalePreferenceProvider);
        await fcm.registerWithExplicitToken(
          user: user,
          token: newToken,
          localeName: locale.languageCode,
        );
      });
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null && mounted) {
      _handleOpenedMessage(initial);
    } else if (mounted) {
      await fcm.consumeLaunchNotificationTap(
        onTap: _navigateFromNotificationData,
      );
    }
  }

  void _navigateFromNotificationData(Map<String, dynamic> data) {
    if (!mounted) {
      return;
    }
    navigateForNotificationPayload(
      router: ref.read(appRouterProvider),
      data: data,
      session: ref.read(sessionUserProvider).asData?.value,
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final router = ref.read(appRouterProvider);
    final session = ref.read(sessionUserProvider).asData?.value;
    final data = message.data.map((k, v) => MapEntry(k, v));
    navigateForNotificationPayload(
      router: router,
      data: data,
      session: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocalePreferenceProvider);

    ref.listen<AsyncValue<AppUser?>>(sessionUserProvider, (prev, next) {
      if (!kFirebasePushMessagingEnabled) {
        return;
      }
      next.whenData((user) async {
        final fcm = ref.read(fcmRegistrationServiceProvider);
        final loc = ref.read(appLocalePreferenceProvider);
        if (user == null) {
          await fcm.unregisterCurrentDevice();
        } else {
          await fcm.registerOrRefreshToken(
            user: user,
            localeName: loc.languageCode,
          );
        }
      });
    });

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.data(locale),
      themeMode: ThemeMode.light,
    );
  }
}
