import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/keyboard_safe_form_scaffold.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../employees/data/models/employee.dart';
import '../../data/models/employee_element_entry_model.dart';
import '../../data/models/payroll_element_model.dart';
import '../../data/payroll_constants.dart';
import '../../logic/payroll_dashboard_providers.dart';
import '../widgets/payroll_recurrence_badge.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class EmployeePayrollSetupScreen extends ConsumerWidget {
  const EmployeePayrollSetupScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(employeePayrollEntriesProvider(employeeId));
    final employeesAsync = ref.watch(employeesStreamProvider);
    final elementsAsync = ref.watch(payrollElementsStreamProvider);

    return Scaffold(
      appBar: AppPageHeader(title: Text(l10n.payrollEmployeeSetupTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'employee_payroll_setup_add_entry_fab',
        onPressed: () => _showEntrySheet(context, ref),
        icon: const Icon(AppIcons.add_rounded),
        label: Text(l10n.payrollEmployeeAddEntry),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 36)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.payrollEmployeeSetupTitle,
              message: l10n.payrollGenericError,
              icon: AppIcons.person_search_outlined,
            ),
          ),
        ),
        data: (entries) {
          final employee = _firstEmployeeById(
            employeesAsync.asData?.value ?? const [],
            employeeId,
          );
          final elements =
              elementsAsync.asData?.value ?? const <PayrollElementModel>[];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.large),
            children: [
              Text(
                employee == null
                    ? l10n.payrollEmployeeSetupTitle
                    : formatTeamMemberName(employee.name),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.small / 2),
              Text(
                l10n.payrollEmployeeSetupSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              if (entries.isEmpty)
                AppEmptyState(
                  title: l10n.payrollEmployeeEntriesEmptyTitle,
                  message: l10n.payrollEmployeeEntriesEmptySubtitle,
                  icon: AppIcons.payments_outlined,
                )
              else
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.medium),
                  _EntryCard(
                    entry: entries[i],
                    element: _firstElementByCode(
                      elements,
                      entries[i].elementCode,
                    ),
                    onDelete: () async {
                      final salonId = ref
                          .read(sessionUserProvider)
                          .asData
                          ?.value
                          ?.salonId
                          ?.trim();
                      if (salonId == null || salonId.isEmpty) {
                        return;
                      }
                      await ref
                          .read(employeeElementEntryRepositoryProvider)
                          .deleteEntry(salonId, entries[i].id);
                      ref.invalidate(
                        employeePayrollEntriesProvider(employeeId),
                      );
                    },
                  ),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEntrySheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final salonId = ref
        .read(sessionUserProvider)
        .asData
        ?.value
        ?.salonId
        ?.trim();
    final employees =
        ref.read(employeesStreamProvider).asData?.value ?? const [];
    final elements =
        ref.read(payrollElementsStreamProvider).asData?.value ?? const [];
    if (salonId == null || salonId.isEmpty || elements.isEmpty) {
      return;
    }
    final employee = _firstEmployeeById(employees, employeeId);
    if (employee == null) {
      return;
    }

    final amountController = TextEditingController(text: '0');
    final percentageController = TextEditingController();
    final noteController = TextEditingController();
    PayrollElementModel selectedElement = elements.first;

    await showAppModalBottomSheet<void>(
      context: context,
      expand: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return KeyboardSafeModalFormScroll(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.payrollEmployeeAddEntry,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppSelectField<String>(
                    label: l10n.payrollFieldElement,
                    value: selectedElement.code,
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedElement = elements.firstWhere(
                            (element) => element.code == value,
                          );
                        });
                      }
                    },
                    options: elements
                        .map(
                          (element) => AppSelectOption(
                            value: element.code,
                            label: element.name,
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AppTextField(
                    label: l10n.payrollFieldAmount,
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AppTextField(
                    label: l10n.payrollFieldPercentageOptional,
                    controller: percentageController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  AppTextField(
                    label: l10n.payrollFieldNote,
                    controller: noteController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  AppPrimaryButton(
                    label: l10n.payrollActionSave,
                    onPressed: () async {
                      final now = DateTime.now();
                      await ref
                          .read(employeeElementEntryRepositoryProvider)
                          .createEntry(
                            salonId,
                            EmployeeElementEntryModel(
                              id: '',
                              employeeId: employee.id,
                              employeeName: formatTeamMemberName(employee.name),
                              elementCode: selectedElement.code,
                              elementName: selectedElement.name,
                              classification: selectedElement.classification,
                              recurrenceType: selectedElement.recurrenceType,
                              amount:
                                  double.tryParse(amountController.text) ?? 0,
                              percentage:
                                  percentageController.text.trim().isEmpty
                                  ? null
                                  : double.tryParse(
                                      percentageController.text.trim(),
                                    ),
                              startDate:
                                  selectedElement.recurrenceType ==
                                      PayrollRecurrenceTypes.recurring
                                  ? DateTime(now.year, now.month, 1)
                                  : null,
                              payrollYear:
                                  selectedElement.recurrenceType ==
                                      PayrollRecurrenceTypes.nonrecurring
                                  ? now.year
                                  : null,
                              payrollMonth:
                                  selectedElement.recurrenceType ==
                                      PayrollRecurrenceTypes.nonrecurring
                                  ? now.month
                                  : null,
                              note: noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim(),
                            ),
                          );
                      ref.invalidate(
                        employeePayrollEntriesProvider(employeeId),
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.element,
    required this.onDelete,
  });

  final EmployeeElementEntryModel entry;
  final PayrollElementModel? element;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.elementName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(AppIcons.delete_outline_rounded),
                ),
              ],
            ),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                PayrollRecurrenceBadge(recurrenceType: entry.recurrenceType),
                _EntryPill(label: entry.classification),
                if (element?.isSystemElement == true)
                  _EntryPill(
                    label: AppLocalizations.of(
                      context,
                    )!.payrollElementsSystemTag,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              entry.percentage != null && entry.percentage! > 0
                  ? '${entry.amount.toStringAsFixed(2)} · ${entry.percentage!.toStringAsFixed(0)}%'
                  : entry.amount.toStringAsFixed(2),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                entry.note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EntryPill extends StatelessWidget {
  const _EntryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

PayrollElementModel? _firstElementByCode(
  List<PayrollElementModel> elements,
  String code,
) {
  for (final element in elements) {
    if (element.code == code) {
      return element;
    }
  }
  return null;
}

Employee? _firstEmployeeById(List<Employee> employees, String employeeId) {
  for (final employee in employees) {
    if (employee.id == employeeId) {
      return employee;
    }
  }
  return null;
}
