import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../features/team_member_profile/presentation/theme/team_member_profile_colors.dart';

class AssignedServicesHeader extends StatelessWidget {
  const AssignedServicesHeader({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.teamServicesAssignedTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: TeamMemberProfileColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.teamServicesAssignedSectionSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: TeamMemberProfileColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TeamMemberProfileColors.softPurple,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TeamMemberProfileColors.border),
          ),
          child: Row(
            children: [
              Text(
                count.toString(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: TeamMemberProfileColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.format_list_bulleted_rounded,
                color: TeamMemberProfileColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
