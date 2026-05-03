import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:genui/genui.dart' show generateId;

import '../../../core/constants/app_routes.dart';
import '../../../core/formatting/app_money_format.dart';
import '../../../core/text/team_member_name.dart';
import '../../../l10n/app_localizations.dart';
import '../../payroll/data/models/payroll_result_model.dart';
import '../../payroll/data/payroll_constants.dart';
import '../domain/models/smart_workspace_intent.dart';
import '../domain/models/smart_workspace_models.dart';
import '../domain/repositories/smart_workspace_repository.dart';

class SmartWorkspaceSurfaceBuilder {
  SmartWorkspaceSurfaceBuilder({required SmartWorkspaceRepository repository})
    : _repository = repository;

  final SmartWorkspaceRepository _repository;

  Future<SmartWorkspaceSurface> build({
    required String salonId,
    required String localeCode,
    required String currentUserId,
    required SmartWorkspaceIntent intent,
    required Map<String, String> selections,
  }) async {
    final l10n = lookupAppLocalizations(Locale(localeCode));
    return switch (intent.flow) {
      SmartWorkspaceFlowType.payrollSetupWizard => _buildPayrollSetupSurface(
        salonId: salonId,
        l10n: l10n,
        intent: intent,
        selections: selections,
      ),
      SmartWorkspaceFlowType.addPayrollElement => _buildPayrollElementSurface(
        l10n: l10n,
        intent: intent,
        selections: selections,
      ),
      SmartWorkspaceFlowType.payrollExplanation =>
        _buildPayrollExplanationSurface(
          salonId: salonId,
          l10n: l10n,
          localeCode: localeCode,
          intent: intent,
          selections: selections,
          currentUserId: currentUserId,
        ),
      SmartWorkspaceFlowType.dynamicAnalytics => _buildAnalyticsSurface(
        salonId: salonId,
        l10n: l10n,
        localeCode: localeCode,
        intent: intent,
        selections: selections,
      ),
      SmartWorkspaceFlowType.attendanceCorrection =>
        _buildAttendanceCorrectionSurface(
          salonId: salonId,
          l10n: l10n,
          intent: intent,
          selections: selections,
          currentUserId: currentUserId,
        ),
      _ => Future.value(
        SmartWorkspaceSurface(
          surfaceId: generateId(),
          flow: SmartWorkspaceFlowType.unknown,
          title: l10n.smartWorkspaceTitle,
          summary: l10n.smartWorkspaceUnknownSummary,
          components: [
            SmartWorkspaceComponent(
              id: generateId(),
              type: SmartWorkspaceComponentType.emptyStateCard,
              title: l10n.smartWorkspaceUnknownTitle,
              subtitle: l10n.smartWorkspaceUnknownMessage,
            ),
            SmartWorkspaceComponent(
              id: generateId(),
              type: SmartWorkspaceComponentType.actionButtonRow,
              actions: [
                SmartWorkspaceAction(
                  id: generateId(),
                  label: l10n.smartWorkspaceSuggestionPayrollSetup,
                  type: SmartWorkspaceActionType.prompt,
                  prompt: l10n.smartWorkspaceSuggestionPayrollSetup,
                  primary: true,
                ),
                SmartWorkspaceAction(
                  id: generateId(),
                  label: l10n.smartWorkspaceSuggestionAnalytics,
                  type: SmartWorkspaceActionType.prompt,
                  prompt: l10n.smartWorkspaceSuggestionAnalytics,
                ),
              ],
            ),
          ],
        ),
      ),
    };
  }

  Future<SmartWorkspaceSurface> _buildPayrollSetupSurface({
    required String salonId,
    required AppLocalizations l10n,
    required SmartWorkspaceIntent intent,
    required Map<String, String> selections,
  }) async {
    final period = _selectedPeriod(intent, selections);
    final employeeId = selections['employeeId'];
    final data = await _repository.getPayrollSetupData(
      salonId: salonId,
      period: period,
      employeeId: employeeId,
      employeeQuery: employeeId == null ? intent.employeeQuery : null,
    );

    return SmartWorkspaceSurface(
      surfaceId: generateId(),
      flow: SmartWorkspaceFlowType.payrollSetupWizard,
      title: l10n.smartWorkspacePayrollSetupTitle,
      summary: l10n.smartWorkspacePayrollSetupSummary,
      components: [
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspacePayrollSetupMissingEmployees,
          value: '${data.missingSetupCount}',
          caption: l10n.smartWorkspacePayrollSetupActiveElements(
            data.elements.length,
          ),
          tone: data.missingSetupCount > 0
              ? SmartWorkspaceStatusTone.warning
              : SmartWorkspaceStatusTone.positive,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.employeePicker,
          title: l10n.smartWorkspaceEmployeePickerLabel,
          selectionKey: 'employeeId',
          selectedOptionId: data.selectedEmployee?.id,
          options: data.employees
              .map(
                (employee) => SmartWorkspaceOption(
                  id: employee.id,
                  label: formatTeamMemberName(employee.name),
                  subtitle: employee.role,
                ),
              )
              .toList(growable: false),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.periodSelector,
          title: l10n.smartWorkspacePeriodSelectorLabel,
          selectionKey: 'period',
          period: data.selectedPeriod,
        ),
        if (data.selectedEmployee != null)
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.summaryCard,
            title: formatTeamMemberName(data.selectedEmployee!.name),
            value: '${data.entries.length}',
            caption: l10n.smartWorkspacePayrollSetupEntriesCount(
              data.entries.length,
            ),
            tone: data.entries.isEmpty
                ? SmartWorkspaceStatusTone.warning
                : SmartWorkspaceStatusTone.info,
          )
        else
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.emptyStateCard,
            title: l10n.smartWorkspacePayrollSetupPickEmployeeTitle,
            subtitle: l10n.smartWorkspacePayrollSetupPickEmployeeMessage,
          ),
        ...data.entries
            .take(4)
            .map(
              (entry) => SmartWorkspaceComponent(
                id: generateId(),
                type: SmartWorkspaceComponentType.payrollElementCard,
                title: entry.elementName,
                subtitle: '${entry.classification} • ${entry.recurrenceType}',
                value: entry.amount.toStringAsFixed(2),
                caption: entry.note,
              ),
            ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.actionButtonRow,
          actions: [
            if (data.selectedEmployee != null)
              SmartWorkspaceAction(
                id: generateId(),
                label: l10n.smartWorkspaceOpenEmployeeSetup,
                type: SmartWorkspaceActionType.navigate,
                route: AppRoutes.ownerTeamMemberDetails(
                  data.selectedEmployee!.id,
                  tab: 'payroll',
                ),
                primary: true,
              ),
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceOpenPayrollRunReview,
              type: SmartWorkspaceActionType.navigate,
              route: AppRoutes.ownerPayrollRunReview,
            ),
          ],
        ),
      ],
    );
  }

  Future<SmartWorkspaceSurface> _buildPayrollElementSurface({
    required AppLocalizations l10n,
    required SmartWorkspaceIntent intent,
    required Map<String, String> selections,
  }) async {
    final elementName = intent.elementName?.trim();
    final amount = intent.elementDefaultAmount;
    final classification =
        selections['classification'] ??
        intent.elementClassification ??
        PayrollElementClassifications.earning;
    final recurrence =
        selections['recurrenceType'] ??
        intent.elementRecurrenceType ??
        PayrollRecurrenceTypes.recurring;
    final calculation =
        selections['calculationMethod'] ??
        intent.elementCalculationMethod ??
        PayrollCalculationMethods.fixed;

    if (elementName == null || elementName.isEmpty || amount == null) {
      return SmartWorkspaceSurface(
        surfaceId: generateId(),
        flow: SmartWorkspaceFlowType.addPayrollElement,
        title: l10n.smartWorkspaceAddElementTitle,
        summary: l10n.smartWorkspaceAddElementSummary,
        components: [
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.emptyStateCard,
            title: l10n.smartWorkspaceAddElementNeedsDetailsTitle,
            subtitle: l10n.smartWorkspaceAddElementNeedsDetailsMessage,
          ),
        ],
      );
    }

    return SmartWorkspaceSurface(
      surfaceId: generateId(),
      flow: SmartWorkspaceFlowType.addPayrollElement,
      title: l10n.smartWorkspaceAddElementTitle,
      summary: l10n.smartWorkspaceAddElementSummary,
      components: [
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.payrollElementCard,
          title: elementName,
          subtitle: _labelForClassification(l10n, classification),
          value: amount.toStringAsFixed(2),
          caption:
              '${_labelForRecurrence(l10n, recurrence)} • ${_labelForCalculation(l10n, calculation)}',
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.actionButtonRow,
          title: l10n.smartWorkspaceElementClassificationTitle,
          actions: [
            _selectionAction(
              l10n.smartWorkspaceClassificationEarning,
              'classification',
              PayrollElementClassifications.earning,
              selected: classification == PayrollElementClassifications.earning,
            ),
            _selectionAction(
              l10n.smartWorkspaceClassificationDeduction,
              'classification',
              PayrollElementClassifications.deduction,
              selected:
                  classification == PayrollElementClassifications.deduction,
            ),
            _selectionAction(
              l10n.smartWorkspaceClassificationInformation,
              'classification',
              PayrollElementClassifications.information,
              selected:
                  classification == PayrollElementClassifications.information,
            ),
          ],
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.actionButtonRow,
          title: l10n.smartWorkspaceElementRecurrenceTitle,
          actions: [
            _selectionAction(
              l10n.smartWorkspaceRecurrenceRecurring,
              'recurrenceType',
              PayrollRecurrenceTypes.recurring,
              selected: recurrence == PayrollRecurrenceTypes.recurring,
            ),
            _selectionAction(
              l10n.smartWorkspaceRecurrenceNonRecurring,
              'recurrenceType',
              PayrollRecurrenceTypes.nonrecurring,
              selected: recurrence == PayrollRecurrenceTypes.nonrecurring,
            ),
          ],
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.actionButtonRow,
          title: l10n.smartWorkspaceElementCalculationTitle,
          actions: [
            _selectionAction(
              l10n.smartWorkspaceCalculationFixed,
              'calculationMethod',
              PayrollCalculationMethods.fixed,
              selected: calculation == PayrollCalculationMethods.fixed,
            ),
            _selectionAction(
              l10n.smartWorkspaceCalculationPercentage,
              'calculationMethod',
              PayrollCalculationMethods.percentage,
              selected: calculation == PayrollCalculationMethods.percentage,
            ),
            _selectionAction(
              l10n.smartWorkspaceCalculationDerived,
              'calculationMethod',
              PayrollCalculationMethods.derived,
              selected: calculation == PayrollCalculationMethods.derived,
            ),
          ],
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.confirmationPanel,
          title: l10n.smartWorkspaceConfirmationTitle,
          subtitle: l10n.smartWorkspaceAddElementConfirmMessage,
          lines: [
            SmartWorkspaceFactLine(
              label: l10n.smartWorkspaceFieldName,
              value: elementName,
            ),
            SmartWorkspaceFactLine(
              label: l10n.smartWorkspaceFieldAmount,
              value: amount.toStringAsFixed(2),
            ),
            SmartWorkspaceFactLine(
              label: l10n.smartWorkspaceFieldClassification,
              value: _labelForClassification(l10n, classification),
            ),
          ],
          actions: [
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceSaveElementAction,
              type: SmartWorkspaceActionType.submit,
              command: 'create_payroll_element',
              primary: true,
            ),
          ],
        ),
      ],
    );
  }

  Future<SmartWorkspaceSurface> _buildPayrollExplanationSurface({
    required String salonId,
    required AppLocalizations l10n,
    required String localeCode,
    required SmartWorkspaceIntent intent,
    required Map<String, String> selections,
    required String currentUserId,
  }) async {
    final period = _selectedPeriod(intent, selections);
    final data = await _repository.getPayrollExplanationData(
      salonId: salonId,
      period: period,
      createdBy: currentUserId,
      employeeId: selections['employeeId'],
      employeeQuery: selections['employeeId'] == null
          ? intent.employeeQuery
          : null,
    );
    final selectedEmployee = data.selectedEmployee;

    return SmartWorkspaceSurface(
      surfaceId: generateId(),
      flow: SmartWorkspaceFlowType.payrollExplanation,
      title: l10n.smartWorkspacePayrollExplanationTitle,
      summary: l10n.smartWorkspacePayrollExplanationSummary,
      components: [
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.employeePicker,
          title: l10n.smartWorkspaceEmployeePickerLabel,
          selectionKey: 'employeeId',
          selectedOptionId: selectedEmployee?.id,
          options: data.employees
              .map(
                (employee) => SmartWorkspaceOption(
                  id: employee.id,
                  label: formatTeamMemberName(employee.name),
                  subtitle: employee.role,
                ),
              )
              .toList(growable: false),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.periodSelector,
          title: l10n.smartWorkspacePeriodSelectorLabel,
          selectionKey: 'period',
          period: data.selectedPeriod,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspaceNetPayTitle,
          value: formatAppMoney(
            data.statement.netPay,
            data.currencyCode,
            Locale(localeCode),
          ),
          caption: formatTeamMemberName(selectedEmployee?.name),
          tone: SmartWorkspaceStatusTone.positive,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.statusChip,
          title: l10n.smartWorkspacePayrollPreviewStatus,
          tone: SmartWorkspaceStatusTone.info,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.earningsBreakdownCard,
          title: l10n.smartWorkspaceEarningsBreakdownTitle,
          lines: _payrollLines(data.earnings, data.currencyCode, localeCode),
          value: formatAppMoney(
            data.statement.totalEarnings,
            data.currencyCode,
            Locale(localeCode),
          ),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.deductionsBreakdownCard,
          title: l10n.smartWorkspaceDeductionsBreakdownTitle,
          lines: _payrollLines(data.deductions, data.currencyCode, localeCode),
          value: formatAppMoney(
            data.statement.totalDeductions,
            data.currencyCode,
            Locale(localeCode),
          ),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.actionButtonRow,
          actions: [
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceOpenQuickPayAction,
              type: SmartWorkspaceActionType.navigate,
              route: AppRoutes.ownerQuickPay,
              primary: true,
            ),
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceOpenPayrollRunReview,
              type: SmartWorkspaceActionType.navigate,
              route: AppRoutes.ownerPayrollRunReview,
            ),
          ],
        ),
      ],
    );
  }

  Future<SmartWorkspaceSurface> _buildAnalyticsSurface({
    required String salonId,
    required AppLocalizations l10n,
    required String localeCode,
    required SmartWorkspaceIntent intent,
    required Map<String, String> selections,
  }) async {
    final period = _selectedPeriod(intent, selections);
    final range = _selectedDateRange(intent, selections);
    final data = await _repository.getAnalyticsData(
      salonId: salonId,
      period: period,
      startDate: range?.start,
      endDate: range?.end,
    );
    final locale = Locale(localeCode);

    return SmartWorkspaceSurface(
      surfaceId: generateId(),
      flow: SmartWorkspaceFlowType.dynamicAnalytics,
      title: l10n.smartWorkspaceAnalyticsTitle,
      summary: data.rangeLabel,
      components: [
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.periodSelector,
          title: l10n.smartWorkspacePeriodSelectorLabel,
          selectionKey: 'period',
          period: period,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.dateRangePicker,
          title: l10n.smartWorkspaceDateRangePickerLabel,
          selectionKey: 'dateRange',
          startDate: range?.start,
          endDate: range?.end,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspaceRevenueTitle,
          value: formatAppMoney(data.totalRevenue, data.currencyCode, locale),
          caption: l10n.smartWorkspaceTransactionsCount(data.transactionCount),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspaceExpensesTitle,
          value: formatAppMoney(data.totalExpenses, data.currencyCode, locale),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspacePayrollTitle,
          value: formatAppMoney(data.totalPayroll, data.currencyCode, locale),
          caption: l10n.smartWorkspaceDraftPayrollRuns(data.draftPayrollRuns),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspaceNetResultTitle,
          value: formatAppMoney(
            data.netAfterExpensesAndPayroll,
            data.currencyCode,
            locale,
          ),
          tone: data.netAfterExpensesAndPayroll >= 0
              ? SmartWorkspaceStatusTone.positive
              : SmartWorkspaceStatusTone.danger,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.chartCard,
          title: l10n.smartWorkspaceChartTitle,
          subtitle: l10n.smartWorkspaceChartSubtitle,
          points: data.chartPoints
              .map(
                (item) => SmartWorkspaceDataPoint(
                  label: item.label,
                  value: item.revenue,
                  secondaryValue: item.expenses,
                ),
              )
              .toList(growable: false),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.actionButtonRow,
          actions: [
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceOpenSalesAction,
              type: SmartWorkspaceActionType.navigate,
              route: AppRoutes.ownerSales,
              primary: true,
            ),
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceOpenExpensesAction,
              type: SmartWorkspaceActionType.navigate,
              route: AppRoutes.ownerExpenses,
            ),
            SmartWorkspaceAction(
              id: generateId(),
              label: l10n.smartWorkspaceOpenPayrollAction,
              type: SmartWorkspaceActionType.navigate,
              route: AppRoutes.ownerPayroll,
            ),
          ],
        ),
      ],
    );
  }

  Future<SmartWorkspaceSurface> _buildAttendanceCorrectionSurface({
    required String salonId,
    required AppLocalizations l10n,
    required SmartWorkspaceIntent intent,
    required Map<String, String> selections,
    required String currentUserId,
  }) async {
    final range = _selectedDateRange(intent, selections) ?? _defaultLastWeek();
    final data = await _repository.getAttendanceCorrectionData(
      salonId: salonId,
      startDate: range.start,
      endDate: range.end,
      employeeId: selections['employeeId'],
      employeeQuery: selections['employeeId'] == null
          ? intent.employeeQuery
          : null,
      recordId: selections['recordId'],
    );
    final record = data.selectedRecord;

    return SmartWorkspaceSurface(
      surfaceId: generateId(),
      flow: SmartWorkspaceFlowType.attendanceCorrection,
      title: l10n.smartWorkspaceAttendanceCorrectionTitle,
      summary: l10n.smartWorkspaceAttendanceCorrectionSummary,
      components: [
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.employeePicker,
          title: l10n.smartWorkspaceEmployeePickerLabel,
          selectionKey: 'employeeId',
          selectedOptionId: data.selectedEmployee?.id,
          options: data.employees
              .map(
                (employee) => SmartWorkspaceOption(
                  id: employee.id,
                  label: formatTeamMemberName(employee.name),
                  subtitle: employee.role,
                ),
              )
              .toList(growable: false),
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.dateRangePicker,
          title: l10n.smartWorkspaceDateRangePickerLabel,
          selectionKey: 'dateRange',
          startDate: data.startDate,
          endDate: data.endDate,
        ),
        SmartWorkspaceComponent(
          id: generateId(),
          type: SmartWorkspaceComponentType.summaryCard,
          title: l10n.smartWorkspaceAttendancePendingTitle,
          value: '${data.pendingCount}',
          caption: l10n.smartWorkspaceAttendanceCorrectionsNeeded(
            data.needsCorrectionCount,
          ),
          tone: data.pendingCount > 0
              ? SmartWorkspaceStatusTone.warning
              : SmartWorkspaceStatusTone.positive,
        ),
        if (record == null)
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.emptyStateCard,
            title: l10n.smartWorkspaceAttendanceNoRecordTitle,
            subtitle: l10n.smartWorkspaceAttendanceNoRecordMessage,
          )
        else ...[
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.summaryCard,
            title: record.employeeName,
            value: record.dateKey,
            caption: l10n.smartWorkspaceAttendanceRecordSummary(record.status),
          ),
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.statusChip,
            title: record.approvalStatus,
            tone: record.needsCorrection
                ? SmartWorkspaceStatusTone.warning
                : SmartWorkspaceStatusTone.info,
          ),
          SmartWorkspaceComponent(
            id: generateId(),
            type: SmartWorkspaceComponentType.confirmationPanel,
            title: l10n.smartWorkspaceConfirmationTitle,
            subtitle:
                intent.checkInTime != null ||
                    intent.checkOutTime != null ||
                    intent.attendanceStatus != null
                ? l10n.smartWorkspaceAttendanceConfirmMessage
                : l10n.smartWorkspaceAttendancePromptForDetails,
            lines: [
              SmartWorkspaceFactLine(
                label: l10n.smartWorkspaceFieldDate,
                value: record.dateKey,
              ),
              if (intent.attendanceStatus != null)
                SmartWorkspaceFactLine(
                  label: l10n.smartWorkspaceFieldStatus,
                  value: intent.attendanceStatus!,
                ),
              if (intent.checkInTime != null)
                SmartWorkspaceFactLine(
                  label: l10n.smartWorkspaceFieldCheckIn,
                  value: intent.checkInTime!,
                ),
              if (intent.checkOutTime != null)
                SmartWorkspaceFactLine(
                  label: l10n.smartWorkspaceFieldCheckOut,
                  value: intent.checkOutTime!,
                ),
            ],
            actions:
                intent.checkInTime != null ||
                    intent.checkOutTime != null ||
                    intent.attendanceStatus != null
                ? [
                    SmartWorkspaceAction(
                      id: generateId(),
                      label: l10n.smartWorkspaceApplyAttendanceAction,
                      type: SmartWorkspaceActionType.submit,
                      command: 'apply_attendance_correction',
                      primary: true,
                    ),
                  ]
                : [
                    SmartWorkspaceAction(
                      id: generateId(),
                      label: l10n.smartWorkspaceOpenAttendanceReviewAction,
                      type: SmartWorkspaceActionType.navigate,
                      route: AppRoutes.attendanceRequestsReview,
                      primary: true,
                    ),
                  ],
          ),
        ],
      ],
    );
  }

  SmartWorkspaceAction _selectionAction(
    String label,
    String key,
    String value, {
    required bool selected,
  }) {
    return SmartWorkspaceAction(
      id: generateId(),
      label: selected ? '$label ✓' : label,
      type: SmartWorkspaceActionType.setSelection,
      selectionKey: key,
      selectionValue: value,
      primary: selected,
    );
  }

  DateTime _selectedPeriod(
    SmartWorkspaceIntent intent,
    Map<String, String> selections,
  ) {
    final year = int.tryParse(selections['periodYear'] ?? '') ?? intent.year;
    final month = int.tryParse(selections['periodMonth'] ?? '') ?? intent.month;
    final now = DateTime.now();
    return DateTime(year ?? now.year, month ?? now.month);
  }

  DateTimeRange? _selectedDateRange(
    SmartWorkspaceIntent intent,
    Map<String, String> selections,
  ) {
    final start =
        _dateFromSelection(selections['startDate']) ?? intent.startDate;
    final end = _dateFromSelection(selections['endDate']) ?? intent.endDate;
    if (start == null || end == null) {
      return null;
    }
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _defaultLastWeek() {
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    final start = end.subtract(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }

  DateTime? _dateFromSelection(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  List<SmartWorkspaceFactLine> _payrollLines(
    List<PayrollResultModel> items,
    String currencyCode,
    String localeCode,
  ) {
    return items
        .take(6)
        .map(
          (item) => SmartWorkspaceFactLine(
            label: item.elementName,
            value: formatAppMoney(
              item.amount,
              currencyCode,
              Locale(localeCode),
            ),
          ),
        )
        .toList(growable: false);
  }

  String _labelForClassification(AppLocalizations l10n, String value) {
    return switch (value) {
      PayrollElementClassifications.earning =>
        l10n.smartWorkspaceClassificationEarning,
      PayrollElementClassifications.deduction =>
        l10n.smartWorkspaceClassificationDeduction,
      PayrollElementClassifications.information =>
        l10n.smartWorkspaceClassificationInformation,
      _ => value,
    };
  }

  String _labelForRecurrence(AppLocalizations l10n, String value) {
    return switch (value) {
      PayrollRecurrenceTypes.recurring =>
        l10n.smartWorkspaceRecurrenceRecurring,
      PayrollRecurrenceTypes.nonrecurring =>
        l10n.smartWorkspaceRecurrenceNonRecurring,
      _ => value,
    };
  }

  String _labelForCalculation(AppLocalizations l10n, String value) {
    return switch (value) {
      PayrollCalculationMethods.fixed => l10n.smartWorkspaceCalculationFixed,
      PayrollCalculationMethods.percentage =>
        l10n.smartWorkspaceCalculationPercentage,
      PayrollCalculationMethods.derived =>
        l10n.smartWorkspaceCalculationDerived,
      _ => value,
    };
  }
}
