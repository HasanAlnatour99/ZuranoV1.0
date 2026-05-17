import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/id_generator.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/repository_providers.dart';
import '../data/firestore_smart_workspace_repository.dart';
import '../data/smart_workspace_intent_service.dart';
import '../domain/models/smart_workspace_intent.dart';
import '../domain/models/smart_workspace_models.dart';
import '../domain/repositories/smart_workspace_repository.dart';
import 'smart_workspace_surface_builder.dart';

enum SmartWorkspaceConversationRole { user, assistant }

class SmartWorkspaceConversationMessage {
  const SmartWorkspaceConversationMessage({
    required this.id,
    required this.role,
    this.text,
    this.surface,
    required this.createdAt,
  });

  final String id;
  final SmartWorkspaceConversationRole role;
  final String? text;
  final SmartWorkspaceSurface? surface;
  final DateTime createdAt;
}

class SmartWorkspaceState {
  const SmartWorkspaceState({
    this.messages = const [],
    this.isLoading = false,
    this.lastError,
    this.lastPrompt,
    this.currentIntent,
    this.currentSurface,
    this.selections = const <String, String>{},
  });

  final List<SmartWorkspaceConversationMessage> messages;
  final bool isLoading;
  final Object? lastError;
  final String? lastPrompt;
  final SmartWorkspaceIntent? currentIntent;
  final SmartWorkspaceSurface? currentSurface;
  final Map<String, String> selections;

  SmartWorkspaceState copyWith({
    List<SmartWorkspaceConversationMessage>? messages,
    bool? isLoading,
    Object? lastError = _sentinel,
    Object? lastPrompt = _sentinel,
    Object? currentIntent = _sentinel,
    Object? currentSurface = _sentinel,
    Map<String, String>? selections,
  }) {
    return SmartWorkspaceState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      lastError: identical(lastError, _sentinel) ? this.lastError : lastError,
      lastPrompt: identical(lastPrompt, _sentinel)
          ? this.lastPrompt
          : lastPrompt as String?,
      currentIntent: identical(currentIntent, _sentinel)
          ? this.currentIntent
          : currentIntent as SmartWorkspaceIntent?,
      currentSurface: identical(currentSurface, _sentinel)
          ? this.currentSurface
          : currentSurface as SmartWorkspaceSurface?,
      selections: selections ?? this.selections,
    );
  }
}

final smartWorkspaceRepositoryProvider = Provider<SmartWorkspaceRepository>((
  ref,
) {
  return FirestoreSmartWorkspaceRepository(
    employeeRepository: ref.watch(employeeRepositoryProvider),
    payrollElementRepository: ref.watch(payrollElementRepositoryProvider),
    employeeElementEntryRepository: ref.watch(
      employeeElementEntryRepositoryProvider,
    ),
    quickPayUseCase: ref.watch(quickPayUseCaseProvider),
    payrollRunRepository: ref.watch(payrollRunRepositoryProvider),
    salesRepository: ref.watch(salesRepositoryProvider),
    expenseRepository: ref.watch(expenseRepositoryProvider),
    attendanceRepository: ref.watch(attendanceRepositoryProvider),
    salonRepository: ref.watch(salonRepositoryProvider),
  );
});

final smartWorkspaceIntentServiceProvider =
    Provider<SmartWorkspaceIntentService>((ref) {
      return SmartWorkspaceIntentService(auth: ref.watch(firebaseAuthProvider));
    });

final smartWorkspaceSurfaceBuilderProvider =
    Provider<SmartWorkspaceSurfaceBuilder>((ref) {
      return SmartWorkspaceSurfaceBuilder(
        repository: ref.watch(smartWorkspaceRepositoryProvider),
      );
    });

final smartWorkspaceControllerProvider =
    NotifierProvider.autoDispose<SmartWorkspaceController, SmartWorkspaceState>(
      SmartWorkspaceController.new,
    );

class SmartWorkspaceController extends Notifier<SmartWorkspaceState> {
  SmartWorkspaceIntentService get _intentService =>
      ref.read(smartWorkspaceIntentServiceProvider);
  SmartWorkspaceSurfaceBuilder get _surfaceBuilder =>
      ref.read(smartWorkspaceSurfaceBuilderProvider);
  SmartWorkspaceRepository get _repository =>
      ref.read(smartWorkspaceRepositoryProvider);

  @override
  SmartWorkspaceState build() {
    return const SmartWorkspaceState();
  }

  Future<void> submitPrompt({
    required String prompt,
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty || state.isLoading) {
      return;
    }

    final nextMessages = [
      ...state.messages,
      SmartWorkspaceConversationMessage(
        id: generateId(),
        role: SmartWorkspaceConversationRole.user,
        text: trimmedPrompt,
        createdAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(
      messages: nextMessages,
      isLoading: true,
      lastError: null,
      lastPrompt: trimmedPrompt,
      currentIntent: null,
      currentSurface: null,
      selections: const <String, String>{},
    );

    try {
      final intent = await _intentService.parseIntent(
        prompt: trimmedPrompt,
        localeCode: localeCode,
      );
      final surface = await _surfaceBuilder.build(
        salonId: salonId,
        localeCode: localeCode,
        currentUserId: currentUserId,
        intent: intent,
        selections: const <String, String>{},
      );

      state = state.copyWith(
        isLoading: false,
        lastError: null,
        currentIntent: intent,
        currentSurface: surface,
        messages: [
          ...nextMessages,
          SmartWorkspaceConversationMessage(
            id: generateId(),
            role: SmartWorkspaceConversationRole.assistant,
            surface: surface,
            createdAt: DateTime.now(),
          ),
        ],
      );
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, lastError: error);
    }
  }

  Future<void> retry({
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    final prompt = state.lastPrompt;
    if (prompt == null || prompt.trim().isEmpty) {
      return;
    }
    await submitPrompt(
      prompt: prompt,
      salonId: salonId,
      localeCode: localeCode,
      currentUserId: currentUserId,
    );
  }

  Future<void> applyAction({
    required SmartWorkspaceAction action,
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    if (state.isLoading) {
      return;
    }

    switch (action.type) {
      case SmartWorkspaceActionType.prompt:
        final prompt = action.prompt;
        if (prompt != null && prompt.trim().isNotEmpty) {
          await submitPrompt(
            prompt: prompt,
            salonId: salonId,
            localeCode: localeCode,
            currentUserId: currentUserId,
          );
        }
        return;
      case SmartWorkspaceActionType.setSelection:
        final key = action.selectionKey;
        final value = action.selectionValue;
        if (key == null || key.isEmpty || value == null || value.isEmpty) {
          return;
        }
        final nextSelections = Map<String, String>.from(state.selections)
          ..[key] = value;
        await _rebuildCurrentSurface(
          salonId: salonId,
          localeCode: localeCode,
          currentUserId: currentUserId,
          selections: nextSelections,
        );
        return;
      case SmartWorkspaceActionType.submit:
        final command = action.command;
        if (command == null || command.isEmpty) {
          return;
        }
        await _executeCommand(
          command: command,
          salonId: salonId,
          localeCode: localeCode,
          currentUserId: currentUserId,
        );
        return;
      case SmartWorkspaceActionType.refresh:
        await _rebuildCurrentSurface(
          salonId: salonId,
          localeCode: localeCode,
          currentUserId: currentUserId,
          selections: state.selections,
        );
        return;
      case SmartWorkspaceActionType.navigate:
        return;
    }
  }

  Future<void> selectEmployee({
    required String employeeId,
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    final nextSelections = Map<String, String>.from(state.selections)
      ..['employeeId'] = employeeId;
    await _rebuildCurrentSurface(
      salonId: salonId,
      localeCode: localeCode,
      currentUserId: currentUserId,
      selections: nextSelections,
    );
  }

  Future<void> selectPeriod({
    required DateTime period,
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    final nextSelections = Map<String, String>.from(state.selections)
      ..['periodYear'] = '${period.year}'
      ..['periodMonth'] = '${period.month}';
    await _rebuildCurrentSurface(
      salonId: salonId,
      localeCode: localeCode,
      currentUserId: currentUserId,
      selections: nextSelections,
    );
  }

  Future<void> selectDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    final nextSelections = Map<String, String>.from(state.selections)
      ..['startDate'] = _formatDate(startDate)
      ..['endDate'] = _formatDate(endDate);
    await _rebuildCurrentSurface(
      salonId: salonId,
      localeCode: localeCode,
      currentUserId: currentUserId,
      selections: nextSelections,
    );
  }

  Future<void> _rebuildCurrentSurface({
    required String salonId,
    required String localeCode,
    required String currentUserId,
    required Map<String, String> selections,
  }) async {
    final intent = state.currentIntent;
    if (intent == null) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      lastError: null,
      selections: selections,
    );
    try {
      final surface = await _surfaceBuilder.build(
        salonId: salonId,
        localeCode: localeCode,
        currentUserId: currentUserId,
        intent: intent,
        selections: selections,
      );
      state = state.copyWith(
        isLoading: false,
        currentSurface: surface,
        messages: _replaceLastAssistantSurface(surface),
      );
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, lastError: error);
    }
  }

  Future<void> _executeCommand({
    required String command,
    required String salonId,
    required String localeCode,
    required String currentUserId,
  }) async {
    final intent = state.currentIntent;
    if (intent == null) {
      return;
    }

    state = state.copyWith(isLoading: true, lastError: null);
    try {
      switch (command) {
        case 'create_payroll_element':
          final proposal = PayrollElementProposal(
            name: intent.elementName?.trim() ?? '',
            classification:
                state.selections['classification'] ??
                intent.elementClassification ??
                'earning',
            recurrenceType:
                state.selections['recurrenceType'] ??
                intent.elementRecurrenceType ??
                'recurring',
            calculationMethod:
                state.selections['calculationMethod'] ??
                intent.elementCalculationMethod ??
                'fixed',
            defaultAmount: intent.elementDefaultAmount ?? 0,
          );
          await _repository.createPayrollElement(
            salonId: salonId,
            proposal: proposal,
          );
          final nextIntent = SmartWorkspaceIntent(
            flow: SmartWorkspaceFlowType.payrollSetupWizard,
            employeeQuery: intent.employeeQuery,
            year: intent.year,
            month: intent.month,
          );
          final surface = await _surfaceBuilder.build(
            salonId: salonId,
            localeCode: localeCode,
            currentUserId: currentUserId,
            intent: nextIntent,
            selections: state.selections,
          );
          state = state.copyWith(
            isLoading: false,
            currentIntent: nextIntent,
            currentSurface: surface,
            messages: [
              ...state.messages,
              SmartWorkspaceConversationMessage(
                id: generateId(),
                role: SmartWorkspaceConversationRole.assistant,
                surface: surface,
                createdAt: DateTime.now(),
              ),
            ],
          );
          return;
        case 'apply_attendance_correction':
          final selectedRecordId = state.selections['recordId'];
          String? recordId = selectedRecordId;
          if (recordId == null || recordId.isEmpty) {
            final range =
                _selectedDateRange(intent, state.selections) ??
                _defaultLastWeek();
            final data = await _repository.getAttendanceCorrectionData(
              salonId: salonId,
              startDate: range.start,
              endDate: range.end,
              employeeId: state.selections['employeeId'],
              employeeQuery: state.selections['employeeId'] == null
                  ? intent.employeeQuery
                  : null,
            );
            recordId = data.selectedRecord?.id;
          }
          if (recordId == null || recordId.isEmpty) {
            throw StateError('No attendance record selected for correction.');
          }
          await _repository.applyAttendanceCorrection(
            salonId: salonId,
            proposal: AttendanceCorrectionProposal(
              recordId: recordId,
              approvedByUid: currentUserId,
              status: intent.attendanceStatus,
              checkInTime: intent.checkInTime,
              checkOutTime: intent.checkOutTime,
              note: intent.note,
            ),
          );
          await _rebuildCurrentSurface(
            salonId: salonId,
            localeCode: localeCode,
            currentUserId: currentUserId,
            selections: state.selections,
          );
          return;
      }
      state = state.copyWith(isLoading: false);
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, lastError: error);
    }
  }

  List<SmartWorkspaceConversationMessage> _replaceLastAssistantSurface(
    SmartWorkspaceSurface surface,
  ) {
    final messages = [...state.messages];
    for (var index = messages.length - 1; index >= 0; index -= 1) {
      final message = messages[index];
      if (message.role == SmartWorkspaceConversationRole.assistant) {
        messages[index] = SmartWorkspaceConversationMessage(
          id: message.id,
          role: message.role,
          surface: surface,
          createdAt: message.createdAt,
        );
        return messages;
      }
    }
    messages.add(
      SmartWorkspaceConversationMessage(
        id: generateId(),
        role: SmartWorkspaceConversationRole.assistant,
        surface: surface,
        createdAt: DateTime.now(),
      ),
    );
    return messages;
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

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

const Object _sentinel = Object();
