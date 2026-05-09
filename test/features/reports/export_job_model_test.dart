import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/features/reports/data/models/export_job_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ExportJobModel parses export job document', () async {
    final fs = FakeFirebaseFirestore();
    const salonId = 's1';
    const jobId = 'job1';
    await fs
        .collection('salons')
        .doc(salonId)
        .collection(FirestorePaths.exportJobs)
        .doc(jobId)
        .set({
      'salonId': salonId,
      'exportType': 'sales',
      'format': 'csv',
      'periodId': '2026-05',
      'status': 'completed',
      'fileName': 'sales.csv',
      'storagePath': 'exports/s1/2026-05/sales.csv',
      'requestedBy': 'u1',
      'requestedByName': 'Owner',
      'createdAt': DateTime.utc(2026, 5, 1),
    });

    final snap = await fs
        .collection('salons')
        .doc(salonId)
        .collection(FirestorePaths.exportJobs)
        .doc(jobId)
        .get();

    final m = ExportJobModel.fromFirestore(snap);
    expect(m.id, jobId);
    expect(m.exportType, 'sales');
    expect(m.isCompleted, true);
  });
}
