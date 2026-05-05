import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../notifications/presentation/controllers/notification_controller.dart';
import '../../notifications/presentation/widgets/mark_all_read_button.dart';
import '../../notifications/presentation/widgets/notification_empty_state.dart';
import '../../notifications/presentation/widgets/notification_filter_chips.dart';
import '../../notifications/presentation/widgets/notification_header.dart';
import '../../../../providers/session_provider.dart';
import '../application/employee_notifications_providers.dart';
import 'widgets/employee_notification_tile.dart';

class EmployeeNotificationsScreen extends ConsumerStatefulWidget {
  const EmployeeNotificationsScreen({super.key});

  @override
  ConsumerState<EmployeeNotificationsScreen> createState() =>
      _EmployeeNotificationsScreenState();
}

class _EmployeeNotificationsScreenState
    extends ConsumerState<EmployeeNotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider);
    final uid = session.asData?.value?.uid ?? '';
    if (uid.isEmpty) {
      return Scaffold(
        backgroundColor: ZuranoTokens.background,
        body: Center(child: Text(l10n.genericError)),
      );
    }

    final listAsync = ref.watch(employeeNotificationsListProvider(uid));
    final repo = ref.read(employeeNotificationsRepositoryProvider);

    return Scaffold(
      backgroundColor: ZuranoTokens.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: listAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: ZuranoTokens.primary),
            ),
            error: (e, _) => Center(
              child: Text(
                l10n.genericError,
                style: const TextStyle(color: ZuranoTokens.textGray),
                textAlign: TextAlign.center,
              ),
            ),
            data: (all) {
              final visible = _filter == NotificationFilter.unread
                  ? all.where((e) => e.isUnread).toList()
                  : all;
              final unread = all.where((e) => e.isUnread).length;
              return Column(
                children: [
                  NotificationHeader(
                    onBack: () => _onBack(context),
                    onOpenSettings: () => context.push(
                      AppRoutes.employeeNotificationSettings,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: NotificationFilterChips(
                          selectedFilter: _filter,
                          onFilterChanged: (f) {
                            setState(() => _filter = f);
                          },
                        ),
                      ),
                      if (unread > 0)
                        MarkAllReadButton(
                          onPressed: () async {
                            await repo.markAllAsRead(uid);
                            ref.invalidate(employeeNotificationsListProvider(uid));
                            ref.invalidate(employeeNotificationUnreadCountProvider(uid));
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: visible.isEmpty
                        ? NotificationEmptyState(
                            onOpenSettings: () => context.push(
                              AppRoutes.employeeNotificationSettings,
                            ),
                          )
                        : ListView.separated(
                            itemCount: visible.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: ZuranoTokens.border,
                            ),
                            itemBuilder: (context, i) {
                              final item = visible[i];
                              return EmployeeNotificationTile(
                                item: item,
                                onTap: () async {
                                  await repo.markAsRead(uid, item.id);
                                  ref.invalidate(employeeNotificationsListProvider(uid));
                                  ref.invalidate(employeeNotificationUnreadCountProvider(uid));
                                  if (!context.mounted) {
                                    return;
                                  }
                                  final route = item.route?.trim() ?? '';
                                  if (route.isNotEmpty) {
                                    context.push(route);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.employeeToday);
  }
}
