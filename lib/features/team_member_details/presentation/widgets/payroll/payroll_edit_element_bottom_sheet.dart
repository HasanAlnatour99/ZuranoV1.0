import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/firebase_error_message.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../payroll/application/payroll_providers.dart';
import '../../../../payroll/domain/models/payroll_adjustment.dart';
import '../../../../payroll/domain/models/team_member_payroll_summary.dart';

Future<void> showPayrollEditElementBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String salonId,
  required String employeeId,
  required String monthKey,
  required PayrollAdjustmentType type,
  required PayrollNamedAmount item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PayrollEditElementSheet(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
      type: type,
      item: item,
    ),
  );
}

class _PayrollEditElementSheet extends ConsumerStatefulWidget {
  const _PayrollEditElementSheet({
    required this.salonId,
    required this.employeeId,
    required this.monthKey,
    required this.type,
    required this.item,
  });

  final String salonId;
  final String employeeId;
  final String monthKey;
  final PayrollAdjustmentType type;
  final PayrollNamedAmount item;

  @override
  ConsumerState<_PayrollEditElementSheet> createState() =>
      _PayrollEditElementSheetState();
}

class _PayrollEditElementSheetState
    extends ConsumerState<_PayrollEditElementSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _elementName;
  late final TextEditingController _note;
  final _formKey = GlobalKey<FormState>();
  late bool _isRecurring;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: _formatAmountForField(widget.item.amount),
    );
    _elementName = TextEditingController(text: widget.item.name);
    _note = TextEditingController(text: widget.item.note ?? '');
    _isRecurring = widget.item.isRecurring;
  }

  static String _formatAmountForField(double amount) {
    final s = amount.toStringAsFixed(2);
    if (s.endsWith('.00')) return s.substring(0, s.length - 3);
    if (s.endsWith('0') && s.contains('.')) {
      return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  void dispose() {
    _amount.dispose();
    _elementName.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.updatePayrollAdjustment,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.amount),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) return l10n.amount;
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _elementName,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l10n.elementName,
                filled: true,
                fillColor: scheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.noteOptional),
            ),
            const SizedBox(height: 12),
            IgnorePointer(
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      selectedIcon: Icon(
                        Icons.check_circle_rounded,
                        color: scheme.primary,
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return scheme.primary.withValues(alpha: 0.18);
                          }
                          return scheme.surfaceContainerLow;
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return scheme.onSurface;
                          }
                          return scheme.onSurfaceVariant;
                        }),
                      ),
                      segments: [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text(l10n.notRecurring),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text(l10n.recurringOneYear),
                        ),
                      ],
                      selected: {_isRecurring},
                      onSelectionChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isSaving = true);
                        try {
                          final trimmedNote = _note.text.trim();
                          await ref
                              .read(payrollActionControllerProvider.notifier)
                              .updateAdjustmentElement(
                                salonId: widget.salonId,
                                employeeId: widget.employeeId,
                                monthKey: widget.monthKey,
                                type: widget.type,
                                reason: widget.item.name,
                                newAmount: double.parse(_amount.text.trim()),
                                isRecurring: _isRecurring,
                                note: trimmedNote.isEmpty ? null : trimmedNote,
                              );
                          if (!context.mounted) return;
                          final params = TeamMemberPayrollParams(
                            salonId: widget.salonId,
                            employeeId: widget.employeeId,
                          );
                          ref.invalidate(teamMemberPayrollSummaryProvider(params));
                          ref.invalidate(teamMemberPayrollHistoryProvider(params));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.payrollElementUpdated)),
                          );
                          Navigator.of(context).pop();
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                FirebaseErrorMessage.fromException(error),
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
                child: Text(l10n.update),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
