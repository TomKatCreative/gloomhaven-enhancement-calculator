import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';

/// Abstract interface for database operations.
///
/// This interface allows for dependency injection and testing by abstracting
/// the database layer. The concrete implementation is [DatabaseHelper].
///
/// ## Usage
///
/// Production code uses the singleton:
/// ```dart
/// CharactersModel(databaseHelper: DatabaseHelper.instance, ...)
/// ```
///
/// Tests use a fake implementation:
/// ```dart
/// CharactersModel(databaseHelper: FakeDatabaseHelper(), ...)
/// ```
abstract class IDatabaseHelper {
  /// Queries all characters from the database.
  Future<List<Character>> queryAllCharacters();

  /// Updates an existing character in the database.
  Future<void> updateCharacter(Character character);

  /// Inserts a new character and returns the generated ID.
  Future<int> insertCharacter(Character character);

  /// Deletes a character and all associated data (perks, masteries).
  Future<void> deleteCharacter(Character character);

  /// Queries all perk selections for a character by UUID.
  Future<List<CharacterPerk>> queryCharacterPerks(String uuid);

  /// Queries all mastery achievements for a character by UUID.
  Future<List<CharacterMastery>> queryCharacterMasteries(String uuid);

  /// Queries available perks for a character based on class and variant.
  Future<List<Map<String, Object?>>> queryPerks(Character character);

  /// Queries available masteries for a character based on class and variant.
  Future<List<Map<String, Object?>>> queryMasteries(Character character);

  /// Updates a character's perk selection.
  Future<void> updateCharacterPerk(CharacterPerk perk, bool value);

  /// Updates a character's mastery achievement status.
  Future<void> updateCharacterMastery(CharacterMastery mastery, bool value);
}
