import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../features/team_member_profile/presentation/theme/team_member_profile_colors.dart';

class AssignedServicesEmptyState extends StatelessWidget {
  const AssignedServicesEmptyState({
    super.key,
    required this.onAssignService,
  });

  final VoidCallback onAssignService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TeamMemberProfileColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: TeamMemberProfileColors.softPurple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.content_cut_rounded,
              color: TeamMemberProfileColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.teamServicesEmptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: TeamMemberProfileColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.teamServicesEmptySubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TeamMemberProfileColors.textSecondary,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: TeamMemberProfileColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: onAssignService,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.teamServicesAssignServicesAction),
          ),
        ],
      ),
    );
  }
}
