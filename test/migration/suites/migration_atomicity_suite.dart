import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:sqflite/sqflite.dart';

import '../harness/dataset.dart';
import '../harness/db_snapshot.dart';
import '../harness/frozen_schemas.dart';
import '../harness/harness.dart';
import '../harness/known_bugs.dart';

/// A migration that throws must leave the database exactly as it was: the
/// upgrade runs in one exclusive transaction and `user_version` is only
/// written after every step succeeds.
/// Also run on device by integration_test/migration_on_device_test.dart.
void defineAtomicityTests() {
  group('migration atomicity', () {
    setUpAll(initMigrationHarness);

    tearDown(closeApp);

    /// Builds a frozen database, lets [corrupt] damage it, and returns its path
    /// with the pre-upgrade schema and data captured.
    Future<({String path, Object master, Object data})> prepare(
      int version,
      Future<void> Function(Database raw) corrupt, {
      FrozenSchema? schema,
    }) async {
      final path = tempDbPath(createTempDbDir());
      final raw = await rawOpen(path);
      await seedFrozenDatabase(raw, version, schema: schema);
      await corrupt(raw);
      final master = await masterDump(raw);
      final data = await dataDump(raw);
      await raw.close();
      return (path: path, master: master, data: data);
    }

    Future<void> expectUntouched(
      ({String path, Object master, Object data}) before,
      int version,
    ) async {
      final raw = await rawOpen(before.path);
      expect(await userVersion(raw), version);
      expect(await masterDump(raw), before.master, reason: 'schema changed');
      expect(await dataDump(raw), before.data, reason: 'data changed');
      final integrity = await raw.rawQuery('PRAGMA integrity_check');
      expect(integrity.first.values.first, 'ok');
      await raw.close();
    }

    group('a step failing late in the chain', () {
      // Steps 7–16 rewrite tables and remap perks; step 17's CREATE TABLE then
      // fails because the table already exists.
      Future<({String path, Object master, Object data})> prepareFailing() =>
          prepare(
            7,
            (raw) => raw.execute(
              'CREATE TABLE PersonalQuestsTable (_id TEXT PRIMARY KEY)',
            ),
          );

      test('surfaces the error and rolls back every earlier step', () async {
        final before = await prepareFailing();
        await expectLater(openThroughApp(before.path), throwsA(anything));
        await expectUntouched(before, 7);
      });

      test('fails the same way on the next launch', () async {
        final before = await prepareFailing();
        await expectLater(openThroughApp(before.path), throwsA(anything));
        await expectLater(openThroughApp(before.path), throwsA(anything));
        await expectUntouched(before, 7);
      });
    });

    group('orphaned perk/mastery rows (no matching character)', () {
      final cases = <String, (int, Future<void> Function(Database))>{
        'v7 perk row': (
          7,
          (raw) => raw.insert('CharacterPerks', {
            'CharacterUuid': 'deleted-character',
            'PerkID': 100,
            'IsSelected': 1,
          }),
        ),
        'v7 mastery row': (
          7,
          (raw) => raw.insert('CharacterMasteries', {
            'CharacterUuid': 'deleted-character',
            // A class no fixture character has, so no live row shares the ID.
            'MasteryID': legacyMasteryIdsByClass()[ClassCodes.hive]!.first,
            'MasteryAchieved': 1,
          }),
        ),
        // v1–v4 deleteCharacter didn't await its deletes, so orphans can exist.
        'v1 perk row': (
          1,
          (raw) => raw.insert('CharacterPerks', {
            'CharacterID': 99,
            'PerkID': 100,
            'IsSelected': 1,
          }),
        ),
      };

      for (final MapEntry(key: label, value: (version, corrupt))
          in cases.entries) {
        test('a $label does not block the upgrade', () async {
          final before = await prepare(version, corrupt);
          final db = await openThroughApp(before.path);
          expect(await userVersion(db), greaterThan(version));
        }, skip: knownBug('BUG-003'));

        test(
          'a $label that blocks the upgrade leaves the data intact',
          () async {
            final before = await prepare(version, corrupt);
            await expectLater(openThroughApp(before.path), throwsA(anything));
            await expectUntouched(before, version);
          },
        );
      }
    });

    group('late v6 development schema (mastery tables, no version bump)', () {
      test('upgrades', () async {
        final before = await prepare(6, (_) async {}, schema: v06LateDev);
        final db = await openThroughApp(before.path);
        expect(await userVersion(db), greaterThan(6));
      }, skip: knownBug('RISK-003'));

      test('a failed upgrade leaves the data intact', () async {
        final before = await prepare(6, (_) async {}, schema: v06LateDev);
        await expectLater(openThroughApp(before.path), throwsA(anything));
        await expectUntouched(before, 6);
      });
    });
  });
}
