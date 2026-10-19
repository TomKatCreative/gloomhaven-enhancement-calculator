import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';

import 'fresh_install_test.dart' show freshSchemaGoldenPath;
import 'harness/frozen_schemas.dart';

/// Fails the moment the schema version is bumped without freezing the
/// outgoing schema, so every version a user can upgrade from stays tested.
void main() {
  const current = DatabaseHelper.currentVersion;
  const howTo = 'See docs/database_migration_testing.md#adding-a-migration.';

  test('every version a user can upgrade from has a frozen schema', () {
    final missing = [
      for (int v = 1; v < current; v++)
        if (!coveredVersions.contains(v)) v,
    ];
    expect(
      missing,
      isEmpty,
      reason:
          'Schema is v$current but no frozen fixture exists for $missing. '
          'Copy the "sql" statements from $freshSchemaGoldenPath (as it was '
          'before your change: `git show HEAD:$freshSchemaGoldenPath`) into a '
          'new FrozenSchema in test/migration/harness/frozen_schemas.dart, '
          'add a seed path in harness/dataset.dart, then regenerate goldens. '
          '$howTo',
    );
  });

  test('no frozen schema claims the current or a future version', () {
    expect(coveredVersions.where((v) => v >= current), isEmpty);
  });

  test('the fresh-install golden was regenerated for this version', () {
    final golden =
        jsonDecode(File(freshSchemaGoldenPath).readAsStringSync()) as Map;
    expect(
      golden['version'],
      current,
      reason:
          'The fresh-install golden is for v${golden['version']}. After '
          'freezing it, run `flutter test --update-goldens '
          'test/migration/fresh_install_test.dart`. $howTo',
    );
  });
}
