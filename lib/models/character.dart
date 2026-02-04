/// Character model representing a player's character instance.
///
/// A [Character] is an instance of a [PlayerClass] with stats, resources,
/// and progression tracking. Characters are persisted to SQLite via
/// [DatabaseHelper].
///
/// ## Key Concepts
///
/// - **Level**: Derived from XP using thresholds (1-9)
/// - **Perks**: Selected from class-specific perk lists, earned through
///   leveling, check marks, retirements, and masteries
/// - **Masteries**: Frosthaven feature - achievement goals that grant
///   additional perks when completed
/// - **Resources**: Frosthaven crafting materials (9 types)
/// - **Variant**: Class variant affecting perks (base, crossover, 2E, etc.)
///
/// ## Database Columns
///
/// The `column*` constants define SQLite column names. The model supports
/// both UUID-based identification (current) and legacy integer IDs.
///
/// See also:
/// - [PlayerClass] for class definitions
/// - [CharacterPerk] and [CharacterMastery] for join tables
/// - `docs/models_reference.md` for full documentation
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';

import 'player_class.dart';

// Database table name
const String tableCharacters = 'Characters';

const String columnCharacterId = '_id';
const String columnCharacterUuid = 'Uuid';
const String columnCharacterName = 'Name';
const String columnCharacterClassCode = 'ClassCode';
const String columnPreviousRetirements = 'PreviousRetirements';
const String columnCharacterXp = 'XP';
const String columnCharacterGold = 'Gold';
const String columnCharacterNotes = 'Notes';
const String columnCharacterCheckMarks = 'CheckMarks';
const String columnResourceHide = 'ResourceHide';
const String columnResourceMetal = 'ResourceMetal';
const String columnResourceLumber = 'ResourceWood';
const String columnResourceArrowvine = 'ResourceArrowVine';
const String columnResourceAxenut = 'ResourceAxeNut';
const String columnResourceRockroot = 'ResourceRockRoot';
const String columnResourceFlamefruit = 'ResourceFlameFruit';
const String columnResourceCorpsecap = 'ResourceCorpseCap';
const String columnResourceSnowthistle = 'ResourceSnowThistle';
const String columnIsRetired = 'IsRetired';
const String columnVariant = 'Variant';

/// A player character instance with stats, resources, and progression.
///
/// Characters belong to a [PlayerClass] and track:
/// - Core stats: XP, gold, check marks, notes
/// - Frosthaven resources: 9 crafting material types
/// - Perks: Selected attack modifier deck changes
/// - Masteries: Achievement goals (Frosthaven+ only)
///
/// ## Level Calculation
///
/// Level is derived from XP using thresholds defined in [PlayerClasses]:
/// - Level 2: 45 XP
/// - Level 3: 95 XP
/// - Level 4: 150 XP
/// - ... up to Level 9: 500 XP
///
/// ## Maximum Perks Formula
///
/// ```
/// maxPerks = (level - 1) + (checkMarks / 3) + retirements + masteryCount
/// ```
class Character {
  int? id;
  late String uuid;
  late String name;
  late PlayerClass playerClass;
  late int previousRetirements;
  late int xp;
  late int gold;
  late String notes;
  late int checkMarks;
  late int resourceHide;
  late int resourceMetal;
  late int resourceLumber;
  late int resourceArrowvine;
  late int resourceAxenut;
  late int resourceRockroot;
  late int resourceFlamefruit;
  late int resourceCorpsecap;
  late int resourceSnowthistle;
  bool isRetired = false;
  Variant variant = Variant.base;
  List<Perk> perks = [];
  List<CharacterPerk> characterPerks = [];
  List<Mastery> masteries = [];
  List<CharacterMastery> characterMasteries = [];
  Character({
    this.id,
    required this.uuid,
    required this.name,
    required this.playerClass,
    this.previousRetirements = 0,
    this.xp = 0,
    this.gold = 0,
    this.notes = 'Items, reminders, wishlist...',
    this.checkMarks = 0,
    this.resourceHide = 0,
    this.resourceMetal = 0,
    this.resourceLumber = 0,
    this.resourceArrowvine = 0,
    this.resourceAxenut = 0,
    this.resourceRockroot = 0,
    this.resourceFlamefruit = 0,
    this.resourceCorpsecap = 0,
    this.resourceSnowthistle = 0,
    this.isRetired = false,
    this.variant = Variant.base,
  });

  Character.fromMap(Map<String, dynamic> map) {
    id = map[columnCharacterId] ?? '';
    // This handles for legacy characters that don't have a uuid
    uuid = map[columnCharacterUuid] ?? map[columnCharacterId].toString();
    name = map[columnCharacterName];
    playerClass = PlayerClasses.playerClassByClassCode(
      map[columnCharacterClassCode].toLowerCase(),
    );
    previousRetirements = map[columnPreviousRetirements];
    xp = map[columnCharacterXp] ?? 0;
    gold = map[columnCharacterGold] ?? 0;
    notes = map[columnCharacterNotes] ?? '';
    checkMarks = map[columnCharacterCheckMarks] ?? 0;
    resourceHide = map[columnResourceHide] ?? 0;
    resourceMetal = map[columnResourceMetal] ?? 0;
    resourceLumber = map[columnResourceLumber] ?? 0;
    resourceArrowvine = map[columnResourceArrowvine] ?? 0;
    resourceAxenut = map[columnResourceAxenut] ?? 0;
    resourceRockroot = map[columnResourceRockroot] ?? 0;
    resourceFlamefruit = map[columnResourceFlamefruit] ?? 0;
    resourceCorpsecap = map[columnResourceCorpsecap] ?? 0;
    resourceSnowthistle = map[columnResourceSnowthistle] ?? 0;
    isRetired = map[columnIsRetired] == 1;
    variant = Variant.values.firstWhere(
      (variant) => variant.name == map[columnVariant],
    );
  }

  Map<String, dynamic> toMap() => {
    columnCharacterId: id,
    columnCharacterUuid: uuid,
    columnCharacterName: name,
    columnCharacterClassCode: playerClass.classCode.toLowerCase(),
    columnPreviousRetirements: previousRetirements,
    columnCharacterXp: xp,
    columnCharacterGold: gold,
    columnCharacterNotes: notes,
    columnCharacterCheckMarks: checkMarks,
    columnResourceHide: resourceHide,
    columnResourceMetal: resourceMetal,
    columnResourceLumber: resourceLumber,
    columnResourceArrowvine: resourceArrowvine,
    columnResourceAxenut: resourceAxenut,
    columnResourceRockroot: resourceRockroot,
    columnResourceFlamefruit: resourceFlamefruit,
    columnResourceCorpsecap: resourceCorpsecap,
    columnResourceSnowthistle: resourceSnowthistle,
    columnIsRetired: isRetired ? 1 : 0,
    columnVariant: variant.name,
  };

  /// Returns the effective theme color for this character.
  ///
  /// Retired characters return a neutral color (white in dark mode,
  /// black in light mode). Active characters return the class primary color.
  Color getEffectiveColor(Brightness brightness) {
    return isRetired
        ? (brightness == Brightness.dark ? Colors.white : Colors.black)
        : Color(playerClass.primaryColor);
  }

  /// Converts XP to character level (1-9).
  static int level(int xp) => PlayerClasses.levelByXp(xp);

  /// Returns the XP threshold for the next level, or null at max level.
  static int xpForNextLevel(int level) => PlayerClasses.nextXpByLevel(level);

  /// Calculates the maximum number of perks available for a character.
  ///
  /// Formula: (level - 1) + (checkMarks / 3) + retirements + achievedMasteries
  static int maximumPerks(Character character) {
    int sum = 0;
    sum += level(character.xp) - 1;
    sum += ((character.checkMarks - 1) / 3).round();
    sum += character.previousRetirements;
    sum += character.characterMasteries.fold(
      0,
      (previousValue, mastery) =>
          previousValue + (mastery.characterMasteryAchieved ? 1 : 0),
    );
    return sum;
  }

  /// Maximum pocket items allowed, calculated as level / 2 (rounded).
  int get pocketItemsAllowed => (level(xp) / 2).round();

  /// Progress toward the next perk from check marks (0, 1, 2, or 3).
  ///
  /// Every 3 check marks grants 1 additional perk. This getter returns
  /// the current progress within the current cycle.
  int get checkMarkProgress => checkMarks != 0
      ? checkMarks % 3 == 0
            ? 3
            : checkMarks % 3
      : 0;

  /// Count of perks currently selected for this character.
  int get numOfSelectedPerks => characterPerks.fold(
    0,
    (previousValue, perk) =>
        previousValue + (perk.characterPerkIsSelected ? 1 : 0),
  );

  /// Whether to display class traits for this character.
  ///
  /// Traits are hidden when:
  /// - The class has no traits defined
  /// - Base variant of non-Frosthaven classes
  /// - Gloomhaven 2E variant (different trait system)
  bool get shouldShowTraits =>
      !(playerClass.traits.isEmpty ||
          (playerClass.category != ClassCategory.frosthaven &&
                  variant == Variant.base ||
              variant == Variant.gloomhaven2E));

  /// Full display name including race and variant name (e.g., "Inox Brute").
  String get classSubtitle => playerClass.getFullDisplayName(variant);

  // TODO: modify this to include Custom and Crimson Scales once they have masteries
  // for now, have to manually add the Custom Classes that have masteries but aren't
  // yet Frosthaven Crossover versions
  bool get shouldShowMasteries =>
      playerClass.classCode == ClassCodes.vimthreader ||
      playerClass.classCode == ClassCodes.core ||
      playerClass.classCode == ClassCodes.dome ||
      playerClass.classCode == ClassCodes.skitterclaw ||
      playerClass.classCode == ClassCodes.alchemancer ||
      playerClass.category == ClassCategory.frosthaven ||
      variant == Variant.frosthavenCrossover ||
      variant == Variant.gloomhaven2E ||
      playerClass.category == ClassCategory.mercenaryPacks;
}
