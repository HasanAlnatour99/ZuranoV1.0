import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/export_job_model.dart';

class ExportJobCard extends StatelessWidget {
  const ExportJobCard({
    super.key,
    required this.job,
    required this.onDownload,
    required this.onRetry,
  });

  final ExportJobModel job;
  final VoidCallback onDownload;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final ts = job.createdAt;
    final timeStr = ts != null
        ? DateFormat.yMMMd(locale).add_jm().format(ts.toLocal())
        : l10n.auditTimestampUnknown;

    final Color badgeColor = job.isCompleted
        ? ZuranoPremiumUiColors.softPurple
        : job.isFailed
            ? ZuranoPremiumUiColors.dangerSoft
            : ZuranoPremiumUiColors.lightSurface;

    final Color badgeFg = job.isCompleted
        ? ZuranoPremiumUiColors.deepPurple
        : job.isFailed
            ? ZuranoPremiumUiColors.danger
            : ZuranoPremiumUiColors.textSecondary;

    final statusLabel = job.isCompleted
        ? l10n.exportJobStatusCompleted
        : job.isFailed
            ? l10n.exportJobStatusFailed
            : l10n.exportJobStatusProcessing;

    return Container(
      decoration: ZuranoOwnerToolsTheme.cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.fileName.isNotEmpty ? job.fileName : job.exportType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ZuranoPremiumUiColors.border),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${job.exportType.toUpperCase()} · ${job.format.toUpperCase()}',
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            timeStr,
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (job.errorCode != null && job.errorCode!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                job.errorCode!,
                style: const TextStyle(
                  color: ZuranoPremiumUiColors.danger,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (job.isCompleted)
                Expanded(
                  child: FilledButton(
                    style: ZuranoOwnerToolsTheme.filledPrimaryButtonStyle(),
                    onPressed: onDownload,
                    child: Text(l10n.exportJobDownload),
                  ),
                ),
              if (job.isFailed) ...[
                if (job.isCompleted) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: ZuranoOwnerToolsTheme.outlinedNeutralButtonStyle(),
                    onPressed: onRetry,
                    child: Text(l10n.exportJobRetry),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
