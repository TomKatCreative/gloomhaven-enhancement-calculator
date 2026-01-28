import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/perk_and_mastery_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/legacy_perk.dart'
    as legacy;

class PerksRepositoryLegacy {
  // Keep this to allow for a database migration
  static final List<legacy.Perk> legacyPerks = [
    // BRUTE
    legacy.Perk(
      ClassCodes.brute,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} PUSH 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} PIERCE 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} DISARM ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brute,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    // TINKERER
    legacy.Perk(
      ClassCodes.tinkerer,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} FIRE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 HEAL 2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.tinkerer,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // SPELLWEAVER
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 ICE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} EARTH and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spellweaver,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} LIGHT and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} DARK ${PerkAndMasteryConstants.card}',
    ),
    // SCOUNDREL
    legacy.Perk(
      ClassCodes.scoundrel,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} PIERCE 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} POISON ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} INVISIBLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.scoundrel,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // CRAGHEART
    legacy.Perk(
      ClassCodes.cragheart,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.two} +2 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} PUSH 2 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} EARTH ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} AIR ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects}',
    ),
    legacy.Perk(
      ClassCodes.cragheart,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // MINDTHIEF
    legacy.Perk(
      ClassCodes.mindthief,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +2 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 ICE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} PULL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} DISARM ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mindthief,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // SUNKEEPER
    legacy.Perk(
      ClassCodes.sunkeeper,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} HEAL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} LIGHT ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sunkeeper,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // QUARTERMASTER
    legacy.Perk(
      ClassCodes.quartermaster,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} PIERCE 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 "RECOVER an item" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.quartermaster,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    // SUMMONER
    legacy.Perk(
      ClassCodes.summoner,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} WOUND ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} POISON ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} HEAL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} FIRE and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} DARK and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.summoner,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    // NIGHTSHROUD
    legacy.Perk(
      ClassCodes.nightshroud,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} -1 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 DARK ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 INVISIBLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} HEAL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} CURSE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.nightshroud,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    // PLAGUEHERALD
    legacy.Perk(
      ClassCodes.plagueherald,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} POISON ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} CURSE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.plagueherald,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    // BERSERKER
    legacy.Perk(
      ClassCodes.berserker,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} WOUND ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +1 DISARM ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} HEAL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.berserker,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects}',
    ),
    //SOOTHSINGER
    legacy.Perk(
      ClassCodes.soothsinger,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +4 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 DISARM ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.soothsinger,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} CURSE ${PerkAndMasteryConstants.cards}',
    ),
    // DOOMSTALKER
    legacy.Perk(
      ClassCodes.doomstalker,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.doomstalker,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // SAWBONES
    legacy.Perk(
      ClassCodes.sawbones,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} WOUND ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} HEAL 3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.sawbones,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 "RECOVER an item" ${PerkAndMasteryConstants.card}',
    ),
    // ELEMENTALIST
    legacy.Perk(
      ClassCodes.elementalist,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} +0 FIRE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} +0 ICE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} +0 AIR ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} +0 EARTH ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +0 FIRE ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} +0 EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +0 ICE ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} +0 AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 PUSH 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.elementalist,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    // BEAST TYRANT
    legacy.Perk(
      ClassCodes.beastTyrant,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} HEAL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} EARTH ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.beastTyrant,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // BLADESWARM
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} HEAL 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bladeswarm,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    // DIVINER
    legacy.Perk(
      ClassCodes.diviner,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +3 "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.shield} 1, Affect any Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 "${PerkAndMasteryConstants.regenerate}, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "HEAL 2, Affect any Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} CURSE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.diviner,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    // DEMOLITIONIST
    legacy.Perk(
      ClassCodes.demolitionist,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.demolitionist,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 "All adjacent enemies suffer 1 DAMAGE" ${PerkAndMasteryConstants.card}',
    ),
    // HATCHET
    legacy.Perk(
      ClassCodes.hatchet,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 PUSH 2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hatchet,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    // RED GUARD
    legacy.Perk(
      ClassCodes.redGuard,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 FIRE&LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.shield} 1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.redGuard,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    // VOIDWARDEN
    legacy.Perk(
      ClassCodes.voidwarden,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ICE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "HEAL 1, Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "HEAL 1, Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.voidwarden,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 CURSE ${PerkAndMasteryConstants.card}',
    ),
    // AMBER AEGIS
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 "Place ${PerkAndMasteryConstants.one} Colony token of your choice on any empty hex within RANGE 2" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self" ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.retaliate} 1, RANGE 3" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 FIRE/EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.amberAegis,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} "+X, where X is the number of active Cultivate actions" card',
    ),
    // ARTIFICER
    legacy.Perk(
      ClassCodes.artificer,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 Any_Element ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 DISARM ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 PUSH 1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 PULL 1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "RECOVER a spent item" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 PIERCE 2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 "HEAL 2, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 POISON ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.artificer,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} +1 WOUND ${PerkAndMasteryConstants.cards}',
    ),
    // BOMBARD
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} PIERCE 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "+3 if Projectile" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.two} +1 "${PerkAndMasteryConstants.retaliate} 1, RANGE 3" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 "PULL 3, Self, toward the target" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 "STRENGTHEN, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bombard,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    // BREWMASTER
    legacy.Perk(
      ClassCodes.brewmaster,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} MUDDLE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +0 "HEAL 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "Give yourself or an adjacent Ally a \'Liquid Rage\' item ${PerkAndMasteryConstants.card}" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 PROVOKE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      2,
      '${PerkAndMasteryConstants.add} four ${PerkAndMasteryConstants.rolling} Shrug_Off 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brewmaster,
      2,
      'Each time you long rest, perform Shrug_Off 1',
    ),
    // BRIGHTSPARK
    legacy.Perk(
      ClassCodes.brightspark,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "Consume_Any_Element to ${PerkAndMasteryConstants.add}L +2 ATTACK" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -2 "RECOVER ${PerkAndMasteryConstants.one} random ${PerkAndMasteryConstants.card} from your discard pile" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +1 "HEAL 1, Affect ${PerkAndMasteryConstants.one} Ally within RANGE 2" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.shield} 1, Affect ${PerkAndMasteryConstants.one} Ally within RANGE 2" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 Any_Element ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "STRENGTHEN, Affect ${PerkAndMasteryConstants.one} Ally within RANGE 2" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "PUSH 1 or PULL 1, AIR" ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.immobilize}, ICE" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "HEAL 1, RANGE 3, LIGHT" ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "PIERCE 2, FIRE" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} "Consume_Any_Element : Any_Element" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.brightspark,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card}',
    ),
    // CHIEFTAIN
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "HEAL 1, Chieftain" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "HEAL 1, Affect all summoned allies owned" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -2 "BLESS, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +0 "${PerkAndMasteryConstants.immobilize} and PUSH 1" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} "+X, where X is the number of summoned allies you own" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.two} +1 "${PerkAndMasteryConstants.rolling} +1, if summon is attacking" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 WOUND, PIERCE 1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "PIERCE 2, ignore ${PerkAndMasteryConstants.retaliate} on the target" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.chieftain,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    // FIRE KNIGHT
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "STRENGTHEN, Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +0 "+2 if you are on Ladder" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +2 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +2 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "STRENGTHEN, Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "HEAL 1, RANGE 1" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} WOUND ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.fireKnight,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} FIRE ${PerkAndMasteryConstants.card}',
    ),
    // FROSTBORN
    legacy.Perk(
      ClassCodes.frostborn,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 CHILL ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +1 PUSH 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ICE CHILL ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 STUN ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} CHILL ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} PUSH 1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      'Ignore difficult and hazardous terrain during move actions',
    ),
    legacy.Perk(
      ClassCodes.frostborn,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // HOLLOWPACT
    legacy.Perk(
      ClassCodes.hollowpact,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "HEAL 2, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +0 VOIDSIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} -2 EARTH ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.two} +2 DARK ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -2 STUN ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} +0 VOIDSIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 DISARM ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} -1 Any_Element ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +1 VOID ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} -1 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +3 "${PerkAndMasteryConstants.regenerate}, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "Create a Void pit in an empty hex within RANGE 2" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hollowpact,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +0 "WARD, Self" ${PerkAndMasteryConstants.card}',
    ),
    // MIREFOOT
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} "+X, where X is the POISON value of the target" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +2 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "Create difficult terrain in the hex occupied by the target" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 WOUND 2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      '${PerkAndMasteryConstants.add} four ${PerkAndMasteryConstants.rolling} +0 "+1 if the target occupies difficult terrain" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "INVISIBLE, Self, if you occupy difficult terrain" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      'Gain "Poison Dagger" (Item 011). You may carry ${PerkAndMasteryConstants.one} additional One_Hand item with "Dagger" in its name',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      'Ignore damage, ${PerkAndMasteryConstants.negative} conditions, and modifiers from Events, and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.mirefoot,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card}',
    ),
    // ROOTWHISPERER
    // May be dead legacy.Perks if Rootwhisperer has a big overhaul - this is fine
    legacy.Perk(
      ClassCodes.rootwhisperer,
      2,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} POISON ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} DISARM ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} HEAL 2 EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rootwhisperer,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    // CHAINGUARD
    legacy.Perk(
      ClassCodes.chainguard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 Shackle ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "+2 if the target is Shackled" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.shield} 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.retaliate} 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} SWING 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "DISARM if the target is Shackled" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "Create a 2 DAMAGE trap in an empty hex within RANGE 2" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 Shackle ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.chainguard,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    // HIEROPHANT
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} EARTH ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.shield} 1, Ally" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 "Give ${PerkAndMasteryConstants.one} Ally a \'Prayer\' ability ${PerkAndMasteryConstants.card}" and ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self or Ally" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 WOUND, MUDDLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      'At the start of your first turn each ${PerkAndMasteryConstants.scenario}, gain BLESS',
    ),
    legacy.Perk(
      ClassCodes.hierophant,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    // LUMINARY
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.remove} four +0 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ICE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -2 "Perform ${PerkAndMasteryConstants.one} Glow ability" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 Any_Element ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +1 "HEAL 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} "POISON, target all enemies in the depicted LUMINARY_HEXES area" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.luminary,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "Consume_Any_Element : Any_Element" ${PerkAndMasteryConstants.card}',
    ),
    // SPIRIT CALLER
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "+2 if a Spirit performed the attack" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} and ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 PIERCE 2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} PIERCE 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ADD TARGET ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +2 PUSH 2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.spiritCaller,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    // STARSLINGER
    legacy.Perk(
      ClassCodes.starslinger,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 "INVISIBLE, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} +0 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 LIGHT ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} LOOT 1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "+3 if you are at full health" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "HEAL 1, RANGE 3" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "Force the target to perform a \'MOVE 1\' ability" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} "HEAL 1, RANGE 1" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.starslinger,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    // RUINMAW
    legacy.Perk(
      ClassCodes.ruinmaw,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} -1 RUPTURE and WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 RUPTURE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.add} +3 instead if the target has RUPTURE or WOUND" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "HEAL 1, Self, EMPOWER" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      1,
      'Once each ${PerkAndMasteryConstants.scenario}, become SATED after collecting your 5th loot token',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      1,
      'Become SATED each time you lose a ${PerkAndMasteryConstants.card} to negate suffering damage',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      1,
      'Whenever ${PerkAndMasteryConstants.one} of your abilities causes at least ${PerkAndMasteryConstants.one} enemy to gain RUPTURE, immediately after that ability perform "MOVE 1"',
    ),
    legacy.Perk(
      ClassCodes.ruinmaw,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}, and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card}',
    ),
    // ************** ^^ THIS IS AS FAR AS RELEASE 3.7.0 GOES ^^ **************
    // DRIFTER
    legacy.Perk(
      ClassCodes.drifter,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.two} +0 "Move ${PerkAndMasteryConstants.one} of your character tokens backward ${PerkAndMasteryConstants.one} slot" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} PIERCE 3 ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} PUSH 2 ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +3 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} "HEAL 1, self" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      'Ignore item item_minus_one ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      2,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may move ${PerkAndMasteryConstants.one} of your character tokens backward ${PerkAndMasteryConstants.one} slot',
      perkIsGrouped: true,
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      'You may bring ${PerkAndMasteryConstants.one} additional One_Hand item into each ${PerkAndMasteryConstants.scenario}',
    ),
    legacy.Perk(
      ClassCodes.drifter,
      1,
      "At the end of each ${PerkAndMasteryConstants.scenario}, you may discard up to ${PerkAndMasteryConstants.two} loot ${PerkAndMasteryConstants.cards}, except 'Random Item', to draw that many new loot ${PerkAndMasteryConstants.cards}",
    ),
    // BLINK BLADE
    legacy.Perk(
      ClassCodes.blinkBlade,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.immobilize} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} "Place this ${PerkAndMasteryConstants.card} in your active area. On your next attack, discard this ${PerkAndMasteryConstants.card} to ${PerkAndMasteryConstants.add}L plustwo ATTACK" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} +2 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} -1 "Gain ${PerkAndMasteryConstants.one} TIME_TOKEN" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 "${PerkAndMasteryConstants.regenerate}, self" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      1,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may spend ${PerkAndMasteryConstants.one} unspent SPENT item for no effect to RECOVER a different spent item',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      1,
      'At the start of your first turn each ${PerkAndMasteryConstants.scenario}, you may perform MOVE 3',
    ),
    legacy.Perk(
      ClassCodes.blinkBlade,
      1,
      'Whenever you would gain ${PerkAndMasteryConstants.immobilize}, prevent the condition',
    ),
    // BANNER SPEAR
    legacy.Perk(
      ClassCodes.bannerSpear,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} "${PerkAndMasteryConstants.shield} 1" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.add} plusone ATTACK for each ally adjacent to the target" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 DISARM ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 PUSH 1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} "HEAL 1, self" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      1,
      'Ignore item item_minus_one ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      1,
      'At the end of each of your long rests, grant ${PerkAndMasteryConstants.one} ally within RANGE 3: MOVE 2',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      1,
      'Whenever you open a door with a move ability, ${PerkAndMasteryConstants.add}L +3 MOVE',
    ),
    legacy.Perk(
      ClassCodes.bannerSpear,
      2,
      'Once each ${PerkAndMasteryConstants.scenario}, during your turn, gain ${PerkAndMasteryConstants.shield} 2 for the round',
      perkIsGrouped: true,
    ),
    // DEATHWALKER
    legacy.Perk(
      ClassCodes.deathwalker,
      1,
      '${PerkAndMasteryConstants.remove} ${PerkAndMasteryConstants.two} -1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} DISARM ${PerkAndMasteryConstants.rolling} and ${PerkAndMasteryConstants.one} MUDDLE ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} "HEAL 1, Target 1 ally" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      1,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may move ${PerkAndMasteryConstants.one} SHADOW up to 3 hexes',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      1,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may consume_DARK to perform MUDDLE, CURSE, RANGE 2 as if you were occupying a hex with a SHADOW',
    ),
    legacy.Perk(
      ClassCodes.deathwalker,
      1,
      'While you are occupying a hex with a SHADOW, all attacks targeting you gain disadvantage',
    ),
    // BONESHAPER
    legacy.Perk(
      ClassCodes.boneshaper,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 CURSE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "Kill the attacking summon to instead ${PerkAndMasteryConstants.add}L +4" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} "HEAL 1, Target Boneshaper" ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      3,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 EARTH/DARK ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.two} +1 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      1,
      'Immediately before each of your rests, you may kill ${PerkAndMasteryConstants.one} of your summons to perform BLESS, self',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      1,
      'Once each ${PerkAndMasteryConstants.scenario}, when any character ally would become exhausted by suffering DAMAGE, you may suffer DAMAGE 2 to reduce their hit point value to 1 instead',
    ),
    legacy.Perk(
      ClassCodes.boneshaper,
      2,
      'At the start of each ${PerkAndMasteryConstants.scenario}, you may play a level 1 ${PerkAndMasteryConstants.card} from your hand to perform a summon action of the ${PerkAndMasteryConstants.card}',
      perkIsGrouped: true,
    ),
    // GEMINATE
    legacy.Perk(
      ClassCodes.geminate,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      3,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 "Consume_Any_Element : Any_Element" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 POISON ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} PIERCE 3 ${PerkAndMasteryConstants.rolling} ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} +1 PUSH 3 ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} 2x "BRITTLE, self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +1 "${PerkAndMasteryConstants.regenerate}, self" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      1,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may ${PerkAndMasteryConstants.remove}L ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.negative} condition from ${PerkAndMasteryConstants.one} ally within RANGE 3',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      1,
      'Once each ${PerkAndMasteryConstants.scenario}, when you would give yourself a ${PerkAndMasteryConstants.negative} condition, prevent the condition',
    ),
    legacy.Perk(
      ClassCodes.geminate,
      2,
      'Whenever you perform an action with a lost icon, you may discard ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.card} to RECOVER ${PerkAndMasteryConstants.one} card from your discard pile of equal or lower level',
      perkIsGrouped: true,
    ),
    // INFUSER
    legacy.Perk(
      ClassCodes.infuser,
      1,
      'Replace one -2 card with one -1 and one -1 AIR EARTH DARK card',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      2,
      'Replace one -1 card with one +0 AIR/EARTH card',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      2,
      'Replace one -1 card with one +0 AIR/DARK card',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      2,
      'Replace one -1 card with one +0 EARTH/DARK card',
    ),
    legacy.Perk(ClassCodes.infuser, 2, 'Replace one +0 card with one +2 card'),
    legacy.Perk(
      ClassCodes.infuser,
      2,
      'Replace one +0 card with three "Move one waning element to strong" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      2,
      'Add two "plusone ATTACK for each pair of active INFUSION" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      1,
      'Ignore ${PerkAndMasteryConstants.scenario} ${PerkAndMasteryConstants.effects}',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      1,
      '${PerkAndMasteryConstants.ignoreItemMinusOneEffects}. Whenever you become exhausted, keep all your active bonuses in play, with your summons acting on initiative 99 each round',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      1,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may Consume_Any_Element to RECOVER one spent One_Hand or Two_Hand item',
    ),
    legacy.Perk(
      ClassCodes.infuser,
      1,
      'Once each scenario, during ordering of initiative, after all ability cards have been revealed, Any_Element',
    ),
    // PYROCLAST
    legacy.Perk(ClassCodes.pyroclast, 1, 'Remove two -1 cards'),
    legacy.Perk(ClassCodes.pyroclast, 1, 'Remove one -2 card'),
    legacy.Perk(
      ClassCodes.pyroclast,
      2,
      'Replace one +0 card with one +1 WOUND card',
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      2,
      'Replace one -1 card with one +0 "Create one 1-hex hazardous terrain tile in a featureless hex adjacent to the target" card',
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      2,
      'Replace two +0 cards with two PUSH 2 ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      1,
      'Replace two +1 cards with two +2 cards',
    ),
    legacy.Perk(ClassCodes.pyroclast, 2, 'Add two +1 FIRE/EARTH cards'),
    legacy.Perk(
      ClassCodes.pyroclast,
      1,
      'Add two +1 MUDDLE ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      1,
      PerkAndMasteryConstants.ignoreScenarioEffects,
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      1,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may destroy one adjacent obstacle to gain WARD',
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      1,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may consume_FIRE to perform WOUND, Target 1 enemy occupying or adjacent to hazardous terrain',
    ),
    legacy.Perk(
      ClassCodes.pyroclast,
      3,
      'You and all allies are unaffected by hazardous terrain you create',
      perkIsGrouped: true,
    ),
    // SHATTERSONG
    legacy.Perk(ClassCodes.shattersong, 1, 'Remove four +0 cards'),
    legacy.Perk(
      ClassCodes.shattersong,
      2,
      'Replace two -1 cards with two +0 "Reveal the top card of the target\'s monster ability deck" cards',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      1,
      'Replace one -2 card with one -1 STUN card',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      2,
      'Replace one +0 card with one +0 BRITTLE card',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      2,
      'Replace two +1 cards with two +2 AIR/LIGHT cards',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      2,
      'Add one "HEAL 2, BLESS, Target 1 ally" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      3,
      'Add one +1 "Gain 1 RESONANCE" card',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      1,
      PerkAndMasteryConstants.ignoreScenarioEffects,
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      2,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may consume_AIR to perform STRENGTHEN, RANGE 3 and consume_LIGHT to perform BLESS, RANGE 3',
      perkIsGrouped: true,
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      1,
      '${PerkAndMasteryConstants.atTheStartOfEachScenario}, you may gain BRITTLE to gain 2 RESONANCE',
    ),
    legacy.Perk(
      ClassCodes.shattersong,
      1,
      'Whenever a new room is revealed, you may reveal the top card of both the monster attack modifier deck and all allies\' attack modifier decks',
    ),
    // TRAPPER
    legacy.Perk(ClassCodes.trapper, 1, 'Remove one -2 card'),
    legacy.Perk(
      ClassCodes.trapper,
      2,
      'Replace one -1 card with one +0 "Create one HEAL 2 trap in an empty hex adjacent to the target" card',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      3,
      'Replace one -1 card with one +0 "Create one DAMAGE 1 trap in an empty hex adjacent to the target" card',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      3,
      'Replace two +0 cards with two +0 "Add DAMAGE 2 or HEAL 2 to a trap within RANGE 2 of you" cards',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      2,
      'Replace two +1 cards with two +2 ${PerkAndMasteryConstants.immobilize} cards',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      3,
      'Add two "Add PUSH 2 or PULL 2" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      1,
      PerkAndMasteryConstants.ignoreScenarioEffects,
    ),
    legacy.Perk(
      ClassCodes.trapper,
      1,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may create one DAMAGE 1 trap in an adjacent empty hex',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      1,
      'Whenever you enter a hex with a trap, you may choose to not spring the trap',
    ),
    legacy.Perk(
      ClassCodes.trapper,
      1,
      '${PerkAndMasteryConstants.atTheStartOfEachScenario}, you may create one DAMAGE 2 trap in an adjacent empty hex',
    ),
    // PAIN CONDUIT
    legacy.Perk(ClassCodes.painConduit, 2, 'Remove two -1 cards'),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      'Replace one -2 card with one -2 CURSE CURSE card',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      'Replace one -1 card with one +0 DISARM card',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      3,
      'Replace one +0 card with one +1 FIRE/AIR card',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      'Replace one +0 card with one +2 card',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      'Replace three +1 cards with three +1 CURSE cards',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      2,
      'Add three "HEAL 1, self" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      2,
      'Add one +0 "Add plusone ATTACK for each negative condition you have" card',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      '${PerkAndMasteryConstants.ignoreScenarioEffects} and add two +1 cards',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      'Each round in which you long rest, you may ignore all negative conditions you have. If you do, they cannot be removed that round',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      1,
      'Whenever you become exhausted, first perform CURSE, Target all, RANGE 3',
    ),
    legacy.Perk(
      ClassCodes.painConduit,
      2,
      'Increase your maximum hit point value by 5',
      perkIsGrouped: true,
    ),
    // SNOWDANCER
    legacy.Perk(
      ClassCodes.snowdancer,
      3,
      'Replace one -1 card with one +0 "HEAL 1, Target 1 ally" card',
    ),
    legacy.Perk(
      ClassCodes.snowdancer,
      2,
      'Replace one -1 card with one +0 ${PerkAndMasteryConstants.immobilize} card',
    ),
    legacy.Perk(ClassCodes.snowdancer, 2, 'Add two +1 ICE/AIR cards'),
    legacy.Perk(
      ClassCodes.snowdancer,
      2,
      'Replace two +0 cards with two "If this action forces the target to move, it suffers DAMAGE 1" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.snowdancer,
      2,
      'Replace one +0 card with one +1 "STRENGTHEN, Target 1 ally" card',
    ),
    legacy.Perk(
      ClassCodes.snowdancer,
      2,
      'Add one "HEAL 1, WARD, Target 1 ally" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(
      ClassCodes.snowdancer,
      1,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may ICE/AIR',
    ),
    legacy.Perk(
      ClassCodes.snowdancer,
      2,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may consume_ICE to perform ${PerkAndMasteryConstants.regenerate}, RANGE 3 and consume_AIR to perform WARD, RANGE 3',
      perkIsGrouped: true,
    ),
    legacy.Perk(
      ClassCodes.snowdancer,
      2,
      '${PerkAndMasteryConstants.atTheStartOfEachScenario}, all enemies gain MUDDLE. Whenever a new room is revealed, all enemies in the newly revealed room gain MUDDLE',
      perkIsGrouped: true,
    ),
    // FROZEN FIST
    legacy.Perk(
      ClassCodes.frozenFist,
      2,
      'Replace one -1 card with one +0 DISARM card',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      1,
      'Replace one -1 card with one +1 card',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      1,
      'Replace one -2 card with one +0 card',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      2,
      'Replace one +0 card with one +1 "${PerkAndMasteryConstants.shield} 1" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      2,
      'Replace one +0 card with one +1 ICE/EARTH card',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      2,
      'Replace one +0 card with one +2 "Create one 1-hex icy terrain tile in a featureless hex adjacent to the target" card',
    ),
    legacy.Perk(ClassCodes.frozenFist, 1, 'Add one +3 card'),
    legacy.Perk(
      ClassCodes.frozenFist,
      3,
      'Add two "HEAL 1, self" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      1,
      '${PerkAndMasteryConstants.ignoreItemMinusOneEffects}, and, whenever you enter icy terrain with a move ability, you may ignore the effect to add plusone MOVE',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      1,
      'Whenever you heal from a long rest, you may consume_ICE/EARTH to add plustwo HEAL',
    ),
    legacy.Perk(
      ClassCodes.frozenFist,
      2,
      'Once each scenario, when you would suffer DAMAGE, you may negate the DAMAGE',
      perkIsGrouped: true,
    ),
    // HIVE
    legacy.Perk(ClassCodes.hive, 1, 'Remove one -2 card and one +1 card'),
    legacy.Perk(
      ClassCodes.hive,
      3,
      'Replace one -1 card with one +0 "After this attack ability, grant one of your summons: MOVE 2" card',
    ),
    legacy.Perk(
      ClassCodes.hive,
      3,
      'Replace one +0 card with one +1 "After this attack ability, TRANSFER" card',
    ),
    legacy.Perk(ClassCodes.hive, 3, 'Add one +1 "HEAL 1, self" card'),
    legacy.Perk(ClassCodes.hive, 2, 'Add one +2 MUDDLE card'),
    legacy.Perk(
      ClassCodes.hive,
      1,
      'Add two POISON ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.hive,
      1,
      'Add two WOUND ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.hive,
      2,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may do so on any initiative value, choosing your initiative after all ability cards have been revealed, and you decide how your summons perform their abilities for the round',
      perkIsGrouped: true,
    ),
    legacy.Perk(
      ClassCodes.hive,
      1,
      'At the end of each of your short rests, you may TRANSFER',
    ),
    legacy.Perk(
      ClassCodes.hive,
      1,
      'Whenever you would gain WOUND, prevent the condition',
    ),
    // METAL MOSAIC
    legacy.Perk(
      ClassCodes.metalMosaic,
      3,
      'Replace one -1 card with one +0 "PRESSURE_GAIN or PRESSURE_LOSE" card',
    ),
    legacy.Perk(
      ClassCodes.metalMosaic,
      2,
      'Replace one -1 card with one "${PerkAndMasteryConstants.shield} 1" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(
      ClassCodes.metalMosaic,
      2,
      'Replace one +0 card with one +0 "The target and all enemies adjacent to it suffer DAMAGE 1" card',
    ),
    legacy.Perk(
      ClassCodes.metalMosaic,
      2,
      'Replace two +0 cards with one PIERCE 3 ${PerkAndMasteryConstants.rolling} and one "${PerkAndMasteryConstants.retaliate} 2" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(ClassCodes.metalMosaic, 2, 'Add one +1 "HEAL 2, self" card'),
    legacy.Perk(ClassCodes.metalMosaic, 1, 'Add one +3 card'),
    legacy.Perk(
      ClassCodes.metalMosaic,
      1,
      '${PerkAndMasteryConstants.ignoreItemMinusOneEffects} and add two +1 cards',
    ),
    legacy.Perk(
      ClassCodes.metalMosaic,
      1,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may PRESSURE_GAIN or PRESSURE_LOSE',
    ),
    legacy.Perk(
      ClassCodes.metalMosaic,
      1,
      'Whenever you would gain POISON, you may suffer DAMAGE 1 to prevent the condition',
    ),
    legacy.Perk(
      ClassCodes.metalMosaic,
      3,
      'Once each scenario, when you would become exhausted, instead gain STUN and INVISIBLE, lose all your cards, RECOVER four lost cards, and then discard the recovered cards',
      perkIsGrouped: true,
    ),
    // DEEPWRAITH
    legacy.Perk(ClassCodes.deepwraith, 1, 'Remove two -1 cards'),
    legacy.Perk(
      ClassCodes.deepwraith,
      2,
      'Replace one -1 card with one +0 DISARM card',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      'Replace one -2 card with one -1 STUN card',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      2,
      'Replace one +0 card with one +0 "INVISIBLE, self" card',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      'Replace two +0 cards with two PIERCE 3 ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      'Replace two +1 cards with two +2 cards',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      'Replace three +1 cards with three +1 CURSE cards',
    ),
    legacy.Perk(ClassCodes.deepwraith, 3, 'Add two +1 "Gain 1 TROPHY" cards'),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      '${PerkAndMasteryConstants.ignoreScenarioEffects} and remove two +0 cards',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may LOOT one adjacent hex. If you gain any loot tokens, gain 1 TROPHY',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      1,
      '${PerkAndMasteryConstants.atTheStartOfEachScenario}, gain 2 TROPHY',
    ),
    legacy.Perk(
      ClassCodes.deepwraith,
      3,
      'While you have INVISIBLE, gain advantage on all your attacks',
      perkIsGrouped: true,
    ),
    // CRASHING TIDE
    legacy.Perk(
      ClassCodes.crashingTide,
      2,
      'Replace one -1 card with two PIERCE 3 ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.crashingTide,
      2,
      'Replace one -1 card with one +0 "plusone Target" card',
    ),
    legacy.Perk(
      ClassCodes.crashingTide,
      2,
      'Replace one +0 card with one +1 "${PerkAndMasteryConstants.shield} 1" ${PerkAndMasteryConstants.rolling} card',
    ),
    legacy.Perk(
      ClassCodes.crashingTide,
      2,
      'Add two +1 "If you performed a TIDE action this round, +2 instead" cards',
    ),
    legacy.Perk(ClassCodes.crashingTide, 2, 'Add one +2 MUDDLE card'),
    legacy.Perk(ClassCodes.crashingTide, 1, 'Add one +1 DISARM card'),
    legacy.Perk(
      ClassCodes.crashingTide,
      2,
      'Add two "HEAL 1, self" ${PerkAndMasteryConstants.rolling} cards',
    ),
    legacy.Perk(
      ClassCodes.crashingTide,
      1,
      '${PerkAndMasteryConstants.ignoreItemMinusOneEffects}, and, whenever you would gain IMPAIR, prevent the condition',
    ),
    legacy.Perk(
      ClassCodes.crashingTide,
      1,
      'Whenever you declare a long rest during card selection, gain ${PerkAndMasteryConstants.shield} 1 for the round',
    ),
    legacy.Perk(
      ClassCodes.crashingTide,
      3,
      'Gain advantage on all your attacks performed while occupying or targeting enemies occupying water hexes',
      perkIsGrouped: true,
    ),
    // THORNREAPER
    legacy.Perk(
      ClassCodes.thornreaper,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "+1 if LIGHT is Strong or Waning" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      2,
      'Add three ${PerkAndMasteryConstants.rolling} "+1 if LIGHT is Strong or Waning" cards',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} LIGHT ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.three} ${PerkAndMasteryConstants.rolling} "EARTH if LIGHT is Strong or Waning" ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} "Create hazardous terrain in ${PerkAndMasteryConstants.one} hex within RANGE 1" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      2,
      'Add one ${PerkAndMasteryConstants.rolling} "On the next attack targeting you while occupying hazardous terrain, discard this card to gain ${PerkAndMasteryConstants.retaliate} 3" card',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      2,
      'Add one ${PerkAndMasteryConstants.rolling} "On the next attack targeting you while occupying hazardous terrain, discard this card to gain ${PerkAndMasteryConstants.shield} 3" card',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      1,
      'Ignore ${PerkAndMasteryConstants.negative} item ${PerkAndMasteryConstants.effects} and ${PerkAndMasteryConstants.add}L ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "+1 if LIGHT is Strong or Waning" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.thornreaper,
      2,
      'Gain ${PerkAndMasteryConstants.shield} 1 while you occupy hazardous terrain',
      perkIsGrouped: true,
    ),
    // INCARNATE
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} ALL_STANCES ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} PIERCE 2, FIRE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.shield} 1, Self, EARTH" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} PUSH 1, AIR ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "RITUALIST : ENFEEBLE / CONQUEROR : EMPOWER, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "REAVER : RUPTURE / CONQUEROR : EMPOWER, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 "REAVER : RUPTURE / RITUALIST : ENFEEBLE" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "RECOVER ${PerkAndMasteryConstants.one} One_Hand or Two_Hand item" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      'Each time you long rest, perform: ALL_STANCES',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      'You may bring one additional One_Hand item into each scenario',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      'Each time you short rest, RECOVER one spent One_Hand item',
    ),
    legacy.Perk(
      ClassCodes.incarnate,
      1,
      '${PerkAndMasteryConstants.ignoreNegativeItemEffects} and ${PerkAndMasteryConstants.remove}L one -1 ${PerkAndMasteryConstants.card}',
    ),
    // RIMEHEARTH
    legacy.Perk(
      ClassCodes.rimehearth,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} WOUND ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} "HEAL 3, WOUND, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.two} +0 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.two} ${PerkAndMasteryConstants.rolling} FIRE ${PerkAndMasteryConstants.cards}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.three} +1 ${PerkAndMasteryConstants.cards} with ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} +1 card, ${PerkAndMasteryConstants.one} +1 WOUND ${PerkAndMasteryConstants.card}, and ${PerkAndMasteryConstants.one} +1 "HEAL 1, Self" ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +0 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 ICE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +0 CHILL ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} +2 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +3 CHILL ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      2,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +2 FIRE/ICE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      '${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} +0 BRITTLE ${PerkAndMasteryConstants.card}',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      'At the start of each ${PerkAndMasteryConstants.scenario}, you may either gain WOUND to generate FIRE or gain CHILL to generate ICE',
    ),
    legacy.Perk(
      ClassCodes.rimehearth,
      1,
      '${PerkAndMasteryConstants.ignoreNegativeItemEffects} and ${PerkAndMasteryConstants.add} ${PerkAndMasteryConstants.one} ${PerkAndMasteryConstants.rolling} FIRE/ICE ${PerkAndMasteryConstants.card}',
    ),
    // SHARDRENDER
    legacy.Perk(ClassCodes.shardrender, 1, 'Remove one -2 card'),
    legacy.Perk(
      ClassCodes.shardrender,
      2,
      '${PerkAndMasteryConstants.replace} ${PerkAndMasteryConstants.one} -1 ${PerkAndMasteryConstants.card} with ${PerkAndMasteryConstants.one} +1 card',
    ),
    legacy.Perk(
      ClassCodes.shardrender,
      2,
      '${PerkAndMasteryConstants.replace} -1 card with one ${PerkAndMasteryConstants.rolling} "Shield 1, Self" card',
    ),
    legacy.Perk(
      ClassCodes.shardrender,
      2,
      '${PerkAndMasteryConstants.replace} two +0 cards with two +0 "Move one character token on a CRYSTALLIZE back one space" cards',
    ),
    legacy.Perk(
      ClassCodes.shardrender,
      2,
      'Replace one +0 card with one ${PerkAndMasteryConstants.rolling} +1 "+2 instead if the attack has PIERCE" card',
    ),
    legacy.Perk(
      ClassCodes.shardrender,
      1,
      'Add two +1 "+2 instead if you CRYSTALLIZE PERSIST one space" cards',
    ),
    legacy.Perk(ClassCodes.shardrender, 1, 'Add one +0 BRITTLE card'),
    legacy.Perk(
      ClassCodes.shardrender,
      2,
      '${PerkAndMasteryConstants.ignoreNegativeItemEffects} and ${PerkAndMasteryConstants.atTheStartOfEachScenario}, you may play a level 1 card from your hand to perform a CRYSTALLIZE action of the card',
      perkIsGrouped: true,
    ),
    legacy.Perk(
      ClassCodes.shardrender,
      1,
      'Once each scenario, when you would suffer damage from an attack, gain "${PerkAndMasteryConstants.shield} 3" for that attack',
    ),
    legacy.Perk(
      ClassCodes.shardrender,
      1,
      'Each time you long rest, perform "${PerkAndMasteryConstants.regenerate}, Self"',
    ),
    // TEMPEST
    legacy.Perk(
      ClassCodes.tempest,
      1,
      'Replace one -2 card with one -1 AIR/LIGHT card',
    ),
    legacy.Perk(
      ClassCodes.tempest,
      1,
      'Replace one -1 AIR/LIGHT card with one +1 AIR/LIGHT card',
    ),
    legacy.Perk(
      ClassCodes.tempest,
      2,
      'Replace one -1 card with one +0 WOUND card',
    ),
    legacy.Perk(
      ClassCodes.tempest,
      2,
      '${PerkAndMasteryConstants.replace} one -1 card with one ${PerkAndMasteryConstants.rolling} "${PerkAndMasteryConstants.regenerate}, RANGE 1" card',
    ),
    legacy.Perk(
      ClassCodes.tempest,
      1,
      'Replace one +0 card with one +2 MUDDLE card',
    ),
    legacy.Perk(
      ClassCodes.tempest,
      1,
      'Replace two +0 cards with one +1 ${PerkAndMasteryConstants.immobilize} card',
    ),
    legacy.Perk(ClassCodes.tempest, 2, 'Add one +1 "DODGE, Self" card'),
    legacy.Perk(ClassCodes.tempest, 1, 'Add one +2 AIR/LIGHT card'),
    legacy.Perk(
      ClassCodes.tempest,
      1,
      'Whenever you dodge an attack, gain one SPARK',
    ),
    legacy.Perk(
      ClassCodes.tempest,
      2,
      '${PerkAndMasteryConstants.wheneverYouLongRest}, you may gain DODGE',
      perkIsGrouped: true,
    ),
    legacy.Perk(
      ClassCodes.tempest,
      1,
      '${PerkAndMasteryConstants.wheneverYouShortRest}, you may consume_SPARK one Spark. If you do, one enemy within RANGE 2 suffers one damage',
    ),
    // VANQUISHER
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Replace two -1 cards with one +0 MUDDLE card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Replace two -1 cards with one -1 "HEAL 2, Self" card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Replace one -2 card with one -1 POISON WOUND card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      2,
      '${PerkAndMasteryConstants.replace} one +0 card with one +1 "HEAL 1, Self" card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Replace two +0 cards with one +0 CURSE card and one +0 ${PerkAndMasteryConstants.immobilize} card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      2,
      'Replace one +1 card with one +2 FIRE/AIR card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Replace one +2 card with one ${PerkAndMasteryConstants.rolling} "Gain one RAGE" card',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      2,
      'Add one +1 "${PerkAndMasteryConstants.retaliate} 1, Self" card and one ${PerkAndMasteryConstants.rolling} PIERCE 3 card',
    ),
    legacy.Perk(ClassCodes.vanquisher, 1, 'Add one +0 "BLESS, Self" card'),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Add two +1 "+2 instead if you suffer 1 damage" cards',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      'Add one +2 "+3 instead if you suffer 1 damage" cards',
    ),
    legacy.Perk(
      ClassCodes.vanquisher,
      1,
      '${PerkAndMasteryConstants.ignoreNegativeItemEffects} and remove one -1 card',
    ),
    // INCARNATE V2
    // Perk(ClassCodes.incarnate, 1,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} -2 ${PerkMasteryText.card} with ${PerkMasteryText.one} +0 ALL_STANCES ${PerkMasteryText.rolling} ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 1,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} -1 ${PerkMasteryText.card} with ${PerkMasteryText.one} +0 PIERCE 2 FIRE ${PerkMasteryText.rolling} ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 1,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} -1 ${PerkMasteryText.card} with ${PerkMasteryText.one} +0 PUSH 1 AIR ${PerkMasteryText.rolling} ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 1,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} -1 ${PerkMasteryText.card} with ${PerkMasteryText.one} +0 "${PerkMasteryText.shield} 1" EARTH ${PerkMasteryText.rolling} ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 2,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} +0 ${PerkMasteryText.card} with ${PerkMasteryText.one} +1 "REAVER : RUPTURE or RITUALIST : ENFEEBLE" ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 2,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} +0 ${PerkMasteryText.card} with ${PerkMasteryText.one} +1 "REAVER : RUPTURE or CONQUEROR : EMPOWER, self" ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 2,
    //     '${PerkMasteryText.replace} ${PerkMasteryText.one} +0 ${PerkMasteryText.card} with ${PerkMasteryText.one} +1 "RITUALIST : ENFEEBLE or CONQUEROR : EMPOWER, self" ${PerkMasteryText.card}'),
    // Perk(ClassCodes.incarnate, 1,
    //     'Add one +0 "RECOVER one One_Hand or Two_Hand item" ${PerkMasteryText.rolling} card'),
    // Perk(ClassCodes.incarnate, 1,
    //     '${PerkMasteryText.ignoreItemMinusOneEffects} and remove one -1 card'),
    // Perk(ClassCodes.incarnate, 1,
    //     '[Eyes of the Ritualist:] ${PerkMasteryText.wheneverYouLongRest}, perform ALL_STANCES'),
    // Perk(ClassCodes.incarnate, 1,
    //     '[Shoulders of the Conqueror:] You may bring one additional One_Hand item into each scenario'),
    // Perk(ClassCodes.incarnate, 1,
    //     '[Hands of the Reaver:] ${PerkMasteryText.wheneverYouShortRest}, RECOVER one spent One_Hand item'),
  ];
}
