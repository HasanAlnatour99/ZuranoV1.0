import 'package:barber_shop_app/core/constants/booking_status_machine.dart';
import 'package:barber_shop_app/core/constants/booking_statuses.dart';
import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/features/bookings/data/booking_repository.dart';
import 'package:barber_shop_app/features/bookings/data/booking_time_overlap_exception.dart';
import 'package:barber_shop_app/features/bookings/data/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit - booking overlap logic', () {
    test(
      'checkBarberAvailability returns false for active overlap',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = BookingRepository(firestore: firestore);
        await firestore
            .collection('salons/salon-1/bookings')
            .doc('b1')
            .set(<String, dynamic>{
              'status': BookingStatuses.confirmed,
              'barberId': 'barber-1',
              'startAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 10, 0)),
              'endAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 11, 0)),
            });

        final available = await repository.checkBarberAvailability(
          salonId: 'salon-1',
          barberId: 'barber-1',
          startAt: DateTime.utc(2026, 1, 1, 10, 30),
          endAt: DateTime.utc(2026, 1, 1, 11, 30),
        );

        expect(available, isFalse);
      },
      tags: ['critical'],
    );

    test(
      'parallel booking creations allow only one success',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = BookingRepository(firestore: firestore);

        final baseBooking = Booking(
          id: '',
          salonId: 'salon-1',
          barberId: 'barber-1',
          customerId: 'customer-1',
          startAt: DateTime.utc(2026, 1, 1, 10, 0),
          endAt: DateTime.utc(2026, 1, 1, 10, 30),
          status: BookingStatuses.confirmed,
          serviceId: 'svc-1',
          customerName: 'Ali',
        );

        final futures = List.generate(2, (_) async {
          try {
            await repository.createBooking(
              'salon-1',
              baseBooking,
              slotStepMinutes: 15,
            );
            return true;
          } catch (e) {
            if (e is BookingTimeOverlapException) {
              return false;
            }
            rethrow;
          }
        });
        final results = await Future.wait(futures);
        final successCount = results.where((s) => s).length;
        final overlapCount = results.where((s) => !s).length;

        expect(successCount, 1);
        expect(overlapCount, 1);
      },
      tags: ['critical'],
      skip:
          'Requires Firestore emulator transaction contention; FakeFirebaseFirestore allows both commits.',
    );
  });

  group('Unit - booking status transition rules', () {
    test('allows pending to confirmed and blocks pending to completed', () {
      expect(
        BookingStatusMachine.canTransition(
          BookingStatuses.pending,
          BookingStatuses.confirmed,
        ),
        isTrue,
      );
      expect(
        BookingStatusMachine.canTransition(
          BookingStatuses.pending,
          BookingStatuses.completed,
        ),
        isFalse,
      );
    });
  });

  group('Unit - booking transactions', () {
    test('booking creation updates customer lastBookingAt', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = BookingRepository(firestore: firestore);
      await firestore
          .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
          .set({
        'id': 'customer-1',
        'salonId': 'salon-1',
      });

      await repository.createBooking(
        'salon-1',
        Booking(
          id: '',
          salonId: 'salon-1',
          barberId: 'barber-1',
          customerId: 'customer-1',
          startAt: DateTime.utc(2026, 1, 2, 9, 0),
          endAt: DateTime.utc(2026, 1, 2, 9, 30),
          status: BookingStatuses.confirmed,
          serviceId: 'svc-1',
          customerName: 'Ali',
        ),
        slotStepMinutes: 15,
      );

      final customerDoc = await firestore
          .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
          .get();
      expect(customerDoc.data()?['lastBookingAt'], isNotNull);
    }, tags: ['critical']);

    test(
      'booking completion does not double increment customer counters',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = BookingRepository(firestore: firestore);
        await firestore
            .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
            .set({
          'id': 'customer-1',
          'salonId': 'salon-1',
          'visitCount': 0,
          'totalSpent': 0,
        });
        await firestore.collection('salons/salon-1/bookings').doc('b-1').set({
          'id': 'b-1',
          'salonId': 'salon-1',
          'barberId': 'barber-1',
          'customerId': 'customer-1',
          'startAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 10, 0)),
          'endAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 10, 30)),
          'status': BookingStatuses.confirmed,
          'totalPrice': 80,
        });

        await repository.completeBookingService(
          salonId: 'salon-1',
          bookingId: 'b-1',
        );
        await repository.completeBookingService(
          salonId: 'salon-1',
          bookingId: 'b-1',
        );

        final customerDoc = await firestore
            .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
            .get();
        expect(customerDoc.data()?['visitCount'], 1);
        expect((customerDoc.data()?['totalSpent'] as num).toDouble(), 80);
      },
      tags: ['critical'],
    );

    test('customer totalSpent equals sum of completed bookings', () async {
      final firestore = FakeFirebaseFirestore();
      final repository = BookingRepository(firestore: firestore);
      await firestore
          .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
          .set({
        'id': 'customer-1',
        'salonId': 'salon-1',
        'visitCount': 0,
        'totalSpent': 0,
      });

      Future<void> seedAndComplete(String bookingId, double totalPrice) async {
        await firestore
            .collection('salons/salon-1/bookings')
            .doc(bookingId)
            .set({
              'id': bookingId,
              'salonId': 'salon-1',
              'barberId': 'barber-1',
              'customerId': 'customer-1',
              'startAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 10, 0)),
              'endAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1, 10, 30)),
              'status': BookingStatuses.confirmed,
              'totalPrice': totalPrice,
            });
        await repository.completeBookingService(
          salonId: 'salon-1',
          bookingId: bookingId,
        );
      }

      await seedAndComplete('b-1', 50);
      await seedAndComplete('b-2', 70);
      await seedAndComplete('b-3', 30);

      final customerDoc = await firestore
          .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
          .get();
      expect((customerDoc.data()?['totalSpent'] as num).toDouble(), 150);
      expect(customerDoc.data()?['visitCount'], 3);
    }, tags: ['critical']);

    test(
      'booking stores UTC timestamp that maps correctly to local time',
      () async {
        final firestore = FakeFirebaseFirestore();
        final repository = BookingRepository(firestore: firestore);
        await firestore
            .doc(FirestorePaths.salonCustomer('salon-1', 'customer-1'))
            .set({
          'id': 'customer-1',
          'salonId': 'salon-1',
        });

        final localStart = DateTime(2026, 3, 10, 14, 30);
        final localEnd = localStart.add(const Duration(minutes: 30));
        final bookingId = await repository.createBooking(
          'salon-1',
          Booking(
            id: '',
            salonId: 'salon-1',
            barberId: 'barber-1',
            customerId: 'customer-1',
            startAt: localStart,
            endAt: localEnd,
            status: BookingStatuses.confirmed,
            serviceId: 'svc-1',
            customerName: 'Ali',
          ),
          slotStepMinutes: 15,
        );

        final doc = await firestore
            .collection('salons/salon-1/bookings')
            .doc(bookingId)
            .get();
        final storedUtc = (doc.data()?['startAt'] as Timestamp).toDate();

        expect(
          storedUtc.millisecondsSinceEpoch,
          localStart.toUtc().millisecondsSinceEpoch,
        );
        expect(storedUtc.toLocal(), localStart);
      },
      tags: ['critical'],
    );
  });
}
