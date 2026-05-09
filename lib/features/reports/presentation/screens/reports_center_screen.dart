import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/reports_providers.dart';
import '../../domain/report_export_kind.dart';
import '../widgets/export_filter_sheet.dart';
import '../widgets/report_type_card.dart';

class ReportsCenterScreen extends ConsumerStatefulWidget {
  const ReportsCenterScreen({super.key});

  @override
  ConsumerState<ReportsCenterScreen> createState() =>
      _ReportsCenterScreenState();
}

class _ReportsCenterScreenState extends ConsumerState<ReportsCenterScreen> {
  var _didDeepLink = false;

  String get _defaultPeriod =>
      DateFormat('yyyy-MM').format(DateTime.now());

  Future<void> _openCsv(ReportCsvExportKind kind, String defaultPeriod) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: ZuranoOwnerToolsTheme.sheetDecoration(),
        child: ExportFilterSheet(
          initialPeriod: defaultPeriod,
          csvKind: kind,
        ),
      ),
    );
  }

  Future<void> _openPayslip(String defaultPeriod) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: ZuranoOwnerToolsTheme.sheetDecoration(),
        child: ExportFilterSheet(
          initialPeriod: defaultPeriod,
          payslipOnly: true,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didDeepLink) return;
    final kind = parseReportCsvExportKind(
      GoRouterState.of(context).uri.queryParameters['kind'],
    );
    if (kind != null) {
      _didDeepLink = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openCsv(kind, _defaultPeriod);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canEnter = ref.watch(canAccessReportsCenterProvider);
    if (!canEnter) {
      return Scaffold(
        backgroundColor: ZuranoOwnerToolsTheme.background,
        appBar: ZuranoOwnerToolsTheme.appBar(
          context: context,
          title: l10n.reportsCenterTitle,
        ),
        body: Center(
          child: Text(
            l10n.genericError,
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final defaultPeriod = _defaultPeriod;

    return Scaffold(
      backgroundColor: ZuranoOwnerToolsTheme.background,
      appBar: ZuranoOwnerToolsTheme.appBar(
        context: context,
        title: l10n.reportsCenterTitle,
        actions: [
          TextButton(
            style: ZuranoOwnerToolsTheme.textAccentButtonStyle(),
            onPressed: () => context.push(AppRoutes.ownerExportJobs),
            child: Text(l10n.reportsExportHistoryAction),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.reportsCenterSubtitle,
            style: const TextStyle(
              color: ZuranoPremiumUiColors.textSecondary,
              height: 1.35,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.reportsSectionExports,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ReportTypeCard(
            icon: Icons.point_of_sale_outlined,
            title: l10n.reportTypeSales,
            subtitle: l10n.reportTypeSalesSubtitle,
            onTap: () =>
                _openCsv(ReportCsvExportKind.sales, defaultPeriod),
          ),
          const SizedBox(height: 8),
          ReportTypeCard(
            icon: Icons.payments_outlined,
            title: l10n.reportTypePayroll,
            subtitle: l10n.reportTypePayrollSubtitle,
            onTap: () =>
                _openCsv(ReportCsvExportKind.payroll, defaultPeriod),
          ),
          const SizedBox(height: 8),
          ReportTypeCard(
            icon: Icons.fact_check_outlined,
            title: l10n.reportTypeAttendance,
            subtitle: l10n.reportTypeAttendanceSubtitle,
            onTap: () =>
                _openCsv(ReportCsvExportKind.attendance, defaultPeriod),
          ),
          const SizedBox(height: 8),
          ReportTypeCard(
            icon: Icons.wallet_outlined,
            title: l10n.reportTypeExpenses,
            subtitle: l10n.reportTypeExpensesSubtitle,
            onTap: () =>
                _openCsv(ReportCsvExportKind.expenses, defaultPeriod),
          ),
          const SizedBox(height: 8),
          ReportTypeCard(
            icon: Icons.manage_history_outlined,
            title: l10n.reportTypeAudit,
            subtitle: l10n.reportTypeAuditSubtitle,
            onTap: () => _openCsv(ReportCsvExportKind.audit, defaultPeriod),
          ),
          const SizedBox(height: 8),
          ReportTypeCard(
            icon: Icons.picture_as_pdf_outlined,
            title: l10n.reportTypePayslipPdf,
            subtitle: l10n.reportTypePayslipSubtitle,
            onTap: () => _openPayslip(defaultPeriod),
          ),
        ],
      ),
    );
  }
}
