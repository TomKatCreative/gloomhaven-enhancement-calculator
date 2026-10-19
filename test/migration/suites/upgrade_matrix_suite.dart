import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/test_helpers.dart';
import '../harness/dataset.dart';
import '../harness/harness.dart';
import '../harness/invariants.dart';
import '../harness/known_bugs.dart';
import '../../backup/backup_harness.dart';

/// Upgrades a frozen database of every historical schema version through the
/// app's real open path and checks the result field by field.
/// Also run on device by integration_test/migration_on_device_test.dart.
void defineUpgradeMatrixTests() {
  group('upgrade matrix', () {
    setUpAll(initMigrationHarness);

    for (int version = 1; version < DatabaseHelper.currentVersion; version++) {
      group('upgrade from v$version', () {
        late Database db;
        final characters = datasetAt(version);

        setUpAll(() async {
          final path = tempDbPath(createTempDbDir());
          final raw = await rawOpen(path);
          await seedFrozenDatabase(raw, version);
          await raw.close();
          db = await openThroughApp(path);
        });

        tearDownAll(closeApp);

        test('reaches the current version and stamps MetaData', () async {
          expect(await userVersion(db), DatabaseHelper.currentVersion);
          final meta = await db.query('MetaData');
          expect(meta, hasLength(1));
          expect(meta.single['DatabaseVersion'], DatabaseHelper.currentVersion);
          expect(meta.single['AppVersion'], kTestAppVersion);
        });

        test('keeps every character and every field', () async {
          final rows = await db.query('Characters', orderBy: '_id');
          expect(rows.map((r) => r['_id']), characters.map((c) => c.id));
          for (final c in characters) {
            final row = rows.firstWhere((r) => r['_id'] == c.id);
            final expected = expectedCharacterRow(c, version);
            expect(
              {for (final key in expected.keys) key: row[key]},
              expected,
              reason: c.name,
            );
          }
        });

        test('maps every perk selection', () async {
          for (final c in characters) {
            final uuid = expectedCharacterRow(c, version)['Uuid'];
            final rows = await db.query(
              'CharacterPerks',
              where: 'CharacterUuid = ?',
              whereArgs: [uuid],
            );
            expect(
              {for (final r in rows) '${r['PerkID']}': r['IsSelected'] == 1},
              expectedPerks(c, version),
              reason: c.name,
            );
          }
        });

        // Characters whose mastery rows a known bug leaves wrong.
        final masteryBugs = {
          for (final c in characters) c: ?masteryBugFor(c, version),
        };
        final bugIds = masteryBugs.values.toSet();

        Future<Map<String, bool>> masteriesOf(FixtureCharacter c) async {
          final rows = await db.query(
            'CharacterMasteries',
            where: 'CharacterUuid = ?',
            whereArgs: [expectedCharacterRow(c, version)['Uuid']],
          );
          return {
            for (final r in rows)
              '${r['MasteryID']}': r['MasteryAchieved'] == 1,
          };
        }

        test('maps every mastery', () async {
          for (final c in characters.where(
            (c) => !masteryBugs.containsKey(c),
          )) {
            expect(
              await masteriesOf(c),
              expectedMasteries(c, version),
              reason: c.name,
            );
          }
        });

        for (final bug in bugIds) {
          test('maps masteries of ${bug == 'BUG-001' ? 'pre-v7' : 'v7'} '
              'characters', () async {
            for (final c in masteryBugs.keys.where(
              (c) => masteryBugs[c] == bug,
            )) {
              expect(
                await masteriesOf(c),
                expectedMasteries(c, version),
                reason: c.name,
              );
            }
          }, skip: knownBug(bug));
        }

        final bugInvariants = {
          if (bugIds.contains('BUG-001')) Invariant.masteryRowsComplete,
          if (bugIds.contains('BUG-002')) Invariant.noOrphanMasteries,
        };

        test(
          'satisfies every database invariant'
          '${bugInvariants.isEmpty ? '' : ' not covered by a known bug'}',
          () async {
            await expectDbInvariants(db, excluding: bugInvariants);
          },
        );

        if (bugInvariants.isNotEmpty) {
          test('satisfies every database invariant', () async {
            await expectDbInvariants(db);
          }, skip: knownBug(bugIds.first));
        }

        Future<CharactersModel> loadModel() async {
          await setupSharedPreferences();
          return loadCharactersModel();
        }

        final hidesMasteries = bugIds.contains('BUG-001');

        test('loads in the app with every perk'
            '${hidesMasteries ? '' : ' and mastery'} visible', () async {
          final model = await loadModel();
          expect(model.characters, hasLength(characters.length));
          expectLoadedModelInvariants(model, masteries: !hidesMasteries);
        });

        if (hidesMasteries) {
          test('loads in the app with every mastery visible', () async {
            expectLoadedModelInvariants(await loadModel());
          }, skip: knownBug('BUG-001'));
        }
      });
    }
  });
}
