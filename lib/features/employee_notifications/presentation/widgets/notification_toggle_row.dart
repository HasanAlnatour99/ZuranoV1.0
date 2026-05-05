import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';

class NotificationToggleRow extends StatelessWidget {
  const NotificationToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(
          color: ZuranoTokens.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
