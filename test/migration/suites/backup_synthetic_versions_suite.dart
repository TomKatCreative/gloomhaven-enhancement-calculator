import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';

import '../../helpers/test_helpers.dart';
import '../harness/dataset.dart';
import '../harness/harness.dart';
import '../harness/invariants.dart';
import '../../backup/backup_harness.dart';

/// A backup exported from any restorable schema (v8+) must restore to the
/// same state the upgrade path produces for that schema.
/// Also run on device by integration_test/migration_on_device_test.dart.
void defineSyntheticBackupTests() {
  group('synthetic backups', () {
    setUpAll(initMigrationHarness);

    setUp(setupSharedPreferences);
    tearDown(closeApp);

    /// Exports a frozen v[version] database exactly as that version's
    /// generateBackup did: [tableNames, tableRows] (prefs came later).
    Future<String> exportFrozen(int version) async {
      final raw = await rawOpen(tempDbPath(createTempDbDir()));
      await seedFrozenDatabase(raw, version);
      const tables = [
        'Characters',
        'CharacterPerks',
        'CharacterMasteries',
        'MetaData',
      ];
      final data = [for (final t in tables) await raw.query(t)];
      await raw.close();
      return jsonEncode([tables, data]);
    }

    for (int version = 8; version < DatabaseHelper.currentVersion; version++) {
      test('a v$version backup restores like a v$version upgrade', () async {
        final db = await freshAppDatabase();
        await restore(await exportFrozen(version));

        final characters = datasetAt(version);
        final rows = await db.query('Characters', orderBy: '_id');
        expect(rows, hasLength(characters.length));
        for (final c in characters) {
          final row = rows.firstWhere((r) => r['_id'] == c.id);
          final expected = expectedCharacterRow(c, version);
          expect(
            {for (final k in expected.keys) k: row[k]},
            expected,
            reason: c.name,
          );
          final uuid = expected['Uuid'];
          final perks = await db.query(
            'CharacterPerks',
            where: 'CharacterUuid = ?',
            whereArgs: [uuid],
          );
          expect(
            {for (final r in perks) '${r['PerkID']}': r['IsSelected'] == 1},
            expectedPerks(c, version),
            reason: c.name,
          );
          final masteries = await db.query(
            'CharacterMasteries',
            where: 'CharacterUuid = ?',
            whereArgs: [uuid],
          );
          expect(
            {
              for (final r in masteries)
                '${r['MasteryID']}': r['MasteryAchieved'] == 1,
            },
            expectedMasteries(c, version),
            reason: c.name,
          );
        }
        await expectDbInvariants(db);
        expectLoadedModelInvariants(await loadCharactersModel());
      });
    }
  });
}
