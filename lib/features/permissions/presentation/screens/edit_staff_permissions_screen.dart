import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/user_roles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../application/permissions_actions_controller.dart';
import '../../application/permissions_providers.dart';
import '../../data/models/permission_key.dart';
import '../permission_labels.dart';
import '../widgets/permission_group_card.dart';
import '../widgets/permission_toggle_tile.dart';
import '../widgets/role_preset_selector.dart';

/// Edit fine-grained permissions for one staff row.
class EditStaffPermissionsScreen extends ConsumerStatefulWidget {
  const EditStaffPermissionsScreen({super.key, required this.staffUid});

  final String staffUid;

  @override
  ConsumerState<EditStaffPermissionsScreen> createState() =>
      _EditStaffPermissionsScreenState();
}

class _EditStaffPermissionsScreenState
    extends ConsumerState<EditStaffPermissionsScreen> {
  var _initialized = false;
  Map<String, bool>? _draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider).asData?.value;
    final staffAsync = ref.watch(staffPermissionForUidProvider(widget.staffUid));
    final presetsAsync = ref.watch(rolePresetsProvider);
    final actions = ref.watch(permissionsActionsControllerProvider);

    final staff = staffAsync.asData?.value;
    if (staff != null && !_initialized) {
      _initialized = true;
      _draft = Map<String, bool>.from(staff.permissions);
    }

    final readOnlyOwnerRow =
        staff != null && staff.role == 'owner' && session?.role != UserRoles.owner;

    final body = staffAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) =>
          Center(child: Text(l10n.editStaffPermissionsLoadError)),
      data: (row) {
        if (row == null) {
          return Center(child: Text(l10n.editStaffPermissionsLoadError));
        }
        final draft = _draft ?? Map<String, bool>.from(row.permissions);

        final byGroup = <String, List<PermissionKey>>{};
        for (final k in PermissionKey.values) {
          byGroup.putIfAbsent(k.l10nGroupKey, () => []).add(k);
        }
        final groupKeys = byGroup.keys.toList()..sort();

        final presetList = presetsAsync.asData?.value ?? const [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              row.displayName.trim().isNotEmpty ? row.displayName : row.email,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(row.email),
            if (readOnlyOwnerRow) ...[
              const SizedBox(height: 16),
              Text(
                l10n.editStaffPermissionsOwnerNote,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            RolePresetSelector(
              presets: presetList,
              selectedRoleId: row.roleId.trim().isEmpty ? null : row.roleId,
              enabled: !readOnlyOwnerRow && !actions.isLoading,
              onSelected: (roleId) async {
                if (roleId == null || roleId.trim().isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                await ref
                    .read(permissionsActionsControllerProvider.notifier)
                    .assignRolePreset(
                      targetUid: widget.staffUid,
                      roleId: roleId,
                    );
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.editStaffPermissionsSaved)),
                );
              },
            ),
            const SizedBox(height: 24),
            for (final gk in groupKeys)
              PermissionGroupCard(
                title: permissionGroupLabel(l10n, gk),
                children: [
                  for (final key in byGroup[gk]!)
                    PermissionToggleTile(
                      title: permissionTitle(l10n, key),
                      description: permissionDescription(l10n, key),
                      value: draft[key.firestoreKey] ?? false,
                      enabled: !readOnlyOwnerRow && !actions.isLoading,
                      onChanged: (v) {
                        setState(() {
                          final base = Map<String, bool>.from(_draft ?? row.permissions);
                          base[key.firestoreKey] = v;
                          _draft = base;
                        });
                      },
                    ),
                ],
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: readOnlyOwnerRow || actions.isLoading
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ref
                          .read(permissionsActionsControllerProvider.notifier)
                          .updateStaffPermissions(
                            targetUid: widget.staffUid,
                            permissions: _draft ?? draft,
                          );
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.editStaffPermissionsSaved)),
                      );
                    },
              child: Text(l10n.editStaffPermissionsSave),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: readOnlyOwnerRow ||
                      actions.isLoading ||
                      row.role == 'owner'
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await ref
                          .read(permissionsActionsControllerProvider.notifier)
                          .setStaffActive(
                            targetUid: widget.staffUid,
                            isActive: !row.isActive,
                          );
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.editStaffPermissionsSaved)),
                      );
                    },
              child: Text(
                row.isActive
                    ? l10n.editStaffPermissionsFreeze
                    : l10n.editStaffPermissionsUnfreeze,
              ),
            ),
          ],
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editStaffPermissionsTitle)),
      body: Stack(
        children: [
          body,
          if (actions.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
