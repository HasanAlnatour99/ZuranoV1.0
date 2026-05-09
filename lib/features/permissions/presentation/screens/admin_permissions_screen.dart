import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../audit/application/audit_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../application/permissions_actions_controller.dart';
import '../../application/permissions_providers.dart';
import '../../data/models/staff_permission_model.dart';

/// Lists salon staff rows (`salons/{salonId}/staff`) for permission management.
class AdminPermissionsScreen extends ConsumerWidget {
  const AdminPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionUserProvider).asData?.value;
    final listAsync = ref.watch(staffPermissionsListProvider);
    final actions = ref.watch(permissionsActionsControllerProvider);
    final presetsAsync = ref.watch(rolePresetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staffPermissionsScreenTitle),
        actions: [
          if (ref.watch(canReadSalonActivityAuditProvider))
            IconButton(
              tooltip: l10n.permissionsViewAuditHistory,
              icon: const Icon(Icons.manage_history_outlined),
              onPressed: () => context.push(AppRoutes.ownerActivityCenter),
            ),
          TextButton(
            onPressed: () {
              final presets = presetsAsync.asData?.value ?? const [];
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (ctx) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: presets.isEmpty
                        ? Center(child: Text(l10n.rolePresetsEmpty))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: presets.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final p = presets[i];
                              final title = p.name.trim().isEmpty ? p.id : p.name;
                              return ListTile(
                                title: Text(title),
                                subtitle: p.description.trim().isNotEmpty
                                    ? Text(p.description)
                                    : null,
                              );
                            },
                          ),
                  );
                },
              );
            },
            child: Text(l10n.staffPermissionsRolePresetsButton),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text(l10n.genericError)),
        data: (rows) {
          if (rows.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.staffPermissionsEmpty,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (session?.role == UserRoles.owner)
                  FilledButton(
                    onPressed: actions.isLoading
                        ? null
                        : () => ref
                            .read(permissionsActionsControllerProvider.notifier)
                            .bootstrapStaffDocuments(),
                    child: Text(l10n.staffPermissionsBootstrapButton),
                  ),
              ],
            );
          }

          final sorted = [...rows]..sort((a, b) {
              int rank(String role) {
                if (role == 'owner') return 0;
                if (role == 'admin') return 1;
                return 2;
              }

              final c = rank(a.role).compareTo(rank(b.role));
              if (c != 0) return c;
              return a.displayName.compareTo(b.displayName);
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.staffPermissionsScreenSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              final staff = sorted[index - 1];
              return _StaffCard(
                staff: staff,
                onTap: () => context.push(
                  AppRoutes.ownerStaffPermissionsEdit(staff.uid),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.staff, required this.onTap});

  final StaffPermissionModel staff;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final roleLabel = switch (staff.role) {
      'owner' => l10n.staffPermissionsRoleOwner,
      'admin' => l10n.staffPermissionsRoleAdmin,
      _ => l10n.staffPermissionsRoleBarber,
    };

    final statusLabel =
        staff.isActive ? l10n.staffPermissionsActive : l10n.staffPermissionsFrozen;
    final statusColor =
        staff.isActive ? scheme.primary : scheme.error;

    return Card(
      child: ListTile(
        title: Text(
          staff.displayName.trim().isNotEmpty
              ? staff.displayName
              : staff.email,
        ),
        subtitle: Text(staff.email),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text(roleLabel),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(statusLabel),
              visualDensity: VisualDensity.compact,
              labelStyle: TextStyle(color: statusColor),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
