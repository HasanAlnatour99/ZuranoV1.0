import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/firebase_error_message.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../payroll/application/payroll_providers.dart';
import '../../../../payroll/domain/models/payroll_adjustment.dart';

Future<void> showPayrollAdjustmentBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String salonId,
  required String employeeId,
  required String monthKey,
  required PayrollAdjustmentType type,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PayrollAdjustmentSheet(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
      type: type,
    ),
  );
}

class _PayrollAdjustmentSheet extends ConsumerStatefulWidget {
  const _PayrollAdjustmentSheet({
    required this.salonId,
    required this.employeeId,
    required this.monthKey,
    required this.type,
  });

  final String salonId;
  final String employeeId;
  final String monthKey;
  final PayrollAdjustmentType type;

  @override
  ConsumerState<_PayrollAdjustmentSheet> createState() =>
      _PayrollAdjustmentSheetState();
}

class _PayrollAdjustmentSheetState
    extends ConsumerState<_PayrollAdjustmentSheet> {
  final _amount = TextEditingController();
  final _elementName = TextEditingController();
  final _note = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRecurring = false;
  bool _isSaving = false;

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
    final isBonus = widget.type == PayrollAdjustmentType.bonus;
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
              l10n.addPayrollAdjustment,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
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
              decoration: InputDecoration(labelText: l10n.elementName),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                  ? l10n.elementName
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.noteOptional),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    selectedIcon: Icon(
                      Icons.check_circle_rounded,
                      color: scheme.primary,
                    ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return scheme.primary.withValues(alpha: 0.18);
                        }
                        return scheme.surfaceContainerLow;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
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
                    onSelectionChanged: (selected) {
                      setState(() {
                        _isRecurring = selected.first;
                      });
                    },
                  ),
                ),
              ],
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
                    await ref
                        .read(payrollActionControllerProvider.notifier)
                        .addAdjustment(
                          salonId: widget.salonId,
                          employeeId: widget.employeeId,
                          monthKey: widget.monthKey,
                          type: widget.type,
                          amount: double.parse(_amount.text.trim()),
                          reason: _elementName.text.trim(),
                          isRecurring: _isRecurring,
                          note: _note.text.trim(),
                        );
                    if (!context.mounted) return;
                    ref.invalidate(
                      teamMemberPayrollSummaryProvider(
                        TeamMemberPayrollParams(
                          salonId: widget.salonId,
                          employeeId: widget.employeeId,
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBonus
                              ? l10n.bonusAddedSuccessfully
                              : l10n.deductionAddedSuccessfully,
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(FirebaseErrorMessage.fromException(error)),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => _isSaving = false);
                    }
                  }
                },
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
