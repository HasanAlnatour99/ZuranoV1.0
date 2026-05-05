import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/personalized_greeting.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/notification_providers.dart';
import '../../data/employee_header_model.dart';
import '../../data/employee_header_repository.dart';
import '../../providers/employee_header_provider.dart';
import 'employee_premium_hero_header.dart';
import 'employee_premium_hero_header_skeleton.dart';

/// Same live hero as the employee Today tab: [employeeHeaderStreamProvider] +
/// [EmployeePremiumHeroHeader].
class EmployeeStreamingHeroHeader extends ConsumerWidget {
  const EmployeeStreamingHeroHeader({
    super.key,
    this.onWorkspaceLinkRetry,
  });

  /// Optional extra invalidation when the user retries workspace link (e.g. sales streams).
  final VoidCallback? onWorkspaceLinkRetry;

  void _retryHeader(WidgetRef ref) {
    ref.invalidate(employeeHeaderStreamProvider);
    onWorkspaceLinkRetry?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerAsync = ref.watch(employeeHeaderStreamProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final unread = ref.watch(unreadNotificationCountProvider);

    return headerAsync.when(
      loading: () => const EmployeePremiumHeroHeaderSkeleton(),
      error: (e, _) {
        if (e is EmployeeHeaderException &&
            e.message == 'WORKSPACE_SCOPE_MISSING') {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 6),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.employeeHeroWorkspaceLinkMissing,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => _retryHeader(ref),
                      child: Text(l10n.employeeTodayTryAgain),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 6),
          child: Text(
            l10n.employeeHeroHeaderLoadError,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        );
      },
      data: (header) {
        final shiftLine = formatEmployeeHeaderShiftLine(
          model: header,
          l10n: l10n,
          locale: locale,
        );
        final dateText = DateFormat.yMMMEd(
          locale.toString(),
        ).format(header.headerAt);
        final greeting = getGreeting(l10n);
        return EmployeePremiumHeroHeader(
          greeting: greeting,
          name: header.name,
          salonName: header.salonName,
          tier: header.tier,
          photoUrl: header.photoUrl,
          shiftLine: shiftLine,
          formattedDate: dateText,
          unreadCount: unread,
          onSettingsTap: () => context.push(AppRoutes.settings),
          onNotificationsTap: () => context.push(AppRoutes.notifications),
        );
      },
    );
  }
}
