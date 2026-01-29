import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Perk definitions for Jaws of the Lion classes.
///
/// Includes: Demolitionist, Hatchet, Red Guard, Voidwarden
class JawsOfTheLionPerks {
  // Action verbs
  static const _add = 'Add';
  static const _remove = 'Remove';
  static const _replace = 'Replace';

  // Numbers
  static const _one = 'one';
  static const _two = 'two';
  static const _four = 'four';

  // Card-related terms
  static const _card = 'card';
  static const _cards = 'cards';

  // Effects and conditions
  static const _damage = 'DAMAGE';
  static const _immobilize = 'IMMOBILIZE';
  static const _shield = 'SHIELD';
  static const _ward = 'WARD';
  static const _push = 'PUSH';
  static const _targetCircle = 'TARGET_CIRCLE';
  static const _stun = 'STUN';
  static const _muddle = 'MUDDLE';
  static const _wound = 'WOUND';
  static const _heal = 'HEAL';
  static const _curse = 'CURSE';
  static const _poison = 'POISON';

  static const _range = 'RANGE';

  // Elements
  static const _fire = 'FIRE';
  static const _light = 'LIGHT';
  static const _dark = 'DARK';
  static const _earth = 'EARTH';
  static const _air = 'AIR';
  static const _ice = 'ICE';
  static const _consume = 'consume_';

  // Scenario and Item related
  static const _ignoreItemMinusOneEffectsAndAdd =
      'Ignore item item_minus_one effects and add';
  static const _ignoreScenarioEffects = 'Ignore scenario effects';
  static const _ignoreScenarioEffectsAndRemove =
      'Ignore scenario effects and remove';
  static const _onceEachScenario = 'Once each scenario';

  static final Map<String, List<Perks>> perks = {
    ClassCodes.demolitionist: [
      Perks([
        Perk('$_remove four +0 $_cards'),
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card and $_one +1 $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 $_muddle $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one -1 $_card with $_one +0 $_poison $_card'),
        Perk('$_add $_one +2 $_card', quantity: 2),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_earth $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one +0 "All adjacent enemies suffer 1 $_damage" $_card',
          quantity: 2,
        ),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_four +0 $_cards'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_poison $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 $_muddle $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +1 $_card with $_two +2 $_cards'),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_earth $_card',
          quantity: 2,
        ),
        Perk('$_add $_two +0 "All adjacent enemies suffer $_damage 1" $_cards'),
        Perk('$_ignoreScenarioEffectsAndRemove $_one -1 $_card'),
        Perk(
          '**Remodeling:** Whenever you rest while adjacent to a wall or obstacle, you may place an obstacle in an empty hex within $_range 2 (of you)',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.hatchet: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_replace $_one +0 $_card with $_one +2 $_muddle $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_push 2 $_card'),
        Perk('$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk('$_replace $_one +1 $_card with $_one +1 $_stun $_card'),
        Perk('$_add $_one +2 $_air $_card', quantity: 3),
        Perk('$_replace $_one +1 $_card with $_one +3 $_card', quantity: 3),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk('$_replace $_one +1 $_card with $_one +1 $_stun $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_muddle $_card'),
        Perk('$_replace $_one +1 $_card with $_one +3 $_card', quantity: 3),
        Perk('$_add $_one +2 $_air $_card', quantity: 3),
        Perk(
          '**Hasty Pick-up:** $_onceEachScenario, during your turn, if the Favourite is in a hex on the map, you may $_consume$_air to return it to its ability card',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.redGuard: [
      Perks([
        Perk('$_remove four +0 $_cards'),
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_remove $_one -2 $_card and $_one +1 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_light $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_fire&$_light $_card', quantity: 2),
        Perk('$_add $_one +1 $_shield 1 $_card', quantity: 2),
        Perk('$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk(
          '$_replace $_one +0 $_card and $_one +1 $_card with $_two +1 "$_shield 1" $_cards',
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_light $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_fire/$_light $_card', quantity: 2),
        Perk('$_ignoreItemMinusOneEffectsAndAdd $_two +1 $_cards'),
        Perk(
          '**Brilliant Aegis:** Whenever you are attacked, you may $_consume$_light to gain $_shield 1 for the attack and have the attacker gain disadvantage for the attack',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.voidwarden: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_dark $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_ice $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, Ally" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 "$_heal 1, Ally" $_card', quantity: 3),
        Perk('$_add $_one +1 $_poison $_card'),
        Perk('$_add $_one +3 $_card'),
        Perk('$_add $_one +1 $_curse $_card', quantity: 2),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, $_targetCircle 1 ally" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_heal 1, $_targetCircle 1 ally" $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_curse $_card',
          quantity: 2,
        ),
        Perk('$_add $_two +1 $_ice $_cards'),
        Perk('$_add $_two +1 $_dark $_cards'),
        Perk('$_add $_one +3 $_card'),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Grave Defense:** Whenever you rest, you may $_consume$_ice/$_dark to give $_ward to one ally who has $_poison',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
  };
}
