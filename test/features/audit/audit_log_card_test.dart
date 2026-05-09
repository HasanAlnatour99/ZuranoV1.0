import 'package:barber_shop_app/features/audit/data/models/audit_log_model.dart';
import 'package:barber_shop_app/features/audit/presentation/widgets/audit_log_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_shop_app/l10n/app_localizations.dart';

void main() {
  testWidgets('AuditLogCard shows summary and invokes onTap (Zurano layout)',
      (tester) async {
    var tapped = false;
    const log = AuditLogModel(
      id: 'a1',
      salonId: 's1',
      actionType: 'update',
      module: 'bookings',
      actorUid: 'u1',
      actorName: 'Alice',
      actorRole: 'owner',
      targetType: 'booking',
      targetId: 'b1',
      targetLabel: 'Haircut',
      summary: 'Booking updated',
      before: {},
      after: {},
      metadata: {},
      createdAt: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: AuditLogCard(
            log: log,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Booking updated'), findsOneWidget);
    expect(find.textContaining('Alice'), findsOneWidget);
    expect(find.byType(InkWell), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(tapped, true);
  });
}
