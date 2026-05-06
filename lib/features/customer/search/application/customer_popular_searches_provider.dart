import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../customer_home/presentation/controllers/customer_home_providers.dart';

/// Firestore `countryCode` on the item, or null/empty/`ALL` = show in every country.
bool _popularSearchDocMatchesCountry(
  Map<String, dynamic> data,
  String customerCountryCode,
) {
  final want = customerCountryCode.trim().toUpperCase();
  final raw = data['countryCode'];
  final d = raw == null ? '' : '$raw'.trim().toUpperCase();
  if (d.isEmpty || d == 'ALL') {
    return true;
  }
  return d == want;
}

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
  // Use only isActive + sortOrder in Firestore (existing index). Country is
  // applied in memory so we do not require a new composite while indexes build.
  return db
      .collection(FirestorePaths.customerDiscovery)
      .doc(FirestorePaths.customerDiscoveryPopularSearchesDoc)
      .collection(FirestorePaths.customerDiscoveryItems)
      .where('isActive', isEqualTo: true)
      .orderBy('sortOrder')
      .limit(64)
      .snapshots()
      .map(
        (snap) {
          final out = <PopularCustomerSearchItem>[];
          for (final doc in snap.docs) {
            if (!_popularSearchDocMatchesCountry(doc.data(), countryCode)) {
              continue;
            }
            final item = PopularCustomerSearchItem.fromDoc(doc);
            if (item.label.isEmpty) {
              continue;
            }
            out.add(item);
            if (out.length >= 24) {
              break;
            }
          }
          return out;
        },
      );
});

