import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class MarkAllReadButton extends StatelessWidget {
  const MarkAllReadButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.done_all_rounded),
      label: Text(l10n.notificationsMarkAllRead),
      style: TextButton.styleFrom(
        foregroundColor: ZuranoTokens.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
