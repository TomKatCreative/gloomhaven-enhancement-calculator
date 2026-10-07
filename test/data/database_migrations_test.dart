import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/database_migrations.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/perks_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Upgrades a v7 database through the v8 perk steps and checks every legacy
/// integer perk ID lands on the matching perk of the character's class.
///
/// Runs the real migration functions in the same order as the v7→v8 step in
/// `DatabaseHelper._runMigrations`, minus `createMetaDataTable`, which needs
/// `PackageInfo` and doesn't touch perks.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  /// Legacy (v7) integer perk IDs per class code, in table order. The v7 table
  /// had one autoincrement row per perk check from
  /// [PerksRepositoryLegacy.legacyPerks].
  Map<String, List<int>> legacyIdsByClass() {
    final result = <String, List<int>>{};
    int id = 0;
    for (final perk in PerksRepositoryLegacy.legacyPerks) {
      for (int i = 0; i < perk.numOfPerks; i++) {
        result.putIfAbsent(perk.perkClassCode, () => []).add(++id);
      }
    }
    return result;
  }

  /// Every third legacy row is selected, so a shifted mapping is detectable.
  bool legacySelected(int legacyId) => legacyId % 3 == 0;

  late Database db;

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // v7 schema (pre-variant): integer perk IDs, no Variant column.
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
        $columnIsRetired BOOL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCharacterPerks (
        $columnAssociatedCharacterUuid TEXT,
        $columnAssociatedPerkId INTEGER,
        $columnCharacterPerkIsSelected BOOL
      )
    ''');
    await db.transaction((txn) async {
      // ignore: deprecated_member_use_from_same_package
      await DatabaseMigrations.regenerateLegacyPerksTable(txn);
    });
  });

  tearDown(() async => db.close());

  Future<void> seedCharacter(
    String classCode,
    List<int> legacyPerkIds, {
    bool Function(int legacyId)? isSelected,
  }) async {
    final uuid = 'uuid-$classCode';
    await db.insert(tableCharacters, {
      columnCharacterUuid: uuid,
      columnCharacterName: classCode,
      columnCharacterClassCode: classCode,
      columnPreviousRetirements: 0,
      columnCharacterXp: 0,
      columnCharacterGold: 0,
      columnCharacterNotes: '',
      columnCharacterCheckMarks: 0,
      columnIsRetired: 0,
    });
    for (final id in legacyPerkIds) {
      await db.insert(tableCharacterPerks, {
        columnAssociatedCharacterUuid: uuid,
        columnAssociatedPerkId: id,
        columnCharacterPerkIsSelected: (isSelected ?? legacySelected)(id)
            ? 1
            : 0,
      });
    }
  }

  Future<void> runV8PerkMigration() async {
    await db.transaction((txn) async {
      await DatabaseMigrations.addVariantColumnToCharacterTable(txn);
      await DatabaseMigrations.convertCharacterPerkIdColumnFromIntToText(txn);
      await DatabaseMigrations.includeClassVariantsAndPerksAsMap(txn);
    });
  }

  Future<Map<String, bool>> migratedPerks(String classCode) async {
    final rows = await db.query(
      tableCharacterPerks,
      where: '$columnAssociatedCharacterUuid = ?',
      whereArgs: ['uuid-$classCode'],
    );
    return {
      for (final row in rows.map(CharacterPerk.fromMap))
        row.associatedPerkId: row.characterPerkIsSelected,
    };
  }

  group('Frozen v7 perk layout', () {
    // Anchors the snapshot the migration depends on. If one of these fails,
    // PerksRepositoryLegacy was edited — it must stay frozen.
    test('has 995 legacy rows with each class in one contiguous run', () {
      final layout = legacyIdsByClass();
      expect(layout.values.fold<int>(0, (sum, ids) => sum + ids.length), 995);
      for (final MapEntry(key: classCode, value: ids) in layout.entries) {
        expect(
          ids,
          List.generate(ids.length, (i) => ids.first + i),
          reason: '$classCode legacy IDs must be contiguous',
        );
      }
    });

    test('places Infuser at legacy IDs 709–725', () {
      final ids = legacyIdsByClass()[ClassCodes.infuser]!;
      expect(ids.first, 709);
      expect(ids.last, 725);
    });
  });

  group('v7→v8 perk migration', () {
    // Regression: IDs used to come from insertion rowids over the live perk
    // map, whose class order changed after v8 (e.g. Vimthreader now precedes
    // Voidwarden), so later classes got shifted perk selections.
    test('maps every legacy perk to the same position in its class', () async {
      final layout = legacyIdsByClass();
      for (final MapEntry(key: classCode, value: ids) in layout.entries) {
        await seedCharacter(classCode, ids);
      }

      await runV8PerkMigration();

      for (final MapEntry(key: classCode, value: legacyIds) in layout.entries) {
        if (classCode == ClassCodes.infuser) continue; // Covered below.
        final expectedIds = PerksRepository.getPerkIds(classCode, Variant.base);
        expect(
          expectedIds.length,
          legacyIds.length,
          reason: '$classCode base perk count changed since v7',
        );
        expect(await migratedPerks(classCode), {
          for (int i = 0; i < legacyIds.length; i++)
            expectedIds[i]: legacySelected(legacyIds[i]),
        }, reason: classCode);
      }
    });

    // Legacy Infuser defined one two-check perk with a single check, so its
    // later legacy rows are one off: legacy 724 is perk 10 and legacy 725 is
    // perk 11, and perk 9's second check had no legacy row. Each case selects
    // exactly one of 724/725 so a swapped or dropped hand-off is detectable.
    for (final (sel724, sel725) in [(true, false), (false, true)]) {
      test(
        'applies the Infuser legacy-definition fix '
        '(724 ${sel724 ? 'on' : 'off'}, 725 ${sel725 ? 'on' : 'off'})',
        () async {
          bool isSelected(int id) => switch (id) {
            724 => sel724,
            725 => sel725,
            _ => legacySelected(id),
          };
          final ids = legacyIdsByClass()[ClassCodes.infuser]!;
          await seedCharacter(ClassCodes.infuser, ids, isSelected: isSelected);

          await runV8PerkMigration();

          final expectedIds = PerksRepository.getPerkIds(
            ClassCodes.infuser,
            Variant.base,
          );
          expect(expectedIds, hasLength(ids.length + 1));
          expect(await migratedPerks(ClassCodes.infuser), {
            for (int i = 0; i < 15; i++) expectedIds[i]: isSelected(ids[i]),
            'infuser_base_09b': false,
            'infuser_base_10a': sel724,
            'infuser_base_11a': sel725,
          });
        },
      );
    }
  });
}
