import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/firebase/cloud_functions_region.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import 'models/monthly_analytics_model.dart';

class AnalyticsRepository {
  AnalyticsRepository({
    required FirebaseFirestore firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore,
       _functions = functions ?? appCloudFunctions();

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _monthly(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonAnalyticsMonthlyCollection(salonId));
  }

  Stream<MonthlyAnalyticsModel?> watchMonthlyAnalytics(
    String salonId,
    String periodId,
  ) {
    if (periodId.trim().isEmpty) {
      return Stream<MonthlyAnalyticsModel?>.value(null);
    }
    return _monthly(salonId).doc(periodId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MonthlyAnalyticsModel.fromFirestore(doc);
    });
  }

  Stream<List<String>> watchAnalyticsMonths(String salonId, {int limit = 12}) {
    return _monthly(salonId)
        .orderBy('periodId', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList(growable: false));
  }

  Future<void> generateMonthlyAnalytics({
    required String salonId,
    required int year,
    required int month,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('generateMonthlyAnalytics');
    await callable.call({'salonId': salonId, 'year': year, 'month': month});
  }
}

