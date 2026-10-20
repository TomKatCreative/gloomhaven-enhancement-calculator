import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/backup_exception.dart';
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
        await expectLater(restore(contents), throwsA(isA<BackupException>()));
      });

      test('leaves the existing characters untouched', () async {
        final db = await databaseWithData();
        final before = await dataDump(db);
        await expectLater(restore(contents), throwsA(anything));
        expect(await dataDump(db), before);
      });
    });
  }

  group('an insert that fails mid-batch', () {
    // Valid rows from other characters come first, so part of the batch has
    // already been inserted when the bad row fails.
    Future<String> backupWithBadLastRow() async {
      final backup = jsonDecode(await generate()) as List;
      final tables = backup[0] as List;
      final characters = backup[1][tables.indexOf('Characters')] as List;
      characters.add({
        ...characters.single as Map,
        '_id': 2,
        'Uuid': 'other',
        'Name': 'Other',
      });
      (backup[1][tables.indexOf('CharacterPerks')] as List).add({
        'CharacterUuid': 'bad',
        'PerkID': 'br_base_01a',
        'IsSelected': 1,
        'NoSuchColumn': 1,
      });
      SharedPrefs().primaryClassColor = 0xff123456;
      backup[2] = {
        'settings': {'primaryClassColor': 0xffabcdef},
      };
      return jsonEncode(backup);
    }

    test('rolls the database back to the previous data', () async {
      final db = await databaseWithData();
      final backup = await backupWithBadLastRow();
      final before = await dataDump(db);
      await expectLater(restore(backup), throwsA(isA<DatabaseException>()));
      expect(await dataDump(db), before);
    });

    test('leaves the prefs untouched', () async {
      await databaseWithData();
      final backup = await backupWithBadLastRow();
      await expectLater(restore(backup), throwsA(anything));
      expect(SharedPrefs().primaryClassColor, 0xff123456);
    });
  });

  test('backups whose tables are not lists of rows are rejected', () async {
    final db = await databaseWithData();
    final before = await dataDump(db);
    final backup = jsonDecode(await generate()) as List;
    final tables = backup[0] as List;
    backup[1][tables.indexOf('Characters')] = {'Name': 'Not a list'};
    await expectLater(
      restore(jsonEncode(backup)),
      throwsA(isA<BackupException>()),
    );
    expect(await dataDump(db), before);
  });

  for (final MapEntry(key: column, value: value) in {
    'ClassCode': 'zz',
    'Variant': 'v99',
  }.entries) {
    test('a character with an unknown $column is rejected untouched', () async {
      final db = await databaseWithData();
      final before = await dataDump(db);
      final backup = jsonDecode(await generate()) as List;
      final tables = backup[0] as List;
      final characters = backup[1][tables.indexOf('Characters')] as List;
      (characters.single as Map)[column] = value;
      await expectLater(
        restore(jsonEncode(backup)),
        throwsA(isA<BackupException>()),
      );
      expect(await dataDump(db), before);
    });
  }

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
  );

  group('a backup whose prefs contain a wrong-typed value', () {
    // The backup's characters differ from the database's, so a restore that
    // touched the database before rejecting the prefs would be visible.
    // primaryClassColor is valid and precedes the bad showRetiredCharacters.
    Future<String> backupWithBadPrefs() async {
      final backup = jsonDecode(await generate()) as List;
      final tables = backup[0] as List;
      (backup[1][tables.indexOf('Characters')] as List).clear();
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
      await expectLater(
        restore(await backupWithBadPrefs()),
        throwsA(isA<BackupException>()),
      );
    });

    test('leaves the database untouched', () async {
      final db = await databaseWithData();
      final before = await dataDump(db);
      await expectLater(
        restore(await backupWithBadPrefs()),
        throwsA(isA<BackupException>()),
      );
      expect(await dataDump(db), before);
    });

    test('leaves every pref as it was', () async {
      await databaseWithData();
      SharedPrefs().primaryClassColor = 0xff123456;
      await expectLater(
        restore(await backupWithBadPrefs()),
        throwsA(isA<BackupException>()),
      );
      expect(SharedPrefs().primaryClassColor, 0xff123456);
    });
  });
}
