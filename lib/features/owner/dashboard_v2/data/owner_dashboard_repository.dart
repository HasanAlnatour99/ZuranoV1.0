import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/firebase/cloud_functions_region.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import 'models/owner_dashboard_snapshot_model.dart';

class OwnerDashboardRepository {
  OwnerDashboardRepository({
    required FirebaseFirestore firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore,
       _functions = functions ?? appCloudFunctions();

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> _snapshots(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonDashboardSnapshots(salonId));
  }

  Stream<OwnerDashboardSnapshotModel?> watchDailySnapshot(
    String salonId,
    String dateKey,
  ) {
    final id = 'daily_$dateKey';
    return _snapshots(salonId).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OwnerDashboardSnapshotModel.fromFirestore(doc);
    });
  }

  Stream<OwnerDashboardSnapshotModel?> watchMonthlySnapshot(
    String salonId,
    String periodId,
  ) {
    final id = 'monthly_$periodId';
    return _snapshots(salonId).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OwnerDashboardSnapshotModel.fromFirestore(doc);
    });
  }

  Future<void> generateSnapshot(String salonId) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final callable = _functions.httpsCallable('generateOwnerDashboardSnapshot');
    await callable.call({'salonId': salonId});
  }
}

