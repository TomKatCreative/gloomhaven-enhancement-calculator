import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
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

  /// Updates a character's perk selection.
  Future<void> updateCharacterPerk(CharacterPerk perk, bool value);

  /// Updates a character's mastery achievement status.
  Future<void> updateCharacterMastery(CharacterMastery mastery, bool value);

  // ── Campaign CRUD ──

  /// Queries all campaigns from the database.
  Future<List<Campaign>> queryAllCampaigns();

  /// Inserts a new campaign into the database.
  Future<void> insertCampaign(Campaign campaign);

  /// Updates an existing campaign in the database.
  Future<void> updateCampaign(Campaign campaign);

  /// Deletes a campaign and all associated parties.
  Future<void> deleteCampaign(String campaignId);

  // ── Party CRUD ──

  /// Queries all parties for a given campaign.
  Future<List<Party>> queryParties(String campaignId);

  /// Inserts a new party into the database.
  Future<void> insertParty(Party party);

  /// Updates an existing party in the database.
  Future<void> updateParty(Party party);

  /// Deletes a party and unlinks associated characters.
  Future<void> deleteParty(String partyId);

  // ── Character-Party linking ──

  /// Assigns a character to a party (or null to unassign).
  Future<void> assignCharacterToParty(String characterUuid, String? partyId);

  /// Queries characters assigned to a specific party.
  Future<List<Character>> queryCharactersByParty(String partyId);
}
