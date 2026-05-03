import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/salon_streams_provider.dart';
import '../../data/repositories/service_mix_repository.dart';
import '../../domain/models/service_mix_item.dart';

final todayServiceMixProvider =
    Provider.family<AsyncValue<List<ServiceMixItem>>, String>((ref, salonId) {
      final trimmed = salonId.trim();
      if (trimmed.isEmpty) {
        return const AsyncValue.data([]);
      }

      final salesAsync = ref.watch(salesStreamProvider);
      return salesAsync.when(
        data: (sales) => AsyncValue.data(
          ServiceMixRepository.buildTodayServiceMix(
            salonId: trimmed,
            recentSales: sales,
            now: DateTime.now(),
          ),
        ),
        loading: () => const AsyncValue<List<ServiceMixItem>>.loading(),
        error: (error, stackTrace) =>
            AsyncValue<List<ServiceMixItem>>.error(error, stackTrace),
      );
    });
