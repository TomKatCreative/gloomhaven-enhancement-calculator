import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:sqflite/sqflite.dart';

/// Properties every current-schema database must have for the app to show a
/// character's data correctly.
enum Invariant {
  /// Every Characters row parses with [Character.fromMap].
  charactersParse,

  /// No two characters share a Uuid.
  uniqueUuids,

  /// Each character has exactly one CharacterPerks row per live perk ID of
  /// its class+variant. A missing row hides that checkbox in the UI.
  perkRowsComplete,

  /// No CharacterPerks row has an ID outside its character's live perk IDs.
  noOrphanPerks,

  /// Each character the app shows masteries for has exactly one
  /// CharacterMasteries row per live mastery ID.
  masteryRowsComplete,

  /// No CharacterMasteries row has an ID outside the live mastery IDs the app
  /// shows for that character (hidden progress is lost progress).
  noOrphanMasteries,

  /// Every perk/mastery row belongs to an existing character.
  rowsHaveCharacter,

  /// Bool columns hold 0 or 1.
  booleans,

  /// `PRAGMA integrity_check` is `ok`.
  integrity,
}

typedef Violations = Map<Invariant, List<String>>;

Future<Violations> checkDbInvariants(Database db) async {
  final violations = {for (final i in Invariant.values) i: <String>[]};
  void flag(Invariant i, String message) => violations[i]!.add(message);

  final integrity = await db.rawQuery('PRAGMA integrity_check');
  if (integrity.first.values.first != 'ok') {
    flag(Invariant.integrity, '$integrity');
  }

  final characterRows = await db.query('Characters');
  final characters = <String, Character>{};
  for (final row in characterRows) {
    try {
      final c = Character.fromMap(row);
      if (characters.containsKey(c.uuid)) {
        flag(Invariant.uniqueUuids, 'duplicate uuid ${c.uuid}');
      }
      characters[c.uuid] = c;
    } catch (e) {
      flag(Invariant.charactersParse, '${row['Uuid'] ?? row['_id']}: $e');
    }
    if (row['IsRetired'] != 0 && row['IsRetired'] != 1) {
      flag(Invariant.booleans, 'IsRetired=${row['IsRetired']}');
    }
  }

  final perkRows = await db.query('CharacterPerks');
  final masteryRows = await db.query('CharacterMasteries');
  for (final row in [...perkRows, ...masteryRows]) {
    final flagValue = row['IsSelected'] ?? row['MasteryAchieved'];
    if (flagValue != 0 && flagValue != 1) {
      flag(Invariant.booleans, '$row');
    }
    if (!characters.containsKey('${row['CharacterUuid']}')) {
      flag(Invariant.rowsHaveCharacter, '$row');
    }
  }

  final perksByCharacter = perkRows.groupListsBy(
    (r) => '${r['CharacterUuid']}',
  );
  final masteriesByCharacter = masteryRows.groupListsBy(
    (r) => '${r['CharacterUuid']}',
  );
  for (final c in characters.values) {
    final label = '${c.name} (${c.playerClass.classCode}/${c.variant.name})';
    final code = c.playerClass.classCode;

    final livePerks = PerksRepository.getPerkIds(code, c.variant);
    final perkIds = [
      for (final r in perksByCharacter[c.uuid] ?? const []) '${r['PerkID']}',
    ];
    final perkCounts = perkIds.groupFoldBy<String, int>(
      (id) => id,
      (n, _) => (n ?? 0) + 1,
    );
    final missingPerks = livePerks.where((id) => perkCounts[id] != 1).toList();
    if (missingPerks.isNotEmpty) {
      flag(
        Invariant.perkRowsComplete,
        '$label missing/duplicated $missingPerks',
      );
    }
    final orphanPerks = perkIds.where((id) => !livePerks.contains(id)).toList();
    if (orphanPerks.isNotEmpty) {
      flag(Invariant.noOrphanPerks, '$label orphans $orphanPerks');
    }

    final shownMasteries = c.shouldShowMasteries
        ? MasteriesRepository.getMasteryIds(code, c.variant)
        : const <String>[];
    final masteryIds = [
      for (final r in masteriesByCharacter[c.uuid] ?? const [])
        '${r['MasteryID']}',
    ];
    final masteryCounts = masteryIds.groupFoldBy<String, int>(
      (id) => id,
      (n, _) => (n ?? 0) + 1,
    );
    final missingMasteries = shownMasteries
        .where((id) => masteryCounts[id] != 1)
        .toList();
    if (missingMasteries.isNotEmpty) {
      flag(
        Invariant.masteryRowsComplete,
        '$label missing/duplicated $missingMasteries',
      );
    }
    final orphanMasteries = masteryIds
        .where((id) => !shownMasteries.contains(id))
        .toList();
    if (orphanMasteries.isNotEmpty) {
      flag(Invariant.noOrphanMasteries, '$label orphans $orphanMasteries');
    }
  }
  return violations;
}

/// Asserts no invariant is violated, except those in [excluding] (known bugs
/// covered by their own skipped tests).
Future<void> expectDbInvariants(
  Database db, {
  Set<Invariant> excluding = const {},
}) async {
  final violations = await checkDbInvariants(db);
  final failing = {
    for (final MapEntry(:key, :value) in violations.entries)
      if (value.isNotEmpty && !excluding.contains(key)) key.name: value,
  };
  expect(failing, isEmpty, reason: 'database invariants violated');
}

/// Asserts what the user would see: every perk and mastery the UI renders for
/// a loaded character has its selection row (mirrors `perk_row.dart`'s
/// lookup, where a missing row silently hides the checkbox).
void expectLoadedModelInvariants(CharactersModel model) {
  final problems = <String>[];
  for (final c in model.characters) {
    for (final perk in c.perks) {
      final row = c.characterPerks.firstWhereOrNull(
        (cp) => cp.associatedPerkId == perk.perkId,
      );
      if (row == null) problems.add('${c.name}: perk ${perk.perkId} hidden');
    }
    for (final mastery in c.masteries) {
      final row = c.characterMasteries.firstWhereOrNull(
        (cm) => cm.associatedMasteryId == mastery.id,
      );
      if (row == null) problems.add('${c.name}: mastery ${mastery.id} hidden');
    }
  }
  expect(problems, isEmpty, reason: 'loaded characters would hide rows');
}
