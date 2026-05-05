import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class AttendanceActionsCard extends StatelessWidget {
  const AttendanceActionsCard({super.key, required this.onRequestTap});

  final VoidCallback onRequestTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8FF)),
        boxShadow: [
          BoxShadow(
            color: ZuranoTokens.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.employeeAttendanceTabActionsSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1D1233),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              // Override AppTheme FilledButton minimum width so Row layout stays bounded.
              FilledButton.tonal(
                onPressed: onRequestTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: ZuranoTokens.lightPurple,
                  foregroundColor: ZuranoTokens.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.employeeAttendanceTabRequestCta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
