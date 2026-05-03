import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/enums/notification_role_scope.dart';
import '../controllers/notification_controller.dart';
import '../controllers/notification_providers.dart';
import '../widgets/mark_all_read_button.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_filter_chips.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_list_section.dart';

class RoleNotificationScreen extends ConsumerStatefulWidget {
  const RoleNotificationScreen({
    super.key,
    required this.salonId,
    required this.scope,
  });

  final String salonId;
  final NotificationRoleScope scope;

  @override
  ConsumerState<RoleNotificationScreen> createState() =>
      _RoleNotificationScreenState();
}

class _RoleNotificationScreenState
    extends ConsumerState<RoleNotificationScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args = buildNotificationControllerArgs(
      ref: ref,
      salonId: widget.salonId,
      scope: widget.scope,
    );
    final request = NotificationViewRequest(
      args: args,
      filter: _selectedFilter,
    );
    final state = ref.watch(notificationStateProvider(request));
    final controller = ref.read(notificationControllerProvider(args));
    final unreadCount =
        ref.watch(notificationUnreadCountProvider(args)).value ?? 0;

    Future<void> onRefresh() async {
      ref.invalidate(notificationStateProvider(request));
    }

    return Scaffold(
      backgroundColor: ZuranoTokens.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              NotificationHeader(
                onBack: () => _handleBack(context),
                onOpenSettings: () => context.push(
                  AppRoutes.notificationSettingsForSalon(widget.salonId),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NotificationFilterChips(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  ),
                  if (unreadCount > 0)
                    MarkAllReadButton(
                      onPressed: () async {
                        await controller.markAllAsRead();
                        ref.invalidate(notificationStateProvider(request));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: state.when(
                  data: (value) {
                    if (value.notifications.isEmpty) {
                      final empty = NotificationEmptyState(
                        onOpenSettings: () => context.push(
                          AppRoutes.notificationSettingsForSalon(
                            widget.salonId,
                          ),
                        ),
                        subtitleOverride: value.provisionalEmptyDueToIndexBuilding
                            ? l10n.notificationsFirestoreIndexBuildingSubtitle
                            : null,
                      );
                      return RefreshIndicator(
                        onRefresh: onRefresh,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: empty,
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: onRefresh,
                      child: NotificationListSection(
                        notifications: value.notifications,
                        readerId: args.readerId,
                        onTapNotification: (notification) => _onTapNotification(
                          context: context,
                          controller: controller,
                          request: request,
                          notification: notification,
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: ZuranoTokens.primary,
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      l10n.genericError,
                      style: const TextStyle(color: ZuranoTokens.textGray),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTapNotification({
    required BuildContext context,
    required NotificationController controller,
    required NotificationViewRequest request,
    required AppNotification notification,
  }) async {
    await controller.markAsRead(notification);
    ref.invalidate(notificationStateProvider(request));
    final route = notification.effectiveActionRoute?.trim();
    if (route != null && route.isNotEmpty && context.mounted) {
      context.push(route);
    }
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    switch (widget.scope) {
      case NotificationRoleScope.customer:
        context.go(AppRoutes.customerHome);
        break;
      case NotificationRoleScope.employee:
        context.go(AppRoutes.employeeToday);
        break;
      case NotificationRoleScope.ownerAdmin:
        context.go(AppRoutes.ownerOverview);
        break;
    }
  }
}
