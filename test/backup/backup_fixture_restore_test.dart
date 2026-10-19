import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/test_helpers.dart';
import '../migration/harness/dataset.dart';
import '../migration/harness/ffi.dart';
import '../migration/harness/harness.dart';
import '../migration/harness/invariants.dart';
import '../migration/harness/known_bugs.dart';
import 'backup_harness.dart';

/// Restores every committed real-world backup through the real
/// `restoreBackup`, into a fresh install and into an upgraded database that
/// already holds characters, and checks the result row by row.
void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  setUp(setupSharedPreferences);
  tearDown(closeApp);

  for (final fixture in backupFixtures) {
    group(fixture.name, () {
      final backup = fixture.decode();

      test('manifest matches the file', () {
        final tables = backup[0] as List;
        final meta = (backup[1][tables.indexOf('MetaData')] as List).single;
        expect(meta['DatabaseVersion'], fixture.databaseVersion);
        expect(meta['AppVersion'], fixture.appVersion);
        expect(
          (backup[1][tables.indexOf('Characters')] as List),
          hasLength(fixture.characters),
        );
        expect(backup.length > 2, fixture.hasPrefs);
      });

      Future<void> expectRestored(Database db) async {
        for (final table in [
          'Characters',
          'CharacterPerks',
          'CharacterMasteries',
        ]) {
          expect(
            await tableRows(db, table),
            canonicalRows(expectedRestoredRows(backup, table)),
            reason: table,
          );
        }
      }

      test('restores row for row into a fresh install', () async {
        final db = await freshAppDatabase();
        await restore(fixture.read());
        await expectRestored(db);
      });

      test('replaces the characters of an upgraded database', () async {
        final path = tempDbPath(createTempDbDir());
        final raw = await rawOpen(path);
        await seedFrozenDatabase(raw, 7);
        await raw.close();
        final db = await openThroughApp(path);
        expect(await db.query('Characters'), isNotEmpty);

        await restore(fixture.read());
        await expectRestored(db);
      });

      test('satisfies every database invariant', () async {
        final db = await freshAppDatabase();
        await restore(fixture.read());
        await expectDbInvariants(db);
      });

      test('loads in the app with every perk and mastery visible', () async {
        await freshAppDatabase();
        await restore(fixture.read());
        final model = await loadCharactersModel();
        expect(model.characters, hasLength(fixture.characters));
        expectLoadedModelInvariants(model);
      });

      test('keeps the MetaData of the running schema', () async {
        final db = await freshAppDatabase();
        final before = await db.query('MetaData');
        await restore(fixture.read());
        expect(await db.query('MetaData'), before);
      }, skip: knownBug('BUG-007'));

      test(
        'round-trips: restore → export → restore → export is stable',
        () async {
          await freshAppDatabase();
          await restore(fixture.read());
          final first = await generate();
          await closeApp();

          await freshAppDatabase();
          await restore(first);
          final second = await generate();
          expect(jsonDecode(second), jsonDecode(first));
        },
      );
    });
  }
}
