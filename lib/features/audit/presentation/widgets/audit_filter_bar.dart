import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/audit_providers.dart';

/// Module chips + optional date picked upstream.
class AuditFilterBar extends ConsumerWidget {
  const AuditFilterBar({super.key});

  static const moduleKeys = <String?>[
    null,
    'bookings',
    'sales',
    'payroll',
    'attendance',
    'permissions',
    'expenses',
    'settings',
    'analytics',
    'customers',
    'team',
    'auth',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(auditModuleFilterProvider);

    String labelFor(String? key) {
      switch (key) {
        case null:
          return l10n.auditFilterAll;
        case 'bookings':
          return l10n.auditModuleBookings;
        case 'sales':
          return l10n.auditModuleSales;
        case 'payroll':
          return l10n.auditModulePayroll;
        case 'attendance':
          return l10n.auditModuleAttendance;
        case 'permissions':
          return l10n.auditModulePermissions;
        case 'expenses':
          return l10n.auditModuleExpenses;
        case 'settings':
          return l10n.auditModuleSettings;
        case 'analytics':
          return l10n.auditModuleAnalytics;
        case 'customers':
          return l10n.auditModuleCustomers;
        case 'team':
          return l10n.auditModuleTeam;
        case 'auth':
          return l10n.auditModuleAuth;
        default:
          return key;
      }
    }

    return Theme(
      data: ZuranoOwnerToolsTheme.chipThemeWrapper(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (final k in moduleKeys)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(labelFor(k)),
                  selected: selected == k,
                  onSelected: (_) {
                    ref.read(auditModuleFilterProvider.notifier).state = k;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
