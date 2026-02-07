import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

/// Fake implementation of [IDatabaseHelper] for testing.
///
/// This class provides an in-memory implementation of the database interface
/// that can be used in unit tests without SQLite dependencies.
///
/// ## Usage
///
/// ```dart
/// final fakeDb = FakeDatabaseHelper();
/// fakeDb.characters = [TestData.createCharacter()];
/// final model = CharactersModel(databaseHelper: fakeDb, ...);
/// ```
///
/// ## Tracking Method Calls
///
/// The [updateCalls] list tracks which characters have been updated,
/// useful for verifying persistence behavior:
///
/// ```dart
/// expect(fakeDb.updateCalls, contains('test-uuid'));
/// ```
class FakeDatabaseHelper implements IDatabaseHelper {
  /// In-memory character storage.
  List<Character> characters = [];

  /// Tracks UUIDs of characters that were updated via [updateCharacter].
  List<String> updateCalls = [];

  /// Tracks UUIDs of characters that were deleted via [deleteCharacter].
  List<String> deleteCalls = [];

  /// Tracks perk update calls as (perkId, value) pairs.
  List<({String perkId, bool value})> perkUpdateCalls = [];

  /// Tracks mastery update calls as (masteryId, value) pairs.
  List<({String masteryId, bool value})> masteryUpdateCalls = [];

  /// In-memory CharacterPerk storage keyed by character UUID.
  Map<String, List<CharacterPerk>> characterPerks = {};

  /// In-memory CharacterMastery storage keyed by character UUID.
  Map<String, List<CharacterMastery>> characterMasteriesMap = {};

  /// Raw perk definition data (returned by [queryPerks]).
  /// If null, auto-generates from PerksRepository for the character's class.
  List<Map<String, Object?>>? perksData;

  /// Raw mastery definition data (returned by [queryMasteries]).
  /// If null, auto-generates from MasteriesRepository for the character's class.
  List<Map<String, Object?>>? masteriesData;

  /// Next ID to assign when inserting a character.
  int _nextId = 1;

  @override
  Future<List<Character>> queryAllCharacters() async {
    return List.from(characters);
  }

  @override
  Future<void> updateCharacter(Character character) async {
    updateCalls.add(character.uuid);
    final idx = characters.indexWhere((c) => c.uuid == character.uuid);
    if (idx >= 0) {
      characters[idx] = character;
    }
  }

  @override
  Future<int> insertCharacter(Character character) async {
    final id = _nextId++;
    character.id = id;
    characters.add(character);

    // Auto-generate CharacterPerk records from PerksRepository
    // (matching what the real database does on insert)
    _generateCharacterPerks(character);
    _generateCharacterMasteries(character);

    return id;
  }

  @override
  Future<void> deleteCharacter(Character character) async {
    deleteCalls.add(character.uuid);
    characters.removeWhere((c) => c.uuid == character.uuid);
    characterPerks.remove(character.uuid);
    characterMasteriesMap.remove(character.uuid);
  }

  @override
  Future<List<CharacterPerk>> queryCharacterPerks(String uuid) async {
    return List.from(characterPerks[uuid] ?? []);
  }

  @override
  Future<List<CharacterMastery>> queryCharacterMasteries(String uuid) async {
    return List.from(characterMasteriesMap[uuid] ?? []);
  }

  @override
  Future<List<Map<String, Object?>>> queryPerks(Character character) async {
    if (perksData != null) return List.from(perksData!);

    // Auto-generate from PerksRepository
    return _generatePerkMaps(character);
  }

  @override
  Future<List<Map<String, Object?>>> queryMasteries(Character character) async {
    if (masteriesData != null) return List.from(masteriesData!);

    // Auto-generate from MasteriesRepository
    return _generateMasteryMaps(character);
  }

  @override
  Future<List<Map<String, Object?>>> queryPersonalQuests({
    GameEdition? edition,
  }) async {
    final quests = edition != null
        ? PersonalQuestsRepository.getByEdition(edition)
        : PersonalQuestsRepository.quests;
    return quests.map((q) => q.toMap()).toList();
  }

  @override
  Future<void> updateCharacterPerk(CharacterPerk perk, bool value) async {
    perkUpdateCalls.add((perkId: perk.associatedPerkId, value: value));

    // Update in-memory storage
    final perks = characterPerks[perk.associatedCharacterUuid];
    if (perks != null) {
      for (final cp in perks) {
        if (cp.associatedPerkId == perk.associatedPerkId) {
          cp.characterPerkIsSelected = value;
        }
      }
    }
  }

  @override
  Future<void> updateCharacterMastery(
    CharacterMastery mastery,
    bool value,
  ) async {
    masteryUpdateCalls.add((
      masteryId: mastery.associatedMasteryId,
      value: value,
    ));

    // Update in-memory storage
    final masteries = characterMasteriesMap[mastery.associatedCharacterUuid];
    if (masteries != null) {
      for (final cm in masteries) {
        if (cm.associatedMasteryId == mastery.associatedMasteryId) {
          cm.characterMasteryAchieved = value;
        }
      }
    }
  }

  /// Generates CharacterPerk records from PerksRepository for a character.
  void _generateCharacterPerks(Character character) {
    final perksList = PerksRepository.perksMap[character.playerClass.classCode];
    if (perksList == null) return;

    final perks = <CharacterPerk>[];
    for (final perksGroup in perksList) {
      if (perksGroup.variant != character.variant) continue;
      int perkIndex = 0;
      for (final perk in perksGroup.perks) {
        for (int i = 0; i < perk.quantity; i++) {
          final perkId =
              '${character.playerClass.classCode}_${perksGroup.variant.name}_$perkIndex';
          perks.add(CharacterPerk(character.uuid, perkId, false));
          perkIndex++;
        }
      }
    }
    characterPerks[character.uuid] = perks;
  }

  /// Generates CharacterMastery records from MasteriesRepository for a character.
  void _generateCharacterMasteries(Character character) {
    final masteriesList =
        MasteriesRepository.masteriesMap[character.playerClass.classCode];
    if (masteriesList == null) return;

    final masteries = <CharacterMastery>[];
    for (final masteriesGroup in masteriesList) {
      if (masteriesGroup.variant != character.variant) continue;
      int masteryIndex = 0;
      for (var i = 0; i < masteriesGroup.masteries.length; i++) {
        final masteryId =
            '${character.playerClass.classCode}_${masteriesGroup.variant.name}_$masteryIndex';
        masteries.add(CharacterMastery(character.uuid, masteryId, false));
        masteryIndex++;
      }
    }
    characterMasteriesMap[character.uuid] = masteries;
  }

  /// Generates perk definition maps from PerksRepository.
  List<Map<String, Object?>> _generatePerkMaps(Character character) {
    final classCode = character.playerClass.classCode;
    final perksList = PerksRepository.perksMap[classCode];
    if (perksList == null) return [];

    final maps = <Map<String, Object?>>[];
    for (final perksGroup in perksList) {
      if (perksGroup.variant != character.variant) continue;
      int perkIndex = 0;
      for (final perk in perksGroup.perks) {
        perk.classCode = classCode;
        perk.variant = perksGroup.variant;
        for (int i = 0; i < perk.quantity; i++) {
          maps.add(perk.toMap('$perkIndex'));
          perkIndex++;
        }
      }
    }
    return maps;
  }

  /// Generates mastery definition maps from MasteriesRepository.
  List<Map<String, Object?>> _generateMasteryMaps(Character character) {
    final classCode = character.playerClass.classCode;
    final masteriesList = MasteriesRepository.masteriesMap[classCode];
    if (masteriesList == null) return [];

    final maps = <Map<String, Object?>>[];
    for (final masteriesGroup in masteriesList) {
      if (masteriesGroup.variant != character.variant) continue;
      int masteryIndex = 0;
      for (final mastery in masteriesGroup.masteries) {
        mastery.classCode = classCode;
        mastery.variant = masteriesGroup.variant;
        maps.add(mastery.toMap('$masteryIndex'));
        masteryIndex++;
      }
    }
    return maps;
  }

  /// Resets all state for test isolation.
  void reset() {
    characters = [];
    updateCalls = [];
    deleteCalls = [];
    perkUpdateCalls = [];
    masteryUpdateCalls = [];
    characterPerks = {};
    characterMasteriesMap = {};
    perksData = null;
    masteriesData = null;
    _nextId = 1;
  }
}
