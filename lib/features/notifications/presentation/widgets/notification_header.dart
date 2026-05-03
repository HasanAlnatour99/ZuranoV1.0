import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({
    super.key,
    required this.onBack,
    required this.onOpenSettings,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _SquareIconButton(
          semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            l10n.notificationsCenterTitle,
            style: const TextStyle(
              color: ZuranoTokens.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _SquareIconButton(
          semanticLabel: l10n.notificationsPreferencesTooltip,
          icon: Icons.settings_outlined,
          onTap: onOpenSettings,
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        onTap: onTap,
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ZuranoTokens.lightPurple,
            borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
            border: Border.all(color: ZuranoTokens.border),
            boxShadow: ZuranoTokens.softCardShadow,
          ),
          child: Icon(icon, color: ZuranoTokens.primary),
        ),
      ),
    );
  }
}
