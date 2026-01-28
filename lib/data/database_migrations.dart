import 'package:collection/collection.dart';
import 'package:gloomhaven_enhancement_calc/data/database_helpers.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/masteries_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/perks_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/legacy_mastery.dart'
    as legacy;
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/legacy_perk.dart'
    as legacy;
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  static Future<void> regeneratePerksAndMasteriesTables(Transaction txn) async {
    await regeneratePerksTable(txn);
    await _regenerateMasteriesTable(txn);
  }

  static Future<void> regeneratePerksTable(Transaction txn) async {
    await txn.execute('DROP TABLE IF EXISTS $tablePerks');
    await txn.execute('''
        ${DatabaseHelper.createTable} $tablePerks(
          $columnPerkId ${DatabaseHelper.idTextPrimaryType},
          $columnPerkClass ${DatabaseHelper.textType},
          $columnPerkDetails ${DatabaseHelper.textType},
          $columnPerkIsGrouped ${DatabaseHelper.boolType} DEFAULT 0,
          $columnPerkVariant ${DatabaseHelper.textType}
        )''');
    await Future.forEach(PerksRepository.perksMap.entries, (
      MapEntry<String, List<Perks>> entry,
    ) async {
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
  }

  static Future<void> _regenerateMasteriesTable(Transaction txn) async {
    await txn.execute('DROP TABLE IF EXISTS $tableMasteries');
    await txn.execute('''
        ${DatabaseHelper.createTable} $tableMasteries (
          $columnMasteryId ${DatabaseHelper.idTextPrimaryType},
          $columnMasteryClass ${DatabaseHelper.textType},
          $columnMasteryDetails ${DatabaseHelper.textType},
          $columnMasteryVariant ${DatabaseHelper.textType}
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
  }

  @Deprecated('Use `regeneratePerksTable` as of database schema version >= 8')
  static Future<void> regenerateLegacyPerksTable(Transaction txn) async {
    await txn.execute('DROP TABLE IF EXISTS ${legacy.tablePerks}');
    await txn
        .execute('''
        ${DatabaseHelper.createTable} ${legacy.tablePerks}(
          ${legacy.columnPerkId} ${DatabaseHelper.idType},
          ${legacy.columnPerkClass} ${DatabaseHelper.textType},
          ${legacy.columnPerkDetails} ${DatabaseHelper.textType},
          ${legacy.columnPerkIsGrouped} ${DatabaseHelper.boolType}
        )''')
        .then((_) async {
          for (legacy.Perk perk in PerksRepositoryLegacy.legacyPerks) {
            for (int i = 0; i < perk.numOfPerks; i++) {
              await txn.insert(tablePerks, perk.toMap());
            }
          }
        });
  }

  static Future<void> migrateToUuids(Transaction txn) async {
    await txn.execute('''
        ALTER TABLE $tableCharacterPerks RENAME TO cptmp
        ''');
    await txn.execute('''
        ${DatabaseHelper.createTable} $tableCharacterPerks(
          $columnAssociatedCharacterUuid ${DatabaseHelper.textType},
          $columnAssociatedPerkId ${DatabaseHelper.integerType},
          $columnCharacterPerkIsSelected ${DatabaseHelper.boolType}
        )''');
    await txn.execute('''
        INSERT INTO $tableCharacterPerks(
          $columnAssociatedCharacterUuid,
          $columnAssociatedPerkId,
          $columnCharacterPerkIsSelected
        ) SELECT CharacterID, 
        $columnAssociatedPerkId, 
        $columnCharacterPerkIsSelected FROM cptmp
        ''');
    await txn.execute('''
        DROP TABLE cptmp
        ''');
    await txn.execute('''
      ALTER TABLE $tableCharacters RENAME TO ctmp
      ''');
    await txn.execute('''
      ALTER TABLE ctmp ADD COLUMN $columnCharacterUuid
      ''');
    await txn.execute('''
      ${DatabaseHelper.createTable} $tableCharacters(
        $columnCharacterId ${DatabaseHelper.idType},
        $columnCharacterUuid ${DatabaseHelper.textType},
        $columnCharacterName ${DatabaseHelper.textType},
        $columnCharacterClassCode ${DatabaseHelper.textType},
        $columnPreviousRetirements ${DatabaseHelper.integerType},
        $columnCharacterXp ${DatabaseHelper.integerType},
        $columnCharacterGold ${DatabaseHelper.integerType},
        $columnCharacterNotes ${DatabaseHelper.textType},
        $columnCharacterCheckMarks ${DatabaseHelper.integerType},
        $columnIsRetired ${DatabaseHelper.boolType}
      )''');
    await txn.execute('''
      INSERT INTO $tableCharacters(
        $columnCharacterId,
        $columnCharacterUuid,
        $columnCharacterName,
        $columnCharacterClassCode,
        $columnPreviousRetirements,
        $columnCharacterXp,
        $columnCharacterGold,
        $columnCharacterNotes,
        $columnCharacterCheckMarks,
        $columnIsRetired
        )
        SELECT $columnCharacterId,
        $columnCharacterId,
        $columnCharacterName,
        $columnCharacterClassCode,
        $columnPreviousRetirements,
        $columnCharacterXp,
        $columnCharacterGold,
        $columnCharacterNotes,
        $columnCharacterCheckMarks,
        $columnIsRetired FROM ctmp;
      ''');
    await txn.execute('''
        DROP TABLE ctmp
        ''');
  }

  static Future<void> includeClassMasteries(Transaction txn) async {
    await txn
        .execute('''
        ${DatabaseHelper.createTable} $tableMasteries (
          $columnMasteryId ${DatabaseHelper.idType},
          $columnMasteryClass ${DatabaseHelper.textType},
          $columnMasteryDetails ${DatabaseHelper.textType}
        )''')
        .then((_) async {
          for (legacy.Mastery mastery in MasteriesRepositoryLegacy.masteries) {
            await txn.insert(tableMasteries, mastery.toMap());
          }
        });
    await txn.execute('''
        ${DatabaseHelper.createTable} $tableCharacterMasteries (
          $columnAssociatedCharacterUuid ${DatabaseHelper.textType},
          $columnAssociatedMasteryId ${DatabaseHelper.integerType},
          $columnCharacterMasteryAchieved ${DatabaseHelper.boolType}
        )''');
  }

  static Future<void> includeResources(Transaction txn) async {
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceHide ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceMetal ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceLumber ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceArrowvine ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceAxenut ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceRockroot ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceFlamefruit ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceCorpsecap ${DatabaseHelper.integerType} DEFAULT 0',
    );
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnResourceSnowthistle ${DatabaseHelper.integerType} DEFAULT 0',
    );
  }

  static Future<void> createMetaDataTable(Transaction txn, int version) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await txn.execute('''
        ${DatabaseHelper.createTable} ${DatabaseHelper.tableMetaData} (
          ${DatabaseHelper.columnDatabaseVersion} ${DatabaseHelper.integerType},
          ${DatabaseHelper.columnAppVersion} ${DatabaseHelper.textType},
          ${DatabaseHelper.columnAppBuildNumber} ${DatabaseHelper.integerType},
          ${DatabaseHelper.columnLastUpdated} ${DatabaseHelper.dateTimeType}
        )''');

    await txn.insert(DatabaseHelper.tableMetaData, {
      DatabaseHelper.columnDatabaseVersion: version,
      DatabaseHelper.columnAppVersion: packageInfo.version,
      DatabaseHelper.columnAppBuildNumber: packageInfo.buildNumber,
    });
  }

  static Future<void> updateMetaDataTable(Transaction txn, int databaseVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    await txn.update(DatabaseHelper.tableMetaData, {
      DatabaseHelper.columnDatabaseVersion: databaseVersion,
      DatabaseHelper.columnAppVersion: packageInfo.version,
      DatabaseHelper.columnAppBuildNumber: packageInfo.buildNumber,
      DatabaseHelper.columnLastUpdated: formattedDate,
    });
  }

  static Future<void> addVariantColumnToCharacterTable(Transaction txn) async {
    await txn.rawInsert(
      'ALTER TABLE $tableCharacters ADD COLUMN $columnVariant ${DatabaseHelper.textType} DEFAULT \'${Variant.base.name}\'',
    );
  }

  static Future<void> convertCharacterPerkIdColumnFromIntToText(Transaction txn) async {
    await txn.execute('''
  ALTER TABLE $tableCharacterPerks
  RENAME TO temp_$tableCharacterPerks
''');

    await txn.execute('''
  ${DatabaseHelper.createTable} $tableCharacterPerks (
    $columnAssociatedCharacterUuid ${DatabaseHelper.textType},
    $columnAssociatedPerkId ${DatabaseHelper.textType},
    $columnCharacterPerkIsSelected ${DatabaseHelper.boolType}
  )
''');

    await txn.execute('''
  INSERT INTO $tableCharacterPerks
  SELECT
    $columnAssociatedCharacterUuid,
    CAST($columnAssociatedPerkId AS TEXT),
    $columnCharacterPerkIsSelected
  FROM temp_$tableCharacterPerks
''');

    await txn.execute('DROP TABLE temp_$tableCharacterPerks');
  }

  static Future<void> convertCharacterMasteryIdColumnFromIntToText(Transaction txn) async {
    await txn.execute('''
  ALTER TABLE $tableCharacterMasteries
  RENAME TO temp_$tableCharacterMasteries
''');

    await txn.execute('''
  CREATE TABLE $tableCharacterMasteries (
    $columnAssociatedCharacterUuid ${DatabaseHelper.textType},
    $columnAssociatedMasteryId ${DatabaseHelper.textType},
    $columnCharacterMasteryAchieved ${DatabaseHelper.boolType}
  )
''');

    await txn.execute('''
  INSERT INTO $tableCharacterMasteries
  SELECT
    $columnAssociatedCharacterUuid,
    CAST($columnAssociatedMasteryId AS TEXT),
    $columnCharacterMasteryAchieved
  FROM temp_$tableCharacterMasteries
''');

    await txn.execute('DROP TABLE temp_$tableCharacterMasteries');
  }

  static Future<void> includeClassVariantsAndPerksAsMap(Transaction txn) async {
    const String tempTablePerks = 'temp_$tablePerks';
    await txn.execute('''
         ${DatabaseHelper.createTable} $tempTablePerks (
           $columnPerkId ${DatabaseHelper.idTextPrimaryType},
           $columnPerkClass ${DatabaseHelper.textType},
           $columnPerkDetails ${DatabaseHelper.textType},
           $columnPerkIsGrouped ${DatabaseHelper.boolType},
           $columnPerkVariant ${DatabaseHelper.textType}
         )''');
    // Handle existing Perks for Variant.base
    await _handleBaseVariantPerks(txn, tempTablePerks);

    // Handle all other Perks
    await _handleRemainingVariantPerks(txn, tempTablePerks);

    // Replace the old table with the temp table
    await _dropCharacterPerksTableAndRenameTemp(txn, tempTablePerks);
  }

  static Future<void> _handleBaseVariantPerks(
    Transaction txn,
    String tempTablePerks,
  ) async {
    final List<Map<String, dynamic>> characterPerksMaps = await txn.query(
      tableCharacterPerks,
    );
    final List<CharacterPerk> characterPerks = characterPerksMaps
        .map((e) => CharacterPerk.fromMap(e))
        .toList();
    final List<Map<String, dynamic>> charactersMaps = await txn.query(
      tableCharacters,
    );
    final List<Character?> characters = charactersMaps
        .map((e) => Character.fromMap(e))
        .toList();
    await Future.forEach(PerksRepository.perksMap.entries, (entry) async {
      final classKey = entry.key;
      final perkLists = entry.value.where(
        (element) => element.variant == Variant.base,
      );

      for (Perks list in perkLists) {
        for (Perk perk in list.perks) {
          perk.classCode = classKey;
          String index = (list.perks.indexOf(perk) + 1).toString().padLeft(
            2,
            '0',
          );
          for (int i = 0; i < perk.quantity; i++) {
            String suffix = '$index${indexToLetter(i)}';

            int id = await txn.insert(tempTablePerks, perk.toMap(suffix));
            // This handles for a mistake when first defining the Infuser perks
            // One perk that has two checks was only given one
            // All perks after 726 (the last Infuser perk) should reference an
            // index one lower than the perk id
            if (id >= 726) {
              id--;
            }
            // MatchingCharacterPerk should be a list. There can be more than 1
            List<CharacterPerk> matchingCharacterPerks = [];

            matchingCharacterPerks = characterPerks
                .where((element) => element.associatedPerkId == id.toString())
                .toList();

            if (matchingCharacterPerks.isNotEmpty) {
              for (final CharacterPerk matchingCharacterPerk
                  in matchingCharacterPerks) {
                Character? character = characters.firstWhere(
                  (element) =>
                      element?.uuid ==
                      matchingCharacterPerk.associatedCharacterUuid,
                );

                if (character != null) {
                  // if character is Infuser and
                  // 724 is selected, make 725 selected and
                  // 725 is selected, make 726 selected
                  // if id is 724, we are at the second of the grouped perks.
                  // ID always increases by 1, regardless of the loop

                  if (matchingCharacterPerk.associatedPerkId == '724') {
                    List<Map<String, dynamic>> perk725List = await txn.query(
                      tableCharacterPerks,
                      where:
                          '$columnAssociatedPerkId = ? AND $columnAssociatedCharacterUuid = ?',
                      whereArgs: ['725', character.uuid],
                    );
                    CharacterPerk perk725 = CharacterPerk.fromMap(
                      perk725List[0],
                    );
                    await txn.insert(
                      tableCharacterPerks,
                      CharacterPerk(
                        character.uuid,
                        'infuser_base_11a',
                        perk725.characterPerkIsSelected,
                      ).toMap(),
                    );
                    await txn.update(
                      tableCharacterPerks,
                      {
                        columnCharacterPerkIsSelected:
                            matchingCharacterPerk.characterPerkIsSelected
                            ? '1'
                            : '0',
                      },
                      where:
                          '$columnAssociatedPerkId = ? AND $columnAssociatedCharacterUuid = ?',
                      whereArgs: ['725', character.uuid],
                    );
                    await txn.update(
                      tableCharacterPerks,
                      {columnCharacterPerkIsSelected: '0'},
                      where:
                          '$columnAssociatedPerkId = ? AND $columnAssociatedCharacterUuid = ?',
                      whereArgs: ['724', character.uuid],
                    );
                  }
                  await txn.update(
                    tableCharacterPerks,
                    {
                      columnAssociatedPerkId:
                          '${character.playerClass.classCode}_${Variant.base.name}_$suffix',
                    },
                    where:
                        '$columnAssociatedPerkId = ? AND $columnAssociatedCharacterUuid = ?',
                    whereArgs: [id, character.uuid],
                  );
                }
              }
            }
          }
        }
      }
    });
  }

  static Future<void> _handleRemainingVariantPerks(
    Transaction txn,
    String tempTablePerks,
  ) async {
    await Future.forEach(PerksRepository.perksMap.entries, (entry) async {
      final classCode = entry.key;
      final perkLists = entry.value.where(
        (element) => element.variant != Variant.base,
      );

      for (Perks list in perkLists) {
        for (Perk perk in list.perks) {
          perk.variant = list.variant;
          perk.classCode = classCode;
          for (int i = 0; i < perk.quantity; i++) {
            await txn.insert(
              tempTablePerks,
              perk.toMap('${list.perks.indexOf(perk)}${indexToLetter(i)}'),
            );
          }
        }
      }
    });
  }

  static Future<void> _dropCharacterPerksTableAndRenameTemp(
    Transaction txn,
    String tempTablePerks,
  ) async {
    await txn.execute('''
       ${DatabaseHelper.dropTable} $tablePerks
        ''');
    await txn.rawUpdate('ALTER TABLE $tempTablePerks RENAME TO $tablePerks');
  }

  static Future<void> includeClassVariantsAndMasteriesAsMap(
    Transaction txn,
  ) async {
    const String tempTableMasteries = 'temp_$tableMasteries';
    await txn.execute('''
        ${DatabaseHelper.createTable} $tempTableMasteries (
          $columnMasteryId ${DatabaseHelper.idTextPrimaryType},
          $columnMasteryClass ${DatabaseHelper.textType},
          $columnMasteryDetails ${DatabaseHelper.textType},
          $columnMasteryVariant ${DatabaseHelper.textType}
        )''');
    // Handle existing Masteries for Variant.base
    await _handleVariantMasteries(txn, tempTableMasteries);

    // Handle all other Perks
    // await _handleRemainingVariantMasteries(
    //   txn,
    //   tempTableMasteries,
    // );

    // Replace the old table with the temp table
    await _dropCharacterMasteriesTableAndRenameTemp(txn, tempTableMasteries);
  }

  // TODO: Masteries can be handled the same regardless of Variant because no
  // new ones have been added (or have they? considering JotL FHCO character
  // sheets...)
  static Future<void> _handleVariantMasteries(
    Transaction txn,
    String tempTableMasteries,
  ) async {
    final List<Map<String, dynamic>> characterMasteriesMaps = await txn.query(
      tableCharacterMasteries,
    );
    final List<CharacterMastery?> characterMasteries = characterMasteriesMaps
        .map((e) => CharacterMastery.fromMap(e))
        .toList();
    await Future.forEach(MasteriesRepository.masteriesMap.entries, (
      entry,
    ) async {
      final classKey = entry.key;
      final masteryLists = entry.value;

      for (Masteries list in masteryLists) {
        for (Mastery mastery in list.masteries) {
          mastery.classCode = classKey;
          mastery.variant = list.variant;

          int id = await txn.insert(
            tempTableMasteries,
            mastery.toMap(list.masteries.indexOf(mastery).toString()),
          );
          CharacterMastery? matchingCharacterMastery;

          matchingCharacterMastery = characterMasteries.firstWhereOrNull(
            (element) => element?.associatedMasteryId == id.toString(),
          );

          if (matchingCharacterMastery != null) {
            final List<Map<String, dynamic>> characters = await txn.query(
              tableCharacters,
              where: '$columnCharacterUuid = ?',
              whereArgs: [matchingCharacterMastery.associatedCharacterUuid],
            );

            Character character = Character.fromMap(characters.first);

            await txn.update(
              tableCharacterMasteries,
              {
                columnAssociatedMasteryId:
                    '${character.playerClass.classCode}_${Variant.base.name}_${list.masteries.indexOf(mastery)}',
              },
              where: '$columnAssociatedMasteryId = ?',
              whereArgs: [id],
            );
          }
          // debugPrint('INSERTED MASTERY ID IS: $id');
        }
      }
    });
  }

  // static Future<void> _handleRemainingVariantMasteries(
  //   Transaction txn,
  //   String tempTableMasteries,
  // ) async {
  //   await Future.forEach(CharacterData.masteriesMap.entries, (entry) async {
  //     final classCode = entry.key;
  //     final masteryLists =
  //         entry.value.where((element) => element.variant != Variant.base);

  //     for (Masteries list in masteryLists) {
  //       for (Mastery mastery in list.masteries) {
  //         mastery.variant = list.variant;
  //         mastery.classCode = classCode;
  //         try {
  //           await txn.insert(
  //             tempTableMasteries,
  //             mastery.toMap('${list.masteries.indexOf(mastery)}'),
  //           );
  //         } catch (e) {
  //           debugPrint('ERROR WITH MASTERIES TABLE: $e');
  //         }
  //       }
  //     }
  //   });
  // }

  static Future<void> _dropCharacterMasteriesTableAndRenameTemp(
    Transaction txn,
    String tempTableMasteries,
  ) async {
    await txn.execute('''
       ${DatabaseHelper.dropTable} $tableMasteries
        ''');
    await txn.rawUpdate(
      'ALTER TABLE $tempTableMasteries RENAME TO $tableMasteries',
    );
  }
}
