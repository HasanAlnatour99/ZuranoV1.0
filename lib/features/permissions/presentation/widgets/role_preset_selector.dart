import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/models/role_preset_model.dart';

/// Dropdown of salon role presets (also supports "Custom").
class RolePresetSelector extends StatelessWidget {
  const RolePresetSelector({
    super.key,
    required this.presets,
    required this.selectedRoleId,
    required this.onSelected,
    this.enabled = true,
  });

  final List<RolePresetModel> presets;
  final String? selectedRoleId;
  final ValueChanged<String?> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final items = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        value: null,
        child: Text(l10n.editStaffPermissionsPresetNone),
      ),
      for (final p in presets)
        DropdownMenuItem<String?>(
          value: p.id,
          child: Text(p.name.trim().isEmpty ? p.id : p.name),
        ),
    ];

    return DropdownButtonFormField<String?>(
      key: ValueKey<String>(
        '${selectedRoleId ?? 'none'}:${presets.map((p) => p.id).join(',')}',
      ),
      initialValue: _safeValue(selectedRoleId, presets),
      decoration: InputDecoration(
        labelText: l10n.editStaffPermissionsPresetLabel,
        filled: true,
        fillColor: scheme.surfaceContainerLow,
      ),
      items: items,
      onChanged: enabled ? onSelected : null,
    );
  }

  String? _safeValue(String? selected, List<RolePresetModel> presets) {
    if (selected == null || selected.trim().isEmpty) return null;
    final ok = presets.any((p) => p.id == selected);
    return ok ? selected : null;
  }
}
