import 'package:flutter/material.dart';

/// Single permission row with a switch.
class PermissionToggleTile extends StatelessWidget {
  const PermissionToggleTile({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: scheme.onSurface)),
      subtitle: Text(
        description,
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
      ),
      value: value,
      onChanged: enabled
          ? (v) {
              onChanged(v);
            }
          : null,
    );
  }
}
