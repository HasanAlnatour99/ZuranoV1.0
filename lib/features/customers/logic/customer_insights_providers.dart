import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../../sales/data/models/sale.dart';
import 'customer_providers.dart';
import 'customer_salon_insights.dart';

/// Completed sales for the salon in the current calendar month (report fields).
final salonMonthlyCompletedSalesStreamProvider =
    StreamProvider.autoDispose.family<List<Sale>, String>((ref, salonId) {
      final sid = salonId.trim();
      if (sid.isEmpty) {
        return Stream.value(const <Sale>[]);
      }
      final now = DateTime.now();
      return ref.watch(salesRepositoryProvider).watchSales(
        sid,
        reportYear: now.year,
        reportMonth: now.month,
        limit: 800,
      );
    });

/// Combines the customer directory stream with monthly sales for insight tiles.
final customerSalonInsightsProvider = Provider.autoDispose
    .family<AsyncValue<CustomerSalonInsights>, String>((ref, salonId) {
      final customers = ref.watch(customersListProvider(salonId));
      final sales = ref.watch(salonMonthlyCompletedSalesStreamProvider(salonId));
      final now = DateTime.now();

      return customers.when(
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
        data: (custList) => sales.when(
          loading: () => const AsyncValue.loading(),
          error: AsyncValue.error,
          data: (saleList) => AsyncValue.data(
            computeCustomerSalonInsights(
              customers: custList,
              salesThisMonth: saleList,
              now: now,
            ),
          ),
        ),
      );
    });
