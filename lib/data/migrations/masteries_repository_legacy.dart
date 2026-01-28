import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/legacy_mastery.dart'
    as legacy;

class MasteriesRepositoryLegacy {
  static final List<legacy.Mastery> masteries = [
    // GLOOMHAVEN
    legacy.Mastery(
      masteryClassCode: ClassCodes.brute,
      masteryDetails:
          'Cause enemies to suffer a total of 12 or more RETALIATE damage during attacks targeting you in a single round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.brute,
      masteryDetails:
          'Across three consecutive rounds, play six different ability cards and cause enemies to suffer at least DAMAGE 6 on each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.tinkerer,
      masteryDetails:
          'Heal an ally or apply a negative condition to an enemy each turn',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.tinkerer,
      masteryDetails:
          'Perform two actions with lost icons before your first rest and then only rest after having played at least two actions with lost icons since your previous rest',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.spellweaver,
      masteryDetails: 'Infuse and consume all six elements',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.spellweaver,
      masteryDetails: 'Perform four different loss actions twice each',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.scoundrel,
      masteryDetails:
          'Kill at least six enemies that are adjacent to at least one of your allies',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.scoundrel,
      masteryDetails:
          'Kill at least six enemies that are adjacent to none of your allies',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.cragheart,
      masteryDetails: 'Only attack enemies adjacent to obstacles or walls',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.cragheart,
      masteryDetails: 'Damage or heal at least one ally each round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.mindthief,
      masteryDetails:
          'Trigger the on-attack effect of four different Augments thrice each',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.mindthief,
      masteryDetails: 'Never be targeted by an attack',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.sunkeeper,
      masteryDetails:
          'Reduce attacks targeting you by a total of 20 or more through Shield effects in a single round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.sunkeeper,
      masteryDetails: 'LIGHT or consume_LIGHT during each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.quartermaster,
      masteryDetails:
          "Spend, lose, or refresh one or more items on each of your turns without ever performing the top action of ~Reinforced ~Steel",
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.quartermaster,
      masteryDetails: 'LOOT six or more loot tokens in a single turn',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.summoner,
      masteryDetails:
          'Summon the Lava Golem on your first turn and keep it alive for the entire scenario',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.summoner,
      masteryDetails:
          'Perform the summon action of five different ability cards',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.nightshroud,
      masteryDetails:
          'Have INVISIBLE at the start or end of each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.nightshroud,
      masteryDetails: 'DARK or consume_DARK during each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.plagueherald,
      masteryDetails: 'Kill at least five enemies with non-attack abilities',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.plagueherald,
      masteryDetails:
          'Perform three different attack abilities that target at least four enemies each',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.berserker,
      masteryDetails:
          "Lose at least one hit point during each of your turns, without ever performing the bottom action of ~Blood ~Pact",
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.berserker,
      masteryDetails:
          'Have exactly one hit point at the end of each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.soothsinger,
      masteryDetails:
          'On your first turn of the scenario and the turn after each of your rests, perform one Song action that you have not yet performed this scenario',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.soothsinger,
      masteryDetails:
          'Have all 10 monster CURSE cards and all 10 BLESS cards in modifier decks at the same time',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.doomstalker,
      masteryDetails:
          'Never perform a Doom action that you have already performed in the scenario',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.doomstalker,
      masteryDetails: 'Kill three Doomed enemies during one of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.sawbones,
      masteryDetails:
          "On each of your turns, give an ally an ability card, target an ally with a HEAL ability, grant an ally SHIELD, or place an ability card in an ally's active area",
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.sawbones,
      masteryDetails: 'Deal at least DAMAGE 20 with a single attack ability',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.elementalist,
      masteryDetails:
          "Consume at least two different elements with each of four different attack abilities without ever performing the bottom action of ~Formless ~Power or ~Shaping ~the ~Ether",
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.elementalist,
      masteryDetails:
          'Infuse five or more elements during one of your turns, then consume five or more elements during your following turn',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.beastTyrant,
      masteryDetails:
          'Have your bear summon deal DAMAGE 10 or more in three consecutive rounds',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.beastTyrant,
      masteryDetails:
          'You or your summons must apply a negative condition to at least 10 different enemies',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.bladeswarm,
      masteryDetails:
          'Perform two different summon actions on your first turn and keep all summons from those actions alive for the entire scenario',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.bladeswarm,
      masteryDetails:
          'Perform three different non-summon persistent loss actions before your first rest',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.diviner,
      masteryDetails:
          'During one round, have at least four monsters move into four different Rifts that affect those monsters',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.diviner,
      masteryDetails:
          'Reveal at least one card from at least one ability card deck or attack modifier deck each round',
    ),
    // JAWS OF THE LION
    legacy.Mastery(
      masteryClassCode: ClassCodes.demolitionist,
      masteryDetails:
          'Deal DAMAGE 10 or more with each of three different attack actions',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.demolitionist,
      masteryDetails:
          'Destroy at least six obstacles. End the scenario with no obstacles on the map other than ones placed by allies',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.hatchet,
      masteryDetails: 'AIR or consume_AIR during each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.hatchet,
      masteryDetails:
          'During each round in which there is at least one enemy on the map at the start of your turn, either place one of your tokens on an ability card of yours or on an enemy',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.redGuard,
      masteryDetails: 'Kill at least five enemies during their turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.redGuard,
      masteryDetails:
          'Force each enemy in the scenario to move at least one hex, forcing at least six enemies to move',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.voidwarden,
      masteryDetails:
          'Cause enemies to suffer DAMAGE 20 or more in a single turn with granted or commanded attacks',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.voidwarden,
      masteryDetails:
          'Give at least one ally or enemy POISON, STRENGTHEN, BLESS, or WARD each round',
    ),
    // FROSTHAVEN
    legacy.Mastery(
      masteryClassCode: ClassCodes.drifter,
      masteryDetails:
          'End a scenario with your character tokens on the last use slots of four persistent abilities',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.drifter,
      masteryDetails:
          'Never perform a move or attack ability with a value less than 4, and perform at least one move or attack ability every round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.blinkBlade,
      masteryDetails: 'Declare Fast seven rounds in a row',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.blinkBlade,
      masteryDetails: 'Never be targeted by an attack',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.bannerSpear,
      masteryDetails:
          'Attack at least three targets with three different area of effect attacks',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.bannerSpear,
      masteryDetails:
          'Play a Banner summon ability on your first turn, always have it within RANGE 3 of you, and keep it alive for the entire scenario',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.deathwalker,
      masteryDetails: 'Consume seven SHADOW in one round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.deathwalker,
      masteryDetails: 'Create or consume at least one SHADOW every round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.boneshaper,
      masteryDetails: 'Kill at least 15 of your summons',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.boneshaper,
      masteryDetails:
          'Play a summon action on your first turn, have this summon kill at least 6 enemies, and keep it alive for the entire scenario',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.geminate,
      masteryDetails: 'Switch forms every round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.geminate,
      masteryDetails: 'Lose at least one card every round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.infuser,
      masteryDetails: 'Have five active INFUSION bonuses',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.infuser,
      masteryDetails: 'Kill at least four enemies, but never attack',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.pyroclast,
      masteryDetails:
          'Create or destroy at least one obstacle or hazardous terrain tile each round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.pyroclast,
      masteryDetails:
          'Move enemies through six different hexes of hazardous terrain you created in one turn',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.shattersong,
      masteryDetails:
          'Always have 0 RESONANCE directly before you gain RESONANCE at the end of each of your turns',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.shattersong,
      masteryDetails:
          'Spend 5 RESONANCE on each of five different Wave abilities',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.trapper,
      masteryDetails:
          'Have one HEAL trap on the map with a value of at least 20',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.trapper,
      masteryDetails:
          'Move enemies through seven or more traps with one ability',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.painConduit,
      masteryDetails:
          'Cause other figures to suffer a total of at least DAMAGE 40 in one round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.painConduit,
      masteryDetails:
          'Start a turn with WOUND, BRITTLE, BANE, POISON, IMMOBILIZE, DISARM, STUN, and MUDDLE',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.snowdancer,
      masteryDetails: 'Cause at least one ally or enemy to move each round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.snowdancer,
      masteryDetails:
          'Ensure the first ally to suffer DAMAGE each round, directly before suffering the DAMAGE, has at least one condition you applied',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.frozenFist,
      masteryDetails:
          'RECOVER at least one card from your discard pile each round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.frozenFist,
      masteryDetails:
          'Enter at least ten different hexes with one move ability, then cause one enemy to suffer at least DAMAGE 10 with one attack ability in the same turn',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.hive,
      masteryDetails: 'TRANSFER each round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.hive,
      masteryDetails: 'TRANSFER into four different summons in one round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.metalMosaic,
      masteryDetails: 'Never attack',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.metalMosaic,
      masteryDetails:
          'For four consecutive rounds, move the pressure gauge up or down three levels from where it started the round (PRESSURE_LOW to PRESSURE_HIGH, or vice versa)',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.deepwraith,
      masteryDetails: 'Perform all your attacks with advantage',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.deepwraith,
      masteryDetails: 'Infuse DARK each round',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.crashingTide,
      masteryDetails:
          'Never suffer damage from attacks, and be targeted by at least five attacks',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.crashingTide,
      masteryDetails:
          'At the start of each of your rests, have more active TIDE than cards in your discard pile',
    ),
    // CUSTOM
    legacy.Mastery(
      masteryClassCode: ClassCodes.incarnate,
      masteryDetails:
          'Never end your turn with the same spirit you started in that turn',
    ),
    legacy.Mastery(
      masteryClassCode: ClassCodes.incarnate,
      masteryDetails:
          'Perform fifteen attacks using One_Hand or Two_Hand items',
    ),
  ];
}
