import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
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
    String? notes,
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
    if (notes != null) {
      character.notes = notes;
    }
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

  // ── Perk Definition Factories ──

  /// SVG-safe perk description texts (no uppercase asset keywords, no +1/-1).
  static const _perkTexts = [
    'Remove two minus one cards',
    'Gain advantage on the next three attacks',
    'Add two rolling push cards',
    'Replace one normal card with one better card',
    'Ignore negative effects and add one card',
  ];

  /// Creates a [Perk] definition with fields set directly.
  ///
  /// The [Perk] constructor doesn't accept perkId/classCode, so this factory
  /// sets those late fields after construction.
  static Perk createPerk({
    String? perkId,
    String classCode = ClassCodes.brute,
    String? perkDetails,
    bool grouped = false,
    Variant variant = Variant.base,
    int index = 0,
  }) {
    final perk = Perk(
      index,
      perkDetails ?? _perkTexts[index % _perkTexts.length],
      grouped: grouped,
    );
    perk.classCode = classCode;
    perk.variant = variant;
    perk.perkId = perkId ?? '${classCode}_${variant.name}_$index';
    return perk;
  }

  /// Creates a list of [Perk] definitions.
  ///
  /// When [sharedDetails] is provided, all perks share the same text,
  /// which triggers grouping into a single PerkRow in the UI.
  static List<Perk> createPerkList({
    int count = 3,
    bool grouped = false,
    String? sharedDetails,
    String classCode = ClassCodes.brute,
    Variant variant = Variant.base,
  }) {
    return List.generate(count, (i) {
      return createPerk(
        perkId: '${classCode}_${variant.name}_$i',
        classCode: classCode,
        perkDetails: sharedDetails ?? _perkTexts[i % _perkTexts.length],
        grouped: grouped,
        variant: variant,
        index: i,
      );
    });
  }

  /// Creates [CharacterPerk] join records matching the given [Perk] list.
  ///
  /// The first [selectedCount] perks will be marked as selected.
  static List<CharacterPerk> createCharacterPerksForPerks({
    required List<Perk> perks,
    String characterUuid = 'test-1',
    int selectedCount = 0,
  }) {
    return List.generate(perks.length, (i) {
      return CharacterPerk(characterUuid, perks[i].perkId, i < selectedCount);
    });
  }

  // ── Mastery Definition Factories ──

  /// SVG-safe mastery description texts.
  static const _masteryTexts = [
    'End a scenario with full health',
    'Complete a scenario without resting',
    'Defeat three enemies in a single round',
  ];

  /// Creates a [Mastery] definition with fields set directly.
  static Mastery createMastery({
    String? id,
    String classCode = ClassCodes.drifter,
    String? masteryDetails,
    Variant variant = Variant.base,
    int index = 0,
  }) {
    final mastery = Mastery(
      index,
      masteryDetails:
          masteryDetails ?? _masteryTexts[index % _masteryTexts.length],
    );
    mastery.classCode = classCode;
    mastery.variant = variant;
    mastery.id = id ?? '${classCode}_${variant.name}_$index';
    return mastery;
  }

  /// Creates a list of [Mastery] definitions.
  static List<Mastery> createMasteryList({
    int count = 3,
    String classCode = ClassCodes.drifter,
    Variant variant = Variant.base,
  }) {
    return List.generate(count, (i) {
      return createMastery(
        id: '${classCode}_${variant.name}_$i',
        classCode: classCode,
        masteryDetails: _masteryTexts[i % _masteryTexts.length],
        variant: variant,
        index: i,
      );
    });
  }

  /// Creates [CharacterMastery] join records matching the given [Mastery] list.
  ///
  /// The first [achievedCount] masteries will be marked as achieved.
  static List<CharacterMastery> createCharacterMasteriesForMasteries({
    required List<Mastery> masteries,
    String characterUuid = 'test-1',
    int achievedCount = 0,
  }) {
    return List.generate(masteries.length, (i) {
      return CharacterMastery(
        characterUuid,
        masteries[i].id,
        i < achievedCount,
      );
    });
  }

  // ── Campaign & Party Factories ──

  /// Creates a test [Campaign] with sensible defaults.
  static Campaign createCampaign({
    String id = 'campaign-1',
    String name = 'Test Campaign',
    GameEdition edition = GameEdition.gloomhaven,
    int prosperityCheckmarks = 0,
    int donatedGold = 0,
  }) {
    return Campaign(
      id: id,
      name: name,
      edition: edition,
      prosperityCheckmarks: prosperityCheckmarks,
      donatedGold: donatedGold,
    );
  }

  /// Creates a test [Party] with sensible defaults.
  static Party createParty({
    String id = 'party-1',
    String campaignId = 'campaign-1',
    String name = 'Test Party',
    int reputation = 0,
    String location = '',
    String notes = '',
    List<String>? achievements,
  }) {
    return Party(
      id: id,
      campaignId: campaignId,
      name: name,
      reputation: reputation,
      location: location,
      notes: notes,
      achievements: achievements,
    );
  }
}
