import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';

import '../test/migration/suites/backup_synthetic_versions_suite.dart';
import '../test/migration/suites/migration_atomicity_suite.dart';
import '../test/migration/suites/migration_idempotence_suite.dart';
import '../test/migration/suites/schema_parity_suite.dart';
import '../test/migration/suites/upgrade_matrix_suite.dart';

/// Runs the migration suites against the device's own SQLite instead of the
/// desktop FFI build used by `flutter test`. Run before any release that
/// touches the database:
///
///   `flutter test integration_test/migration_on_device_test.dart -d DEVICE_ID`
///
/// See docs/database_migration_testing.md#on-device-run.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('reports the platform SQLite version', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    final rows = await db.rawQuery('SELECT sqlite_version() AS v');
    debugPrint('Platform SQLite ${rows.single['v']}');
    await db.close();
  });

  defineUpgradeMatrixTests();
  defineSchemaParityTests();
  defineAtomicityTests();
  defineIdempotenceTests();
  defineSyntheticBackupTests();
}
