import 'package:flutter/material.dart';

import '../../../../../core/utils/firebase_error_message.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../features/team_member_profile/presentation/theme/team_member_profile_colors.dart';

class AssignedServicesErrorState extends StatelessWidget {
  const AssignedServicesErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = FirebaseErrorMessage.fromException(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: TeamMemberProfileColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.teamServicesLoadErrorTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TeamMemberProfileColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TeamMemberProfileColors.textSecondary,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: TeamMemberProfileColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              child: Text(l10n.teamServicesRetryAction),
            ),
          ],
        ),
      ),
    );
  }
}
