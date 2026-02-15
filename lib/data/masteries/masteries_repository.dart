import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/perk_and_mastery_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

class MasteriesRepository {
  /// Returns mastery definitions with canonical IDs for a given class and variant.
  ///
  /// This is the single source of truth for mastery loading — replaces the
  /// former database query approach.
  static List<Mastery> getMasteriesForCharacter(
    String classCode,
    Variant variant,
  ) {
    final masteriesList = masteriesMap[classCode];
    if (masteriesList == null) return [];

    final result = <Mastery>[];
    for (final masteriesGroup in masteriesList) {
      if (masteriesGroup.variant != variant) continue;

      // Validate that all mastery numbers are unique within this group
      assert(() {
        final numbers = masteriesGroup.masteries.map((m) => m.number).toList();
        final unique = numbers.toSet();
        if (unique.length != numbers.length) {
          final duplicates = numbers.where(
            (n) => numbers.where((m) => m == n).length > 1,
          );
          throw StateError(
            'Duplicate mastery numbers for $classCode/${masteriesGroup.variant.name}: '
            '${duplicates.toSet()}',
          );
        }
        return true;
      }());

      for (final mastery in masteriesGroup.masteries) {
        // Create a copy so each entry gets its own ID
        final masteryCopy = Mastery(
          mastery.number,
          masteryDetails: mastery.masteryDetails,
        );
        masteryCopy.classCode = classCode;
        masteryCopy.variant = masteriesGroup.variant;
        masteryCopy.id = '${classCode}_${variant.name}_${mastery.number}';
        result.add(masteryCopy);
      }
    }
    return result;
  }

  /// Returns canonical mastery IDs for a given class and variant.
  ///
  /// Used when creating CharacterMastery join records for a new character.
  static List<String> getMasteryIds(String classCode, Variant variant) {
    return getMasteriesForCharacter(
      classCode,
      variant,
    ).map((m) => m.id).toList();
  }

  static final Map<String, List<Masteries>> masteriesMap = {
    // BRUTE/BRUISER
    ClassCodes.brute: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Cause enemies to suffer a total of 12 or more ${PerkAndMasteryConstants.retaliate} damage during attacks targeting you in a single round',
        ),
        Mastery(
          1,
          masteryDetails:
              'Across three consecutive rounds, play six different ability cards and cause enemies to suffer at least DAMAGE 6 on each of your turns',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In 3 different scenarios, kill an enemy that you Pushed or Pulled that round',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, across 3 consecutive rounds, play 6 different ability cards and cause enemies to suffer 7 or more damage during each of those rounds',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // TINKERER
    ClassCodes.tinkerer: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Heal an ally or apply a negative condition to an enemy each turn',
        ),
        Mastery(
          1,
          masteryDetails:
              'Perform two actions with lost icons before your first rest and then only rest after having played at least two actions with lost icons since your previous rest',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, during each of your turns, give an enemy a negative condition, give an ally a positive condition, heal an ally, or grant an ally shield',
        ),
        Mastery(1, masteryDetails: 'Perform 11 different LOSS actions'),
      ], variant: Variant.gloomhaven2E),
    ],
    // SPELLWEAVER
    ClassCodes.spellweaver: [
      Masteries([
        Mastery(0, masteryDetails: 'Infuse and consume all six elements'),
        Mastery(
          1,
          masteryDetails: 'Perform four different loss actions twice each',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, consume both ${PerkAndMasteryConstants.fire} and ${PerkAndMasteryConstants.ice} during the same turn 6 times',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, perform 4 different LOSS actions twice each',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SCOUNDREL/SILENT KNIFE
    ClassCodes.scoundrel: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Kill at least six enemies that are adjacent to at least one of your allies',
        ),
        Mastery(
          1,
          masteryDetails:
              'Kill at least six enemies that are adjacent to none of your allies',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, only attack enemies that are adjacent to one of your allies or adjacent to none of their allies, and perform at least 10 attacks',
        ),
        Mastery(
          1,
          masteryDetails: 'End 3 scenarios with 12 or more money tokens',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // CRAGHEART
    ClassCodes.cragheart: [
      Masteries([
        Mastery(
          0,
          masteryDetails: 'Only attack enemies adjacent to obstacles or walls',
        ),
        Mastery(
          1,
          masteryDetails: 'Damage or heal at least one ally each round',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, create, destroy, or move at least one obstacle tile each round',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, heal 8 or more hit points during a single round, deal 8 or more damage with a ranged attack ability, and deal 8 or more damage with a melee attack ability',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // MINDTHIEF
    ClassCodes.mindthief: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Trigger the on-attack effect of four different Augments thrice each',
        ),
        Mastery(1, masteryDetails: 'Never be targeted by an attack'),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, kill 5 or more enemies with control abilities',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, trigger the on-attack effect from four different Augments at least 3 times each',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SUNKEEPER
    ClassCodes.sunkeeper: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Reduce attacks targeting you by a total of 20 or more through Shield effects in a single round',
        ),
        Mastery(
          1,
          masteryDetails: 'LIGHT or consume_LIGHT during each of your turns',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, infuse or consume LIGHT during each of your turns',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, deal 8 or more damage with an attack 3 or more times',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // QUARTERMASTER
    ClassCodes.quartermaster: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Spend, lose, or refresh one or more items on each of your turns without ever performing the top action of *Reinforced Steel*',
        ),
        Mastery(
          1,
          masteryDetails: 'LOOT six or more loot tokens in a single turn',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, spend 50 SUPPLIES to refresh 50 gold of lost items 3 times',
        ),
        Mastery(
          1,
          masteryDetails:
              'For an entire scenario, give yourself or an ally an item from the Quartermaster item Supply each round except when performing a long rest',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SUMMONER/SOULTETHER
    ClassCodes.summoner: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Summon the Lava Golem on your first turn and keep it alive for the entire scenario',
        ),
        Mastery(
          1,
          masteryDetails:
              'Perform the summon action of five different ability cards',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Perform 3 different summon actions before your first rest and keep those cards in your active area for the entire scenario',
        ),
        Mastery(
          1,
          masteryDetails:
              'Perform 6 different summon abilities from your ability cards over the course of the first rounds of 6 scenarios',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // NIGHTSHROUD
    ClassCodes.nightshroud: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Have INVISIBLE at the start or end of each of your turns',
        ),
        Mastery(
          1,
          masteryDetails: 'DARK or consume_DARK during each of your turns',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, infuse or consume DARK during each of your turns',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, perform an attack ability during your turn in 5 consecutive rounds',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // PLAGUEHERALD
    ClassCodes.plagueherald: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Kill at least five enemies with non-attack abilities',
        ),
        Mastery(
          1,
          masteryDetails:
              'Perform three different attack abilities that target at least four enemies each',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single turn, kill 3 or more enemies without drawing an attack modifier card',
        ),
        Mastery(
          1,
          masteryDetails:
              'For an entire scenario, either apply or remove poison from an ally or enemy each round',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // BERSERKER
    ClassCodes.berserker: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Lose at least one hit point during each of your turns, without ever performing the bottom action of *Blood Pact*',
        ),
        Mastery(
          1,
          masteryDetails:
              'Have exactly one hit point at the end of each of your turns',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(0, masteryDetails: 'Kill 20 enemies with retaliate'),
        Mastery(
          1,
          masteryDetails:
              'For an entire scenario, never end your turn with your current hit point value above half your maximum',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SOOTHSINGER
    ClassCodes.soothsinger: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'On your first turn of the scenario and the turn after each of your rests, perform one Song action that you have not yet performed this scenario',
        ),
        Mastery(
          1,
          masteryDetails:
              'Have all 10 monster CURSE cards and all 10 BLESS cards in modifier decks at the same time',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, perform 7 different SONG actions',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, create 20 or more Notes and use each Note you create in a SONG',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // DOOMSTALKER
    ClassCodes.doomstalker: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Never perform a Doom action that you have already performed in the scenario',
        ),
        Mastery(
          1,
          masteryDetails: 'Kill three Doomed enemies during one of your turns',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(0, masteryDetails: 'Kill 20 Doomed enemies'),
        Mastery(
          1,
          masteryDetails:
              'In a single round, you and one of your summons must perform a combined total of 6 or more attack abilities',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SAWBONES
    ClassCodes.sawbones: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'On each of your turns, give an ally an ability card, target an ally with a HEAL ability, grant an ally ${PerkAndMasteryConstants.shield}, or place an ability card in an ally\'s active area',
        ),
        Mastery(
          1,
          masteryDetails:
              'Deal at least DAMAGE 20 with a single attack ability',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, give an ally a medical pack or PRESCRIPTION each round except when performing a long rest',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, never attack an undamaged enemy while there are any damaged monsters alive, and perform at least 10 attacks',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // ELEMENTALIST
    ClassCodes.elementalist: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Consume at least two different elements with each of four different attack abilities without ever performing the bottom action of *Formless Power* or *Shaping the Ether*',
        ),
        Mastery(
          1,
          masteryDetails:
              'Infuse five or more elements during one of your turns, then consume five or more elements during your following turn',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, consume 4 or more elements in a single turn 5 times',
        ),
        Mastery(
          1,
          masteryDetails:
              'Once in 3 different scenarios, have all 6 elements strong or waning at the same time',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // BEAST TYRANT / WILDFURY
    ClassCodes.beastTyrant: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Have your bear summon deal DAMAGE 10 or more in three consecutive rounds',
        ),
        Mastery(
          1,
          masteryDetails:
              'You or your summons must apply a negative condition to at least 10 different enemies',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'In a single scenario, infuse or consume AIR or EARTH during each of your turns',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, kill 4 or more enemies with COMMAND attacks of 7 or greater (after all bonuses, before attack modifiers)',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // BLADESWARM
    ClassCodes.bladeswarm: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Perform two different summon actions on your first turn and keep all summons from those actions alive for the entire scenario',
        ),
        Mastery(
          1,
          masteryDetails:
              'Perform three different non-summon persistent loss actions before your first rest',
        ),
      ], variant: Variant.frosthavenCrossover),
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Perform 6 different PERSISTENT LOSS abilities with no more than 3 of the 6 being summon abilities',
        ),
        Mastery(
          1,
          masteryDetails: 'Gain this mastery when you feel you deserve it',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // DIVINER
    ClassCodes.diviner: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'During one round, have at least four monsters move into four different Rifts that affect those monsters',
        ),
        Mastery(
          1,
          masteryDetails:
              'Reveal at least one card from at least one ability card deck or attack modifier deck each round',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    // Jaws of the Lion
    ClassCodes.demolitionist: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Deal DAMAGE 10 or more with each of three different attack actions',
        ),
        Mastery(
          1,
          masteryDetails:
              'Destroy at least six obstacles. End the scenario with no obstacles on the map other than ones placed by allies',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.hatchet: [
      Masteries([
        Mastery(
          0,
          masteryDetails: 'AIR or consume_AIR during each of your turns',
        ),
        Mastery(
          1,
          masteryDetails:
              'During each round in which there is at least one enemy on the map at the start of your turn, either place one of your tokens on an ability card of yours or on an enemy',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.redGuard: [
      Masteries([
        Mastery(
          0,
          masteryDetails: 'Kill at least five enemies during their turns',
        ),
        Mastery(
          1,
          masteryDetails:
              'Force each enemy in the scenario to move at least one hex, forcing at least six enemies to move',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.voidwarden: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Cause enemies to suffer DAMAGE 20 or more in a single turn with granted or commanded attacks',
        ),
        Mastery(
          1,
          masteryDetails:
              'Give at least one ally or enemy POISON, STRENGTHEN, BLESS, or WARD each round',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    // Frosthaven
    ClassCodes.drifter: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'End a scenario with your character tokens on the last use slots of four persistent abilities',
        ),
        Mastery(
          1,
          masteryDetails:
              'Never perform a move or attack ability with a value less than 4, and perform at least one move or attack ability every round',
        ),
      ]),
    ],
    ClassCodes.blinkBlade: [
      Masteries([
        Mastery(0, masteryDetails: 'Declare Fast seven rounds in a row'),
        Mastery(1, masteryDetails: 'Never be targeted by an attack'),
      ]),
    ],
    ClassCodes.bannerSpear: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Attack at least three targets with three different area of effect attacks',
        ),
        Mastery(
          1,
          masteryDetails:
              'Play a Banner summon ability on your first turn, always have it within RANGE 3 of you, and keep it alive for the entire scenario',
        ),
      ]),
    ],
    ClassCodes.deathwalker: [
      Masteries([
        Mastery(0, masteryDetails: 'Consume seven SHADOW in one round'),
        Mastery(
          1,
          masteryDetails: 'Create or consume at least one SHADOW every round',
        ),
      ]),
    ],
    ClassCodes.boneshaper: [
      Masteries([
        Mastery(0, masteryDetails: 'Kill at least 15 of your summons'),
        Mastery(
          1,
          masteryDetails:
              'Play a summon action on your first turn, have this summon kill at least 6 enemies, and keep it alive for the entire scenario',
        ),
      ]),
    ],
    ClassCodes.geminate: [
      Masteries([
        Mastery(0, masteryDetails: 'Switch forms every round'),
        Mastery(1, masteryDetails: 'Lose at least one card every round'),
      ]),
    ],
    ClassCodes.infuser: [
      Masteries([
        Mastery(0, masteryDetails: 'Have five active INFUSION bonuses'),
        Mastery(
          1,
          masteryDetails: 'Kill at least four enemies, but never attack',
        ),
      ]),
    ],
    ClassCodes.pyroclast: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Create or destroy at least one obstacle or hazardous terrain tile each round',
        ),
        Mastery(
          1,
          masteryDetails:
              'Move enemies through six different hexes of hazardous terrain you created in one turn',
        ),
      ]),
    ],
    ClassCodes.shattersong: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Always have 0 RESONANCE directly before you gain RESONANCE at the end of each of your turns',
        ),
        Mastery(
          1,
          masteryDetails:
              'Spend 5 RESONANCE on each of five different Wave abilities',
        ),
      ]),
    ],
    ClassCodes.trapper: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Have one HEAL trap on the map with a value of at least 20',
        ),
        Mastery(
          1,
          masteryDetails:
              'Move enemies through seven or more traps with one ability',
        ),
      ]),
    ],
    ClassCodes.painConduit: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Cause other figures to suffer a total of at least DAMAGE 40 in one round',
        ),
        Mastery(
          1,
          masteryDetails:
              'Start a turn with WOUND, BRITTLE, BANE, POISON, ${PerkAndMasteryConstants.immobilize}, DISARM, STUN, and MUDDLE',
        ),
      ]),
    ],
    ClassCodes.snowdancer: [
      Masteries([
        Mastery(
          0,
          masteryDetails: 'Cause at least one ally or enemy to move each round',
        ),
        Mastery(
          1,
          masteryDetails:
              'Ensure the first ally to suffer DAMAGE each round, directly before suffering the DAMAGE, has at least one condition you applied',
        ),
      ]),
    ],
    ClassCodes.frozenFist: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'RECOVER at least one card from your discard pile each round',
        ),
        Mastery(
          1,
          masteryDetails:
              'Enter at least ten different hexes with one move ability, then cause one enemy to suffer at least DAMAGE 10 with one attack ability in the same turn',
        ),
      ]),
    ],
    ClassCodes.hive: [
      Masteries([
        Mastery(0, masteryDetails: 'TRANSFER each round'),
        Mastery(
          1,
          masteryDetails: 'TRANSFER into four different summons in one round',
        ),
      ]),
    ],
    ClassCodes.metalMosaic: [
      Masteries([
        Mastery(0, masteryDetails: 'Never attack'),
        Mastery(
          1,
          masteryDetails:
              'For four consecutive rounds, move the pressure gauge up or down three levels from where it started the round (PRESSURE_LOW to PRESSURE_HIGH, or vice versa)',
        ),
      ]),
    ],
    ClassCodes.deepwraith: [
      Masteries([
        Mastery(0, masteryDetails: 'Perform all your attacks with advantage'),
        Mastery(1, masteryDetails: 'Infuse DARK each round'),
      ]),
    ],
    ClassCodes.crashingTide: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Never suffer damage from attacks, and be targeted by at least five attacks',
        ),
        Mastery(
          1,
          masteryDetails:
              'At the start of each of your rests, have more active TIDE than cards in your discard pile',
        ),
      ]),
    ],
    // Mercenary Packs
    ClassCodes.anaphi: [
      Masteries([
        Mastery(
          0,
          masteryDetails: 'Have 3 different summons kill 3 enemies each',
        ),
        Mastery(
          1,
          masteryDetails:
              'In each of 3 scenarios, perform 8 attacks targetting enemies that have negative conditions',
        ),
      ]),
    ],
    ClassCodes.cassandra: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, reveal at least one card from an attack modifier deck or monster ability card deck each round',
        ),
        Mastery(
          1,
          masteryDetails:
              'Target 6 figures with an ability that targets figures occupying hexes containing RIFT',
        ),
      ]),
    ],
    ClassCodes.hail: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, gain at least 1 RESOLVE each round',
        ),
        Mastery(
          1,
          masteryDetails:
              'In a single scenario, across three consecutive rounds, spend at least 3 RESOLVE each round',
        ),
      ]),
    ],
    ClassCodes.satha: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, have at least one ally perform a move or attack ability during each of your turns except when performing a long rest',
        ),
        Mastery(
          1,
          masteryDetails:
              'For an entire scenario, never have an ally be a target of an attack',
        ),
      ]),
    ],
    // Custom
    ClassCodes.vimthreader: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'For an entire scenario, perform a heal ability and cause a figure to suffer DAMAGE each round',
        ),
        Mastery(
          1,
          masteryDetails: 'Gain the attributes of 12 different monster types',
        ),
      ]),
    ],
    ClassCodes.incarnate: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Never end your turn in the same spirit you started in that turn',
        ),
        Mastery(
          1,
          masteryDetails:
              'Perform fifteen attacks using One_Hand or Two_Hand items',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.core: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Kill the last enemy to die in the scenario and finish with nine ability cards in your lost pile.',
        ),
        Mastery(
          1,
          masteryDetails:
              'Trigger an ongoing effect on *Chaotic Recursion* six or more times in one round.',
        ),
      ]),
    ],
    ClassCodes.dome: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Only declare rests while your helper bot is adjacent to a figure, but not adjacent to you.',
        ),
        Mastery(
          1,
          masteryDetails:
              'Never end your turn with 0 or 1 barrier, and absorb (partially or fully) at least 10 attacks with your barrier.',
        ),
      ]),
    ],
    ClassCodes.skitterclaw: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Have at least one Latched summon on four different enemies',
        ),
        Mastery(
          1,
          masteryDetails:
              'Have your summons perform twelve attacks in one round',
        ),
      ]),
    ],
    ClassCodes.alchemancer: [
      Masteries([
        Mastery(
          0,
          masteryDetails:
              'Activate 12 EXPERIMENT abilities with at least two Vial_Wild used for bonuses during a single scenario',
        ),
        Mastery(
          1,
          masteryDetails:
              'Consume six elements in one turn twice during a single scenario',
        ),
      ]),
    ],
  };
}
