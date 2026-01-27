import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';

import 'database_migrations.dart';

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = 'GloomhavenCompanion.db';

  // Increment this version when you need to change the schema.
  static const _databaseVersion = 16;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  // String? databasePath;
  List<String> tables = [
    tableCharacters,
    tableCharacterPerks,
    tableCharacterMasteries,
    tableMetaData,
  ];

  Future<Database> get database async => _database ??= await _initDatabase();

  static const String tableMetaData = 'MetaData';

  static const String columnDatabaseVersion = 'DatabaseVersion';
  static const String columnAppVersion = 'AppVersion';
  static const String columnAppBuildNumber = 'AppBuildNumber';
  static const String columnLastUpdated = 'LastUpdated';

  // open the database
  Future<Database> _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String databasePath = join(documentsDirectory.path, _databaseName);
    debugPrint('Database Path:: $databasePath');
    // Open the database. Can also add an onUpgrade callback parameter.
    return await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String idTextPrimaryType = 'TEXT PRIMARY KEY';
  static const String textType = 'TEXT NOT NULL';
  static const String boolType = 'BOOL NOT NULL';
  static const String integerType = 'INTEGER NOT NULL';
  static const String dateTimeType = 'DATETIME DEFAULT CURRENT_TIMESTAMP';
  static const String createTable = 'CREATE TABLE';
  static const String dropTable = 'DROP TABLE';

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await DatabaseMigrations.createMetaDataTable(txn, version);
      await txn.execute('''
        $createTable $tableCharacters (
          $columnCharacterId $idType,
          $columnCharacterUuid $textType,
          $columnCharacterName $textType,
          $columnCharacterClassCode $textType,
          $columnPreviousRetirements $integerType,
          $columnCharacterXp $integerType,
          $columnCharacterGold $integerType,
          $columnCharacterNotes $textType,
          $columnCharacterCheckMarks $integerType,
          $columnIsRetired $boolType,
          $columnResourceHide $integerType,
          $columnResourceMetal $integerType,
          $columnResourceLumber $integerType,
          $columnResourceArrowvine $integerType,
          $columnResourceAxenut $integerType,
          $columnResourceRockroot $integerType,
          $columnResourceFlamefruit $integerType,
          $columnResourceCorpsecap $integerType,
          $columnResourceSnowthistle $integerType,
          $columnVariant $textType
        )''');
      await txn.execute('''
        $createTable $tablePerks (
          $columnPerkId $idTextPrimaryType,
          $columnPerkClass $textType,
          $columnPerkDetails $textType,
          $columnPerkIsGrouped $boolType DEFAULT 0,
          $columnPerkVariant $textType
        )''');
      await Future.forEach(PerksRepository.perksMap.entries, (entry) async {
        final classCode = entry.key;
        final perkLists = entry.value;
        for (Perks list in perkLists) {
          for (Perk perk in list.perks) {
            perk.variant = list.variant;
            perk.classCode = classCode;
            for (int i = 0; i < perk.quantity; i++) {
              String index = (list.perks.indexOf(perk) + 1).toString().padLeft(
                2,
                '0',
              );
              await txn.insert(
                tablePerks,
                perk.toMap('$index${indexToLetter(i)}'),
              );
            }
          }
        }
      });
      await txn.execute('''
        $createTable $tableCharacterPerks (
          $columnAssociatedCharacterUuid $textType,
          $columnAssociatedPerkId $textType,
          $columnCharacterPerkIsSelected $boolType
        )''');
      await txn.execute('''
        $createTable $tableMasteries (
          $columnMasteryId $idTextPrimaryType,
          $columnMasteryClass $textType,
          $columnMasteryDetails $textType,
          $columnMasteryVariant $textType
        )''');
      await Future.forEach(MasteriesRepository.masteriesMap.entries, (
        entry,
      ) async {
        final classCode = entry.key;
        final masteriesList = entry.value;
        for (Masteries list in masteriesList) {
          for (Mastery mastery in list.masteries) {
            mastery.variant = list.variant;
            mastery.classCode = classCode;
            await txn.insert(
              tableMasteries,
              mastery.toMap('${list.masteries.indexOf(mastery)}'),
            );
          }
        }
      });
      await txn.execute('''
        $createTable $tableCharacterMasteries (
          $columnAssociatedCharacterUuid $textType,
          $columnAssociatedMasteryId $textType,
          $columnCharacterMasteryAchieved $boolType
        )''');
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      if (oldVersion <= 4) {
        // Add perks for Crimson Scales classes
        await DatabaseMigrations.regenerateLegacyPerksTable(txn);
        // Add Uuid column to CharactersTable and CharacterPerks table,
        // and change schema for both
        await DatabaseMigrations.migrateToUuids(txn);
      }
      if (oldVersion <= 5) {
        // Cleanup perks and add Ruinmaw
        // https://discord.com/channels/728375347732807825/755811690159013925
        await DatabaseMigrations.regenerateLegacyPerksTable(txn);
      }
      if (oldVersion <= 6) {
        // Include all Frosthaven class perks
        // Include Thornreaper, Incarnate, and Rimehearth perks
        await DatabaseMigrations.regenerateLegacyPerksTable(txn);
        // Include class Masteries
        await DatabaseMigrations.includeClassMasteries(txn);
        // Include Resources
        await DatabaseMigrations.includeResources(txn);
      }
      if (oldVersion <= 7) {
        await DatabaseMigrations.createMetaDataTable(txn, newVersion);
        await DatabaseMigrations.addVariantColumnToCharacterTable(txn);
        await DatabaseMigrations.convertCharacterPerkIdColumnFromIntToText(txn);
        await DatabaseMigrations.convertCharacterMasteryIdColumnFromIntToText(
          txn,
        );
        await DatabaseMigrations.includeClassVariantsAndPerksAsMap(txn);
        await DatabaseMigrations.includeClassVariantsAndMasteriesAsMap(txn);
      }
      if (oldVersion <= 8) {
        // Added Vimthreader class
        // https://discord.com/channels/728375347732807825/732003202458714193
        await DatabaseMigrations.regeneratePerksTable(txn);
      }
      if (oldVersion <= 9) {
        // Added CORE class
        // https://discord.com/channels/728375347732807825/880838569734852638
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      if (oldVersion <= 10) {
        // Added DOME class
        // https://discord.com/channels/728375347732807825/756851069471948800
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      if (oldVersion <= 11) {
        // Added Skitterclaw class
        // https://discord.com/channels/728375347732807825/1115885987415998574
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      if (oldVersion <= 12) {
        // Added Bruiser, Tinkerer, Spellweaver, Silent Knife, Cragheart,
        // and Mindthief Gloomhaven Second Edition classes
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      if (oldVersion <= 13) {
        // Added Mercenary Pack 2025 classes
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      if (oldVersion <= 14) {
        // Minor fix for 'consume_X' icons in Perks Repository
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      if (oldVersion <= 15) {
        // Add Alchemancer class
        // https://discord.com/channels/728375347732807825/1268641237955514491
        await DatabaseMigrations.regeneratePerksAndMasteriesTables(txn);
      }
      // Always update metadata table
      await DatabaseMigrations.updateMetaDataTable(txn, newVersion);
    });
  }

  Future<String> generateBackup() async {
    Database dbs = await database;
    List data = [];
    List<Map<String, dynamic>> listMaps = [];

    for (final String table in tables) {
      listMaps = await dbs.query(table);
      data.add(listMaps);
    }

    List backups = [tables, data];

    return convert.jsonEncode(backups);
  }

  Future<void> restoreBackup(String backup) async {
    // Backup the current data incase of an error and restore it
    String fallBack = await generateBackup();

    var dbs = await database;

    await _clearAllTables();

    Batch batch = dbs.batch();

    List json = convert.jsonDecode(backup);

    if (!json[0].contains('MetaData')) {
      throw ('No Meta Data Table');
    }

    for (var i = 0; i < json[0].length; i++) {
      for (var k = 0; k < json[1][i].length; k++) {
        // This handles the case where a user tries to restore a backup
        // from a database version before 7 (Resources)
        if (i < 1) {
          json[1][i][k][columnResourceHide] ??= 0;
          json[1][i][k][columnResourceMetal] ??= 0;
          json[1][i][k][columnResourceLumber] ??= 0;
          json[1][i][k][columnResourceArrowvine] ??= 0;
          json[1][i][k][columnResourceAxenut] ??= 0;
          json[1][i][k][columnResourceRockroot] ??= 0;
          json[1][i][k][columnResourceFlamefruit] ??= 0;
          json[1][i][k][columnResourceCorpsecap] ??= 0;
          json[1][i][k][columnResourceSnowthistle] ??= 0;
        }

        batch.insert(json[0][i], json[1][i][k]);
      }
    }

    await batch.commit(continueOnError: false, noResult: true).onError((
      error,
      stackTrace,
    ) async {
      await restoreBackup(fallBack);
      throw error ?? 'Error restoring backup';
    });
  }

  Future _clearAllTables() async {
    try {
      Database dbs = await database;
      for (String table in tables) {
        await dbs.delete(table);
        await dbs.rawQuery('DELETE FROM sqlite_sequence where name="$table"');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<int> insertCharacter(Character character) async {
    Database db = await database;
    int id = await db.insert(tableCharacters, character.toMap());
    final perks = await queryPerks(character);
    for (final perk in perks) {
      await db.insert(tableCharacterPerks, {
        columnAssociatedCharacterUuid: character.uuid,
        columnAssociatedPerkId: perk[columnPerkId],
        columnCharacterPerkIsSelected: 0,
      });
    }
    if (character.showMasteries()) {
      final masteries = await queryMasteries(character);
      for (final mastery in masteries) {
        await db.insert(tableCharacterMasteries, {
          columnAssociatedCharacterUuid: character.uuid,
          columnAssociatedMasteryId: mastery[columnMasteryId],
          columnCharacterMasteryAchieved: 0,
        });
      }
    }
    return id;
  }

  Future<void> updateCharacter(Character updatedCharacter) async {
    Database db = await database;
    await db.update(
      tableCharacters,
      updatedCharacter.toMap(),
      where: '$columnCharacterUuid = ?',
      whereArgs: [updatedCharacter.uuid],
    );
  }

  Future<void> updateCharacterPerk(CharacterPerk perk, bool value) async {
    Database db = await database;
    Map<String, dynamic> map = {
      columnAssociatedCharacterUuid: perk.associatedCharacterUuid,
      columnAssociatedPerkId: perk.associatedPerkId,
      columnCharacterPerkIsSelected: value ? 1 : 0,
    };
    await db.update(
      tableCharacterPerks,
      map,
      where:
          '$columnAssociatedPerkId = ? AND $columnAssociatedCharacterUuid = ?',
      whereArgs: [perk.associatedPerkId, perk.associatedCharacterUuid],
    );
  }

  Future<void> updateCharacterMastery(
    CharacterMastery mastery,
    bool value,
  ) async {
    Database db = await database;
    Map<String, dynamic> map = {
      columnAssociatedCharacterUuid: mastery.associatedCharacterUuid,
      columnAssociatedMasteryId: mastery.associatedMasteryId,
      columnCharacterMasteryAchieved: value ? 1 : 0,
    };
    await db.update(
      tableCharacterMasteries,
      map,
      where:
          '$columnAssociatedMasteryId = ? AND $columnAssociatedCharacterUuid = ?',
      whereArgs: [mastery.associatedMasteryId, mastery.associatedCharacterUuid],
    );
  }

  Future<List<CharacterPerk>> queryCharacterPerks(String characterUuid) async {
    Database db = await database;
    List<CharacterPerk> list = [];
    List<Map<String, Object?>> result = await db.query(
      tableCharacterPerks,
      where: '$columnAssociatedCharacterUuid = ?',
      whereArgs: [characterUuid],
    );
    for (final perk in result) {
      list.add(CharacterPerk.fromMap(perk));
    }
    return list;
  }

  Future<List<CharacterMastery>> queryCharacterMasteries(
    String characterUuid,
  ) async {
    Database db = await database;
    List<CharacterMastery> list = [];
    List<Map<String, Object?>> result = await db.query(
      tableCharacterMasteries,
      where: '$columnAssociatedCharacterUuid = ?',
      whereArgs: [characterUuid],
    );
    for (final mastery in result) {
      list.add(CharacterMastery.fromMap(mastery));
    }
    return list;
  }

  Future<List<Map<String, Object?>>> queryPerks(Character character) async {
    Database db = await database;
    List<Map<String, Object?>> result = await db.query(
      tablePerks,
      where: '$columnPerkClass = ? AND $columnPerkVariant = ?',
      whereArgs: [character.playerClass.classCode, character.variant.name],
    );
    return result.toList();
  }

  Future<List<Map<String, Object?>>> queryMasteries(Character character) async {
    Database db = await database;
    List<Map<String, Object?>> result = await db.query(
      tableMasteries,
      where: '$columnMasteryClass = ? AND $columnMasteryVariant = ?',
      whereArgs: [character.playerClass.classCode, character.variant.name],
    );
    return result.toList();
  }

  Future<List<Character>> queryAllCharacters() async {
    Database db = await database;
    List<Character> list = [];
    await db.query(tableCharacters).then((charactersMap) {
      for (final character in charactersMap) {
        list.add(Character.fromMap(character));
      }
    });
    return list;
  }

  Future<void> deleteCharacter(Character character) async {
    Database db = await database;
    return await db.transaction((txn) async {
      await txn.delete(
        tableCharacters,
        where: '$columnCharacterUuid = ?',
        whereArgs: [character.uuid],
      );
      await txn.delete(
        tableCharacterPerks,
        where: '$columnAssociatedCharacterUuid = ?',
        whereArgs: [character.uuid],
      );
      await txn.delete(
        tableCharacterMasteries,
        where: '$columnAssociatedCharacterUuid = ?',
        whereArgs: [character.uuid],
      );
    });
  }
}

String indexToLetter(int index) {
  if (index < 0) {
    throw ArgumentError('Index must be non-negative');
  }

  const int alphabetSize = 26; // Assuming you want to use the English alphabet

  // Calculate the corresponding letter based on ASCII value
  // 'a' is ASCII 97
  final int letterCode = 97 + (index % alphabetSize);

  return String.fromCharCode(letterCode);
}
