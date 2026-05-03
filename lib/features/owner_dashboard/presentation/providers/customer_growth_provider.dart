import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../../data/repositories/customer_growth_repository.dart';
import '../../domain/models/customer_growth_summary.dart';

final customerGrowthRepositoryProvider = Provider<CustomerGrowthRepository>((
  ref,
) {
  return CustomerGrowthRepository(firestore: ref.watch(firestoreProvider));
});

final customerGrowthProvider =
    StreamProvider.family<CustomerGrowthSummary, String>((ref, salonId) {
      final trimmed = salonId.trim();
      if (trimmed.isEmpty) {
        return Stream<CustomerGrowthSummary>.value(
          const CustomerGrowthSummary.empty(),
        );
      }

      final repository = ref.watch(customerGrowthRepositoryProvider);
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startOfMonth = DateTime(now.year, now.month);
      final endOfMonth = DateTime(now.year, now.month + 1);

      return repository.watchCustomerGrowth(
        salonId: trimmed,
        startOfDay: startOfDay,
        endOfDay: endOfDay,
        startOfMonth: startOfMonth,
        endOfMonth: endOfMonth,
      );
    });
