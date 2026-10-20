import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/masteries_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/perks_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:sqflite/sqflite.dart';

import 'harness/dataset.dart';
import 'harness/frozen_schemas.dart';
import 'harness/ffi.dart';
import 'harness/harness.dart';

/// Proves where every legacy (v7, app 4.0.0) integer perk and mastery ID
/// lands after a real upgrade, against a reviewed golden map.
///
/// Each legacy row is tagged with its 1-based position within its class. The
/// upgrade runs once per bit of that tag, selecting a row in run b only when
/// bit b is set, so every migrated row's selections across the runs decode
/// exactly which legacy row it came from (0 = no legacy source).
void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  const perkGoldenPath = 'test/fixtures/legacy_ids/v7_perk_id_map.json';
  const masteryGoldenPath = 'test/fixtures/legacy_ids/v7_mastery_id_map.json';
  const bits = 5; // Largest class has 18 legacy rows; tags fit in 5 bits.

  final legacyPerks = legacyPerkIdsByClass();
  final legacyMasteries = legacyMasteryIdsByClass();

  group('golden maps', () {
    test('perk golden matches positional mapping of the frozen layout', () {
      final golden = _perkGolden(legacyPerks);
      _expectGolden(perkGoldenPath, golden);
    });

    test('mastery golden matches positional mapping of the frozen layout', () {
      final golden = _masteryGolden(legacyMasteries);
      _expectGolden(masteryGoldenPath, golden);
    });
  });

  group('v7 upgrade', () {
    // classCode → migrated ID → decoded 1-based legacy position (0 = none).
    final perkTags = <String, Map<String, int>>{};
    final masteryTags = <String, Map<String, int>>{};

    setUpAll(() async {
      final dir = createTempDbDir();
      for (int bit = 0; bit < bits; bit++) {
        final path = tempDbPath(dir, 'run$bit.db');
        final raw = await rawOpen(path);
        await _seedTaggedV7(raw, legacyPerks, legacyMasteries, bit);
        await raw.close();
        final db = await openThroughApp(path);
        for (final r in await db.query('CharacterPerks')) {
          final map = perkTags.putIfAbsent('${r['CharacterUuid']}', () => {});
          map['${r['PerkID']}'] =
              (map['${r['PerkID']}'] ?? 0) | ((r['IsSelected'] as int) << bit);
        }
        for (final r in await db.query('CharacterMasteries')) {
          final map = masteryTags.putIfAbsent(
            '${r['CharacterUuid']}',
            () => {},
          );
          map['${r['MasteryID']}'] =
              (map['${r['MasteryID']}'] ?? 0) |
              ((r['MasteryAchieved'] as int) << bit);
        }
        await closeApp();
      }
    });

    test('every legacy perk lands on the golden live perk', () {
      final golden = _goldenFile(perkGoldenPath);
      for (final classCode in legacyPerks.keys) {
        final expected = <String, int>{
          for (final live in PerksRepository.getPerkIds(
            classCode,
            Variant.base,
          ))
            live: 0,
        };
        for (final entry in golden.values.cast<Map<String, dynamic>>()) {
          if (entry['class'] != classCode) continue;
          expected[entry['migratedId'] as String] = entry['position'] as int;
        }
        expect(perkTags[classCode], expected, reason: classCode);
      }
    });

    test('every legacy mastery lands on the golden live mastery', () {
      final golden = _goldenFile(masteryGoldenPath);
      for (final classCode in legacyMasteries.keys) {
        final expected = {
          for (final entry in golden.values.cast<Map<String, dynamic>>())
            if (entry['class'] == classCode && entry['migratedId'] != null)
              entry['migratedId'] as String: entry['position'] as int,
        };
        // Hidden after v8 and deleted by v21: see the next test.
        if (expected.isEmpty) continue;
        expect(masteryTags[classCode], expected, reason: classCode);
      }
    });

    // A character's variant is fixed at creation, so base-variant characters
    // can never show these masteries: the rows must be removed, not kept.
    test('legacy masteries of classes without live base masteries leave no '
        'hidden rows', () {
      final golden = _goldenFile(masteryGoldenPath);
      final affected = {
        for (final entry in golden.values.cast<Map<String, dynamic>>())
          if (entry['migratedId'] == null) entry['class'] as String,
      };
      expect(affected, isNotEmpty);
      for (final classCode in affected) {
        expect(masteryTags[classCode] ?? const {}, isEmpty, reason: classCode);
      }
    });
  });

  group('Infuser legacy-definition fix', () {
    // Legacy Infuser defined perk 9 as one check, so legacy 724 is perk 10
    // and legacy 725 is perk 11; perk 9's second check had no legacy row.
    final infuserIds = legacyPerks[ClassCodes.infuser]!;

    Future<Database> upgrade(List<FixtureCharacter> characters) async {
      final path = tempDbPath(createTempDbDir());
      final raw = await rawOpen(path);
      await seedFrozenDatabase(raw, 7, characters: characters);
      await raw.close();
      return openThroughApp(path);
    }

    FixtureCharacter infuser(String uuid, bool sel724, bool sel725) =>
        FixtureCharacter(
          id: uuid.hashCode & 0xffff,
          uuid: uuid,
          name: 'Infuser $uuid',
          classCode: ClassCodes.infuser,
          minVersion: 7,
          legacySelectionOverrides: {724: sel724, 725: sel725},
        );

    Future<Map<String, bool>> perksOf(Database db, String uuid) async => {
      for (final r in await db.query(
        'CharacterPerks',
        where: 'CharacterUuid = ?',
        whereArgs: [uuid],
      ))
        '${r['PerkID']}': r['IsSelected'] == 1,
    };

    tearDown(closeApp);

    test('legacy layout places Infuser at IDs 709–725', () {
      expect(infuserIds.first, 709);
      expect(infuserIds.last, 725);
    });

    // All four combinations, plus a second Infuser in the same database with
    // the opposite selections, so cross-character updates are detectable.
    for (final (sel724, sel725) in [
      (false, false),
      (true, false),
      (false, true),
      (true, true),
    ]) {
      test('724 ${sel724 ? 'on' : 'off'}, 725 ${sel725 ? 'on' : 'off'}, '
          'alongside an opposite Infuser', () async {
        final a = infuser('infuser-a', sel724, sel725);
        final b = infuser('infuser-b', !sel724, !sel725);
        final db = await upgrade([a, b]);
        for (final c in [a, b]) {
          final actual = await perksOf(db, c.uuid);
          expect(actual, hasLength(18), reason: c.uuid);
          expect(actual, expectedPerks(c, 7), reason: c.uuid);
        }
      });
    }

    // A second, complete Infuser in the same database checks that the repair
    // matches 725 rows per character, not database-wide.
    for (final sel724 in [true, false]) {
      test('a character with a 724 row (${sel724 ? 'on' : 'off'}) but no 725 '
          'row still upgrades, alongside a complete Infuser', () async {
        final path = tempDbPath(createTempDbDir());
        final raw = await rawOpen(path);
        final c = infuser('infuser-no-725', sel724, false);
        final complete = infuser('infuser-complete', !sel724, true);
        await seedFrozenDatabase(raw, 7, characters: [c, complete]);
        await raw.delete(
          'CharacterPerks',
          where: 'PerkID = ? AND CharacterUuid = ?',
          whereArgs: [725, c.uuid],
        );
        await raw.close();

        final db = await openThroughApp(path);
        expect(await userVersion(db), greaterThan(7));
        // The missing 725 row is treated as unselected.
        expect(await perksOf(db, c.uuid), expectedPerks(c, 7));
        expect(await perksOf(db, complete.uuid), expectedPerks(complete, 7));
      });
    }
  });
}

/// Writes one character per legacy class into a v7 database, selecting each
/// legacy row when [bit] of its 1-based position within the class is set.
Future<void> _seedTaggedV7(
  Database db,
  Map<String, List<int>> legacyPerks,
  Map<String, List<int>> legacyMasteries,
  int bit,
) async {
  bool tagged(int position) => (position >> bit) & 1 == 1;
  await db.transaction((txn) async {
    for (final statement in schemaFor(7).statements) {
      await txn.execute(statement);
    }
    for (final classCode in legacyPerks.keys) {
      await txn.insert('Characters', {
        'Uuid': classCode,
        'Name': classCode,
        'ClassCode': classCode,
        'PreviousRetirements': 0,
        'XP': 0,
        'Gold': 0,
        'Notes': '',
        'CheckMarks': 0,
        'IsRetired': 0,
        'ResourceHide': 0,
        'ResourceMetal': 0,
        'ResourceWood': 0,
        'ResourceArrowVine': 0,
        'ResourceAxeNut': 0,
        'ResourceRockRoot': 0,
        'ResourceFlameFruit': 0,
        'ResourceCorpseCap': 0,
        'ResourceSnowThistle': 0,
      });
      final perkIds = legacyPerks[classCode]!;
      for (int i = 0; i < perkIds.length; i++) {
        await txn.insert('CharacterPerks', {
          'CharacterUuid': classCode,
          'PerkID': perkIds[i],
          'IsSelected': tagged(i + 1) ? 1 : 0,
        });
      }
      final masteryIds = legacyMasteries[classCode] ?? const <int>[];
      for (int i = 0; i < masteryIds.length; i++) {
        await txn.insert('CharacterMasteries', {
          'CharacterUuid': classCode,
          'MasteryID': masteryIds[i],
          'MasteryAchieved': tagged(i + 1) ? 1 : 0,
        });
      }
    }
  });
  await db.execute('PRAGMA user_version = 7');
}

/// Legacy perk ID → where it must land. A legacy row maps to the live base
/// perk check at the same position in its class; Infuser's last two legacy
/// rows skip perk 9's second check (see the Infuser group).
Map<String, Object?> _perkGolden(Map<String, List<int>> legacyPerks) {
  final legacyText = <int, String>{};
  int id = 0;
  for (final perk in PerksRepositoryLegacy.legacyPerks) {
    for (int i = 0; i < perk.numOfPerks; i++) {
      legacyText[++id] = perk.perkDetails;
    }
  }
  final golden = <String, Object?>{};
  for (final MapEntry(key: classCode, value: ids) in legacyPerks.entries) {
    final live = PerksRepository.getPerksForCharacter(classCode, Variant.base);
    for (int i = 0; i < ids.length; i++) {
      final liveIndex = classCode == ClassCodes.infuser && i >= 15 ? i + 1 : i;
      golden['${ids[i]}'] = {
        'class': classCode,
        'position': i + 1,
        'migratedId': live[liveIndex].perkId,
        'legacyText': legacyText[ids[i]],
        'liveText': live[liveIndex].perkDetails,
      };
    }
  }
  return golden;
}

/// Legacy mastery ID → where it must land: the live base mastery at the same
/// position, or null when the class has no live base masteries.
Map<String, Object?> _masteryGolden(Map<String, List<int>> legacyMasteries) {
  final golden = <String, Object?>{};
  for (final MapEntry(key: classCode, value: ids) in legacyMasteries.entries) {
    final live = MasteriesRepository.getMasteriesForCharacter(
      classCode,
      Variant.base,
    );
    for (int i = 0; i < ids.length; i++) {
      golden['${ids[i]}'] = {
        'class': classCode,
        'position': i + 1,
        'migratedId': i < live.length ? live[i].id : null,
        'legacyText':
            MasteriesRepositoryLegacy.masteries[ids[i] - 1].masteryDetails,
        'liveText': i < live.length ? live[i].masteryDetails : null,
      };
    }
  }
  return golden;
}

Map<String, dynamic> _goldenFile(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// Compares the mapping fields of [computed] with the committed golden at
/// [path]; `flutter test --update-goldens` rewrites it for review.
void _expectGolden(String path, Map<String, Object?> computed) {
  final file = File(path);
  if (autoUpdateGoldenFiles) {
    file.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(computed)}\n',
    );
  }
  Map<String, Object?> mappingOnly(Map<String, dynamic> golden) => {
    for (final MapEntry(:key, :value) in golden.entries)
      key: {
        'class': (value as Map)['class'],
        'position': value['position'],
        'migratedId': value['migratedId'],
      },
  };
  expect(
    mappingOnly(_goldenFile(path)),
    mappingOnly(computed),
    reason: '$path is out of date; review and run --update-goldens',
  );
}
