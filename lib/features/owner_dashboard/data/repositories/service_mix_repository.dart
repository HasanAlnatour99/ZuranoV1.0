import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../sales/data/models/sale.dart';
import '../../domain/models/service_mix_item.dart';

class ServiceMixRepository {
  ServiceMixRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Watches today's completed POS sales and groups sold line items by service.
  ///
  /// Zurano's `services` collection is the catalog; completed service records
  /// are persisted as `salons/{salonId}/sales` with `lineItems`.
  Stream<List<ServiceMixItem>> watchTodayServiceMix({
    required String salonId,
    required DateTime startOfDay,
    required DateTime endOfDay,
  }) {
    final trimmed = salonId.trim();
    if (trimmed.isEmpty) {
      return Stream<List<ServiceMixItem>>.value(const []);
    }

    return _firestore
        .collection(FirestorePaths.salonSales(trimmed))
        .where('status', isEqualTo: SaleStatuses.completed)
        .where('soldAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('soldAt', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
          final sales = snapshot.docs.map((doc) {
            return Sale.fromJson(<String, dynamic>{
              ...doc.data(),
              'id': doc.id,
            });
          });
          return _buildServiceMix(sales);
        });
  }

  /// Builds today's service mix from an already-open sales stream.
  ///
  /// This keeps the owner overview reactive without opening an additional
  /// Firestore listener that requires its own composite index.
  static List<ServiceMixItem> buildTodayServiceMix({
    required String salonId,
    required List<Sale> recentSales,
    required DateTime now,
  }) {
    final trimmed = salonId.trim();
    if (trimmed.isEmpty) return const [];
    final sales = recentSales.where((sale) {
      final sid = sale.salonId.trim();
      if (sid.isNotEmpty && sid != trimmed) return false;
      if (sale.status != SaleStatuses.completed) return false;
      return _sameLocalDay(sale.soldAt, now);
    });
    return _buildServiceMix(sales);
  }

  static List<ServiceMixItem> _buildServiceMix(Iterable<Sale> sales) {
    final grouped = <String, _ServiceMixAccumulator>{};

    for (final sale in sales) {
      for (final line in sale.lineItems) {
        final key = _serviceKey(line);
        if (key.isEmpty) continue;
        final label = line.serviceName.trim().isNotEmpty
            ? line.serviceName.trim()
            : key;
        final count = line.quantity <= 0 ? 1 : line.quantity;
        grouped
            .putIfAbsent(key, () => _ServiceMixAccumulator(label: label))
            .add(count: count, revenue: line.total);
      }
    }

    final totalCount = grouped.values.fold<int>(0, (runningTotal, item) {
      return runningTotal + item.count;
    });
    if (totalCount == 0) return const [];

    final items = grouped.entries.map((entry) {
      final value = entry.value;
      return ServiceMixItem(
        serviceKey: entry.key,
        serviceLabel: value.label,
        count: value.count,
        revenue: value.revenue,
        percentage: value.count / totalCount,
      );
    }).toList();

    items.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) return byCount;
      return b.revenue.compareTo(a.revenue);
    });

    if (items.length <= 4) return items;

    final top = items.take(3).toList();
    final rest = items.skip(3).toList();
    final otherCount = rest.fold<int>(
      0,
      (runningTotal, item) => runningTotal + item.count,
    );
    final otherRevenue = rest.fold<double>(
      0,
      (runningTotal, item) => runningTotal + item.revenue,
    );
    top.add(
      ServiceMixItem(
        serviceKey: 'other',
        serviceLabel: 'Other',
        count: otherCount,
        revenue: otherRevenue,
        percentage: otherCount / totalCount,
      ),
    );
    return top;
  }

  static String _serviceKey(SaleLineItem line) {
    final id = line.serviceId.trim();
    if (id.isNotEmpty) return id;
    final iconOrCategory = line.serviceIcon?.trim();
    if (iconOrCategory != null && iconOrCategory.isNotEmpty) {
      return iconOrCategory;
    }
    return line.serviceName.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
  }

  static bool _sameLocalDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}

class _ServiceMixAccumulator {
  _ServiceMixAccumulator({required this.label});

  final String label;
  int count = 0;
  double revenue = 0;

  void add({required int count, required double revenue}) {
    this.count += count;
    this.revenue += revenue;
  }
}
