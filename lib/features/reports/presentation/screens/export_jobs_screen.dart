import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/reports_actions_controller.dart';
import '../../application/reports_providers.dart';
import '../widgets/export_job_card.dart';

class ExportJobsScreen extends ConsumerWidget {
  const ExportJobsScreen({super.key});

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    String jobId,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final actions = ref.read(reportsActionsControllerProvider.notifier);

    final pair = await actions.openExportDownload(exportJobId: jobId);
    if (!context.mounted || pair == null) return;
    final uri = Uri.tryParse(pair.downloadUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportJobOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final jobs = ref.watch(exportJobsProvider);

    return Scaffold(
      backgroundColor: ZuranoOwnerToolsTheme.background,
      appBar: ZuranoOwnerToolsTheme.appBar(
        context: context,
        title: l10n.reportsExportHistoryTitle,
      ),
      body: jobs.when(
        loading: () => ZuranoOwnerToolsTheme.loadingIndicator(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.genericError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ZuranoPremiumUiColors.textSecondary,
              ),
            ),
          ),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.exportJobsEmpty,
                  style: const TextStyle(
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final job = rows[i];
              return ExportJobCard(
                job: job,
                onDownload: () => _download(context, ref, job.id),
                onRetry: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.exportJobRetryHint)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
