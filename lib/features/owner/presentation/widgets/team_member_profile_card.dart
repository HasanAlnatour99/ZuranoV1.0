import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employees/data/models/employee.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// Glass-style team card inspired by modern profile templates (photo + frosted footer).
class TeamMemberProfileCard extends StatelessWidget {
  const TeamMemberProfileCard({
    super.key,
    required this.employee,
    required this.colorIndex,
    required this.roleLabel,
    required this.statusLabel,
    required this.onSelected,
  });

  final Employee employee;
  final int colorIndex;
  final String roleLabel;
  final String statusLabel;
  final void Function(String action) onSelected;

  static const _ribbonIcons = [
    AppIcons.workspace_premium_rounded,
    AppIcons.diamond_outlined,
    AppIcons.star_rounded,
  ];

  Color _accent(ColorScheme scheme) {
    switch (colorIndex % 3) {
      case 0:
        return Color.lerp(scheme.tertiary, scheme.primary, 0.35)!;
      case 1:
        return Color.lerp(scheme.primary, scheme.surfaceTint, 0.2)!;
      default:
        return Color.lerp(scheme.secondary, scheme.tertiaryContainer, 0.25)!;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final s = parts.single;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    String ch(String s) => s.isEmpty ? '' : s.substring(0, 1);
    return (ch(parts.first) + ch(parts.last)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final accent = _accent(scheme);
    final initials = _initials(formatTeamMemberName(employee.name));
    final ribbon = _ribbonIcons[colorIndex % _ribbonIcons.length];

    return Material(
      elevation: 6,
      shadowColor: scheme.shadow.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.profileCard),
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.profileCard),
        child: SizedBox(
          height: 312,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: accent),
              Positioned(
                top: 28,
                left: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: scheme.surface.withValues(alpha: 0.92),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: accent.withValues(alpha: 0.35),
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: AppSpacing.small,
                top: 0,
                child: _RibbonBadge(icon: ribbon, scheme: scheme),
              ),
              PositionedDirectional(
                end: AppSpacing.small,
                top: AppSpacing.small,
                child: _StatusPill(
                  active: employee.isActive,
                  scheme: scheme,
                  l10n: l10n,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 148,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.52),
                        border: Border(
                          top: BorderSide(
                            color: scheme.onSurface.withValues(alpha: 0.07),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.medium,
                          AppSpacing.medium,
                          AppSpacing.medium,
                          AppSpacing.small,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeamMemberNameText(
                              employee.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      _MiniStat(
                                        label: l10n.ownerTeamCardRoleLabel,
                                        value: roleLabel,
                                        scheme: scheme,
                                        theme: theme,
                                      ),
                                      const SizedBox(width: AppSpacing.large),
                                      _MiniStat(
                                        label: l10n.ownerTeamCardStatusLabel,
                                        value: statusLabel,
                                        scheme: scheme,
                                        theme: theme,
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: l10n.ownerEditMember,
                                  onSelected: onSelected,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(l10n.ownerEditMember),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Text(
                                        employee.isActive
                                            ? l10n.ownerDeactivate
                                            : l10n.ownerActivate,
                                      ),
                                    ),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.medium,
                                      vertical: AppSpacing.small,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.surface,
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: scheme.shadow.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.ownerTeamCardManage,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          AppIcons.expand_more_rounded,
                                          size: 18,
                                          color: scheme.onSurface,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}

class _RibbonBadge extends StatelessWidget {
  const _RibbonBadge({required this.icon, required this.scheme});

  final IconData icon;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surface.withValues(alpha: 0.9),
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.medium),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
        child: Icon(icon, size: 20, color: scheme.onSurface),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.active,
    required this.scheme,
    required this.l10n,
  });

  final bool active;
  final ColorScheme scheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = active
        ? l10n.ownerTeamCardStatusActive
        : l10n.ownerTeamCardStatusInactive;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? AppIcons.bolt_rounded : AppIcons.pause_circle_outline,
              size: 16,
              color: active ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.scheme,
    required this.theme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
