import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../data/models/assigned_barber_service_model.dart';
import '../data/repositories/barber_services_repository.dart';

final barberServicesRepositoryProvider = Provider<BarberServicesRepository>((
  ref,
) {
  return BarberServicesRepository(ref.watch(firestoreProvider));
});

class AssignedBarberServicesParams {
  const AssignedBarberServicesParams({
    required this.salonId,
    required this.employeeId,
    required this.salonFallbackCurrencyCode,
  });

  final String salonId;
  final String employeeId;
  final String salonFallbackCurrencyCode;

  @override
  bool operator ==(Object other) {
    return other is AssignedBarberServicesParams &&
        other.salonId == salonId &&
        other.employeeId == employeeId &&
        other.salonFallbackCurrencyCode == salonFallbackCurrencyCode;
  }

  @override
  int get hashCode =>
      Object.hash(salonId, employeeId, salonFallbackCurrencyCode);
}

final assignedBarberServicesProvider = StreamProvider.autoDispose
    .family<List<AssignedBarberServiceModel>, AssignedBarberServicesParams>(
      (ref, params) {
        final repository = ref.watch(barberServicesRepositoryProvider);
        return repository.watchAssignedServicesJoined(
          salonId: params.salonId,
          employeeId: params.employeeId,
          salonFallbackCurrencyCode: params.salonFallbackCurrencyCode,
        );
      },
    );
