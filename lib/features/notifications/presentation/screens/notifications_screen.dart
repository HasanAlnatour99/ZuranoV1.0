import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || salonId.isEmpty || session == null) {
        return;
      }
      final role = session.role.trim();
      if (role == 'customer') {
        context.go(AppRoutes.customerNotifications(salonId));
        return;
      }
      if (role == 'owner' || role == 'admin') {
        context.go(AppRoutes.ownerNotifications(salonId));
        return;
      }
      context.go(AppRoutes.employeeNotifications(salonId));
    });

    return Scaffold(
      body: Center(
        child: Text(
          l10n.notificationsCenterTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
