import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/test_helpers.dart';
import '../migration/harness/db_snapshot.dart';
import '../migration/harness/ffi.dart';
import '../migration/harness/harness.dart';
import '../migration/harness/invariants.dart';
import '../migration/harness/known_bugs.dart';
import 'backup_harness.dart';

/// Backups the app must refuse, and what refusing does to the user's data.
void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  setUp(setupSharedPreferences);
  tearDown(closeApp);

  /// A fresh database holding one character the user cares about.
  Future<Database> databaseWithData() async {
    final db = await freshAppDatabase();
    await DatabaseHelper.instance.insertCharacter(
      Character(
        uuid: 'precious',
        name: 'Precious',
        playerClass: PlayerClasses.playerClassByClassCode(ClassCodes.brute),
        xp: 120,
      ),
    );
    return db;
  }

  // A v7 (app 4.0.x) backup: no MetaData, integer perk IDs.
  final v7Backup = jsonEncode([
    ['Characters', 'CharacterPerks', 'CharacterMasteries'],
    [
      [
        {
          '_id': 1,
          'Uuid': 'old',
          'Name': 'Old',
          'ClassCode': 'br',
          'PreviousRetirements': 0,
          'XP': 0,
          'Gold': 0,
          'Notes': '',
          'CheckMarks': 0,
          'IsRetired': 0,
        },
      ],
      [
        {'CharacterUuid': 'old', 'PerkID': 1, 'IsSelected': 1},
      ],
      <Object>[],
    ],
  ]);
  String withMeta(List<Map<String, Object?>> meta) => jsonEncode([
    ['Characters', 'MetaData'],
    [<Object>[], meta],
  ]);

  final rejected = <String, String>{
    'a v7 backup without MetaData': v7Backup,
    'a backup whose MetaData says v5': withMeta([
      {'DatabaseVersion': 5, 'AppVersion': '3.2.5', 'AppBuildNumber': 76},
    ]),
    'a backup with empty MetaData': withMeta([]),
    'a file that is not JSON': 'not json at all',
    'an empty JSON object': '{}',
    'truncated JSON': '[["Characters"], [[{"Name": "Trun',
  };

  for (final MapEntry(key: label, value: contents) in rejected.entries) {
    group(label, () {
      test('is rejected', () async {
        await databaseWithData();
        await expectLater(restore(contents), throwsA(anything));
      });

      test('leaves the existing characters untouched', () async {
        final db = await databaseWithData();
        final before = await dataDump(db);
        await expectLater(restore(contents), throwsA(anything));
        expect(await dataDump(db), before);
      }, skip: knownBug('BUG-004'));
    });
  }

  test('a row the schema rejects falls back to the previous data', () async {
    final db = await databaseWithData();
    final before = await dataDump(db);
    final backup = jsonDecode(await generate()) as List;
    final tables = backup[0] as List;
    (backup[1][tables.indexOf('Characters')] as List).add({
      'Uuid': 'bad',
      'Name': 'Bad',
      'ClassCode': 'br',
      'NoSuchColumn': 1,
    });
    await expectLater(restore(jsonEncode(backup)), throwsA(anything));
    expect(await dataDump(db), before);
  });

  test('tables the current schema does not have are skipped', () async {
    final db = await databaseWithData();
    final backup = jsonDecode(await generate()) as List;
    (backup[0] as List).add('PerksTable');
    (backup[1] as List).add([
      {'_id': 'x', 'Class': 'x', 'Details': 'x'},
    ]);
    await restore(jsonEncode(backup));
    expect(await db.query('Characters'), hasLength(1));
  });

  test(
    'perk/mastery IDs the app does not know are not restored as orphans',
    () async {
      final db = await databaseWithData();
      final backup = jsonDecode(await generate()) as List;
      final tables = backup[0] as List;
      (backup[1][tables.indexOf('CharacterPerks')] as List).add({
        'CharacterUuid': 'precious',
        'PerkID': 'br_base_99z',
        'IsSelected': 1,
      });
      await restore(jsonEncode(backup));
      await expectDbInvariants(db);
    },
    skip: knownBug('BUG-006'),
  );

  group('a backup whose prefs contain a wrong-typed value', () {
    // The database part is the user's own current data, so only the prefs
    // import can change anything. primaryClassColor is valid and applied
    // before the bad showRetiredCharacters value is reached.
    Future<String> backupWithBadPrefs() async {
      final backup = jsonDecode(await generate()) as List;
      backup[2] = {
        'settings': {
          'primaryClassColor': 0xffabcdef,
          'showRetiredCharacters': 'yes',
        },
      };
      return jsonEncode(backup);
    }

    test('is rejected', () async {
      await databaseWithData();
      SharedPrefs().primaryClassColor = 0xff123456;
      await expectLater(restore(await backupWithBadPrefs()), throwsA(anything));
    });

    test('leaves every pref as it was', () async {
      await databaseWithData();
      SharedPrefs().primaryClassColor = 0xff123456;
      await expectLater(restore(await backupWithBadPrefs()), throwsA(anything));
      expect(SharedPrefs().primaryClassColor, 0xff123456);
    }, skip: knownBug('BUG-005'));
  });
}
