import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../customer_home/presentation/controllers/customer_home_providers.dart';

class PopularCustomerSearchItem {
  const PopularCustomerSearchItem({
    required this.id,
    required this.label,
    required this.type,
    this.iconName,
    this.audience,
    this.sortOrder = 999,
  });

  final String id;
  final String label;
  final String type; // service | salon | specialist | etc
  final String? iconName;
  final String? audience; // men | ladies | unisex | all
  final int sortOrder;

  factory PopularCustomerSearchItem.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return PopularCustomerSearchItem(
      id: doc.id,
      label: '${data['label'] ?? ''}'.trim(),
      type: '${data['type'] ?? ''}'.trim(),
      iconName: data['iconName'] == null ? null : '${data['iconName']}'.trim(),
      audience: data['audience'] == null ? null : '${data['audience']}'.trim(),
      sortOrder: (data['sortOrder'] is num) ? (data['sortOrder'] as num).toInt() : 999,
    );
  }
}

final customerPopularSearchesProvider =
    StreamProvider.autoDispose<List<PopularCustomerSearchItem>>((ref) {
  final db = ref.watch(firestoreProvider);
  final countryCode = ref.watch(customerDiscoveryCountryCodeProvider);
  return db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryPopularSearchesDoc)
      .collection(FirestorePaths.customerDiscoveryItems)
      .where('isActive', isEqualTo: true)
      .where('countryCode', whereIn: [countryCode, 'ALL'])
      .orderBy('sortOrder')
      .limit(24)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map(PopularCustomerSearchItem.fromDoc)
            .where((e) => e.label.isNotEmpty)
            .toList(growable: false),
      );
});

