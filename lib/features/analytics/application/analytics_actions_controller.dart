import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';

class AnalyticsActionsState {
  const AnalyticsActionsState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  AnalyticsActionsState copyWith({bool? isLoading, String? errorMessage}) {
    return AnalyticsActionsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AnalyticsActionsController extends Notifier<AnalyticsActionsState> {
  @override
  AnalyticsActionsState build() => const AnalyticsActionsState();

  Future<void> generateForMonth(DateTime month) async {
    final user = ref.read(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    if (salonId.isEmpty) {
      state = state.copyWith(errorMessage: 'missing_salon');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await ref.read(analyticsRepositoryProvider).generateMonthlyAnalytics(
            salonId: salonId,
            year: month.year,
            month: month.month,
          );
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'generic_error');
    }
  }
}

final analyticsActionsControllerProvider =
    NotifierProvider<AnalyticsActionsController, AnalyticsActionsState>(
  AnalyticsActionsController.new,
);

