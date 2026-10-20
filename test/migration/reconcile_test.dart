import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/data/database_migrations.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:sqflite/sqflite.dart';

import '../backup/backup_harness.dart';
import '../helpers/test_helpers.dart';
import 'harness/ffi.dart';
import 'harness/harness.dart';
import 'harness/invariants.dart';

/// DatabaseMigrations.reconcileCharacterRows: the v21 step and the
/// last step of every restore.
void main() {
  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  setUp(setupSharedPreferences);
  tearDown(closeApp);

  final drifterPerks = PerksRepository.getPerkIds(
    ClassCodes.drifter,
    Variant.base,
  );
  final drifterMasteries = MasteriesRepository.getMasteryIds(
    ClassCodes.drifter,
    Variant.base,
  );

  /// A fresh database with a Drifter (base masteries) and a base Brute (none).
  Future<Database> databaseWithCharacters() async {
    final db = await freshAppDatabase();
    for (final (uuid, classCode) in [
      ('drifter', ClassCodes.drifter),
      ('brute', ClassCodes.brute),
    ]) {
      await DatabaseHelper.instance.insertCharacter(
        Character(
          uuid: uuid,
          name: uuid,
          playerClass: PlayerClasses.playerClassByClassCode(classCode),
        ),
      );
    }
    return db;
  }

  Future<void> reconcile(Database db) =>
      db.transaction(DatabaseMigrations.reconcileCharacterRows);

  /// [table]'s rows for [uuid] as ID → selected.
  Future<Map<String, bool>> rowsOf(
    Database db,
    String table,
    String uuid,
  ) async {
    final idColumn = table == 'CharacterPerks' ? 'PerkID' : 'MasteryID';
    final flagColumn = table == 'CharacterPerks'
        ? 'IsSelected'
        : 'MasteryAchieved';
    final rows = await db.query(
      table,
      where: 'CharacterUuid = ?',
      whereArgs: [uuid],
    );
    expect(
      rows.map((r) => r[idColumn]).toSet(),
      hasLength(rows.length),
      reason: 'duplicate $table rows for $uuid',
    );
    return {for (final r in rows) '${r[idColumn]}': r[flagColumn] == 1};
  }

  /// Every perk/mastery row with its rowid, so a rewrite is visible.
  Future<List<Map<String, Object?>>> rowsWithRowids(Database db) async => [
    ...await db.rawQuery('SELECT rowid, * FROM CharacterPerks ORDER BY rowid'),
    ...await db.rawQuery(
      'SELECT rowid, * FROM CharacterMasteries ORDER BY rowid',
    ),
  ];

  test('inserts missing perk and mastery rows unselected (BUG-001)', () async {
    final db = await databaseWithCharacters();
    await db.update(
      'CharacterPerks',
      {'IsSelected': 1},
      where: 'PerkID = ?',
      whereArgs: [drifterPerks[1]],
    );
    await db.delete(
      'CharacterPerks',
      where: 'PerkID = ?',
      whereArgs: [drifterPerks[0]],
    );
    await db.delete('CharacterMasteries');

    await reconcile(db);

    expect(await rowsOf(db, 'CharacterPerks', 'drifter'), {
      for (final id in drifterPerks) id: id == drifterPerks[1],
    });
    expect(await rowsOf(db, 'CharacterMasteries', 'drifter'), {
      for (final id in drifterMasteries) id: false,
    });
    await expectDbInvariants(db);
  });

  test('deletes hidden and unknown rows (BUG-002, BUG-006)', () async {
    final db = await databaseWithCharacters();
    await db.insert('CharacterMasteries', {
      'CharacterUuid': 'brute',
      'MasteryID': 'br_base_0',
      'MasteryAchieved': 1,
    });
    await db.insert('CharacterPerks', {
      'CharacterUuid': 'drifter',
      'PerkID': 'drifter_base_99z',
      'IsSelected': 1,
    });

    await reconcile(db);

    expect(await rowsOf(db, 'CharacterMasteries', 'brute'), isEmpty);
    expect(
      (await rowsOf(db, 'CharacterPerks', 'drifter')).keys,
      unorderedEquals(drifterPerks),
    );
    await expectDbInvariants(db);
  });

  test('collapses duplicates, keeping selected if any was selected', () async {
    final db = await databaseWithCharacters();
    await db.insert('CharacterPerks', {
      'CharacterUuid': 'drifter',
      'PerkID': drifterPerks[2],
      'IsSelected': 1,
    });
    // Selected row first, so "last row wins" would lose it.
    await db.update(
      'CharacterMasteries',
      {'MasteryAchieved': 1},
      where: 'CharacterUuid = ? AND MasteryID = ?',
      whereArgs: ['drifter', drifterMasteries[0]],
    );
    await db.insert('CharacterMasteries', {
      'CharacterUuid': 'drifter',
      'MasteryID': drifterMasteries[0],
      'MasteryAchieved': 0,
    });

    await reconcile(db);

    final perks = await rowsOf(db, 'CharacterPerks', 'drifter');
    expect(perks[drifterPerks[2]], isTrue);
    expect(perks.values.where((s) => s), hasLength(1));
    expect(await rowsOf(db, 'CharacterMasteries', 'drifter'), {
      for (final id in drifterMasteries) id: id == drifterMasteries[0],
    });
    await expectDbInvariants(db);
  });

  test('deletes rows whose character no longer exists', () async {
    final db = await databaseWithCharacters();
    await db.delete('Characters', where: 'Uuid = ?', whereArgs: ['drifter']);

    await reconcile(db);

    expect(await rowsOf(db, 'CharacterPerks', 'drifter'), isEmpty);
    expect(await rowsOf(db, 'CharacterMasteries', 'drifter'), isEmpty);
    await expectDbInvariants(db);
  });

  test('reads the uppercase class codes of v1–v4 characters', () async {
    final db = await databaseWithCharacters();
    await db.update(
      'Characters',
      {'ClassCode': 'DRIFTER'},
      where: 'Uuid = ?',
      whereArgs: ['drifter'],
    );
    await db.delete('CharacterMasteries');

    await reconcile(db);

    expect(
      (await rowsOf(db, 'CharacterMasteries', 'drifter')).keys,
      unorderedEquals(drifterMasteries),
    );
  });

  test('leaves a character with an unknown variant untouched', () async {
    final db = await databaseWithCharacters();
    await db.update(
      'Characters',
      {'Variant': 'fromTheFuture'},
      where: 'Uuid = ?',
      whereArgs: ['drifter'],
    );
    await db.insert('CharacterPerks', {
      'CharacterUuid': 'drifter',
      'PerkID': 'drifter_fromTheFuture_0',
      'IsSelected': 1,
    });
    final before = await rowsWithRowids(db);

    await reconcile(db);

    expect(await rowsWithRowids(db), before);
  });

  test('writes nothing when every row already matches', () async {
    final db = await databaseWithCharacters();
    final before = await rowsWithRowids(db);

    await reconcile(db);

    expect(await rowsWithRowids(db), before);
  });

  test('is idempotent', () async {
    final db = await databaseWithCharacters();
    await db.delete('CharacterMasteries');
    await db.insert('CharacterPerks', {
      'CharacterUuid': 'brute',
      'PerkID': 'unknown',
      'IsSelected': 0,
    });

    await reconcile(db);
    final once = await rowsWithRowids(db);
    await reconcile(db);

    expect(await rowsWithRowids(db), once);
  });

  test('restoring a backup reconciles its rows', () async {
    final db = await databaseWithCharacters();
    final backup = jsonDecode(await generate()) as List;
    final tables = backup[0] as List;
    final masteries = backup[1][tables.indexOf('CharacterMasteries')] as List;
    masteries.clear();
    masteries.add({
      'CharacterUuid': 'brute',
      'MasteryID': 'br_base_0',
      'MasteryAchieved': 1,
    });

    await restore(jsonEncode(backup));

    expect(await rowsOf(db, 'CharacterMasteries', 'drifter'), {
      for (final id in drifterMasteries) id: false,
    });
    expect(await rowsOf(db, 'CharacterMasteries', 'brute'), isEmpty);
    await expectDbInvariants(db);
  });
}
