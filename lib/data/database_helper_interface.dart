import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/world.dart';

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

  /// Queries available personal quests, optionally filtered by edition.
  Future<List<Map<String, Object?>>> queryPersonalQuests({
    GameEdition? edition,
  });

  // ── World CRUD ──

  /// Queries all worlds from the database.
  Future<List<World>> queryAllWorlds();

  /// Inserts a new world into the database.
  Future<void> insertWorld(World world);

  /// Updates an existing world in the database.
  Future<void> updateWorld(World world);

  /// Deletes a world and all associated campaigns.
  Future<void> deleteWorld(String worldId);

  // ── Campaign CRUD ──

  /// Queries all campaigns for a given world.
  Future<List<Campaign>> queryCampaigns(String worldId);

  /// Inserts a new campaign into the database.
  Future<void> insertCampaign(Campaign campaign);

  /// Updates an existing campaign in the database.
  Future<void> updateCampaign(Campaign campaign);

  /// Deletes a campaign and unlinks associated characters.
  Future<void> deleteCampaign(String campaignId);

  // ── Character-Campaign linking ──

  /// Assigns a character to a campaign (or null to unassign).
  Future<void> assignCharacterToCampaign(
    String characterUuid,
    String? campaignId,
  );

  /// Queries characters assigned to a specific campaign.
  Future<List<Character>> queryCharactersByCampaign(String campaignId);
}
