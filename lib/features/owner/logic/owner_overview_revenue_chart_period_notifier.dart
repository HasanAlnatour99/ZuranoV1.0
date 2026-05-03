import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'owner_overview_state.dart';

class OwnerOverviewRevenueChartPeriodNotifier
    extends Notifier<OwnerOverviewRevenueChartPeriod> {
  @override
  OwnerOverviewRevenueChartPeriod build() =>
      OwnerOverviewRevenueChartPeriod.month;

  void setPeriod(OwnerOverviewRevenueChartPeriod period) => state = period;
}

final ownerOverviewRevenueChartPeriodProvider =
    NotifierProvider<OwnerOverviewRevenueChartPeriodNotifier,
        OwnerOverviewRevenueChartPeriod>(
      OwnerOverviewRevenueChartPeriodNotifier.new,
    );
