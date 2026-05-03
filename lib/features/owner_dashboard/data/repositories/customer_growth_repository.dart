import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../domain/models/customer_growth_summary.dart';

class CustomerGrowthRepository {
  CustomerGrowthRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<CustomerGrowthSummary> watchCustomerGrowth({
    required String salonId,
    required DateTime startOfDay,
    required DateTime endOfDay,
    required DateTime startOfMonth,
    required DateTime endOfMonth,
  }) {
    final trimmed = salonId.trim();
    if (trimmed.isEmpty) {
      return Stream<CustomerGrowthSummary>.value(
        const CustomerGrowthSummary.empty(),
      );
    }

    final customers = _firestore.collection(
      FirestorePaths.salonCustomers(trimmed),
    );
    final dayStart = Timestamp.fromDate(startOfDay);
    final dayEnd = Timestamp.fromDate(endOfDay);
    final monthStart = Timestamp.fromDate(startOfMonth);
    final monthEnd = Timestamp.fromDate(endOfMonth);

    final controller = StreamController<CustomerGrowthSummary>();
    QuerySnapshot<Map<String, dynamic>>? newTodaySnap;
    QuerySnapshot<Map<String, dynamic>>? activeTodaySnap;
    QuerySnapshot<Map<String, dynamic>>? activeMonthSnap;

    void emitIfReady() {
      final newSnap = newTodaySnap;
      final todaySnap = activeTodaySnap;
      final monthSnap = activeMonthSnap;
      if (newSnap == null || todaySnap == null || monthSnap == null) return;

      final returningToday = todaySnap.docs.where((doc) {
        final firstVisit = _dateTimeFromCustomer(
          doc.data(),
          primary: 'firstVisitAt',
          fallback: 'firstServiceAt',
        );
        return firstVisit != null && firstVisit.isBefore(startOfDay);
      }).length;

      controller.add(
        CustomerGrowthSummary(
          newToday: newSnap.docs.length,
          returningToday: returningToday,
          totalThisMonth: monthSnap.docs.length,
        ),
      );
    }

    final subscriptions = <StreamSubscription<Object?>>[];
    subscriptions.add(
      customers
          .where('firstVisitAt', isGreaterThanOrEqualTo: dayStart)
          .where('firstVisitAt', isLessThan: dayEnd)
          .snapshots()
          .listen((snapshot) {
            newTodaySnap = snapshot;
            emitIfReady();
          }, onError: controller.addError),
    );
    subscriptions.add(
      customers
          .where('lastVisitAt', isGreaterThanOrEqualTo: dayStart)
          .where('lastVisitAt', isLessThan: dayEnd)
          .snapshots()
          .listen((snapshot) {
            activeTodaySnap = snapshot;
            emitIfReady();
          }, onError: controller.addError),
    );
    subscriptions.add(
      customers
          .where('lastVisitAt', isGreaterThanOrEqualTo: monthStart)
          .where('lastVisitAt', isLessThan: monthEnd)
          .snapshots()
          .listen((snapshot) {
            activeMonthSnap = snapshot;
            emitIfReady();
          }, onError: controller.addError),
    );

    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };

    return controller.stream;
  }

  static DateTime? _dateTimeFromCustomer(
    Map<String, dynamic> data, {
    required String primary,
    required String fallback,
  }) {
    final raw = data[primary] ?? data[fallback];
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }
}
