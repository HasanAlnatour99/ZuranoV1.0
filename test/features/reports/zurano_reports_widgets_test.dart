import 'package:barber_shop_app/features/reports/data/models/export_job_model.dart';
import 'package:barber_shop_app/features/reports/presentation/widgets/export_job_card.dart';
import 'package:barber_shop_app/features/reports/presentation/widgets/report_type_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barber_shop_app/l10n/app_localizations.dart';

void main() {
  group('Zurano reports widgets', () {
    testWidgets('ReportTypeCard invokes onTap and shows copy', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ReportTypeCard(
              icon: Icons.point_of_sale_outlined,
              title: 'Sales export',
              subtitle: 'CSV for the selected month',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Sales export'), findsOneWidget);
      expect(find.text('CSV for the selected month'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('ExportJobCard shows download CTA when completed',
        (tester) async {
      var downloaded = false;
      const job = ExportJobModel(
        id: 'j1',
        salonId: 's1',
        exportType: 'sales',
        format: 'csv',
        periodId: '2026-05',
        dateFrom: null,
        dateTo: null,
        employeeId: null,
        status: 'completed',
        fileName: 'sales_export.csv',
        storagePath: 'exports/s1/x.csv',
        downloadUrl: null,
        requestedBy: 'u1',
        requestedByName: 'Owner',
        createdAt: null,
        updatedAt: null,
        completedAt: null,
        failedAt: null,
        errorCode: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ExportJobCard(
              job: job,
              onDownload: () => downloaded = true,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('sales_export.csv'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(downloaded, true);
    });
  });
}
