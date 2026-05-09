import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/monthly_analytics_model.dart';

String _periodId(DateTime month) {
  final y = month.year.toString().padLeft(4, '0');
  final m = month.month.toString().padLeft(2, '0');
  return '$y-$m';
}

final selectedAnalyticsMonthProvider = NotifierProvider<_SelectedAnalyticsMonth, DateTime>(
  _SelectedAnalyticsMonth.new,
);

class _SelectedAnalyticsMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void select(DateTime value) {
    state = DateTime(value.year, value.month);
  }
}

final analyticsMonthsProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) {
    return Stream.value(const <String>[]);
  }
  return ref.read(analyticsRepositoryProvider).watchAnalyticsMonths(salonId);
});

final monthlyAnalyticsProvider = StreamProvider.autoDispose<MonthlyAnalyticsModel?>((ref) {
  final user = ref.watch(sessionUserProvider).asData?.value;
  final salonId = user?.salonId?.trim() ?? '';
  if (salonId.isEmpty) {
    return Stream.value(null);
  }
  final month = ref.watch(selectedAnalyticsMonthProvider);
  return ref.read(analyticsRepositoryProvider).watchMonthlyAnalytics(
        salonId,
        _periodId(month),
      );
});

