import 'dart:convert' as convert;

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_backup_service.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Tests for [DatabaseBackupService] using an in-memory FFI SQLite instance.
///
/// The MetaData table is created manually here (instead of going through
/// [DatabaseMigrations.createMetaDataTable]) because that helper calls
/// [PackageInfo.fromPlatform] which doesn't work in tests.
void main() {
  // sqflite_common_ffi requires global init for the test environment.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late DatabaseBackupService service;
  final tables = [
    tableCharacters,
    tableCharacterPerks,
    tableCharacterMasteries,
    DatabaseHelper.tableMetaData,
  ];

  Future<void> seedMetaData(int dbVersion, String appVersion) async {
    await db.insert(DatabaseHelper.tableMetaData, {
      DatabaseHelper.columnDatabaseVersion: dbVersion,
      DatabaseHelper.columnAppVersion: appVersion,
      DatabaseHelper.columnAppBuildNumber: '1',
    });
  }

  Future<void> seedCharacterRow({
    required String uuid,
    String name = 'Test Char',
    String classCode = 'br',
    int xp = 0,
    int gold = 0,
  }) async {
    await db.insert(tableCharacters, {
      columnCharacterUuid: uuid,
      columnCharacterName: name,
      columnCharacterClassCode: classCode,
      columnPreviousRetirements: 0,
      columnCharacterXp: xp,
      columnCharacterGold: gold,
      columnCharacterNotes: '',
      columnCharacterCheckMarks: 0,
      columnIsRetired: 0,
      columnShowResources: 1,
      columnIsJawsOfTheLion: 0,
      columnResourceHide: 0,
      columnResourceMetal: 0,
      columnResourceLumber: 0,
      columnResourceArrowvine: 0,
      columnResourceAxenut: 0,
      columnResourceRockroot: 0,
      columnResourceFlamefruit: 0,
      columnResourceCorpsecap: 0,
      columnResourceSnowthistle: 0,
      columnVariant: 'base',
      columnCharacterPersonalQuestId: '',
      columnCharacterPersonalQuestProgress: '[]',
    });
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefs().init();
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 20),
    );

    // Manually build the current schema (a subset matching what generateBackup
    // walks). Mirrors DatabaseHelper._createTables (fresh install — NOT NULL
    // with no DEFAULT) and DatabaseMigrations.createMetaDataTable.
    await db.execute('''
      CREATE TABLE $tableCharacters (
        $columnCharacterId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCharacterUuid TEXT NOT NULL,
        $columnCharacterName TEXT NOT NULL,
        $columnCharacterClassCode TEXT NOT NULL,
        $columnPreviousRetirements INTEGER NOT NULL,
        $columnCharacterXp INTEGER NOT NULL,
        $columnCharacterGold INTEGER NOT NULL,
        $columnCharacterNotes TEXT NOT NULL,
        $columnCharacterCheckMarks INTEGER NOT NULL,
        $columnIsRetired BOOL NOT NULL,
        $columnShowResources BOOL NOT NULL,
        $columnIsJawsOfTheLion BOOL NOT NULL,
        $columnResourceHide INTEGER NOT NULL,
        $columnResourceMetal INTEGER NOT NULL,
        $columnResourceLumber INTEGER NOT NULL,
        $columnResourceArrowvine INTEGER NOT NULL,
        $columnResourceAxenut INTEGER NOT NULL,
        $columnResourceRockroot INTEGER NOT NULL,
        $columnResourceFlamefruit INTEGER NOT NULL,
        $columnResourceCorpsecap INTEGER NOT NULL,
        $columnResourceSnowthistle INTEGER NOT NULL,
        $columnVariant TEXT NOT NULL,
        $columnCharacterPersonalQuestId TEXT DEFAULT '',
        $columnCharacterPersonalQuestProgress TEXT DEFAULT '[]'
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCharacterPerks (
        $columnAssociatedCharacterUuid TEXT NOT NULL,
        $columnAssociatedPerkId TEXT NOT NULL,
        $columnCharacterPerkIsSelected BOOL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCharacterMasteries (
        $columnAssociatedCharacterUuid TEXT NOT NULL,
        $columnAssociatedMasteryId TEXT NOT NULL,
        $columnCharacterMasteryAchieved BOOL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableMetaData} (
        ${DatabaseHelper.columnDatabaseVersion} INTEGER NOT NULL,
        ${DatabaseHelper.columnAppVersion} TEXT NOT NULL,
        ${DatabaseHelper.columnAppBuildNumber} TEXT NOT NULL,
        ${DatabaseHelper.columnLastUpdated} DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    service = DatabaseBackupService(
      getDatabase: () async => db,
      tables: tables,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('generateBackup', () {
    test('produces a 3-element JSON array (tables, data, prefs)', () async {
      await seedMetaData(19, '4.5.3');
      final backup = await service.generateBackup();
      final json = convert.jsonDecode(backup) as List;

      expect(json.length, 3);
      expect(json[0], tables);
      expect(json[1], isA<List>());
      expect(json[2], isA<Map>());
    });

    test('table data is in same order as table names', () async {
      await seedMetaData(19, '4.5.3');
      await seedCharacterRow(uuid: 'uuid-1', name: 'Brutus');
      await db.insert(tableCharacterPerks, {
        columnAssociatedCharacterUuid: 'uuid-1',
        columnAssociatedPerkId: 'br_base_01a',
        columnCharacterPerkIsSelected: 1,
      });

      final json = convert.jsonDecode(await service.generateBackup()) as List;

      final charactersIdx = (json[0] as List).indexOf(tableCharacters);
      final perksIdx = (json[0] as List).indexOf(tableCharacterPerks);

      final characters = json[1][charactersIdx] as List;
      final perks = json[1][perksIdx] as List;

      expect(characters, hasLength(1));
      expect(characters[0][columnCharacterName], 'Brutus');
      expect(perks, hasLength(1));
      expect(perks[0][columnAssociatedCharacterUuid], 'uuid-1');
    });

    test('empty database produces empty table arrays', () async {
      final json = convert.jsonDecode(await service.generateBackup()) as List;

      // All four tables present, all empty.
      for (final tableData in json[1]) {
        expect(tableData, isEmpty);
      }
    });

    test('SharedPreferences are included as the third element', () async {
      // Set a known pref value — exportForBackup includes settings.darkTheme
      // and calculator.gameEdition among others.
      SharedPrefs().darkTheme = true;
      SharedPrefs().showRetiredCharacters = false;

      final json = convert.jsonDecode(await service.generateBackup()) as List;
      final prefs = json[2] as Map;

      expect(prefs['settings'], isA<Map>());
      expect(prefs['settings']['darkTheme'], true);
      expect(prefs['settings']['showRetiredCharacters'], false);
    });
  });

  group('restoreBackup — round-trip', () {
    test('character data survives backup → wipe → restore', () async {
      await seedMetaData(19, '4.5.3');
      await seedCharacterRow(
        uuid: 'uuid-restore-1',
        name: 'Survivor',
        xp: 123,
        gold: 50,
      );

      final backup = await service.generateBackup();

      // Wipe and restore.
      await service.restoreBackup(backup);

      final rows = await db.query(tableCharacters);
      expect(rows, hasLength(1));
      expect(rows.first[columnCharacterName], 'Survivor');
      expect(rows.first[columnCharacterXp], 123);
      expect(rows.first[columnCharacterGold], 50);
    });

    test('perks and masteries survive round-trip', () async {
      await seedMetaData(19, '4.5.3');
      await seedCharacterRow(uuid: 'uuid-pm');
      await db.insert(tableCharacterPerks, {
        columnAssociatedCharacterUuid: 'uuid-pm',
        columnAssociatedPerkId: 'br_base_01a',
        columnCharacterPerkIsSelected: 1,
      });
      await db.insert(tableCharacterMasteries, {
        columnAssociatedCharacterUuid: 'uuid-pm',
        columnAssociatedMasteryId: 'br_base_1',
        columnCharacterMasteryAchieved: 1,
      });

      final backup = await service.generateBackup();
      await service.restoreBackup(backup);

      final perks = await db.query(tableCharacterPerks);
      final masteries = await db.query(tableCharacterMasteries);
      expect(perks, hasLength(1));
      expect(perks.first[columnAssociatedPerkId], 'br_base_01a');
      expect(masteries, hasLength(1));
      expect(masteries.first[columnAssociatedMasteryId], 'br_base_1');
    });

    test(
      'restore replaces existing data — pre-existing rows are wiped',
      () async {
        await seedMetaData(19, '4.5.3');
        await seedCharacterRow(uuid: 'uuid-old', name: 'Old');
        final backup = await service.generateBackup();

        // Add another row that should be removed by restore.
        await seedCharacterRow(uuid: 'uuid-new', name: 'New');

        await service.restoreBackup(backup);

        final rows = await db.query(tableCharacters);
        expect(rows, hasLength(1));
        expect(rows.first[columnCharacterName], 'Old');
      },
    );

    test('SharedPreferences are restored from the backup payload', () async {
      await seedMetaData(19, '4.5.3');
      SharedPrefs().darkTheme = true;
      final backup = await service.generateBackup();

      // Mutate prefs after backing up.
      SharedPrefs().darkTheme = false;
      expect(SharedPrefs().darkTheme, false);

      await service.restoreBackup(backup);

      expect(SharedPrefs().darkTheme, true);
    });
  });

  group('restoreBackup — version validation', () {
    test('throws when backup omits the MetaData table', () async {
      final invalid = convert.jsonEncode([
        ['Characters'],
        [[]],
        {},
      ]);

      expect(
        () => service.restoreBackup(invalid),
        throwsA(contains('No Meta Data Table')),
      );
    });

    test('throws when MetaData rows are empty', () async {
      final invalid = convert.jsonEncode([
        [DatabaseHelper.tableMetaData],
        [<Map<String, dynamic>>[]],
        {},
      ]);

      expect(
        () => service.restoreBackup(invalid),
        throwsA(contains('no longer supported')),
      );
    });

    test('throws when DB version is below the minimum supported (8)', () async {
      final invalid = convert.jsonEncode([
        [DatabaseHelper.tableMetaData],
        [
          [
            {
              DatabaseHelper.columnDatabaseVersion: 5,
              DatabaseHelper.columnAppVersion: '3.0.0',
            },
          ],
        ],
        {},
      ]);

      expect(
        () => service.restoreBackup(invalid),
        throwsA(allOf(contains('3.0.0'), contains('no longer supported'))),
      );
    });

    test('accepts DB version 8 (the minimum)', () async {
      // Seed a v8-shaped backup with no rows other than MetaData.
      // The restoreBackup path skips tables not in the current schema,
      // and MetaData is always preserved.
      final v8Backup = convert.jsonEncode([
        [DatabaseHelper.tableMetaData],
        [
          [
            {
              DatabaseHelper.columnDatabaseVersion: 8,
              DatabaseHelper.columnAppVersion: '4.2.0',
              DatabaseHelper.columnAppBuildNumber: '1',
            },
          ],
        ],
        {},
      ]);

      // Should not throw.
      await service.restoreBackup(v8Backup);

      final meta = await db.query(DatabaseHelper.tableMetaData);
      expect(meta.first[DatabaseHelper.columnAppVersion], '4.2.0');
    });
  });

  group('restoreBackup — column patching', () {
    test(
      'older backups missing PersonalQuest columns get default values',
      () async {
        // Build a backup map by hand without PersonalQuest columns.
        final char = {
          columnCharacterUuid: 'uuid-old-schema',
          columnCharacterName: 'Pre-PQ',
          columnCharacterClassCode: 'br',
          columnPreviousRetirements: 0,
          columnCharacterXp: 0,
          columnCharacterGold: 0,
          columnCharacterNotes: '',
          columnCharacterCheckMarks: 0,
          columnIsRetired: 0,
          columnResourceHide: 0,
          columnResourceMetal: 0,
          columnResourceLumber: 0,
          columnResourceArrowvine: 0,
          columnResourceAxenut: 0,
          columnResourceRockroot: 0,
          columnResourceFlamefruit: 0,
          columnResourceCorpsecap: 0,
          columnResourceSnowthistle: 0,
          columnVariant: 'base',
          // No personalQuestId / personalQuestProgress
        };

        final backup = convert.jsonEncode([
          [tableCharacters, DatabaseHelper.tableMetaData],
          [
            [char],
            [
              {
                DatabaseHelper.columnDatabaseVersion: 17,
                DatabaseHelper.columnAppVersion: '4.4.0',
                DatabaseHelper.columnAppBuildNumber: '1',
              },
            ],
          ],
          {},
        ]);

        await service.restoreBackup(backup);

        final rows = await db.query(tableCharacters);
        expect(rows, hasLength(1));
        expect(rows.first[columnCharacterPersonalQuestId], '');
        expect(rows.first[columnCharacterPersonalQuestProgress], '[]');
      },
    );

    test(
      'older backups missing ShowResources/IsJawsOfTheLion get defaults',
      () async {
        // A pre-v20 character row: no ShowResources or IsJawsOfTheLion columns
        // (both added in v20). Restoring into the current NOT NULL schema must
        // patch them, otherwise the insert violates the NOT NULL constraint.
        final char = {
          columnCharacterUuid: 'uuid-pre-v20',
          columnCharacterName: 'Pre-Resources',
          columnCharacterClassCode: 'br',
          columnPreviousRetirements: 0,
          columnCharacterXp: 0,
          columnCharacterGold: 0,
          columnCharacterNotes: '',
          columnCharacterCheckMarks: 0,
          columnIsRetired: 0,
          columnResourceHide: 0,
          columnResourceMetal: 0,
          columnResourceLumber: 0,
          columnResourceArrowvine: 0,
          columnResourceAxenut: 0,
          columnResourceRockroot: 0,
          columnResourceFlamefruit: 0,
          columnResourceCorpsecap: 0,
          columnResourceSnowthistle: 0,
          columnVariant: 'base',
          columnCharacterPersonalQuestId: '',
          columnCharacterPersonalQuestProgress: '[]',
          // No ShowResources / IsJawsOfTheLion
        };

        final backup = convert.jsonEncode([
          [tableCharacters, DatabaseHelper.tableMetaData],
          [
            [char],
            [
              {
                DatabaseHelper.columnDatabaseVersion: 19,
                DatabaseHelper.columnAppVersion: '4.5.3',
                DatabaseHelper.columnAppBuildNumber: '1',
              },
            ],
          ],
          {},
        ]);

        await service.restoreBackup(backup);

        final rows = await db.query(tableCharacters);
        expect(rows, hasLength(1));
        // Defaults: resources shown, not a JotL character.
        expect(rows.first[columnShowResources], 1);
        expect(rows.first[columnIsJawsOfTheLion], 0);
      },
    );
  });

  group('restoreBackup — unknown tables', () {
    test('tables present in backup but not in schema are skipped', () async {
      // Build a backup that includes a "FuturePersonalQuestsTable" not in
      // our schema. Restore should ignore it and complete without error.
      final backup = convert.jsonEncode([
        [
          tableCharacters,
          'FuturePersonalQuestsTable',
          DatabaseHelper.tableMetaData,
        ],
        [
          [],
          [
            {'fake_column': 'fake_value'},
          ],
          [
            {
              DatabaseHelper.columnDatabaseVersion: 19,
              DatabaseHelper.columnAppVersion: '4.5.3',
              DatabaseHelper.columnAppBuildNumber: '1',
            },
          ],
        ],
        {},
      ]);

      await service.restoreBackup(backup);

      // Restore completed and the known tables still respond to queries.
      final rows = await db.query(tableCharacters);
      expect(rows, isEmpty);
    });
  });

  group('CharacterPerk / CharacterMastery model serialization', () {
    test('CharacterPerk.fromMap reconstructs a backup row', () async {
      final map = {
        columnAssociatedCharacterUuid: 'uuid-perk',
        columnAssociatedPerkId: 'br_base_01a',
        columnCharacterPerkIsSelected: 1,
      };
      final perk = CharacterPerk.fromMap(map);
      expect(perk.associatedCharacterUuid, 'uuid-perk');
      expect(perk.associatedPerkId, 'br_base_01a');
      expect(perk.characterPerkIsSelected, true);
    });

    test('CharacterMastery.fromMap reconstructs a backup row', () async {
      final map = {
        columnAssociatedCharacterUuid: 'uuid-mast',
        columnAssociatedMasteryId: 'br_base_1',
        columnCharacterMasteryAchieved: 0,
      };
      final mastery = CharacterMastery.fromMap(map);
      expect(mastery.associatedCharacterUuid, 'uuid-mast');
      expect(mastery.associatedMasteryId, 'br_base_1');
      expect(mastery.characterMasteryAchieved, false);
    });
  });
}
