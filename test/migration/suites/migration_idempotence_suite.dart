import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/data/database_too_new_exception.dart';
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

    group('a database from a newer app version (RISK-001)', () {
      /// A database with one character, stamped one version ahead of the app.
      Future<({String path, Object master, Object data})> newer() async {
        final path = tempDbPath(createTempDbDir());
        await openThroughApp(path);
        await DatabaseHelper.instance.insertCharacter(
          Character(
            uuid: 'downgrade-survivor',
            name: 'Survivor',
            playerClass: PlayerClasses.playerClassByClassCode(ClassCodes.brute),
          ),
        );
        await closeApp();
        final raw = await rawOpen(path);
        await raw.execute(
          'PRAGMA user_version = ${DatabaseHelper.currentVersion + 1}',
        );
        final master = await masterDump(raw);
        final data = await dataDump(raw);
        await raw.close();
        return (path: path, master: master, data: data);
      }

      Future<void> expectRefusedAndUntouched(
        ({String path, Object master, Object data}) before,
      ) async {
        await expectLater(
          openThroughApp(before.path),
          throwsA(
            isA<DatabaseTooNewException>()
                .having(
                  (e) => e.found,
                  'found',
                  DatabaseHelper.currentVersion + 1,
                )
                .having(
                  (e) => e.supported,
                  'supported',
                  DatabaseHelper.currentVersion,
                ),
          ),
        );
        final raw = await rawOpen(before.path);
        expect(await userVersion(raw), DatabaseHelper.currentVersion + 1);
        expect(await masterDump(raw), before.master);
        expect(await dataDump(raw), before.data);
        await raw.close();
      }

      test('is refused and left untouched', () async {
        await expectRefusedAndUntouched(await newer());
      });

      test('is refused the same way on the next launch', () async {
        final before = await newer();
        await expectRefusedAndUntouched(before);
        await expectRefusedAndUntouched(before);
      });
    });
  });
}
