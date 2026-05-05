import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../data/models/customer.dart';

typedef CustomerSearchParams = ({String salonId, String query});

/// Arguments for [customerDetailsProvider] (salon + document id).
class CustomerDetailsArgs {
  const CustomerDetailsArgs({required this.salonId, required this.customerId});

  final String salonId;
  final String customerId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerDetailsArgs &&
          runtimeType == other.runtimeType &&
          salonId == other.salonId &&
          customerId == other.customerId;

  @override
  int get hashCode => Object.hash(salonId, customerId);
}

final customersListProvider = StreamProvider.family<List<Customer>, String>((
  ref,
  salonId,
) {
  final sid = salonId.trim();
  if (sid.isEmpty) {
    return Stream.value(const <Customer>[]);
  }
  return ref
      .watch(customerRepositoryProvider)
      .streamCustomers(salonId: sid, includeInactive: true);
});

/// Active salon customers for POS (add sale) — excludes archived rows.
final salonCustomersForPosProvider =
    StreamProvider.family<List<Customer>, String>((ref, salonId) {
      final sid = salonId.trim();
      if (sid.isEmpty) {
        return Stream.value(const <Customer>[]);
      }
      return ref.watch(customerRepositoryProvider).streamCustomers(
            salonId: sid,
            includeInactive: false,
          );
    });

final customerDetailsProvider =
    StreamProvider.family<Customer?, CustomerDetailsArgs>((ref, args) {
      final sid = args.salonId.trim();
      final cid = args.customerId.trim();
      if (sid.isEmpty || cid.isEmpty) {
        return Stream.value(null);
      }
      return ref
          .watch(customerRepositoryProvider)
          .watchCustomerById(
            salonId: sid,
            customerId: cid,
            requireActive: false,
          );
    });

final customerSearchProvider =
    FutureProvider.family<List<Customer>, CustomerSearchParams>((
      ref,
      params,
    ) async {
      final sid = params.salonId.trim();
      final q = params.query.trim();
      if (sid.isEmpty || q.isEmpty) {
        return const <Customer>[];
      }
      return ref.watch(customerRepositoryProvider).searchCustomers(sid, q);
    });

bool isCustomerPermissionDenied(Object error) {
  return error is FirebaseException && error.code == 'permission-denied';
}
