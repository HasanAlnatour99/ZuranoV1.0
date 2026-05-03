import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../employee_today/application/break_timer_provider.dart';

/// Live break countdown / exceeded timer for the employee Today attendance card.
class BreakCountdownCard extends ConsumerWidget {
  const BreakCountdownCard({
    super.key,
    required this.breakStartedAt,
    required this.remainingAllowanceMinutes,
    this.shiftStart,
    this.shiftEnd,
  });

  final DateTime breakStartedAt;
  final int remainingAllowanceMinutes;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final timer = ref.watch(
      breakTimerProvider(
        BreakTimerArgs(
          breakOutAt: breakStartedAt,
          remainingAllowanceMinutes: remainingAllowanceMinutes,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
        ),
      ),
    );

    return timer.when(
      data: (state) {
        final isExceeded = state.isExceeded;
        final bg = isExceeded
            ? scheme.errorContainer.withValues(alpha: 0.35)
            : scheme.primaryContainer.withValues(alpha: 0.45);
        final border = isExceeded
            ? scheme.error.withValues(alpha: 0.35)
            : scheme.primary.withValues(alpha: 0.22);
        final iconColor = isExceeded ? scheme.error : scheme.primary;

        return Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isExceeded ? Icons.warning_rounded : Icons.timer_rounded,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isExceeded
                      ? l10n.employeeTodayBreakCountdownExceeded(
                          state.exceededLabel,
                        )
                      : l10n.employeeTodayBreakCountdownRemaining(
                          state.remainingLabel,
                        ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
