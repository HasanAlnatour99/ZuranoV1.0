import 'package:barber_shop_app/core/theme/app_colors.dart';
import 'package:barber_shop_app/core/ui/zurano_owner_tools_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZuranoOwnerToolsTheme', () {
    test('background matches Zurano premium palette', () {
      expect(
        ZuranoOwnerToolsTheme.background,
        ZuranoPremiumUiColors.background,
      );
    });

    test('cardDecoration uses Zurano card surface', () {
      final d = ZuranoOwnerToolsTheme.cardDecoration();
      expect(d.color, ZuranoPremiumUiColors.cardBackground);
      expect(d.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('sectionCard renders title and body', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZuranoOwnerToolsTheme.sectionCard(
              title: 'Section A',
              child: const Text('Body content'),
            ),
          ),
        ),
      );
      expect(find.text('Section A'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('chipThemeWrapper preserves brightness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final wrapped = ZuranoOwnerToolsTheme.chipThemeWrapper(context);
              expect(wrapped.chipTheme.backgroundColor,
                  ZuranoPremiumUiColors.lightSurface);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}
