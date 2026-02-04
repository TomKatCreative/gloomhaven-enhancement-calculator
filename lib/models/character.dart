import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/character_mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';

import 'player_class.dart';

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

  Color getEffectiveColor(Brightness brightness) {
    return isRetired
        ? (brightness == Brightness.dark ? Colors.white : Colors.black)
        : Color(playerClass.primaryColor);
  }

  static int level(int xp) => PlayerClasses.levelByXp(xp);

  static int xpForNextLevel(int level) => PlayerClasses.nextXpByLevel(level);

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

  int get pocketItemsAllowed => (level(xp) / 2).round();

  int get checkMarkProgress => checkMarks != 0
      ? checkMarks % 3 == 0
            ? 3
            : checkMarks % 3
      : 0;

  int get numOfSelectedPerks => characterPerks.fold(
    0,
    (previousValue, perk) =>
        previousValue + (perk.characterPerkIsSelected ? 1 : 0),
  );

  bool get shouldShowTraits =>
      !(playerClass.traits.isEmpty ||
          (playerClass.category != ClassCategory.frosthaven &&
                  variant == Variant.base ||
              variant == Variant.gloomhaven2E));

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
