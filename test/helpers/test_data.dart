import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Test data fixtures for unit and widget tests.
///
/// Provides factory methods for creating test characters with sensible defaults.
/// All UUIDs use the 'test-' prefix for easy identification in debug output.
class TestData {
  /// Returns the Brute player class (Gloomhaven starting class).
  static PlayerClass get brute => PlayerClasses.playerClasses.firstWhere(
    (c) => c.classCode == ClassCodes.brute,
  );

  /// Returns the Tinkerer player class (Gloomhaven starting class).
  static PlayerClass get tinkerer => PlayerClasses.playerClasses.firstWhere(
    (c) => c.classCode == ClassCodes.tinkerer,
  );

  /// Returns the Drifter player class (Frosthaven starting class).
  static PlayerClass get drifter => PlayerClasses.playerClasses.firstWhere(
    (c) => c.classCode == ClassCodes.drifter,
  );

  /// Returns the Hail player class (Mercenary Packs).
  static PlayerClass get hail => PlayerClasses.playerClasses.firstWhere(
    (c) => c.classCode == ClassCodes.hail,
  );

  /// Creates a test character with sensible defaults.
  ///
  /// Parameters:
  /// - [uuid]: Unique identifier (defaults to 'test-1')
  /// - [name]: Character name (defaults to 'Test Character')
  /// - [playerClass]: The character's class (defaults to Brute)
  /// - [isRetired]: Whether the character is retired (defaults to false)
  /// - [previousRetirements]: Count of prior retirements (defaults to 0)
  /// - [xp]: Experience points (defaults to 0)
  /// - [gold]: Gold amount (defaults to 0)
  /// - [checkMarks]: Battle goal checkmarks (defaults to 0)
  /// - [variant]: Class variant (defaults to Variant.base)
  /// - [characterMasteries]: List of mastery achievements (defaults to empty)
  static Character createCharacter({
    String uuid = 'test-1',
    String name = 'Test Character',
    PlayerClass? playerClass,
    bool isRetired = false,
    int previousRetirements = 0,
    int xp = 0,
    int gold = 0,
    int checkMarks = 0,
    Variant variant = Variant.base,
    List<CharacterMastery>? characterMasteries,
    List<CharacterPerk>? characterPerks,
  }) {
    final character = Character(
      uuid: uuid,
      name: name,
      playerClass: playerClass ?? brute,
      isRetired: isRetired,
      previousRetirements: previousRetirements,
      xp: xp,
      gold: gold,
      checkMarks: checkMarks,
      variant: variant,
    );
    if (characterMasteries != null) {
      character.characterMasteries = characterMasteries;
    }
    if (characterPerks != null) {
      character.characterPerks = characterPerks;
    }
    return character;
  }

  /// Creates a retired test character.
  static Character createRetiredCharacter({
    String uuid = 'test-retired',
    String name = 'Retired Character',
    PlayerClass? playerClass,
  }) {
    return createCharacter(
      uuid: uuid,
      name: name,
      playerClass: playerClass,
      isRetired: true,
    );
  }

  /// Creates a test CharacterPerk.
  static CharacterPerk createCharacterPerk({
    String associatedCharacterUuid = 'test-1',
    String associatedPerkId = 'perk-1',
    bool isSelected = false,
  }) {
    return CharacterPerk(associatedCharacterUuid, associatedPerkId, isSelected);
  }

  /// Creates a list of CharacterPerks for testing.
  static List<CharacterPerk> createCharacterPerkList({
    String characterUuid = 'test-1',
    int count = 3,
    int selectedCount = 0,
  }) {
    return List.generate(count, (i) {
      return CharacterPerk(characterUuid, 'perk-$i', i < selectedCount);
    });
  }

  /// Creates a list of test characters with mixed retirement status.
  ///
  /// Returns:
  /// - Character 1: Active (uuid: 'test-1', name: 'Active 1')
  /// - Character 2: Retired (uuid: 'test-2', name: 'Retired 1')
  /// - Character 3: Active (uuid: 'test-3', name: 'Active 2')
  static List<Character> createMixedCharacters() {
    return [
      createCharacter(uuid: 'test-1', name: 'Active 1', isRetired: false),
      createCharacter(uuid: 'test-2', name: 'Retired 1', isRetired: true),
      createCharacter(uuid: 'test-3', name: 'Active 2', isRetired: false),
    ];
  }

  /// Creates a list of all retired characters.
  static List<Character> createAllRetiredCharacters() {
    return [
      createCharacter(uuid: 'test-1', name: 'Retired 1', isRetired: true),
      createCharacter(uuid: 'test-2', name: 'Retired 2', isRetired: true),
    ];
  }

  /// Creates a list of all active (non-retired) characters.
  static List<Character> createAllActiveCharacters() {
    return [
      createCharacter(uuid: 'test-1', name: 'Active 1', isRetired: false),
      createCharacter(uuid: 'test-2', name: 'Active 2', isRetired: false),
    ];
  }

  /// Creates a CharacterMastery for testing.
  static CharacterMastery createCharacterMastery({
    String associatedCharacterUuid = 'test-1',
    String associatedMasteryId = 'mastery-1',
    bool characterMasteryAchieved = false,
  }) {
    return CharacterMastery(
      associatedCharacterUuid,
      associatedMasteryId,
      characterMasteryAchieved,
    );
  }
}
