import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/application/reports_providers.dart';
import '../../application/audit_providers.dart';
import '../widgets/audit_filter_bar.dart';
import '../widgets/audit_log_card.dart';

class AuditActivityScreen extends ConsumerStatefulWidget {
  const AuditActivityScreen({super.key});

  @override
  ConsumerState<AuditActivityScreen> createState() =>
      _AuditActivityScreenState();
}

class _AuditActivityScreenState extends ConsumerState<AuditActivityScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(auditSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initial = ref.read(auditDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: l10n.activityCenterDateFilter,
      initialDateRange: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ZuranoPremiumUiColors.primaryPurple,
              onPrimary: Colors.white,
              surface: ZuranoPremiumUiColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      ref.read(auditDateRangeProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final logs = ref.watch(auditLogsProvider);
    final range = ref.watch(auditDateRangeProvider);
    final showAuditExport = ref.watch(canExportAuditCsvProvider);

    return Scaffold(
      backgroundColor: ZuranoOwnerToolsTheme.background,
      appBar: ZuranoOwnerToolsTheme.appBar(
        context: context,
        title: l10n.activityCenterTitle,
        actions: [
          if (showAuditExport)
            IconButton(
              tooltip: l10n.auditExportAuditAction,
              icon: const Icon(Icons.table_chart_outlined),
              onPressed: () => context.push(
                '${AppRoutes.ownerReportsCenter}?kind=audit',
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              l10n.activityCenterSubtitle,
              style: const TextStyle(
                color: ZuranoPremiumUiColors.textSecondary,
                height: 1.35,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              label: l10n.activityCenterSearchLabel,
              controller: _search,
              hintText: l10n.activityCenterSearchHint,
              onChanged: (v) {
                ref.read(auditSearchQueryProvider.notifier).state = v;
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: ZuranoOwnerToolsTheme.outlinedNeutralButtonStyle(),
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range_outlined, size: 18),
                  label: Text(l10n.activityCenterDateFilter),
                ),
                if (range != null)
                  TextButton(
                    style: ZuranoOwnerToolsTheme.textAccentButtonStyle(),
                    onPressed: () {
                      ref.read(auditDateRangeProvider.notifier).state = null;
                    },
                    child: Text(l10n.activityCenterClearDate),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AuditFilterBar(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: logs.when(
              loading: () => ZuranoOwnerToolsTheme.loadingIndicator(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.activityCenterError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ZuranoPremiumUiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: ZuranoOwnerToolsTheme.filledPrimaryButtonStyle(),
                        onPressed: () =>
                            ref.invalidate(auditLogsRawProvider),
                        child: Text(l10n.activityCenterRetry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.activityCenterEmpty,
                        style: const TextStyle(
                          color: ZuranoPremiumUiColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final log = items[i];
                    return AuditLogCard(
                      log: log,
                      onTap: () => context.push(
                        AppRoutes.ownerAuditLogDetails(log.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
