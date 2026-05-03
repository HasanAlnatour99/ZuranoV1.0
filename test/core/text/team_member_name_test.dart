import 'package:barber_shop_app/core/text/team_member_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatTeamMemberName', () {
    test('title-cases multiple words and collapses spaces', () {
      expect(formatTeamMemberName('alice  alnatour'), 'Alice Alnatour');
      expect(formatTeamMemberName('  john  doe  '), 'John Doe');
    });

    test('normalizes all caps single word', () {
      expect(formatTeamMemberName('AHMED'), 'Ahmed');
    });

    test('returns empty string for null, empty, or whitespace-only', () {
      expect(formatTeamMemberName(null), '');
      expect(formatTeamMemberName(''), '');
      expect(formatTeamMemberName('   '), '');
    });

    test('Arabic passes through unchanged (no case folding)', () {
      const arabic = 'أحمد الناطور';
      expect(formatTeamMemberName(arabic), arabic);
    });
  });

  group('TeamMemberNameText', () {
    testWidgets('renders title-cased name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeamMemberNameText('jane DOE'),
          ),
        ),
      );
      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('renders empty for blank input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TeamMemberNameText('   '),
          ),
        ),
      );
      expect(find.text(''), findsOneWidget);
    });
  });
}
