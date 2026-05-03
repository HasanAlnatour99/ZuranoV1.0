import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_bar_leading_back.dart';
import 'app_glow_navigation_bar.dart';

/// Breakpoint (in logical pixels) above which [AdaptiveAppShell] switches
/// from the phone bottom-nav layout to the wider [NavigationRail] layout.
///
/// Width-based on purpose — orientation alone is unreliable (a large phone in
/// landscape is still narrow for a permanent rail, while an iPad in portrait
/// has enough width to host one comfortably).
const double kAdaptiveShellBreakpoint = 700;

/// A single destination in the adaptive shell. Icon-only targets are fine —
/// the shell applies the label only where needed.
class AdaptiveShellDestination {
  const AdaptiveShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;

  /// Optional tooltip, used by the rail's icon buttons and the compact bar.
  final String? tooltip;
}

/// A top-level header/footer control rendered in the navigation rail trailing
/// slot (notifications, settings, sign out, etc.).
class AdaptiveShellRailAction {
  const AdaptiveShellRailAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
}

/// Reusable adaptive navigation scaffold.
///
/// - width < [kAdaptiveShellBreakpoint]  → [AppBar] + body + bottom navigation
/// - width ≥ [kAdaptiveShellBreakpoint]  → [NavigationRail] + body (no AppBar)
///
/// Page content is treated as a dumb child: the shell never injects its own
/// greeting/subtitle, so pages stay fully in charge of their own titles and
/// the narrow layout never ends up with two stacked headers.
class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBarTitle,
    this.appBarActions = const <Widget>[],
    this.railLeading,
    this.railActions = const <AdaptiveShellRailAction>[],
    this.extendedRailThreshold = 960,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
  }) : assert(destinations.length >= 2);

  final List<AdaptiveShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// The page content. No extra padding/header is added — the caller owns
  /// those so content stays consistent across the shell modes.
  final Widget body;

  /// Narrow-mode AppBar title. Optional; pass `null` to hide the AppBar
  /// entirely in narrow mode.
  final Widget? appBarTitle;

  /// Narrow-mode AppBar actions.
  final List<Widget> appBarActions;

  /// Wide-mode rail leading (typically a brand icon).
  final Widget? railLeading;

  /// Wide-mode rail trailing action buttons. Rendered inside a scrollable
  /// column so they never overflow on short-height devices.
  final List<AdaptiveShellRailAction> railActions;

  /// Width at which the rail expands its labels. Only applies in wide mode.
  final double extendedRailThreshold;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kAdaptiveShellBreakpoint;
        if (isWide) {
          return _WideShell(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            railLeading: railLeading,
            railActions: railActions,
            extended: constraints.maxWidth >= extendedRailThreshold,
            child: body,
          );
        }
        return _NarrowShell(
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          appBarTitle: appBarTitle,
          appBarActions: appBarActions,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
          extendBody: extendBody,
          child: body,
        );
      },
    );
  }
}

class _NarrowShell extends StatelessWidget {
  const _NarrowShell({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    required this.appBarTitle,
    required this.appBarActions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  final List<AdaptiveShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final Widget? appBarTitle;
  final List<Widget> appBarActions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: extendBody,
      resizeToAvoidBottomInset: true,
      backgroundColor: scheme.surface,
      appBar: appBarTitle == null
          ? null
          : AppBar(
              leading: const AppBarLeadingBack(),
              automaticallyImplyLeading: false,
              title: appBarTitle,
              actions: appBarActions,
            ),
      body: SafeArea(top: false, bottom: false, child: child),
      bottomNavigationBar:
          bottomNavigationBar ??
          AppGlowNavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              for (final d in destinations)
                NavigationDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: d.label,
                  tooltip: d.tooltip,
                ),
            ],
          ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation:
          floatingActionButtonLocation ?? FloatingActionButtonLocation.endFloat,
    );
  }
}

class _WideShell extends StatelessWidget {
  const _WideShell({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.railLeading,
    required this.railActions,
    required this.extended,
    required this.child,
  });

  final List<AdaptiveShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? railLeading;
  final List<AdaptiveShellRailAction> railActions;
  final bool extended;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Row(
          children: [
            _ShellRail(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              leading: railLeading,
              actions: railActions,
              extended: extended,
            ),
            VerticalDivider(width: 1, color: scheme.outline),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Custom rail that mirrors Material's [NavigationRail] look but puts the
/// leading + destinations + trailing actions in a single [SingleChildScrollView].
///
/// Required because [NavigationRail.trailing] is NOT scrollable and short
/// phone landscape / short tablet heights can cause the trailing icon stack
/// to overflow the rail's vertical budget.
class _ShellRail extends StatelessWidget {
  const _ShellRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.leading,
    required this.actions,
    required this.extended,
  });

  final List<AdaptiveShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? leading;
  final List<AdaptiveShellRailAction> actions;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = extended ? 240.0 : 88.0;

    return Material(
      color: scheme.surfaceContainer,
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: Column(
            children: [
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: leading,
                ),
              for (var i = 0; i < destinations.length; i++)
                _RailDestination(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  extended: extended,
                  onTap: () => onDestinationSelected(i),
                ),
              if (actions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium,
                    vertical: AppSpacing.small,
                  ),
                  child: Divider(color: scheme.outlineVariant, height: 1),
                ),
                for (final action in actions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: IconButton(
                      tooltip: action.tooltip,
                      onPressed: action.onTap,
                      icon: action.icon,
                      color: action.color,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RailDestination extends StatelessWidget {
  const _RailDestination({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final AdaptiveShellDestination destination;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.primary : scheme.onSurfaceVariant;
    final background = selected
        ? scheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.small / 2,
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? AppSpacing.medium : 0,
              vertical: AppSpacing.small,
            ),
            child: extended
                ? Row(
                    children: [
                      IconTheme.merge(
                        data: IconThemeData(color: foreground),
                        child: selected
                            ? destination.selectedIcon
                            : destination.icon,
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: Text(
                          destination.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: foreground,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme.merge(
                        data: IconThemeData(color: foreground),
                        child: selected
                            ? destination.selectedIcon
                            : destination.icon,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
