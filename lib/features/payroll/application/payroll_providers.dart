import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/month_key_utils.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../domain/models/payroll_adjustment.dart';
import '../domain/models/payroll_record.dart';
import '../domain/models/team_member_payroll_summary.dart';
import 'payroll_service.dart';

class TeamMemberPayrollParams {
  final String salonId;
  final String employeeId;

  const TeamMemberPayrollParams({
    required this.salonId,
    required this.employeeId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamMemberPayrollParams &&
          runtimeType == other.runtimeType &&
          salonId == other.salonId &&
          employeeId == other.employeeId;

  @override
  int get hashCode => Object.hash(salonId, employeeId);
}

class CurrentPayrollMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void previousMonth() => state = DateTime(state.year, state.month - 1, 1);

  void nextMonth() => state = DateTime(state.year, state.month + 1, 1);
}

final currentPayrollMonthProvider =
    NotifierProvider<CurrentPayrollMonthNotifier, DateTime>(
      CurrentPayrollMonthNotifier.new,
    );

final currentPayrollMonthKeyProvider = Provider<String>((ref) {
  final selected = ref.watch(currentPayrollMonthProvider);
  return MonthKeyUtils.fromDate(selected);
});

final payrollAppServiceProvider = Provider<PayrollAppService>((ref) {
  final repository = ref.read(payrollRepositoryProvider);
  return PayrollAppService(payrollRepository: repository);
});

final teamMemberPayrollSummaryProvider =
    FutureProvider.family<TeamMemberPayrollSummary, TeamMemberPayrollParams>((
      ref,
      params,
    ) async {
      final selected = ref.watch(currentPayrollMonthProvider);
      final monthKey = ref.watch(currentPayrollMonthKeyProvider);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      return ref
          .read(payrollAppServiceProvider)
          .loadSummary(
            salonId: params.salonId,
            employeeId: params.employeeId,
            monthKey: monthKey,
            monthStart: MonthKeyUtils.monthStart(selected),
            nextMonthStart: MonthKeyUtils.nextMonthStart(selected),
            todayStart: todayStart,
            tomorrowStart: tomorrowStart,
          );
    });

final teamMemberPayrollHistoryProvider =
    FutureProvider.family<List<PayrollRecord>, TeamMemberPayrollParams>((
      ref,
      params,
    ) {
      return ref
          .read(payrollRepositoryProvider)
          .getTeamMemberPayrollHistory(
            salonId: params.salonId,
            employeeId: params.employeeId,
            limit: 12,
          );
    });

class PayrollActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  bool get _isActive => ref.mounted;

  Future<void> addAdjustment({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required double amount,
    required String reason,
    required bool isRecurring,
    String? note,
  }) async {
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) throw StateError('Not authenticated.');
    final service = ref.read(payrollAppServiceProvider);
    final summary = await ref.read(
      teamMemberPayrollSummaryProvider(
        TeamMemberPayrollParams(salonId: salonId, employeeId: employeeId),
      ).future,
    );
    if (!_isActive) return;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() {
      return service.addAdjustment(
        salonId: salonId,
        employeeId: employeeId,
        monthKey: monthKey,
        type: type,
        amount: amount,
        reason: reason,
        isRecurring: isRecurring,
        note: note,
        summary: summary,
        actor: user,
      );
    });
    if (!_isActive) return;
    state = nextState;
  }

  Future<void> generatePayslip({
    required String salonId,
    required String employeeId,
  }) async {
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) throw StateError('Not authenticated.');
    final service = ref.read(payrollAppServiceProvider);
    final summary = await ref.read(
      teamMemberPayrollSummaryProvider(
        TeamMemberPayrollParams(salonId: salonId, employeeId: employeeId),
      ).future,
    );
    if (!_isActive) return;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => service.generatePayslip(summary: summary, actor: user),
    );
    if (!_isActive) return;
    state = nextState;
  }

  Future<void> reverseLatestPayrollMonth({
    required String salonId,
    required String employeeId,
  }) async {
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) throw StateError('Not authenticated.');
    final service = ref.read(payrollAppServiceProvider);
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => service.reverseLatestPayrollMonth(
        salonId: salonId,
        employeeId: employeeId,
        actor: user,
      ),
    );
    if (!_isActive) return;
    state = nextState;
  }

  Future<void> removeAdjustmentElement({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required String reason,
  }) async {
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) throw StateError('Not authenticated.');
    final service = ref.read(payrollAppServiceProvider);
    final summary = await ref.read(
      teamMemberPayrollSummaryProvider(
        TeamMemberPayrollParams(salonId: salonId, employeeId: employeeId),
      ).future,
    );
    if (!_isActive) return;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => service.removeAdjustmentElement(
        salonId: salonId,
        employeeId: employeeId,
        monthKey: monthKey,
        type: type,
        reason: reason,
        summary: summary,
        actor: user,
      ),
    );
    if (!_isActive) return;
    state = nextState;
    if (nextState.hasError) {
      Error.throwWithStackTrace(nextState.error!, nextState.stackTrace!);
    }
  }

  Future<void> updateAdjustmentElement({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required String reason,
    required double newAmount,
    required bool isRecurring,
    String? note,
  }) async {
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) throw StateError('Not authenticated.');
    final service = ref.read(payrollAppServiceProvider);
    final summary = await ref.read(
      teamMemberPayrollSummaryProvider(
        TeamMemberPayrollParams(salonId: salonId, employeeId: employeeId),
      ).future,
    );
    if (!_isActive) return;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() {
      return service.updateAdjustmentElement(
        salonId: salonId,
        employeeId: employeeId,
        monthKey: monthKey,
        type: type,
        reason: reason,
        newAmount: newAmount,
        isRecurring: isRecurring,
        note: note,
        summary: summary,
        actor: user,
      );
    });
    if (!_isActive) return;
    state = nextState;
  }
}

final payrollActionControllerProvider =
    AsyncNotifierProvider.autoDispose<PayrollActionController, void>(
      PayrollActionController.new,
    );
