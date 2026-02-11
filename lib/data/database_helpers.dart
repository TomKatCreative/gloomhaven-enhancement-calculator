import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';

import 'database_migrations.dart';

// singleton class to manage the database
class DatabaseHelper implements IDatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = 'GloomhavenCompanion.db';

  // Increment this version when you need to change the schema.
  static const _databaseVersion = (kTownSheetEnabled || kPersonalQuestsEnabled)
      ? 18
      : 17;

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
    if (kTownSheetEnabled) tableCampaigns,
    if (kTownSheetEnabled) tableParties,
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
      onDowngrade: onDatabaseDowngradeDelete,
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
      await _createTables(txn);
      if (kTownSheetEnabled) await _createCampaignPartyTables(txn);
      await _seedPerks(txn);
      await _seedMasteries(txn);
      if (kPersonalQuestsEnabled) await _seedPersonalQuests(txn);
    });
  }

  /// Creates all database tables (Characters, Perks, CharacterPerks,
  /// Masteries, CharacterMasteries).
  Future<void> _createTables(Transaction txn) async {
    final characterColumns = [
      '$columnCharacterId $idType',
      '$columnCharacterUuid $textType',
      '$columnCharacterName $textType',
      '$columnCharacterClassCode $textType',
      '$columnPreviousRetirements $integerType',
      '$columnCharacterXp $integerType',
      '$columnCharacterGold $integerType',
      '$columnCharacterNotes $textType',
      '$columnCharacterCheckMarks $integerType',
      '$columnIsRetired $boolType',
      '$columnResourceHide $integerType',
      '$columnResourceMetal $integerType',
      '$columnResourceLumber $integerType',
      '$columnResourceArrowvine $integerType',
      '$columnResourceAxenut $integerType',
      '$columnResourceRockroot $integerType',
      '$columnResourceFlamefruit $integerType',
      '$columnResourceCorpsecap $integerType',
      '$columnResourceSnowthistle $integerType',
      '$columnVariant $textType',
      if (kPersonalQuestsEnabled)
        "$columnCharacterPersonalQuestId $textType DEFAULT ''",
      if (kPersonalQuestsEnabled)
        "$columnCharacterPersonalQuestProgress $textType DEFAULT '[]'",
      if (kTownSheetEnabled) '$columnCharacterPartyId TEXT DEFAULT NULL',
    ];
    await txn.execute(
      '$createTable $tableCharacters (${characterColumns.join(', ')})',
    );

    await txn.execute('''
      $createTable $tablePerks (
        $columnPerkId $idTextPrimaryType,
        $columnPerkClass $textType,
        $columnPerkDetails $textType,
        $columnPerkIsGrouped $boolType DEFAULT 0,
        $columnPerkVariant $textType
      )''');

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

    await txn.execute('''
      $createTable $tableCharacterMasteries (
        $columnAssociatedCharacterUuid $textType,
        $columnAssociatedMasteryId $textType,
        $columnCharacterMasteryAchieved $boolType
      )''');

    if (kPersonalQuestsEnabled) {
      await txn.execute('''
        $createTable $tablePersonalQuests (
          $columnPersonalQuestId $idTextPrimaryType,
          $columnPersonalQuestNumber $textType,
          $columnPersonalQuestTitle $textType,
          $columnPersonalQuestEdition $textType
        )''');
    }
  }

  /// Seeds the Perks table from PerksRepository.
  Future<void> _seedPerks(Transaction txn) async {
    for (final entry in PerksRepository.perksMap.entries) {
      final classCode = entry.key;
      final perkLists = entry.value;

      for (final list in perkLists) {
        for (int perkIndex = 0; perkIndex < list.perks.length; perkIndex++) {
          final perk = list.perks[perkIndex];
          perk.variant = list.variant;
          perk.classCode = classCode;

          final paddedIndex = (perkIndex + 1).toString().padLeft(2, '0');
          for (int i = 0; i < perk.quantity; i++) {
            await txn.insert(
              tablePerks,
              perk.toMap('$paddedIndex${indexToLetter(i)}'),
            );
          }
        }
      }
    }
  }

  /// Seeds the Masteries table from MasteriesRepository.
  Future<void> _seedMasteries(Transaction txn) async {
    for (final entry in MasteriesRepository.masteriesMap.entries) {
      final classCode = entry.key;
      final masteriesList = entry.value;

      for (final list in masteriesList) {
        for (int i = 0; i < list.masteries.length; i++) {
          final mastery = list.masteries[i];
          mastery.variant = list.variant;
          mastery.classCode = classCode;

          await txn.insert(tableMasteries, mastery.toMap('$i'));
        }
      }
    }
  }

  /// Seeds the PersonalQuests table from PersonalQuestsRepository.
  Future<void> _seedPersonalQuests(Transaction txn) async {
    for (final quest in PersonalQuestsRepository.quests) {
      await txn.insert(tablePersonalQuests, quest.toMap());
    }
  }

  /// Creates Campaigns and Parties tables (for fresh installs).
  Future<void> _createCampaignPartyTables(Transaction txn) async {
    await txn.execute('''
      $createTable $tableCampaigns (
        $columnCampaignId $idTextPrimaryType,
        $columnCampaignName $textType,
        $columnCampaignEdition $textType,
        $columnCampaignProsperityCheckmarks $integerType DEFAULT 0,
        $columnCampaignDonatedGold $integerType DEFAULT 0,
        $columnCampaignCreatedAt $dateTimeType
      )''');

    await txn.execute('''
      $createTable $tableParties (
        $columnPartyId $idTextPrimaryType,
        $columnPartyCampaignId $textType,
        $columnPartyName $textType,
        $columnPartyReputation $integerType DEFAULT 0,
        $columnPartyCreatedAt $dateTimeType,
        $columnPartyLocation $textType DEFAULT '',
        $columnPartyNotes $textType DEFAULT '',
        $columnPartyAchievements $textType DEFAULT '[]',
        FOREIGN KEY ($columnPartyCampaignId) REFERENCES $tableCampaigns($columnCampaignId) ON DELETE CASCADE
      )''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.transaction((txn) async {
      await _runMigrations(txn, oldVersion, newVersion);
      await DatabaseMigrations.updateMetaDataTable(txn, newVersion);
    });
  }

  /// Runs all applicable migrations between oldVersion and newVersion.
  Future<void> _runMigrations(
    Transaction txn,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration map: version -> migration function
    // Each migration runs for users upgrading FROM a version <= the key
    final migrations = <int, Future<void> Function()>{
      // v5: Add perks for Crimson Scales classes
      // Add Uuid column to CharactersTable and CharacterPerks table,
      // and change schema for both
      4: () async {
        // ignore: deprecated_member_use_from_same_package
        await DatabaseMigrations.regenerateLegacyPerksTable(txn);
        await DatabaseMigrations.migrateToUuids(txn);
      },
      // v6: Cleanup perks and add Ruinmaw
      // https://discord.com/channels/728375347732807825/755811690159013925
      5: () async {
        // ignore: deprecated_member_use_from_same_package
        await DatabaseMigrations.regenerateLegacyPerksTable(txn);
      },
      // v7: Include all Frosthaven class perks
      // Include Thornreaper, Incarnate, and Rimehearth perks
      // Include class Masteries
      // Include Resources
      6: () async {
        // ignore: deprecated_member_use_from_same_package
        await DatabaseMigrations.regenerateLegacyPerksTable(txn);
        await DatabaseMigrations.includeClassMasteries(txn);
        await DatabaseMigrations.includeResources(txn);
      },
      // v8: Metadata table, variants, schema changes
      7: () async {
        await DatabaseMigrations.createMetaDataTable(txn, newVersion);
        await DatabaseMigrations.addVariantColumnToCharacterTable(txn);
        await DatabaseMigrations.convertCharacterPerkIdColumnFromIntToText(txn);
        await DatabaseMigrations.convertCharacterMasteryIdColumnFromIntToText(
          txn,
        );
        await DatabaseMigrations.includeClassVariantsAndPerksAsMap(txn);
        await DatabaseMigrations.includeClassVariantsAndMasteriesAsMap(txn);
      },
      // v9: Added Vimthreader class
      // https://discord.com/channels/728375347732807825/732003202458714193
      8: () => DatabaseMigrations.regeneratePerksTable(txn),
      // v10: Added CORE class
      // https://discord.com/channels/728375347732807825/880838569734852638
      9: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v11: Added DOME class
      // https://discord.com/channels/728375347732807825/756851069471948800
      10: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v12: Added Skitterclaw class
      // https://discord.com/channels/728375347732807825/1115885987415998574
      11: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v13: Added Bruiser, Tinkerer, Spellweaver, Silent Knife, Cragheart,
      // and Mindthief Gloomhaven Second Edition classes
      12: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v14: Added Mercenary Pack 2025 classes
      13: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v15: Minor fix for 'consume_X' icons in Perks Repository
      14: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v16: Add Alchemancer class
      // https://discord.com/channels/728375347732807825/1268641237955514491
      15: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v17: Rename item_minus_one to ITEM_MINUS_ONE
      16: () => DatabaseMigrations.regeneratePerksAndMasteriesTables(txn),
      // v18: Add Personal Quests + Campaigns/Parties tables + PartyId column
      17: () async {
        await DatabaseMigrations.createAndSeedPersonalQuestsTable(txn);
        await DatabaseMigrations.addPersonalQuestColumnsToCharacters(txn);
        await DatabaseMigrations.createCampaignPartyTablesAndAddPartyIdToCharacters(
          txn,
        );
      },
    };

    // Run migrations in order for versions > oldVersion
    final sortedVersions = migrations.keys.toList()..sort();
    for (final version in sortedVersions) {
      if (oldVersion <= version) {
        await migrations[version]!();
      }
    }
  }

  Future<String> generateBackup() async {
    Database dbs = await database;
    List data = [];
    List<Map<String, dynamic>> listMaps = [];

    for (final String table in tables) {
      listMaps = await dbs.query(table);
      data.add(listMaps);
    }

    List backups = [tables, data, SharedPrefs().exportForBackup()];

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
      // Skip tables that don't exist in the current schema
      if (!tables.contains(json[0][i])) continue;

      for (var k = 0; k < json[1][i].length; k++) {
        // This handles the case where a user tries to restore a backup
        // from a database version before 7 (Resources), 18 (Personal Quests),
        // or 19 (Party details)
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
          if (kPersonalQuestsEnabled) {
            json[1][i][k][columnCharacterPersonalQuestId] ??= '';
            json[1][i][k][columnCharacterPersonalQuestProgress] ??= '[]';
          } else {
            // Strip columns that don't exist in the current schema
            json[1][i][k].remove(columnCharacterPersonalQuestId);
            json[1][i][k].remove(columnCharacterPersonalQuestProgress);
          }
          if (kTownSheetEnabled) {
            // PartyId is nullable, no default needed — just ensure key exists
            json[1][i][k].putIfAbsent(columnCharacterPartyId, () => null);
          } else {
            json[1][i][k].remove(columnCharacterPartyId);
          }
        }

        // Default missing party detail columns (added in v19)
        if (json[0][i] == tableParties) {
          json[1][i][k][columnPartyLocation] ??= '';
          json[1][i][k][columnPartyNotes] ??= '';
          json[1][i][k][columnPartyAchievements] ??= '[]';
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

    // Restore SharedPreferences if present (new format backups)
    if (json.length > 2 && json[2] is Map) {
      SharedPrefs().importFromBackup(Map<String, dynamic>.from(json[2]));
    }
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

  @override
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
    if (character.shouldShowMasteries) {
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

  @override
  Future<void> updateCharacter(Character updatedCharacter) async {
    Database db = await database;
    await db.update(
      tableCharacters,
      updatedCharacter.toMap(),
      where: '$columnCharacterUuid = ?',
      whereArgs: [updatedCharacter.uuid],
    );
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<List<Map<String, Object?>>> queryPerks(Character character) async {
    Database db = await database;
    List<Map<String, Object?>> result = await db.query(
      tablePerks,
      where: '$columnPerkClass = ? AND $columnPerkVariant = ?',
      whereArgs: [character.playerClass.classCode, character.variant.name],
    );
    return result.toList();
  }

  @override
  Future<List<Map<String, Object?>>> queryMasteries(Character character) async {
    Database db = await database;
    List<Map<String, Object?>> result = await db.query(
      tableMasteries,
      where: '$columnMasteryClass = ? AND $columnMasteryVariant = ?',
      whereArgs: [character.playerClass.classCode, character.variant.name],
    );
    return result.toList();
  }

  @override
  Future<List<Map<String, Object?>>> queryPersonalQuests({
    GameEdition? edition,
  }) async {
    Database db = await database;
    if (edition != null) {
      return await db.query(
        tablePersonalQuests,
        where: '$columnPersonalQuestEdition = ?',
        whereArgs: [edition.name],
      );
    }
    return await db.query(tablePersonalQuests);
  }

  @override
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

  @override
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

  // ── Campaign CRUD ──

  @override
  Future<List<Campaign>> queryAllCampaigns() async {
    Database db = await database;
    final maps = await db.query(tableCampaigns);
    return maps.map((m) => Campaign.fromMap(m)).toList();
  }

  @override
  Future<void> insertCampaign(Campaign campaign) async {
    Database db = await database;
    await db.insert(tableCampaigns, campaign.toMap());
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    Database db = await database;
    await db.update(
      tableCampaigns,
      campaign.toMap(),
      where: '$columnCampaignId = ?',
      whereArgs: [campaign.id],
    );
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    Database db = await database;
    await db.transaction((txn) async {
      // Unlink characters from parties in this campaign
      final parties = await txn.query(
        tableParties,
        where: '$columnPartyCampaignId = ?',
        whereArgs: [campaignId],
      );
      for (final party in parties) {
        final partyId = party[columnPartyId] as String;
        await txn.update(
          tableCharacters,
          {columnCharacterPartyId: null},
          where: '$columnCharacterPartyId = ?',
          whereArgs: [partyId],
        );
      }
      // Delete parties (CASCADE would handle this but being explicit)
      await txn.delete(
        tableParties,
        where: '$columnPartyCampaignId = ?',
        whereArgs: [campaignId],
      );
      await txn.delete(
        tableCampaigns,
        where: '$columnCampaignId = ?',
        whereArgs: [campaignId],
      );
    });
  }

  // ── Party CRUD ──

  @override
  Future<List<Party>> queryParties(String campaignId) async {
    Database db = await database;
    final maps = await db.query(
      tableParties,
      where: '$columnPartyCampaignId = ?',
      whereArgs: [campaignId],
    );
    return maps.map((m) => Party.fromMap(m)).toList();
  }

  @override
  Future<void> insertParty(Party party) async {
    Database db = await database;
    await db.insert(tableParties, party.toMap());
  }

  @override
  Future<void> updateParty(Party party) async {
    Database db = await database;
    await db.update(
      tableParties,
      party.toMap(),
      where: '$columnPartyId = ?',
      whereArgs: [party.id],
    );
  }

  @override
  Future<void> deleteParty(String partyId) async {
    Database db = await database;
    await db.transaction((txn) async {
      // Unlink characters from this party
      await txn.update(
        tableCharacters,
        {columnCharacterPartyId: null},
        where: '$columnCharacterPartyId = ?',
        whereArgs: [partyId],
      );
      await txn.delete(
        tableParties,
        where: '$columnPartyId = ?',
        whereArgs: [partyId],
      );
    });
  }

  // ── Character-Party linking ──

  @override
  Future<void> assignCharacterToParty(
    String characterUuid,
    String? partyId,
  ) async {
    Database db = await database;
    await db.update(
      tableCharacters,
      {columnCharacterPartyId: partyId},
      where: '$columnCharacterUuid = ?',
      whereArgs: [characterUuid],
    );
  }

  @override
  Future<List<Character>> queryCharactersByParty(String partyId) async {
    Database db = await database;
    final maps = await db.query(
      tableCharacters,
      where: '$columnCharacterPartyId = ?',
      whereArgs: [partyId],
    );
    return maps.map((m) => Character.fromMap(m)).toList();
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
