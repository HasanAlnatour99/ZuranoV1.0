import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/widgets/zurano/zurano_icon_box.dart';
import '../../data/models/audit_log_model.dart';

class AuditLogCard extends StatelessWidget {
  const AuditLogCard({
    super.key,
    required this.log,
    required this.onTap,
  });

  final AuditLogModel log;
  final VoidCallback onTap;

  IconData _iconForModule(String module) {
    switch (module) {
      case 'bookings':
        return Icons.calendar_month_outlined;
      case 'sales':
        return Icons.point_of_sale_outlined;
      case 'payroll':
        return Icons.payments_outlined;
      case 'attendance':
        return Icons.fact_check_outlined;
      case 'permissions':
      case 'team':
      case 'auth':
        return Icons.admin_panel_settings_outlined;
      case 'expenses':
        return Icons.wallet_outlined;
      case 'settings':
        return Icons.tune_outlined;
      default:
        return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final ts = log.createdAt;
    final timeStr = ts != null
        ? DateFormat.yMMMd(locale).add_jm().format(ts.toLocal())
        : l10n.auditTimestampUnknown;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: ZuranoOwnerToolsTheme.cardDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZuranoIconBox(icon: _iconForModule(log.module)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.summary,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: ZuranoPremiumUiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          log.actorName,
                          if ((log.targetLabel ?? log.targetId ?? '')
                              .trim()
                              .isNotEmpty)
                            (log.targetLabel ?? log.targetId)!,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ZuranoPremiumUiColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
