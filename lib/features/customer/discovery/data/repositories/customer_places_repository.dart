import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_paths.dart';
import '../models/customer_place_model.dart';

/// Local substring filter (name, area, city, keywords) — same scaling caveats as
/// [filterPublicSalonsByQuery].
List<CustomerPlaceModel> filterCustomerPlacesByQuery(
  List<CustomerPlaceModel> items,
  String rawQuery,
) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) {
    return items;
  }

  bool tokenMatch(CustomerPlaceModel p) {
    final name = p.name.toLowerCase();
    final area = p.area.toLowerCase();
    final city = p.city.toLowerCase();
    if (name.contains(q) || area.contains(q) || city.contains(q)) {
      return true;
    }
    final gender = p.genderTarget ?? '';
    if (gender.isNotEmpty && gender.toLowerCase().contains(q)) {
      return true;
    }
    for (final k in p.searchKeywords) {
      if (k.toLowerCase().contains(q)) {
        return true;
      }
    }
    return false;
  }

  return items.where(tokenMatch).toList(growable: false);
}

class CustomerPlacesRepository {
  CustomerPlacesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Published discovery salons from the canonical `salons` collection.
  Stream<List<CustomerPlaceModel>> watchPublicPlaces({int limit = 30}) {
    return _firestore
        .collection(FirestorePaths.salons)
        .where('isPublic', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .where('isPublished', isEqualTo: true)
        .orderBy('ratingAvg', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(CustomerPlaceModel.fromFirestore)
              .where((place) => place.coverImageUrl.isNotEmpty)
              .toList(growable: false);
        });
  }
}
