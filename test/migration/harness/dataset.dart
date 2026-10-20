import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/masteries_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/perks_repository_legacy.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:sqflite/sqflite.dart';

import 'frozen_schemas.dart';

/// How a fixture character's perks are selected.
enum PerkPattern {
  /// Every third legacy row (v1–v7) or every third perk check (v8+), so a
  /// shifted mapping always changes the result.
  everyThird,
  all,
  none,
}

/// One character as it would have been stored by an old app version.
///
/// [classCode] is the canonical lowercase code; v1–v4 stored GH codes in
/// uppercase ('BR'), which the v1–v4 writer reproduces.
class FixtureCharacter {
  const FixtureCharacter({
    required this.id,
    required this.uuid,
    required this.name,
    required this.classCode,
    required this.minVersion,
    this.variant = Variant.base,
    this.previousRetirements = 0,
    this.xp = 0,
    this.gold = 0,
    this.notes = '',
    this.checkMarks = 0,
    this.isRetired = false,
    this.resources = const [0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.personalQuestId = '',
    this.personalQuestProgress = '[]',
    this.perkPattern = PerkPattern.everyThird,
    this.masteriesAchieved = const [true, false],
    this.legacySelectionOverrides = const {},
  });

  final int id;

  /// Stored Uuid from v5 on. Characters that date back to v1–v4 carry their
  /// old integer `_id` as text, exactly as the v5 migration produced.
  final String uuid;
  final String name;
  final String classCode;

  /// First schema version in which this character could exist.
  final int minVersion;
  final Variant variant;
  final int previousRetirements;
  final int xp;
  final int gold;
  final String notes;
  final int checkMarks;
  final bool isRetired;

  /// Hide, Metal, Wood, ArrowVine, AxeNut, RockRoot, FlameFruit, CorpseCap,
  /// SnowThistle (v7+).
  final List<int> resources;
  final String personalQuestId;
  final String personalQuestProgress;
  final PerkPattern perkPattern;

  /// Achieved flag per mastery index (v7+).
  final List<bool> masteriesAchieved;

  /// Explicit IsSelected values for specific legacy perk IDs (v1–v7).
  final Map<int, bool> legacySelectionOverrides;

  bool legacyPerkSelected(int legacyId) =>
      legacySelectionOverrides[legacyId] ??
      switch (perkPattern) {
        PerkPattern.everyThird => legacyId % 3 == 0,
        PerkPattern.all => true,
        PerkPattern.none => false,
      };

  bool perkSelectedAt(int index) => switch (perkPattern) {
    PerkPattern.everyThird => index % 3 == 0,
    PerkPattern.all => true,
    PerkPattern.none => false,
  };
}

const _hostileNotes =
    'Retired after "Crypt of Blood" 💀\n'
    "It's O'Brien's turn; DROP TABLE Characters; --\n"
    'Ünïcödé — 日本語 ✓';

/// The logical dataset written into every frozen schema.
const List<FixtureCharacter> fixtureDataset = [
  // ── Created on v1 (3.0.0). Uuid became the old integer _id in v5. ──
  FixtureCharacter(
    id: 1,
    uuid: '1',
    name: 'Grukk the Retired',
    classCode: ClassCodes.brute,
    minVersion: 1,
    previousRetirements: 2,
    xp: 450,
    gold: 1234567,
    notes: _hostileNotes,
    checkMarks: 18,
    isRetired: true,
    perkPattern: PerkPattern.all,
  ),
  FixtureCharacter(
    id: 2,
    uuid: '2',
    name: 'Orchid Weaver',
    classCode: ClassCodes.spellweaver,
    minVersion: 1,
    xp: 95,
    gold: 30,
    checkMarks: 3,
  ),
  // _id gap: characters 3 and 4 were deleted.
  FixtureCharacter(
    id: 5,
    uuid: '5',
    name: 'Mïndthief',
    classCode: ClassCodes.mindthief,
    minVersion: 1,
    notes: 'Ünïcödé — 日本語',
    perkPattern: PerkPattern.none,
  ),
  FixtureCharacter(
    id: 7,
    uuid: '7',
    name: 'Sawbones',
    classCode: ClassCodes.sawbones,
    minVersion: 1,
    xp: 210,
    gold: 77,
    notes: 'Line one\nLine two',
    checkMarks: 7,
  ),
  // ── Created on v5+ (UUIDs). ──
  FixtureCharacter(
    id: 8,
    uuid: '0b5c3e4a-7f43-4d1e-9a51-0f2a6e1c9d01',
    name: 'Hollowpact',
    classCode: ClassCodes.hollowpact,
    minVersion: 5,
    xp: 60,
  ),
  FixtureCharacter(
    id: 9,
    uuid: '1c6d4f5b-8a54-4e2f-8b62-1a3b7f2dae12',
    name: 'Drifter Early',
    classCode: ClassCodes.drifter,
    minVersion: 6,
    xp: 30,
  ),
  // ── Created on v7 (4.0.0). Resources and masteries. ──
  FixtureCharacter(
    id: 10,
    uuid: '2d7e5a6c-9b65-4f3a-9c73-2b4c8a3ebf23',
    name: 'Infuser',
    classCode: ClassCodes.infuser,
    minVersion: 7,
    resources: [1, 2, 3, 4, 5, 6, 7, 8, 9],
    // Legacy 724 → perk 10 and 725 → perk 11 (Infuser legacy fix).
    legacySelectionOverrides: {724: true, 725: false},
  ),
  FixtureCharacter(
    id: 11,
    uuid: '3e8f6b7d-ac76-4a4b-8d84-3c5d9b4fc034',
    name: 'Boneshaper',
    classCode: ClassCodes.boneshaper,
    minVersion: 7,
    resources: [0, 12, 0, 3, 0, 0, 1, 0, 2],
    masteriesAchieved: [true, true],
    perkPattern: PerkPattern.all,
  ),
  FixtureCharacter(
    id: 12,
    uuid: '4f9a7c8e-bd87-4b5c-9e95-4d6eac5ad145',
    name: 'Incarnate',
    classCode: ClassCodes.incarnate,
    minVersion: 7,
    masteriesAchieved: [false, true],
  ),
  FixtureCharacter(
    id: 13,
    uuid: '5a0b8d9f-ce98-4c6d-8fa6-5e7fbd6be256',
    name: 'Demolitionist',
    classCode: ClassCodes.demolitionist,
    minVersion: 7,
  ),
  // ── Created on v8+ (variants, text IDs). ──
  FixtureCharacter(
    id: 14,
    uuid: '6b1c9eaf-dfa9-4d7e-9ab7-6f80ce7cf367',
    name: 'Berserker FHCO',
    classCode: ClassCodes.berserker,
    minVersion: 8,
    variant: Variant.frosthavenCrossover,
    masteriesAchieved: [true, false],
  ),
  FixtureCharacter(
    id: 15,
    uuid: '7c2dafb0-e0ba-4e8f-8bc8-7091df8d0478',
    name: 'Vimthreader',
    classCode: ClassCodes.vimthreader,
    minVersion: 9,
  ),
  FixtureCharacter(
    id: 16,
    uuid: '8d3eb0c1-f1cb-4f90-9cd9-81a2e09e1589',
    name: 'CORE',
    classCode: ClassCodes.core,
    minVersion: 10,
  ),
  FixtureCharacter(
    id: 17,
    uuid: '9e4fc1d2-02dc-4a01-8dea-92b3f1af269a',
    name: 'DOME',
    classCode: ClassCodes.dome,
    minVersion: 11,
  ),
  FixtureCharacter(
    id: 18,
    uuid: 'af50d2e3-13ed-4b12-9efb-a3c402b037ab',
    name: 'Skitterclaw',
    classCode: ClassCodes.skitterclaw,
    minVersion: 12,
  ),
  FixtureCharacter(
    id: 19,
    uuid: 'b061e3f4-24fe-4c23-8f0c-b4d513c148bc',
    name: 'Spellweaver 2E',
    classCode: ClassCodes.spellweaver,
    minVersion: 13,
    variant: Variant.gloomhaven2E,
  ),
  FixtureCharacter(
    id: 20,
    uuid: 'c172f405-350f-4d34-9a1d-c5e624d259cd',
    name: 'Cassandra',
    classCode: ClassCodes.cassandra,
    minVersion: 14,
  ),
  FixtureCharacter(
    id: 21,
    uuid: 'd2830516-4610-4e45-8b2e-d6f735e36ade',
    name: 'Alchemancer',
    classCode: ClassCodes.alchemancer,
    minVersion: 16,
  ),
  // ── Created on v18+ (personal quests). ──
  FixtureCharacter(
    id: 22,
    uuid: 'e3941627-5721-4f56-9c3f-e70846f47bef',
    name: 'Questing Tinkerer',
    classCode: ClassCodes.tinkerer,
    minVersion: 18,
    personalQuestId: 'pq_cs_rm_001',
    personalQuestProgress: '[1,30,1]',
  ),
];

/// Characters that exist in a database of schema [version].
List<FixtureCharacter> datasetAt(int version) =>
    fixtureDataset.where((c) => c.minVersion <= version).toList();

// ── Legacy (v7, app 4.0.0) layouts, derived from the frozen repositories ──

/// Legacy integer perk IDs per class code, in table order: one autoincrement
/// row per perk check of [PerksRepositoryLegacy.legacyPerks].
Map<String, List<int>> legacyPerkIdsByClass() {
  final result = <String, List<int>>{};
  int id = 0;
  for (final perk in PerksRepositoryLegacy.legacyPerks) {
    for (int i = 0; i < perk.numOfPerks; i++) {
      result.putIfAbsent(perk.perkClassCode, () => []).add(++id);
    }
  }
  return result;
}

/// Legacy integer mastery IDs per class code: one row per
/// [MasteriesRepositoryLegacy.masteries] entry.
Map<String, List<int>> legacyMasteryIdsByClass() {
  final result = <String, List<int>>{};
  int id = 0;
  for (final mastery in MasteriesRepositoryLegacy.masteries) {
    result.putIfAbsent(mastery.masteryClassCode, () => []).add(++id);
  }
  return result;
}

// ── Seed writers: one per frozen schema family, literal column names ──

/// Creates [schema] in [db], writes [datasetAt] [version] in that shape, and
/// stamps `PRAGMA user_version`.
Future<void> seedFrozenDatabase(
  Database db,
  int version, {
  FrozenSchema? schema,
  List<FixtureCharacter>? characters,
}) async {
  schema ??= schemaFor(version);
  characters ??= datasetAt(version);
  await db.transaction((txn) async {
    for (final statement in schema!.statements) {
      await txn.execute(statement);
    }
    if (version >= 8) {
      await txn.insert('MetaData', {
        'DatabaseVersion': version,
        'AppVersion': 'fixture-v$version',
        'AppBuildNumber': version,
      });
    }
    for (final c in characters!) {
      await _writeCharacter(txn, c, version);
    }
  });
  await db.execute('PRAGMA user_version = $version');
}

const _resourceColumns = [
  'ResourceHide',
  'ResourceMetal',
  'ResourceWood',
  'ResourceArrowVine',
  'ResourceAxeNut',
  'ResourceRockRoot',
  'ResourceFlameFruit',
  'ResourceCorpseCap',
  'ResourceSnowThistle',
];

Future<void> _writeCharacter(
  Transaction txn,
  FixtureCharacter c,
  int version,
) async {
  final row = <String, Object?>{
    '_id': c.id,
    'Name': c.name,
    'ClassCode': version <= 4 ? c.classCode.toUpperCase() : c.classCode,
    'PreviousRetirements': c.previousRetirements,
    'XP': c.xp,
    'Gold': c.gold,
    'Notes': c.notes,
    'CheckMarks': c.checkMarks,
    'IsRetired': c.isRetired ? 1 : 0,
  };
  if (version <= 4) {
    row.addAll({
      'ClassColor': '0xff000000',
      'ClassIcon': '${c.classCode}.png',
      'ClassRace': 'Race',
      'ClassName': c.name,
    });
  } else {
    row['Uuid'] = c.uuid;
  }
  if (version >= 7) {
    for (int i = 0; i < _resourceColumns.length; i++) {
      row[_resourceColumns[i]] = c.resources[i];
    }
  }
  if (version >= 8) row['Variant'] = c.variant.name;
  if (version >= 18) {
    row['PersonalQuestId'] = c.personalQuestId;
    row['PersonalQuestProgress'] = c.personalQuestProgress;
  }
  if (version >= 20) {
    // The v20 fresh install declares these without DEFAULTs.
    row['ShowResources'] = 1;
    row['IsJawsOfTheLion'] = 0;
  }
  await txn.insert('Characters', row);

  if (version <= 7) {
    final legacyIds = legacyPerkIdsByClass()[c.classCode];
    if (legacyIds == null) {
      throw StateError('${c.classCode} has no legacy perks (v$version)');
    }
    for (final legacyId in legacyIds) {
      await txn.insert('CharacterPerks', {
        if (version <= 4) 'CharacterID': c.id else 'CharacterUuid': c.uuid,
        'PerkID': legacyId,
        'IsSelected': c.legacyPerkSelected(legacyId) ? 1 : 0,
      });
    }
    if (version == 7) {
      // 4.0.0 inserted mastery rows for every character whose class had
      // legacy masteries (Character.includeMasteries defaulted to true).
      final legacyMasteries = legacyMasteryIdsByClass()[c.classCode] ?? [];
      for (int i = 0; i < legacyMasteries.length; i++) {
        await txn.insert('CharacterMasteries', {
          'CharacterUuid': c.uuid,
          'MasteryID': legacyMasteries[i],
          'MasteryAchieved': c.masteriesAchieved[i] ? 1 : 0,
        });
      }
    }
    return;
  }

  final perkIds = PerksRepository.getPerkIds(c.classCode, c.variant);
  if (perkIds.isEmpty) {
    throw StateError('${c.classCode}/${c.variant.name} has no perks');
  }
  for (int i = 0; i < perkIds.length; i++) {
    await txn.insert('CharacterPerks', {
      'CharacterUuid': c.uuid,
      'PerkID': perkIds[i],
      'IsSelected': c.perkSelectedAt(i) ? 1 : 0,
    });
  }
  if (_showsMasteries(c)) {
    final masteryIds = MasteriesRepository.getMasteryIds(
      c.classCode,
      c.variant,
    );
    for (int i = 0; i < masteryIds.length; i++) {
      await txn.insert('CharacterMasteries', {
        'CharacterUuid': c.uuid,
        'MasteryID': masteryIds[i],
        'MasteryAchieved': c.masteriesAchieved[i] ? 1 : 0,
      });
    }
  }
}

bool _showsMasteries(FixtureCharacter c) => Character(
  uuid: c.uuid,
  name: c.name,
  playerClass: PlayerClasses.playerClassByClassCode(c.classCode),
  variant: c.variant,
).shouldShowMasteries;

// ── Expected state after upgrading to the current schema ──

/// The Characters row a [c] from schema [fromVersion] must have after the
/// upgrade, stated as a spec independent of the migration code.
Map<String, Object?> expectedCharacterRow(FixtureCharacter c, int fromVersion) {
  final legacyEra = fromVersion <= 4;
  return {
    '_id': c.id,
    'Uuid': legacyEra ? '${c.id}' : c.uuid,
    'Name': c.name,
    // Nothing ever rewrote the uppercase v1–v4 class codes.
    'ClassCode': legacyEra ? c.classCode.toUpperCase() : c.classCode,
    'PreviousRetirements': c.previousRetirements,
    'XP': c.xp,
    'Gold': c.gold,
    'Notes': c.notes,
    'CheckMarks': c.checkMarks,
    'IsRetired': c.isRetired ? 1 : 0,
    for (int i = 0; i < _resourceColumns.length; i++)
      _resourceColumns[i]: fromVersion >= 7 ? c.resources[i] : 0,
    'Variant': fromVersion >= 8 ? c.variant.name : 'base',
    'PersonalQuestId': fromVersion >= 18 ? c.personalQuestId : '',
    'PersonalQuestProgress': fromVersion >= 18 ? c.personalQuestProgress : '[]',
    'ShowResources': 1,
    'IsJawsOfTheLion': 0,
  };
}

/// Expected PerkID → IsSelected for [c] after upgrading from [fromVersion].
Map<String, bool> expectedPerks(FixtureCharacter c, int fromVersion) {
  final liveIds = PerksRepository.getPerkIds(c.classCode, c.variant);
  if (fromVersion >= 8) {
    return {
      for (int i = 0; i < liveIds.length; i++) liveIds[i]: c.perkSelectedAt(i),
    };
  }
  // v1–v7: legacy row N of a class is the class's Nth live base perk check.
  final legacyIds = legacyPerkIdsByClass()[c.classCode]!;
  if (c.classCode == ClassCodes.infuser) {
    // The legacy Infuser list defined perk 9 as a single check, so legacy 724
    // is perk 10 and 725 is perk 11; perk 9's second check had no legacy row.
    return {
      for (int i = 0; i < 15; i++)
        liveIds[i]: c.legacyPerkSelected(legacyIds[i]),
      'infuser_base_09b': false,
      'infuser_base_10a': c.legacyPerkSelected(724),
      'infuser_base_11a': c.legacyPerkSelected(725),
    };
  }
  return {
    for (int i = 0; i < legacyIds.length; i++)
      liveIds[i]: c.legacyPerkSelected(legacyIds[i]),
  };
}

/// Expected MasteryID → achieved for [c] after upgrading from [fromVersion]:
/// the live mastery IDs when the app shows masteries for the character,
/// otherwise none.
Map<String, bool> expectedMasteries(FixtureCharacter c, int fromVersion) {
  if (!_showsMasteries(c)) return {};
  final liveIds = MasteriesRepository.getMasteryIds(c.classCode, c.variant);
  // Before v7 no mastery progress existed, so everything starts unachieved.
  final hadProgress = fromVersion >= 7;
  return {
    for (int i = 0; i < liveIds.length; i++)
      liveIds[i]: hadProgress && c.masteriesAchieved[i],
  };
}
