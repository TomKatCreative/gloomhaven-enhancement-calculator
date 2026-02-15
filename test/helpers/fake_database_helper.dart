import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/data/masteries/masteries_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
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

  /// In-memory campaign storage.
  List<Campaign> campaigns = [];

  /// In-memory party storage keyed by campaign ID.
  Map<String, List<Party>> partiesMap = {};

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

  /// Generates CharacterPerk records using canonical IDs from PerksRepository.
  void _generateCharacterPerks(Character character) {
    final perkIds = PerksRepository.getPerkIds(
      character.playerClass.classCode,
      character.variant,
    );
    characterPerks[character.uuid] = perkIds
        .map((id) => CharacterPerk(character.uuid, id, false))
        .toList();
  }

  /// Generates CharacterMastery records using canonical IDs from MasteriesRepository.
  void _generateCharacterMasteries(Character character) {
    final masteryIds = MasteriesRepository.getMasteryIds(
      character.playerClass.classCode,
      character.variant,
    );
    characterMasteriesMap[character.uuid] = masteryIds
        .map((id) => CharacterMastery(character.uuid, id, false))
        .toList();
  }

  // ── Campaign CRUD ──

  @override
  Future<List<Campaign>> queryAllCampaigns() async {
    return List.from(campaigns);
  }

  @override
  Future<void> insertCampaign(Campaign campaign) async {
    campaigns.add(campaign);
  }

  @override
  Future<void> updateCampaign(Campaign campaign) async {
    final idx = campaigns.indexWhere((c) => c.id == campaign.id);
    if (idx >= 0) {
      campaigns[idx] = campaign;
    }
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    // Unlink characters from parties in this campaign
    final parties = partiesMap[campaignId] ?? [];
    for (final party in parties) {
      for (final character in characters) {
        if (character.partyId == party.id) {
          character.partyId = null;
        }
      }
    }
    partiesMap.remove(campaignId);
    campaigns.removeWhere((c) => c.id == campaignId);
  }

  // ── Party CRUD ──

  @override
  Future<List<Party>> queryParties(String campaignId) async {
    return List.from(partiesMap[campaignId] ?? []);
  }

  @override
  Future<void> insertParty(Party party) async {
    partiesMap.putIfAbsent(party.campaignId, () => []);
    partiesMap[party.campaignId]!.add(party);
  }

  @override
  Future<void> updateParty(Party party) async {
    final parties = partiesMap[party.campaignId];
    if (parties != null) {
      final idx = parties.indexWhere((p) => p.id == party.id);
      if (idx >= 0) {
        parties[idx] = party;
      }
    }
  }

  @override
  Future<void> deleteParty(String partyId) async {
    // Unlink characters from this party
    for (final character in characters) {
      if (character.partyId == partyId) {
        character.partyId = null;
      }
    }
    for (final parties in partiesMap.values) {
      parties.removeWhere((p) => p.id == partyId);
    }
  }

  // ── Character-Party linking ──

  @override
  Future<void> assignCharacterToParty(
    String characterUuid,
    String? partyId,
  ) async {
    final idx = characters.indexWhere((c) => c.uuid == characterUuid);
    if (idx >= 0) {
      characters[idx].partyId = partyId;
    }
  }

  @override
  Future<List<Character>> queryCharactersByParty(String partyId) async {
    return characters.where((c) => c.partyId == partyId).toList();
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
    campaigns = [];
    partiesMap = {};
    _nextId = 1;
  }
}
