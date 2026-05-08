import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/user_roles.dart';
import '../core/session/app_session_status.dart';
import '../features/bookings/data/models/booking.dart';
import '../features/bookings/data/models/barber_metrics.dart';
import '../features/customer/application/customer_public_salon_service_adapter.dart';
import '../features/customer/application/customer_salon_profile_providers.dart';
import '../features/employees/data/models/employee.dart';
import '../features/salon/data/models/salon.dart';
import '../features/services/data/models/service.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';
import 'session_provider.dart';

bool _isPermissionDenied(Object error) {
  return error is FirebaseException && error.code == 'permission-denied';
}

bool _canReadCustomerStreams(Ref ref) {
  final status = ref.watch(appSessionBootstrapProvider).status;
  // Guests need published salon + `publicSalons/*` mirrors after splash resolves.
  return status != AppSessionStatus.initializing;
}

/// All active salons for discovery (not scoped to session salon).
final activeSalonsStreamProvider = StreamProvider<List<Salon>>((ref) {
  if (!_canReadCustomerStreams(ref)) {
    return Stream.value(const <Salon>[]);
  }
  final repo = ref.watch(salonRepositoryProvider);
  return repo.watchActiveSalons();
});

/// Single salon document for customer flows.
final customerSalonStreamProvider = StreamProvider.family<Salon?, String>((
  ref,
  salonId,
) {
  if (!_canReadCustomerStreams(ref)) {
    return Stream.value(null);
  }
  final repo = ref.watch(salonRepositoryProvider);
  if (salonId.isEmpty) {
    return Stream.value(null);
  }
  return repo.watchSalon(salonId);
});

/// Services for a salon (public mirror — not `salons/.../services`).
final customerSalonServicesStreamProvider =
    StreamProvider.family<List<SalonService>, String>((ref, salonId) {
      if (!_canReadCustomerStreams(ref)) {
        return Stream.value(const <SalonService>[]);
      }
      if (salonId.isEmpty) {
        return Stream.value(const <SalonService>[]);
      }
      final stream = ref
          .watch(customerSalonProfileRepositoryProvider)
          .watchVisibleServices(salonId)
          .map(
            (list) => list
                .map(salonServiceFromCustomerPublic)
                .toList(growable: false),
          );
      return stream;
    });

/// Bookable specialists for customer booking (public team mirror — not `salons/.../employees`).
final customerSalonBarbersStreamProvider =
    StreamProvider.family<List<Employee>, String>((ref, salonId) {
      if (!_canReadCustomerStreams(ref)) {
        return Stream.value(const <Employee>[]);
      }
      if (salonId.isEmpty) {
        return Stream.value(const <Employee>[]);
      }
      final teamStream = ref
          .watch(customerSalonProfileRepositoryProvider)
          .watchBookableTeamMembers(salonId)
          .map(
            (members) => members
                .map(
                  (m) => Employee.customerBookingFromPublicMirror(
                    id: m.id,
                    salonId: m.salonId,
                    displayName: m.displayTitle,
                    profileImageUrl: m.profileImageUrl,
                  ),
                )
                .toList(growable: false),
          );
      return teamStream;
    });

/// KPI snapshots keyed by `employeeId` for customer salon views.
final customerSalonBarberMetricsMapProvider = FutureProvider.autoDispose
    .family<Map<String, BarberMetrics>, String>((ref, salonId) async {
      if (salonId.isEmpty) {
        return const {};
      }
      final barbersAsync = ref.watch(
        customerSalonBarbersStreamProvider(salonId),
      );
      final barbers = barbersAsync.maybeWhen(
        data: (list) => list,
        orElse: () => const <Employee>[],
      );
      if (barbers.isEmpty) {
        return const {};
      }
      final repo = ref.read(barberMetricsRepositoryProvider);
      return repo.getForEmployees(salonId, barbers.map((e) => e.id).toList());
    });

typedef CustomerBarberDayKey = ({
  String salonId,
  DateTime day,
  String barberId,
});

/// Busy intervals for one barber on a local calendar day (for slot masking).
///
/// Uses [BookingRepository.fetchDayBusyMask] (`bookingDayBusyMask` callable).
/// Customers are not allowed to list `salons/{id}/bookings` in Firestore rules.
final customerBarberDayBookingsStreamProvider =
    StreamProvider.family<List<Booking>, CustomerBarberDayKey>((ref, key) {
      if (!_canReadCustomerStreams(ref)) {
        return Stream.value(const <Booking>[]);
      }
      final repo = ref.watch(bookingRepositoryProvider);
      if (key.salonId.isEmpty || key.barberId.isEmpty) {
        return Stream.value(const <Booking>[]);
      }
      final d = key.day;
      final startLocal = DateTime(d.year, d.month, d.day);
      final endLocal = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
      return Stream.fromFuture(() async {
        try {
          final all = await repo.fetchDayBusyMask(
            salonId: key.salonId,
            startFromUtc: startLocal.toUtc(),
            startToUtc: endLocal.toUtc(),
          );
          return all
              .where((b) => b.barberId == key.barberId)
              .toList(growable: false);
        } on Object {
          return const <Booking>[];
        }
      }());
    });

typedef CustomerBookingKey = ({String salonId, String bookingId});

final customerBookingStreamProvider =
    StreamProvider.family<Booking?, CustomerBookingKey>((ref, key) {
      if (!_canReadCustomerStreams(ref)) {
        return Stream.value(null);
      }
      final repo = ref.watch(bookingRepositoryProvider);
      if (key.salonId.isEmpty || key.bookingId.isEmpty) {
        return Stream.value(null);
      }
      return repo.watchBooking(key.salonId, key.bookingId);
    });

/// Signed-in customer's bookings (for profile stats). Empty stream when not a customer.
final customerBookingsForProfileStreamProvider =
    StreamProvider.autoDispose<List<Booking>>((ref) {
      if (!_canReadCustomerStreams(ref)) {
        return Stream.value(const <Booking>[]);
      }
      final isAnonymous =
          ref.watch(firebaseAuthProvider).currentUser?.isAnonymous == true;
      return ref
          .watch(sessionUserProvider)
          .when(
            data: (user) {
              if (user == null ||
                  user.role != UserRoles.customer ||
                  user.uid.isEmpty) {
                return Stream.value(const <Booking>[]);
              }
              if (isAnonymous) {
                final guestIdentity = ref.read(guestIdentityRepositoryProvider);
                return Stream.fromFuture(
                  guestIdentity.getOrCreateGuestProfileId(),
                ).asyncExpand(
                  (id) => ref
                      .read(bookingRepositoryProvider)
                      .watchBookingsForGuestProfileId(id, limit: 80),
                );
              }
              return ref
                  .read(bookingRepositoryProvider)
                  .watchBookingsForCustomer(user.uid)
                  .transform<List<Booking>>(
                    StreamTransformer.fromHandlers(
                      handleError:
                          (
                            Object error,
                            StackTrace _,
                            EventSink<List<Booking>> sink,
                          ) {
                            if (_isPermissionDenied(error)) {
                              sink.add(const <Booking>[]);
                              sink.close();
                              return;
                            }
                            sink.addError(error);
                          },
                    ),
                  );
            },
            loading: () => Stream.value(const <Booking>[]),
            error: (_, _) => Stream.value(const <Booking>[]),
          );
    });

/// Active services across discoverable salons (refreshes when the salon list changes).
final customerDiscoveryServicesProvider =
    FutureProvider.autoDispose<List<SalonService>>((ref) async {
      final salonsAsync = ref.watch(activeSalonsStreamProvider);
      if (salonsAsync.isLoading || salonsAsync.hasError) {
        return const [];
      }
      final salons = salonsAsync.value ?? const <Salon>[];
      if (salons.isEmpty) {
        return const [];
      }
      final profileRepo = ref.read(customerSalonProfileRepositoryProvider);
      const maxSalons = 12;
      const maxServices = 28;
      final all = <SalonService>[];
      for (final salon in salons.take(maxSalons)) {
        if (!salon.isActive) {
          continue;
        }
        List<SalonService> list;
        try {
          final public = await profileRepo.fetchVisibleServices(salon.id);
          list = public
              .map(salonServiceFromCustomerPublic)
              .toList(growable: false);
        } on FirebaseException catch (error) {
          if (_isPermissionDenied(error)) {
            continue;
          }
          rethrow;
        }
        all.addAll(list);
        if (all.length >= maxServices) {
          break;
        }
      }
      all.sort(
        (a, b) =>
            a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase()),
      );
      if (all.length <= maxServices) {
        return all;
      }
      return all.take(maxServices).toList();
    });
