import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/salon_streams_provider.dart';
import '../../data/repositories/team_performance_repository.dart';
import '../../domain/models/team_performance_item.dart';

/// Top barbers for **today** from [salesStreamProvider] + [employeesStreamProvider].
///
/// Reuses the same bounded sales listener as the owner overview (no extra index).
final todayTeamPerformanceProvider =
    Provider.family<AsyncValue<List<TeamPerformanceItem>>, String>((
      ref,
      salonId,
    ) {
      final trimmed = salonId.trim();
      if (trimmed.isEmpty) {
        return const AsyncValue.data([]);
      }

      final salesAsync = ref.watch(salesStreamProvider);
      final employeesAsync = ref.watch(employeesStreamProvider);

      return salesAsync.when(
        data: (sales) => employeesAsync.when(
          data: (employees) {
            final items = TeamPerformanceRepository.buildTodayTopBarbers(
              salonId: trimmed,
              recentSales: sales,
              employees: employees,
              now: DateTime.now(),
            );
            return AsyncValue.data(items);
          },
          loading: () => const AsyncValue<List<TeamPerformanceItem>>.loading(),
          error: (e, st) => AsyncValue<List<TeamPerformanceItem>>.error(e, st),
        ),
        loading: () => const AsyncValue<List<TeamPerformanceItem>>.loading(),
        error: (e, st) => AsyncValue<List<TeamPerformanceItem>>.error(e, st),
      );
    });
