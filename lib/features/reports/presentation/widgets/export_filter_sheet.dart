import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/zurano_owner_tools_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/reports_actions_controller.dart';
import '../../domain/report_export_kind.dart';

/// Bottom sheet: period [YYYY-MM] and optional payslip employee id.
class ExportFilterSheet extends ConsumerStatefulWidget {
  const ExportFilterSheet({
    super.key,
    required this.initialPeriod,
    this.csvKind,
    this.payslipOnly = false,
    this.initialEmployeeId,
  });

  final String initialPeriod;
  final ReportCsvExportKind? csvKind;
  final bool payslipOnly;
  final String? initialEmployeeId;

  @override
  ConsumerState<ExportFilterSheet> createState() => _ExportFilterSheetState();
}

class _ExportFilterSheetState extends ConsumerState<ExportFilterSheet> {
  late final TextEditingController _period;
  late final TextEditingController _employeeId;

  @override
  void initState() {
    super.initState();
    _period = TextEditingController(text: widget.initialPeriod);
    _employeeId = TextEditingController(text: widget.initialEmployeeId ?? '');
  }

  @override
  void dispose() {
    _period.dispose();
    _employeeId.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final actions = ref.read(reportsActionsControllerProvider.notifier);
    final loading = ref.read(reportsActionsControllerProvider);
    if (loading) return;

    final period = _period.text.trim();
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(period)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportsPeriodInvalid)),
      );
      return;
    }

    String? err;
    if (widget.payslipOnly) {
      final eid = _employeeId.text.trim();
      if (eid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportsEmployeeIdRequired)),
        );
        return;
      }
      err = await actions.generatePayslipPdf(
        periodId: period,
        employeeId: eid,
      );
    } else if (widget.csvKind != null) {
      err = await actions.requestCsvExport(
        kind: widget.csvKind!,
        periodId: period,
      );
    }

    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loading = ref.watch(reportsActionsControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ZuranoPremiumUiColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(
            widget.payslipOnly
                ? l10n.reportTypePayslipPdf
                : l10n.reportsExportCsvTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: ZuranoPremiumUiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _period,
            style: const TextStyle(color: ZuranoPremiumUiColors.textPrimary),
            decoration: ZuranoOwnerToolsTheme.zuranoInputDecoration(
              labelText: l10n.reportsPeriodLabel,
              hintText: '2026-05',
            ),
            keyboardType: TextInputType.datetime,
          ),
          if (widget.payslipOnly) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _employeeId,
              style: const TextStyle(color: ZuranoPremiumUiColors.textPrimary),
              decoration: ZuranoOwnerToolsTheme.zuranoInputDecoration(
                labelText: l10n.reportsEmployeeIdLabel,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            style: ZuranoOwnerToolsTheme.filledPrimaryButtonStyle(),
            onPressed: loading ? null : () => _submit(context),
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.reportsGenerateButton),
          ),
        ],
      ),
    );
  }
}
