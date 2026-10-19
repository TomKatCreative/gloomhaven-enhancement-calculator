import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:sqflite/sqflite.dart';

import '../harness/dataset.dart';
import '../harness/db_snapshot.dart';
import '../harness/harness.dart';

/// Opening an up-to-date database runs nothing; the same input always
/// migrates to the same output; definition-table contents never matter; and
/// what a downgrade does is pinned down.
/// Also run on device by integration_test/migration_on_device_test.dart.
void defineIdempotenceTests() {
  group('migration idempotence', () {
    setUpAll(initMigrationHarness);

    tearDown(closeApp);

    Future<String> frozen(
      int version, {
      Future<void> Function(Database)? extra,
    }) async {
      final path = tempDbPath(createTempDbDir());
      final raw = await rawOpen(path);
      await seedFrozenDatabase(raw, version);
      if (extra != null) await extra(raw);
      await raw.close();
      return path;
    }

    test('reopening a migrated database changes nothing', () async {
      final path = await frozen(1);
      await openThroughApp(path);
      await closeApp();

      final raw = await rawOpen(path);
      final master = await masterDump(raw);
      final rawMeta = await raw.query('MetaData');
      final data = await dataDump(raw);
      await raw.close();

      final db = await openThroughApp(path);
      expect(await masterDump(db), master);
      // Byte-exact, including MetaData's LastUpdated: no upgrade ran.
      expect(await db.query('MetaData'), rawMeta);
      expect(await dataDump(db), data);
    });

    test('the same input always migrates to the same output', () async {
      final first = await frozen(1);
      final second = await frozen(1);
      final a = await openThroughApp(first);
      final aMaster = await masterDump(a);
      final aData = await dataDump(a);
      final b = await openThroughApp(second);
      expect(await masterDump(b), aMaster);
      expect(await dataDump(b), aData);
    });

    group('definition tables are never read for character data', () {
      // Old installs' PerksTable/MasteriesTable/PersonalQuestsTable contents
      // depended on which build created them. Garbage there must not matter.
      final garbage = <int, Future<void> Function(Database)>{
        7: (raw) async {
          for (int i = 1; i <= 50; i++) {
            await raw.insert('PerksTable', {
              'Class': 'zz',
              'Details': 'garbage $i',
              'IsGrouped': 0,
            });
            await raw.insert('MasteriesTable', {
              'Class': 'zz',
              'Details': 'garbage $i',
            });
          }
        },
        8: (raw) async {
          await raw.insert('PerksTable', {
            '_id': 'br_base_01a',
            'Class': 'zz',
            'Details': 'garbage',
            'Variant': 'v3',
          });
          await raw.insert('MasteriesTable', {
            '_id': 'drifter_base_0',
            'Class': 'zz',
            'Details': 'garbage',
            'Variant': 'v3',
          });
        },
        18: (raw) => raw.insert('PersonalQuestsTable', {
          '_id': 'pq_cs_rm_001',
          'Number': -1,
          'Title': 'garbage',
          'Edition': 'zz',
        }),
      };

      for (final MapEntry(key: version, value: fill) in garbage.entries) {
        test('v$version', () async {
          final clean = await openThroughApp(await frozen(version));
          final expected = await dataDump(clean);
          final dirty = await openThroughApp(
            await frozen(version, extra: fill),
          );
          expect(await dataDump(dirty), expected);
        });
      }
    });

    test(
      'a database from a newer app version is deleted on open (RISK-001)',
      () async {
        // Characterizes onDatabaseDowngradeDelete: installing an older build over
        // a newer database wipes every character. Documented as RISK-001.
        final path = tempDbPath(createTempDbDir());
        await openThroughApp(path);
        await DatabaseHelper.instance.insertCharacter(
          Character(
            uuid: 'downgrade-victim',
            name: 'Victim',
            playerClass: PlayerClasses.playerClassByClassCode(ClassCodes.brute),
          ),
        );
        await closeApp();
        final raw = await rawOpen(path);
        await raw.execute(
          'PRAGMA user_version = ${DatabaseHelper.currentVersion + 1}',
        );
        await raw.close();

        final db = await openThroughApp(path);
        expect(await userVersion(db), DatabaseHelper.currentVersion);
        expect(await db.query('Characters'), isEmpty);
      },
    );
  });
}
