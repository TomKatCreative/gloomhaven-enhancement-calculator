import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
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
    return id;
  }

  @override
  Future<void> deleteCharacter(Character character) async {
    deleteCalls.add(character.uuid);
    characters.removeWhere((c) => c.uuid == character.uuid);
  }

  @override
  Future<List<CharacterPerk>> queryCharacterPerks(String uuid) async {
    // Return empty list - perks are not tested in retirement tests
    return [];
  }

  @override
  Future<List<CharacterMastery>> queryCharacterMasteries(String uuid) async {
    // Return empty list - masteries are not tested in retirement tests
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> queryPerks(Character character) async {
    // Return empty list - perks are not tested in retirement tests
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> queryMasteries(Character character) async {
    // Return empty list - masteries are not tested in retirement tests
    return [];
  }

  @override
  Future<void> updateCharacterPerk(CharacterPerk perk, bool value) async {
    // No-op for retirement tests
  }

  @override
  Future<void> updateCharacterMastery(
    CharacterMastery mastery,
    bool value,
  ) async {
    // No-op for retirement tests
  }

  /// Resets all state for test isolation.
  void reset() {
    characters = [];
    updateCalls = [];
    deleteCalls = [];
    _nextId = 1;
  }
}
