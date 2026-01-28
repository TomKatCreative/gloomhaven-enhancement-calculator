import 'package:gloomhaven_enhancement_calc/data/perks/perk_text_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

// Use a shorter alias for the constants class
typedef P = PerkTextConstants;

/// Perk definitions for Custom (user-created) classes.
///
/// These are community-created classes not part of official expansions.
class CustomPerks {
  static final Map<String, List<Perks>> perks = {
    ClassCodes.vimthreader: [
      Perks([
        Perk(
          '${P.replace} ${P.one} -2 ${P.card} with ${P.one} -1 "If the target has an attribute, ${P.addLowercase} ${P.wound}, ${P.poison}, ${P.muddle}" ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 ${P.enfeeble} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 "${P.empower}, ${P.range} 2" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.heal} 1, ${P.targetDiamond} 1 ally" ${P.card}',
          quantity: 3,
        ),
        Perk('${P.replace} ${P.one} +2 ${P.card} with ${P.four} +1 ${P.rolling} ${P.cards}'),
        Perk('${P.add} ${P.two} ${P.pierce} 2 ${P.poison} ${P.rolling} ${P.cards}'),
        Perk(
          '${P.add} ${P.three} "${P.heal} 1, ${P.range} 1" ${P.rolling} ${P.cards}',
          quantity: 2,
        ),
        Perk('${P.ignoreScenarioEffectsAndRemove} ${P.one} +0 ${P.card}'),
        Perk('${P.ignoreItemMinusOneEffectsAndRemove} ${P.one} +0 ${P.card}'),
        Perk(
          '${P.wheneverYouShortRest}, ${P.one} adjacent enemy suffers ${P.damage} 1, and you perform "${P.heal} 1, self"',
        ),
        Perk(
          '${P.atTheStartOfEachScenario}, you may suffer ${P.damage} 1 to grant all allies and self ${P.move} 3',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'Once each ${P.scenario}, ${P.removeLowercase} all ${P.negative} conditions you have. One adjacent enemy suffers ${P.damage} equal to the number of conditions removed',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.core: [
      Perks([
        Perk('${P.replace} ${P.one} -2 ${P.card} with ${P.one} +0 ${P.card}'),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +1 ${P.wound}, "${P.wound}, self" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +1 ${P.poison}, "${P.poison}, self" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 ${P.immobilize} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.one} +0 "Add ${P.plusOne} ${P.attack} for each condition you have" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.two} "${P.heal} 1, ${P.range} 1" ${P.rolling} ${P.cards}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.one} "${P.ward}, ${P.regenerate}, self" ${P.rolling} ${P.card}',
          quantity: 2,
        ),
        Perk('${P.add} ${P.one} -2 ${P.brittle} and one +3 "${P.brittle}, self" ${P.card}'),
        Perk('${P.ignoreItemMinusOneEffectsAndRemove} ${P.one} +0 ${P.card}'),
        Perk(
          '${P.atTheStartOfEachScenario}, you may perform "${P.strengthen}, ${P.wound}, self" or "${P.ward}, ${P.immobilize}, self"',
        ),
        Perk('Once each ${P.scenario}, avoid an Overdrive exhaustion check'),
        Perk(
          'Once each ${P.scenario}, during your turn, ${P.removeLowercase} any number of ${P.negative} conditions you have',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.brewmaster: [
      Perks([
        Perk('${P.replace} ${P.one} -2 ${P.card} with ${P.one} -1 ${P.stun} ${P.card}'),
        Perk('${P.replace} ${P.one} -1 ${P.card} with ${P.one} +1 ${P.card}', quantity: 2),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.two} ${P.rolling} ${P.muddle} ${P.cards}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.two} +0 ${P.cards} with ${P.two} +0 "${P.heal} 1, Self" ${P.cards}',
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +0 "Give yourself or an adjacent Ally a \'Liquid Rage\' item ${P.card}" ${P.card}',
          quantity: 2,
        ),
        Perk('${P.add} ${P.one} +2 PROVOKE ${P.card}', quantity: 2),
        Perk('${P.add} four ${P.rolling} Shrug_Off 1 ${P.cards}', quantity: 2),
        Perk('${P.ignoreNegativeScenarioEffectsAndAdd} ${P.one} +1 ${P.card}'),
        Perk('Each time you long rest, perform Shrug_Off 1', quantity: 2),
      ], variant: Variant.base),
    ],
    ClassCodes.frostborn: [
      Perks([
        Perk('${P.remove} ${P.two} -1 ${P.cards}', quantity: 2),
        Perk('${P.replace} ${P.one} -2 ${P.card} with ${P.one} +0 CHILL ${P.card}'),
        Perk(
          '${P.replace} ${P.two} +0 ${P.cards} with ${P.two} +1 ${P.push} 1 ${P.cards}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 ${P.ice} CHILL ${P.card}',
          quantity: 2,
        ),
        Perk('${P.replace} ${P.one} +1 ${P.card} with ${P.one} +3 ${P.card}'),
        Perk('${P.add} ${P.one} +0 ${P.stun} ${P.card}'),
        Perk('${P.add} ${P.one} ${P.rolling} ADD ${P.targetDiamond} ${P.card}', quantity: 2),
        Perk('${P.add} ${P.three} ${P.rolling} CHILL ${P.cards}'),
        Perk('${P.add} ${P.three} ${P.rolling} ${P.push} 1 ${P.cards}'),
        Perk('Ignore difficult and hazardous terrain during move actions'),
        Perk(P.ignoreScenarioEffects),
      ], variant: Variant.base),
    ],
    ClassCodes.rootwhisperer: [
      Perks([
        Perk('${P.remove} ${P.two} -1 ${P.cards}', quantity: 2),
        Perk('${P.remove} four +0 ${P.cards}'),
        Perk('${P.replace} ${P.one} +0 ${P.card} with ${P.one} +2 ${P.card}', quantity: 2),
        Perk('${P.add} ${P.one} ${P.rolling} +2 ${P.card}', quantity: 2),
        Perk('${P.add} ${P.one} +1 ${P.immobilize} ${P.card}', quantity: 2),
        Perk('${P.add} ${P.two} ${P.rolling} ${P.poison} ${P.cards}', quantity: 2),
        Perk('${P.add} ${P.one} ${P.rolling} ${P.disarm} ${P.card}'),
        Perk('${P.add} ${P.one} ${P.rolling} ${P.heal} 2 ${P.earth} ${P.card}', quantity: 2),
        Perk(P.ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
    ],
    ClassCodes.incarnate: [
      Perks([
        Perk(
          '${P.replace} ${P.one} -2 ${P.card} with ${P.one} ${P.rolling} ALL_STANCES ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} ${P.rolling} ${P.pierce} 2, ${P.fire} ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} ${P.rolling} "${P.shield} 1, Self, ${P.earth}" ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} ${P.rolling} ${P.push} 1, ${P.air} ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.ritualist} : ${P.enfeeble} / ${P.conqueror} : ${P.empower}, Self" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.reaver} : ${P.rupture} / ${P.conqueror} : ${P.empower}, Self" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.reaver} : ${P.rupture} / ${P.ritualist} : ${P.enfeeble}" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.one} ${P.rolling} "${P.recover} ${P.one} ${P.oneHand} or ${P.twoHand} item" ${P.card}',
        ),
        Perk('Each time you long rest, perform: ALL_STANCES'),
        Perk(
          'You may bring one additional ${P.oneHand} item into each ${P.scenario}',
        ),
        Perk('Each time you short rest, ${P.recover} one spent ${P.oneHand} item'),
        Perk('${P.ignoreNegativeItemEffectsAndRemove} one -1 ${P.card}'),
      ], variant: Variant.base),
      Perks([
        Perk(
          '${P.replace} ${P.one} -2 ${P.card} with ${P.one} +0 ${P.reaver} ${P.ritualist} ${P.conqueror} ${P.rolling} ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 ${P.pierce} 2 ${P.fire} ${P.rolling} ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 ${P.push} 1 ${P.air} ${P.rolling} ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 "${P.shield} 1" ${P.earth} ${P.rolling} ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.reaver} : ${P.rupture} or ${P.ritualist} : ${P.enfeeble}" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.reaver} : ${P.rupture} or ${P.conqueror} : ${P.empower}, self" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.ritualist} : ${P.enfeeble} or ${P.conqueror} : ${P.empower}, self" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.one} +0 "${P.recover} one ${P.oneHand} or ${P.twoHand} item" ${P.rolling} ${P.card}',
        ),
        Perk('${P.ignoreItemMinusOneEffectsAndRemove} ${P.one} -1 ${P.card}'),
        Perk(
          '**Eyes of the Ritualist:** ${P.wheneverYouLongRest}, perform ${P.reaver} ${P.ritualist} ${P.conqueror}',
        ),
        Perk(
          '**Hands of the Reaver:** ${P.wheneverYouShortRest}, ${P.recover} one spent ${P.oneHand} item',
        ),
        Perk(
          '**Shoulders of the Conqueror:** You may bring one additional ${P.oneHand} item into each ${P.scenario}',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.rimehearth: [
      Perks([
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} ${P.rolling} ${P.wound} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} ${P.rolling} "${P.heal} 3, ${P.wound}, Self" ${P.card}',
        ),
        Perk('${P.replace} ${P.two} +0 ${P.cards} with ${P.two} ${P.rolling} ${P.fire} ${P.cards}'),
        Perk(
          '${P.replace} ${P.three} +1 ${P.cards} with ${P.one} ${P.rolling} +1 card, ${P.one} +1 ${P.wound} ${P.card}, and ${P.one} +1 "${P.heal} 1, Self" ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 ${P.ice} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 CHILL ${P.card}',
          quantity: 2,
        ),
        Perk('${P.replace} ${P.one} +2 ${P.card} with ${P.one} +3 CHILL ${P.card}'),
        Perk('${P.add} ${P.one} +2 ${P.fire}/${P.ice} ${P.card}', quantity: 2),
        Perk('${P.add} ${P.one} +0 ${P.brittle} ${P.card}'),
        Perk(
          'At the start of each ${P.scenario}, you may either gain ${P.wound} to generate ${P.fire} or gain CHILL to generate ${P.ice}',
        ),
        Perk(
          '${P.ignoreNegativeItemEffectsAndAdd} ${P.one} ${P.rolling} ${P.fire}/${P.ice} ${P.card}',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.shardrender: [
      Perks([
        Perk('Remove one -2 card'),
        Perk('${P.replace} ${P.one} -1 ${P.card} with ${P.one} +1 card', quantity: 2),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} ${P.rolling} "${P.shield} 1, Self" card',
          quantity: 2,
        ),
        Perk(
          '${P.replace} two +0 cards with two +0 "Move one character token on a CRYSTALLIZE back one space" cards',
          quantity: 2,
        ),
        Perk(
          'Replace one +0 card with one ${P.rolling} +1 "+2 instead if the attack has ${P.pierce}" card',
          quantity: 2,
        ),
        Perk(
          'Add two +1 "+2 instead if you CRYSTALLIZE PERSIST one space" cards',
        ),
        Perk('Add one +0 ${P.brittle} card'),
        Perk(
          '${P.ignoreNegativeItemEffects} and at the start of each scenario, you may play a level 1 card from your hand to perform a CRYSTALLIZE action of the card',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '${P.onceEachScenario}, when you would suffer damage from an attack, gain "${P.shield} 3" for that attack',
        ),
        Perk('Each time you long rest, perform "${P.regenerate}, Self"'),
      ], variant: Variant.base),
    ],
    ClassCodes.tempest: [
      Perks([
        Perk('Replace one -2 card with one -1 ${P.air}/${P.light} card'),
        Perk(
          'Replace one -1 ${P.air}/${P.light} card with one +1 ${P.air}/${P.light} card',
        ),
        Perk('Replace one -1 card with one +0 ${P.wound} card', quantity: 2),
        Perk(
          '${P.replace} one -1 card with one ${P.rolling} "${P.regenerate}, ${P.range} 1" card',
          quantity: 2,
        ),
        Perk('Replace one +0 card with one +2 ${P.muddle} card'),
        Perk('Replace two +0 cards with one +1 ${P.immobilize} card'),
        Perk('Add one +1 "DODGE, Self" card', quantity: 2),
        Perk('Add one +2 ${P.air}/${P.light} card'),
        Perk('Whenever you dodge an attack, gain one SPARK'),
        Perk(
          '${P.wheneverYouLongRest}, you may gain DODGE',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '${P.wheneverYouShortRest}, you may ${P.consume}SPARK one Spark. If you do, one enemy within ${P.range} 2 suffers one damage',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.dome: [
      Perks([
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 ${P.strengthen} ${P.targetCircle} 1 ally ${P.rolling} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 "Grant the ally with ${P.project} : ${P.attack} 2" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +0 "Place this card in your active area. On your next attack granting ability, discard this card to add ${P.plusTwo} ${P.attack}" ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.two} +0 ${P.cards} with ${P.two} +0 ${P.pierce} 3 ${P.rolling} ${P.cards}',
        ),
        Perk('${P.add} ${P.three} ${P.barrierPlus} 1 ${P.rolling} ${P.cards}', quantity: 2),
        Perk('${P.add} ${P.one} +2 ${P.light} ${P.card}', quantity: 2),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "${P.regenerate}, self" ${P.rolling} ${P.card}',
          quantity: 2,
        ),
        Perk(
          'Your summons gain ${P.retaliate} 1. Whenever one of your summons dies, perform: ${P.barrierPlus} 3',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'At the end of each of your rests, perform: ${P.barrierPlus} 1 and ${P.project} ${P.range} 4',
        ),
        Perk(
          '${P.onceEachScenario}, at the end of an ally\'s turn, perform: ${P.barrierPlus} 5 and ${P.project}, ${P.targetCircle} that ally',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.skitterclaw: [
      Perks([
        Perk('${P.replace} ${P.one} -2 ${P.card} with ${P.one} +0 ${P.card}'),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 ${P.immobilize} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 "After the attack ability, grant one of your summons: ${P.move} 2" ${P.card}',
          quantity: 3,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 "If the target is Latched, +2 instead" ${P.card}',
          quantity: 2,
        ),
        Perk('${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 ${P.poison} ${P.card}'),
        Perk(
          '${P.add} ${P.two} "${P.heal} 1, ${P.targetCircle} 1 ally." ${P.rolling} ${P.cards}',
        ),
        Perk(
          '${P.add} ${P.one} +1 "All Latched enemies suffer ${P.damage} 1" ${P.card}',
          quantity: 2,
        ),
        Perk('${P.ignoreScenarioEffectsAndAdd} ${P.one} +1 ${P.card}'),
        Perk('You may summon ${P.critters} summons in adjacent occupied hexes'),
        Perk(
          '${P.oncePerScenario}, when you or an ally would suffer ${P.damage} from an attack, ${P.removeLowercase} a Latched summon from the attacker or the target to negate the damage instead',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '${P.atTheStartOfEachScenario}, you may play a card from your hand to perform a summon action of the card',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.alchemancer: [
      Perks([
        Perk(
          '${P.replace} ${P.one} -2 ${P.card} with ${P.one} -1 "${P.consume}${P.wildElement}: ${P.plusTwo} ${P.attack}" ${P.card}',
        ),
        Perk(
          '${P.replace} ${P.one} -1 ${P.card} with ${P.one} +0 ${P.wildElement} ${P.card}',
          quantity: 3,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +0 "Add a ${P.vialWild} to an active ${P.experiment}" ${P.card}',
          quantity: 3,
        ),
        Perk(
          '${P.replace} ${P.one} +0 ${P.card} with ${P.one} +1 ${P.immobilize} ${P.card}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.two} +1 "If you drew this as part of a ${P.experiment} ability, +2 instead" ${P.cards}',
          quantity: 2,
        ),
        Perk(
          '${P.add} ${P.one} ${P.fire}/${P.ice} ${P.rolling} ${P.card}, ${P.one} ${P.fire}/${P.earth} ${P.rolling} ${P.card}, and ${P.one} ${P.ice}/${P.earth} ${P.rolling} ${P.card}',
          quantity: 2,
        ),
        Perk('${P.ignoreScenarioEffectsAndRemove} ${P.one} +0 ${P.card}'),
        Perk(
          'Whenever you rest, you may ${P.consume}${P.wildElement} : ${P.wildElement}',
        ),
        Perk(
          'Whenever you consume a potion ${P.pocket}, you may place ${P.one} ${P.vialWild} on an active ${P.experiment}',
        ),
        Perk(
          'At the end of each of your turns during which you performed no attacks and you are not performing a long rest, ${P.fire}/${P.ice}/${P.earth}',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],
  };

  // Private constructor to prevent instantiation
  const CustomPerks._();
}
