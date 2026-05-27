import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS pods manifest check fails instead of mutating stale lock files', () {
    final podfile = File('ios/Podfile').readAsStringSync();
    final project = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    for (final content in [podfile, project]) {
      expect(content, contains('Pods manifest is missing'));
      expect(content, isNot(contains('cp "$PODFILE_LOCK" "$MANIFEST_LOCK"')));
    }
  });
}
