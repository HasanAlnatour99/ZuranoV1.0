import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/session/app_session_status.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_app_shell.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/app_settings_providers.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/auth_session_actions.dart';
import '../../../../providers/session_provider.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../../shared/navigation/zurano_swipe_shell.dart';
import '../widgets/owner_zurano_bottom_nav.dart';

Future<void> _toggleDashboardLocale(WidgetRef ref) async {
  final loc = ref.read(appLocalePreferenceProvider);
  final next = loc.languageCode == 'ar'
      ? const Locale('en')
      : const Locale('ar');
  await ref.read(appLocalePreferenceProvider.notifier).setLocale(next);
}

class _OwnerAiAssistantAppBarButton extends StatefulWidget {
  const _OwnerAiAssistantAppBarButton({required this.tooltip});

  final String tooltip;

  @override
  State<_OwnerAiAssistantAppBarButton> createState() =>
      _OwnerAiAssistantAppBarButtonState();
}

class _OwnerAiAssistantAppBarButtonState
    extends State<_OwnerAiAssistantAppBarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0.95,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 42,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0.95,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 58,
    ),
  ]).animate(_scaleController);

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onTap(BuildContext context) async {
    await _scaleController.forward(from: 0);
    if (!context.mounted) return;
    await context.push(AppRoutes.ownerDashboardAssistant);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: ListenableBuilder(
        listenable: _scaleController,
        builder: (context, _) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B61FF), Color(0xFF9F7BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7B61FF).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.08),
                  onTap: () => _onTap(context),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({
    super.key,
    required this.navigationShell,
    this.branchPages = const <Widget>[],
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> branchPages;

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(appSessionBootstrapProvider);
    final sessionAsync = ref.watch(sessionUserProvider);
    if (sessionState.status == AppSessionStatus.unauthenticated) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context)!;
    final resolvedUser = sessionAsync.asData?.value ?? sessionState.user;

    if (kDebugMode) {
      debugPrint(
        '[OwnerDashboard] status=${sessionState.status.name} '
        'bootstrapUser=${sessionState.user?.uid ?? "(null)"} '
        'streamUser=${sessionAsync.asData?.value?.uid ?? "(null)"}',
      );
    }

    if (sessionState.status == AppSessionStatus.initializing &&
        resolvedUser == null &&
        sessionAsync.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const DashboardSkeleton(),
      );
    }

    if (sessionState.status == AppSessionStatus.error && resolvedUser == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppFadeIn(
              child: AppEmptyState(
                title: l10n.ownerWorkspaceWide,
                message: l10n.ownerLoadError,
                icon: AppIcons.cloud_off_outlined,
              ),
            ),
          ),
        ),
      );
    }

    final user = resolvedUser;
    if (user == null) {
      if (kDebugMode) {
        debugPrint(
          '[OwnerDashboard] blocking provider: user unresolved '
          '(sessionUserProvider + appSessionBootstrapProvider)',
        );
      }
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const DashboardSkeleton(),
      );
    }

    if (user.role == UserRoles.owner &&
        (user.salonId == null || user.salonId!.trim().isEmpty)) {
      return _SalonSetupScaffold(l10n: l10n);
    }

    if (kDebugMode) {
      debugPrint(
        '[OwnerDashboard] dashboard loading false '
        'uid=${user.uid} role=${user.role} salonId=${user.salonId ?? "(null)"}',
      );
    }

    final scheme = Theme.of(context).colorScheme;

    /// Finance, Customers, Team, and Overview embed the purple hero in the tab body.
    /// Settings opens from the hero header (narrow) or rail (wide), not as a tab.
    final usesOwnerHeroInBody = widget.navigationShell.currentIndex <= 3;

    final canOpenOwnerSettings =
        user.role == UserRoles.owner || user.role == UserRoles.admin;

    final destinations = <AdaptiveShellDestination>[
      AdaptiveShellDestination(
        icon: const Icon(AppIcons.account_balance_wallet_outlined),
        selectedIcon: const Icon(AppIcons.account_balance_wallet),
        label: l10n.ownerTabFinance,
      ),
      AdaptiveShellDestination(
        icon: const Icon(AppIcons.groups_2_outlined),
        selectedIcon: const Icon(AppIcons.groups),
        label: l10n.ownerTabCustomers,
      ),
      AdaptiveShellDestination(
        icon: const Icon(AppIcons.groups_outlined),
        selectedIcon: const Icon(AppIcons.groups),
        label: l10n.ownerTabTeam,
      ),
      AdaptiveShellDestination(
        icon: const Icon(AppIcons.dashboard_outlined),
        selectedIcon: const Icon(AppIcons.dashboard),
        label: l10n.ownerTabOverview,
      ),
    ];

    final appBarActions = <Widget>[
      _NotificationsButton(l10n: l10n),
      _OwnerAiAssistantAppBarButton(tooltip: l10n.ownerAiAssistantTooltip),
      IconButton(
        tooltip: l10n.ownerTooltipLanguageShort,
        onPressed: () => _toggleDashboardLocale(ref),
        icon: const Icon(AppIcons.language_outlined),
      ),
      IconButton(
        tooltip: l10n.ownerTooltipSignOut,
        onPressed: () => performAppSignOut(context),
        icon: const Icon(AppIcons.logout_rounded),
      ),
    ];

    final railActions = <AdaptiveShellRailAction>[
      AdaptiveShellRailAction(
        icon: const Icon(AppIcons.auto_awesome_outlined),
        tooltip: l10n.ownerAiAssistantTooltip,
        onTap: () => context.push(AppRoutes.ownerDashboardAssistant),
      ),
      AdaptiveShellRailAction(
        icon: _NotificationsBadgeIcon(),
        tooltip: l10n.notificationsInboxTooltip,
        onTap: () => context.push(AppRoutes.notifications),
      ),
      if (canOpenOwnerSettings)
        AdaptiveShellRailAction(
          icon: const Icon(AppIcons.settings_outlined),
          tooltip: l10n.ownerDashboardSettingsTooltip,
          onTap: () => context.push(AppRoutes.ownerSettings),
        ),
      AdaptiveShellRailAction(
        icon: const Icon(AppIcons.language_outlined),
        tooltip: l10n.ownerTooltipLanguage,
        onTap: () => _toggleDashboardLocale(ref),
      ),
      AdaptiveShellRailAction(
        icon: const Icon(AppIcons.logout_rounded),
        tooltip: l10n.ownerTooltipSignOut,
        onTap: () => performAppSignOut(context),
        color: scheme.onSurfaceVariant,
      ),
    ];

    void goToBranch(int i) {
      widget.navigationShell.goBranch(
        i,
        initialLocation: i == widget.navigationShell.currentIndex,
      );
    }

    final ownerBottomNav = OwnerZuranoBottomNav(
      selectedIndex: widget.navigationShell.currentIndex,
      onDestinationSelected: goToBranch,
      onCenterTap: () => _showOwnerShellQuickActions(context),
    );

    final shellBody = widget.branchPages.isNotEmpty
        ? ZuranoSwipeShell(
            pages: widget.branchPages,
            currentIndex: widget.navigationShell.currentIndex,
            onIndexChanged: goToBranch,
            bottomNavigationBar: ownerBottomNav,
          )
        : widget.navigationShell;

    return AdaptiveAppShell(
      destinations: destinations,
      selectedIndex: widget.navigationShell.currentIndex,
      onDestinationSelected: goToBranch,
      appBarTitle: usesOwnerHeroInBody ? null : Text(l10n.ownerDashboardTitle),
      appBarActions: usesOwnerHeroInBody ? const <Widget>[] : appBarActions,
      railLeading: Icon(
        AppIcons.content_cut_rounded,
        color: scheme.primary,
        size: 28,
      ),
      railActions: railActions,
      body: shellBody,
      bottomNavigationBar: widget.branchPages.isNotEmpty
          ? null
          : ownerBottomNav,
      extendBody: true,
    );
  }
}

Future<void> _showOwnerShellQuickActions(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final scheme = Theme.of(context).colorScheme;
  final nav = Navigator.of(context);
  final router = GoRouter.of(context);

  void popAndPush(String path) {
    nav.pop();
    Future.microtask(() => router.push(path));
  }

  void popAndPushNamed(String name) {
    nav.pop();
    Future.microtask(() => router.pushNamed(name));
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.ownerOverviewFabSheetTitle,
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.small),
              _OwnerQuickActionTile(
                icon: AppIcons.badge_outlined,
                label: l10n.teamAddBarberAction,
                onTap: () => popAndPushNamed(AppRouteNames.addTeamMember),
              ),
              _OwnerQuickActionTile(
                icon: AppIcons.point_of_sale_outlined,
                label: l10n.ownerOverviewQuickAddSale,
                onTap: () => popAndPush(AppRoutes.ownerSalesAdd),
              ),
              _OwnerQuickActionTile(
                icon: AppIcons.event_available_outlined,
                label: l10n.ownerOverviewFabBookAppointment,
                onTap: () => popAndPush(AppRoutes.bookingsNew),
              ),
              _OwnerQuickActionTile(
                icon: AppIcons.receipt_long_outlined,
                label: l10n.ownerOverviewQuickAddExpense,
                onTap: () => popAndPush(AppRoutes.ownerExpensesAdd),
              ),
              _OwnerQuickActionTile(
                icon: AppIcons.design_services_outlined,
                label: l10n.ownerOverviewSmartAddService,
                onTap: () => popAndPush(AppRoutes.ownerServices),
              ),
              _OwnerQuickActionTile(
                icon: AppIcons.person_add_alt_outlined,
                label: l10n.customersAddCustomerFab,
                onTap: () => popAndPush(AppRoutes.customerNew),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OwnerQuickActionTile extends StatelessWidget {
  const _OwnerQuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        AppIcons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class _NotificationsButton extends ConsumerWidget {
  const _NotificationsButton({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(unreadNotificationCountProvider);
    return IconButton(
      tooltip: l10n.notificationsInboxTooltip,
      onPressed: () => context.push(AppRoutes.notifications),
      icon: AppNotificationBadge(
        count: n,
        child: const Icon(AppIcons.notifications_outlined),
      ),
    );
  }
}

class _NotificationsBadgeIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(unreadNotificationCountProvider);
    return AppNotificationBadge(
      count: n,
      child: const Icon(AppIcons.notifications_outlined),
    );
  }
}

class _SalonSetupScaffold extends StatelessWidget {
  const _SalonSetupScaffold({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.ownerSalonSetupTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(l10n.ownerSalonSetupMessage, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.large),
              FilledButton(
                onPressed: () => context.go(AppRoutes.createSalon),
                child: Text(l10n.ownerSalonSetupCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
