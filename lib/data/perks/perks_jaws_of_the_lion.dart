import 'package:gloomhaven_enhancement_calc/data/perks/perk_text_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Perk definitions for Jaws of the Lion classes.
///
/// Includes: Demolitionist, Hatchet, Red Guard, Voidwarden
class JawsOfTheLionPerks {
  // Short aliases for PerkTextConstants to keep perk definitions readable
  static const _add = PerkTextConstants.add;
  static const _remove = PerkTextConstants.remove;
  static const _replace = PerkTextConstants.replace;
  static const _one = PerkTextConstants.one;
  static const _two = PerkTextConstants.two;
  static const _four = PerkTextConstants.four;
  static const _card = PerkTextConstants.card;
  static const _cards = PerkTextConstants.cards;
  static const _damage = PerkTextConstants.damage;
  static const _immobilize = PerkTextConstants.immobilize;
  static const _shield = PerkTextConstants.shield;
  static const _ward = PerkTextConstants.ward;
  static const _push = PerkTextConstants.push;
  static const _targetCircle = PerkTextConstants.targetCircle;
  static const _stun = PerkTextConstants.stun;
  static const _muddle = PerkTextConstants.muddle;
  static const _wound = PerkTextConstants.wound;
  static const _heal = PerkTextConstants.heal;
  static const _curse = PerkTextConstants.curse;
  static const _poison = PerkTextConstants.poison;
  static const _range = PerkTextConstants.range;
  static const _fire = PerkTextConstants.fire;
  static const _light = PerkTextConstants.light;
  static const _dark = PerkTextConstants.dark;
  static const _earth = PerkTextConstants.earth;
  static const _air = PerkTextConstants.air;
  static const _ice = PerkTextConstants.ice;
  static const _consume = PerkTextConstants.consume;
  static const _ignoreItemMinusOneEffectsAndAdd =
      PerkTextConstants.ignoreItemMinusOneEffectsAndAdd;
  static const _ignoreScenarioEffects = PerkTextConstants.ignoreScenarioEffects;
  static const _ignoreScenarioEffectsAndRemove =
      PerkTextConstants.ignoreScenarioEffectsAndRemove;
  static const _onceEachScenario = PerkTextConstants.onceEachScenario;

  static final Map<String, List<Perks>> perks = {
    ClassCodes.demolitionist: [
      Perks([
        Perk(1, '$_remove four +0 $_cards'),
        Perk(2, '$_remove $_two -1 $_cards', quantity: 2),
        Perk(3, '$_remove $_one -2 $_card and $_one +1 $_card'),
        Perk(
          4,
          '$_replace $_one +0 $_card with $_one +2 $_muddle $_card',
          quantity: 2,
        ),
        Perk(5, '$_replace $_one -1 $_card with $_one +0 $_poison $_card'),
        Perk(6, '$_add $_one +2 $_card', quantity: 2),
        Perk(
          7,
          '$_replace $_one +1 $_card with $_one +2 $_earth $_card',
          quantity: 2,
        ),
        Perk(
          8,
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          9,
          '$_add $_one +0 "All adjacent enemies suffer 1 $_damage" $_card',
          quantity: 2,
        ),
      ], variant: Variant.base),
      Perks([
        Perk(1, '$_remove $_two -1 $_cards', quantity: 2),
        Perk(2, '$_remove $_four +0 $_cards'),
        Perk(3, '$_replace $_one -2 $_card with $_one +0 $_poison $_card'),
        Perk(
          4,
          '$_replace $_one +0 $_card with $_one +2 $_muddle $_card',
          quantity: 2,
        ),
        Perk(5, '$_replace $_one +1 $_card with $_two +2 $_cards'),
        Perk(
          6,
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          7,
          '$_replace $_one +1 $_card with $_one +2 $_earth $_card',
          quantity: 2,
        ),
        Perk(
          8,
          '$_add $_two +0 "All adjacent enemies suffer $_damage 1" $_cards',
        ),
        Perk(9, '$_ignoreScenarioEffectsAndRemove $_one -1 $_card'),
        Perk(
          10,
          '**Remodeling:** Whenever you rest while adjacent to a wall or obstacle, you may place an obstacle in an empty hex within $_range 2 (of you)',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.hatchet: [
      Perks([
        Perk(1, '$_remove $_two -1 $_cards', quantity: 2),
        Perk(2, '$_replace $_one +0 $_card with $_one +2 $_muddle $_card'),
        Perk(3, '$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk(4, '$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk(5, '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk(6, '$_replace $_one +0 $_card with $_one +1 $_push 2 $_card'),
        Perk(7, '$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk(8, '$_replace $_one +1 $_card with $_one +1 $_stun $_card'),
        Perk(9, '$_add $_one +2 $_air $_card', quantity: 3),
        Perk(10, '$_replace $_one +1 $_card with $_one +3 $_card', quantity: 3),
      ], variant: Variant.base),
      Perks([
        Perk(1, '$_remove $_two -1 $_cards', quantity: 2),
        Perk(2, '$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk(3, '$_replace $_one +1 $_card with $_one +1 $_stun $_card'),
        Perk(4, '$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk(5, '$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk(6, '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk(7, '$_replace $_one +0 $_card with $_one +2 $_muddle $_card'),
        Perk(8, '$_replace $_one +1 $_card with $_one +3 $_card', quantity: 3),
        Perk(9, '$_add $_one +2 $_air $_card', quantity: 3),
        Perk(
          10,
          '**Hasty Pick-up:** $_onceEachScenario, during your turn, if the Favourite is in a hex on the map, you may $_consume$_air to return it to its ability card',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.redGuard: [
      Perks([
        Perk(1, '$_remove four +0 $_cards'),
        Perk(2, '$_remove $_two -1 $_cards'),
        Perk(3, '$_remove $_one -2 $_card and $_one +1 $_card'),
        Perk(4, '$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          5,
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          6,
          '$_replace $_one +1 $_card with $_one +2 $_light $_card',
          quantity: 2,
        ),
        Perk(7, '$_add $_one +1 $_fire&$_light $_card', quantity: 2),
        Perk(8, '$_add $_one +1 $_shield 1 $_card', quantity: 2),
        Perk(9, '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk(10, '$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
      ], variant: Variant.base),
      Perks([
        Perk(1, '$_remove $_two -1 $_cards', quantity: 2),
        Perk(2, '$_remove $_one -2 $_card'),
        Perk(3, '$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk(4, '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk(
          5,
          '$_replace $_one +0 $_card and $_one +1 $_card with $_two +1 "$_shield 1" $_cards',
        ),
        Perk(
          6,
          '$_replace $_one +1 $_card with $_one +2 $_fire $_card',
          quantity: 2,
        ),
        Perk(
          7,
          '$_replace $_one +1 $_card with $_one +2 $_light $_card',
          quantity: 2,
        ),
        Perk(8, '$_add $_one +1 $_fire/$_light $_card', quantity: 2),
        Perk(9, '$_ignoreItemMinusOneEffectsAndAdd $_two +1 $_cards'),
        Perk(
          10,
          '**Brilliant Aegis:** Whenever you are attacked, you may $_consume$_light to gain $_shield 1 for the attack and have the attacker gain disadvantage for the attack',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
    ClassCodes.voidwarden: [
      Perks([
        Perk(1, '$_remove $_two -1 $_cards'),
        Perk(2, '$_remove $_one -2 $_card'),
        Perk(
          3,
          '$_replace $_one +0 $_card with $_one +1 $_dark $_card',
          quantity: 2,
        ),
        Perk(
          4,
          '$_replace $_one +0 $_card with $_one +1 $_ice $_card',
          quantity: 2,
        ),
        Perk(
          5,
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, Ally" $_card',
          quantity: 2,
        ),
        Perk(6, '$_add $_one +1 "$_heal 1, Ally" $_card', quantity: 3),
        Perk(7, '$_add $_one +1 $_poison $_card'),
        Perk(8, '$_add $_one +3 $_card'),
        Perk(9, '$_add $_one +1 $_curse $_card', quantity: 2),
      ], variant: Variant.base),
      Perks([
        Perk(1, '$_remove $_two -1 $_cards'),
        Perk(2, '$_remove $_one -2 $_card'),
        Perk(
          3,
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, $_targetCircle 1 ally" $_card',
          quantity: 2,
        ),
        Perk(
          4,
          '$_replace $_one +0 $_card with $_one +1 "$_heal 1, $_targetCircle 1 ally" $_card',
          quantity: 3,
        ),
        Perk(5, '$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk(
          6,
          '$_replace $_one +0 $_card with $_one +1 $_curse $_card',
          quantity: 2,
        ),
        Perk(7, '$_add $_two +1 $_ice $_cards'),
        Perk(8, '$_add $_two +1 $_dark $_cards'),
        Perk(9, '$_add $_one +3 $_card'),
        Perk(10, _ignoreScenarioEffects),
        Perk(
          11,
          '**Grave Defense:** Whenever you rest, you may $_consume$_ice/$_dark to give $_ward to one ally who has $_poison',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
  };
}
