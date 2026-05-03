import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({
    super.key,
    required this.onOpenSettings,
    this.subtitleOverride,
  });

  final VoidCallback onOpenSettings;

  /// When set (e.g. Firestore index still provisioning), replaces [notificationsEmptySubtitle].
  final String? subtitleOverride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.sectionShadow,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ZuranoTokens.primaryGradient,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.notificationsEmptyTitle,
              style: const TextStyle(
                color: ZuranoTokens.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitleOverride ?? l10n.notificationsEmptySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ZuranoTokens.textGray,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: Text(l10n.notificationsPreferencesTitle),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZuranoTokens.primary,
                side: const BorderSide(color: ZuranoTokens.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ZuranoTokens.radiusButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
