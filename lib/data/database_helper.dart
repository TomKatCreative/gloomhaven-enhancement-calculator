import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/database_backup_service.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

import 'database_migrations.dart';

// singleton class to manage the database
class DatabaseHelper implements IDatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = 'GloomhavenCompanion.db';

  // Increment this version when you need to change the schema.
  static const _databaseVersion = 19;

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

  DatabaseBackupService get backupService =>
      DatabaseBackupService(getDatabase: () => database, tables: tables);

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
    });
  }

  /// Creates all database tables (Characters, CharacterPerks,
  /// CharacterMasteries).
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
      "$columnCharacterPersonalQuestId $textType DEFAULT ''",
      "$columnCharacterPersonalQuestProgress $textType DEFAULT '[]'",
      if (kTownSheetEnabled) '$columnCharacterPartyId TEXT DEFAULT NULL',
    ];
    await txn.execute(
      '$createTable $tableCharacters (${characterColumns.join(', ')})',
    );

    await txn.execute('''
      $createTable $tableCharacterPerks (
        $columnAssociatedCharacterUuid $textType,
        $columnAssociatedPerkId $textType,
        $columnCharacterPerkIsSelected $boolType
      )''');

    await txn.execute('''
      $createTable $tableCharacterMasteries (
        $columnAssociatedCharacterUuid $textType,
        $columnAssociatedMasteryId $textType,
        $columnCharacterMasteryAchieved $boolType
      )''');
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
      // v18: Personal Quests
      17: () async {
        await DatabaseMigrations.createAndSeedPersonalQuestsTable(txn);
        await DatabaseMigrations.addPersonalQuestColumnsToCharacters(txn);
      },
      // v19: Drop all definition tables (Perks, Masteries, PersonalQuests).
      // Definitions now come from repositories directly at runtime.
      // PersonalQuests was regenerated in v18→v19 for FH quests, but
      // the table itself is no longer needed.
      18: () async {
        await txn.execute('DROP TABLE IF EXISTS PerksTable');
        await txn.execute('DROP TABLE IF EXISTS MasteriesTable');
        await txn.execute('DROP TABLE IF EXISTS PersonalQuestsTable');
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

  @override
  Future<int> insertCharacter(Character character) async {
    Database db = await database;
    int id = await db.insert(tableCharacters, character.toMap());
    final perkIds = PerksRepository.getPerkIds(
      character.playerClass.classCode,
      character.variant,
    );
    for (final perkId in perkIds) {
      await db.insert(tableCharacterPerks, {
        columnAssociatedCharacterUuid: character.uuid,
        columnAssociatedPerkId: perkId,
        columnCharacterPerkIsSelected: 0,
      });
    }
    if (character.shouldShowMasteries) {
      final masteryIds = MasteriesRepository.getMasteryIds(
        character.playerClass.classCode,
        character.variant,
      );
      for (final masteryId in masteryIds) {
        await db.insert(tableCharacterMasteries, {
          columnAssociatedCharacterUuid: character.uuid,
          columnAssociatedMasteryId: masteryId,
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

  /// Generic query helper that maps database rows to typed objects.
  Future<List<T>> _queryAndMap<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final maps = await db.query(table, where: where, whereArgs: whereArgs);
    return maps.map(fromMap).toList();
  }

  @override
  Future<List<CharacterPerk>> queryCharacterPerks(String characterUuid) =>
      _queryAndMap(
        tableCharacterPerks,
        CharacterPerk.fromMap,
        where: '$columnAssociatedCharacterUuid = ?',
        whereArgs: [characterUuid],
      );

  @override
  Future<List<CharacterMastery>> queryCharacterMasteries(
    String characterUuid,
  ) => _queryAndMap(
    tableCharacterMasteries,
    CharacterMastery.fromMap,
    where: '$columnAssociatedCharacterUuid = ?',
    whereArgs: [characterUuid],
  );

  @override
  Future<List<Character>> queryAllCharacters() =>
      _queryAndMap(tableCharacters, Character.fromMap);

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
  Future<List<Campaign>> queryAllCampaigns() =>
      _queryAndMap(tableCampaigns, Campaign.fromMap);

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
  Future<List<Party>> queryParties(String campaignId) => _queryAndMap(
    tableParties,
    Party.fromMap,
    where: '$columnPartyCampaignId = ?',
    whereArgs: [campaignId],
  );

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
  Future<List<Character>> queryCharactersByParty(String partyId) =>
      _queryAndMap(
        tableCharacters,
        Character.fromMap,
        where: '$columnCharacterPartyId = ?',
        whereArgs: [partyId],
      );
}
