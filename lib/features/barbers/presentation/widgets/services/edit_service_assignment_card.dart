import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../features/team_member_profile/presentation/theme/team_member_profile_colors.dart';

class EditServiceAssignmentCard extends StatelessWidget {
  const EditServiceAssignmentCard({
    super.key,
    required this.onTap,
  });

  /// When null (e.g. catalog still loading), the card appears disabled.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TeamMemberProfileColors.softPurple,
                TeamMemberProfileColors.softPurple.withValues(alpha: 0.65),
              ],
            ),
            border: Border.all(color: TeamMemberProfileColors.border),
            boxShadow: [
              BoxShadow(
                color: TeamMemberProfileColors.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TeamMemberProfileColors.border,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: TeamMemberProfileColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.teamServicesEditAssignmentsAction,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: TeamMemberProfileColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.teamServicesEditAssignmentCardSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: TeamMemberProfileColors.primary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        TeamMemberProfileColors.primary.withValues(alpha: 0.88),
                        TeamMemberProfileColors.primary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
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
