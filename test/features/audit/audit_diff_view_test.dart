import 'package:barber_shop_app/features/audit/presentation/widgets/audit_diff_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_shop_app/l10n/app_localizations.dart';

void main() {
  testWidgets('AuditDiffView shows before and after keys', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: AuditDiffView(
            before: {'status': 'a'},
            after: {'status': 'b'},
            beforeTitle: 'Before',
            afterTitle: 'After',
            emptyLabel: 'Empty',
          ),
        ),
      ),
    );

    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
    expect(find.text('status'), findsNWidgets(2));
  });
}
