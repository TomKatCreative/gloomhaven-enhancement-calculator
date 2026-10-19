import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';

import 'harness/db_snapshot.dart';
import 'harness/ffi.dart';
import 'harness/harness.dart';

/// Golden of the schema a fresh install creates. Its `sql` statements are
/// what gets copied into `frozen_schemas.dart` when the version is bumped.
const freshSchemaGoldenPath = kTownSheetEnabled
    ? 'test/fixtures/schema/fresh_current_town.json'
    : 'test/fixtures/schema/fresh_current.json';

void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  tearDown(closeApp);

  test(
    'fresh install creates the golden schema at the current version',
    () async {
      final db = await openThroughApp(tempDbPath(createTempDbDir()));
      final actual = {
        'version': await userVersion(db),
        'tables': await schemaSnapshotJson(db),
        'sql': [
          for (final row in await masterDump(db))
            if (row['type'] == 'table' &&
                !(row['name'] as String).startsWith('sqlite_'))
              row['sql'],
        ],
      };
      final file = File(freshSchemaGoldenPath);
      if (autoUpdateGoldenFiles) {
        file.createSync(recursive: true);
        file.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(actual)}\n',
        );
      }
      expect(
        actual,
        jsonDecode(file.readAsStringSync()),
        reason:
            'The fresh-install schema changed. If intended, follow '
            'docs/database_migration_testing.md#adding-a-migration and run '
            '`flutter test --update-goldens test/migration/fresh_install_test.dart`.',
      );
    },
  );

  test('fresh install stamps MetaData once with the current version', () async {
    final db = await openThroughApp(tempDbPath(createTempDbDir()));
    final meta = await db.query('MetaData');
    expect(meta, hasLength(1));
    expect(meta.single['DatabaseVersion'], DatabaseHelper.currentVersion);
    expect(meta.single['AppVersion'], kTestAppVersion);
    expect(await db.query('Characters'), isEmpty);
  });
}
