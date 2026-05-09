import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/audit_providers.dart';
import '../widgets/audit_diff_view.dart';

class AuditLogDetailsScreen extends ConsumerWidget {
  const AuditLogDetailsScreen({super.key, required this.auditId});

  final String auditId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final asyncLog = ref.watch(auditLogDetailsProvider(auditId.trim()));

    return Scaffold(
      backgroundColor: ZuranoOwnerToolsTheme.background,
      appBar: ZuranoOwnerToolsTheme.appBar(
        context: context,
        title: l10n.auditDetailsTitle,
      ),
      body: asyncLog.when(
        loading: () => ZuranoOwnerToolsTheme.loadingIndicator(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.activityCenterError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ZuranoPremiumUiColors.textPrimary),
            ),
          ),
        ),
        data: (log) {
          if (log == null) {
            return Center(
              child: Text(
                l10n.activityCenterEmpty,
                style: const TextStyle(
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
            );
          }
          final dash = l10n.auditValueNotApplicable;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ZuranoOwnerToolsTheme.sectionCard(
                title: l10n.auditSectionSummary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.summary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ZuranoPremiumUiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _kv(context, l10n.auditLabelActionType, log.actionType),
                    _kv(context, l10n.auditLabelModule, log.module),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ZuranoOwnerToolsTheme.sectionCard(
                title: l10n.auditSectionActor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(context, l10n.auditLabelActorName, log.actorName),
                    _kv(context, l10n.auditLabelActorUid, log.actorUid),
                    _kv(context, l10n.auditLabelRole, log.actorRole),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ZuranoOwnerToolsTheme.sectionCard(
                title: l10n.auditSectionTarget,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(
                      context,
                      l10n.auditLabelTargetType,
                      log.targetType ?? dash,
                    ),
                    _kv(context, l10n.auditLabelTargetId, log.targetId ?? dash),
                    _kv(
                      context,
                      l10n.auditLabelTargetLabel,
                      log.targetLabel ?? dash,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ZuranoOwnerToolsTheme.sectionCard(
                title: l10n.auditSectionChanges,
                child: AuditDiffView(
                  before: log.before,
                  after: log.after,
                  beforeTitle: l10n.auditDiffBefore,
                  afterTitle: l10n.auditDiffAfter,
                  emptyLabel: l10n.auditDiffEmpty,
                ),
              ),
              const SizedBox(height: 12),
              ZuranoOwnerToolsTheme.sectionCard(
                title: l10n.auditSectionMetadata,
                child: _MetadataBlock(metadata: log.metadata),
              ),
              const SizedBox(height: 12),
              ZuranoOwnerToolsTheme.sectionCard(
                title: l10n.auditSectionTimestamp,
                child: Text(
                  log.createdAt != null
                      ? DateFormat.yMMMMEEEEd(locale)
                          .add_jm()
                          .format(log.createdAt!.toLocal())
                      : l10n.auditTimestampUnknown,
                  style: const TextStyle(
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _kv(BuildContext context, String k, String v) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            k,
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MetadataBlock extends StatelessWidget {
  const _MetadataBlock({required this.metadata});

  final Map<String, dynamic> metadata;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (metadata.isEmpty) {
      return Text(
        l10n.auditDiffEmpty,
        style: const TextStyle(color: ZuranoPremiumUiColors.textSecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in metadata.entries)
          _kv(context, e.key, e.value?.toString() ?? 'null'),
      ],
    );
  }
}
