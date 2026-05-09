import 'package:barber_shop_app/features/owner/dashboard_v2/data/models/owner_dashboard_snapshot_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses sparse Firestore payload with zero defaults', () async {
    final fs = FakeFirebaseFirestore();
    await fs.doc('salons/s1/dashboardSnapshots/daily_2026-05-08').set({
      'salonId': 's1',
      'snapshotType': 'daily',
      'dateKey': '2026-05-08',
      'revenueToday': 12.5,
    });

    final snap =
        await fs.doc('salons/s1/dashboardSnapshots/daily_2026-05-08').get();

    final m = OwnerDashboardSnapshotModel.fromFirestore(snap);

    expect(m.id, 'daily_2026-05-08');
    expect(m.salonId, 's1');
    expect(m.snapshotType, 'daily');
    expect(m.dateKey, '2026-05-08');
    expect(m.revenueToday, 12.5);
    expect(m.bookingsToday, 0);
    expect(m.alertMissingCheckouts, 0);
    expect(m.alertPayrollNeedsApproval, 0);
  });
}
