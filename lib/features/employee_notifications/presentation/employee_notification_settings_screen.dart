import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../application/employee_notifications_providers.dart';
import 'widgets/notification_settings_card.dart';

class EmployeeNotificationSettingsScreen extends ConsumerWidget {
  const EmployeeNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider);
    final uid = session.asData?.value?.uid ?? '';

    if (uid.isEmpty) {
      return Scaffold(
        backgroundColor: ZuranoTokens.background,
        appBar: AppBar(
          backgroundColor: ZuranoTokens.surface,
          foregroundColor: ZuranoTokens.textDark,
          elevation: 0,
          title: Text(l10n.notificationsPreferencesTitle),
        ),
        body: Center(child: Text(l10n.genericError)),
      );
    }

    final settingsAsync = ref.watch(employeeNotificationSettingsProvider(uid));

    return Scaffold(
      backgroundColor: ZuranoTokens.background,
      appBar: AppBar(
        backgroundColor: ZuranoTokens.surface,
        foregroundColor: ZuranoTokens.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.employeeToday);
            }
          },
        ),
        title: Text(
          l10n.notificationsPreferencesTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: ZuranoTokens.textDark,
          ),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: ZuranoTokens.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            l10n.genericError,
            style: const TextStyle(color: ZuranoTokens.textGray),
          ),
        ),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              NotificationSettingsCard(
                settings: settings,
                onChanged: (next) {
                  ref
                      .read(employeeNotificationsRepositoryProvider)
                      .updateSettings(uid, next);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
