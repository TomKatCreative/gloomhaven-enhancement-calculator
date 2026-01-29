import 'package:gloomhaven_enhancement_calc/data/perks/perk_text_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Perk definitions for Crimson Scales classes.
///
/// This is a fan-made expansion with community-created classes.
class CrimsonScalesPerks {
  // Private aliases for PerkTextConstants to keep perk definitions readable
  static const _add = PerkTextConstants.add;
  static const _addLowercase = PerkTextConstants.addLowercase;
  static const _remove = PerkTextConstants.remove;
  static const _removeLowercase = PerkTextConstants.removeLowercase;
  static const _replace = PerkTextConstants.replace;
  static const _one = PerkTextConstants.one;
  static const _two = PerkTextConstants.two;
  static const _three = PerkTextConstants.three;
  static const _card = PerkTextConstants.card;
  static const _cards = PerkTextConstants.cards;
  static const _rolling = PerkTextConstants.rolling;
  static const _damage = PerkTextConstants.damage;
  static const _immobilize = PerkTextConstants.immobilize;
  static const _regenerate = PerkTextConstants.regenerate;
  static const _retaliate = PerkTextConstants.retaliate;
  static const _shield = PerkTextConstants.shield;
  static const _ward = PerkTextConstants.ward;
  static const _push = PerkTextConstants.push;
  static const _pull = PerkTextConstants.pull;
  static const _targetDiamond = PerkTextConstants.targetDiamond;
  static const _pierce = PerkTextConstants.pierce;
  static const _stun = PerkTextConstants.stun;
  static const _disarm = PerkTextConstants.disarm;
  static const _muddle = PerkTextConstants.muddle;
  static const _wound = PerkTextConstants.wound;
  static const _heal = PerkTextConstants.heal;
  static const _curse = PerkTextConstants.curse;
  static const _bless = PerkTextConstants.bless;
  static const _strengthen = PerkTextConstants.strengthen;
  static const _poison = PerkTextConstants.poison;
  static const _invisible = PerkTextConstants.invisible;
  static const _rupture = PerkTextConstants.rupture;
  static const _empower = PerkTextConstants.empower;
  static const _attack = PerkTextConstants.attack;
  static const _range = PerkTextConstants.range;
  static const _move = PerkTextConstants.move;
  static const _loot = PerkTextConstants.loot;
  static const _recover = PerkTextConstants.recover;
  static const _fire = PerkTextConstants.fire;
  static const _light = PerkTextConstants.light;
  static const _dark = PerkTextConstants.dark;
  static const _earth = PerkTextConstants.earth;
  static const _air = PerkTextConstants.air;
  static const _ice = PerkTextConstants.ice;
  static const _wildElement = PerkTextConstants.wildElement;
  static const _consume = PerkTextConstants.consume;
  static const _oneHand = PerkTextConstants.oneHand;
  static const _negative = PerkTextConstants.negative;
  static const _scenario = PerkTextConstants.scenario;
  static const _ignoreNegativeItemEffectsAndAdd =
      PerkTextConstants.ignoreNegativeItemEffectsAndAdd;
  static const _ignoreNegativeItemEffectsAndRemove =
      PerkTextConstants.ignoreNegativeItemEffectsAndRemove;
  static const _ignoreNegativeScenarioEffects =
      PerkTextConstants.ignoreNegativeScenarioEffects;
  static const _ignoreNegativeScenarioEffectsAndAdd =
      PerkTextConstants.ignoreNegativeScenarioEffectsAndAdd;
  static const _ignoreNegativeScenarioEffectsAndRemove =
      PerkTextConstants.ignoreNegativeScenarioEffectsAndRemove;
  static const _ignoreScenarioEffectsAndAdd =
      PerkTextConstants.ignoreScenarioEffectsAndAdd;

  static final Map<String, List<Perks>> perks = {
    ClassCodes.amberAegis: [
      Perks([
        Perk(
          '$_replace $_one -2 $_card with $_one -1 "Place $_one Colony token of your choice on any empty hex within $_range 2" $_card',
        ),
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +2 $_muddle $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_poison $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_wound $_card'),
        Perk('$_add $_two $_rolling +1 $_immobilize $_cards', quantity: 2),
        Perk(
          '$_add $_one $_rolling "$_heal 1, Self" $_card and $_one $_rolling "$_shield 1, Self" $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one $_rolling "$_retaliate 1, $_range 3" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +2 $_fire/$_earth $_card'),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_one +1 $_card'),
        Perk(
          '$_ignoreScenarioEffectsAndAdd $_one "+X, where X is the number of active Cultivate actions" card',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.artificer: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one -1 $_wildElement $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_disarm $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +1 $_push 1 $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +1 $_pull 1 $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +0 "$_recover a spent item" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_shield 1, Self" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_pierce 2 $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +2 $_card with $_one +3 "$_heal 2, Self" $_card'),
        Perk(
          '$_replace $_two +1 $_cards with $_two $_rolling +1 $_poison $_cards',
        ),
        Perk(
          '$_replace $_two +1 $_cards with $_two $_rolling +1 $_wound $_cards',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.bombard: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk(
          '$_replace $_two +0 $_cards with $_two $_rolling $_pierce 3 $_cards',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "+3 if Projectile" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +2 $_immobilize $_card', quantity: 2),
        Perk(
          '$_replace $_one +1 $_card with $_two +1 "$_retaliate 1, $_range 3" $_cards',
        ),
        Perk('$_add $_two +1 "$_pull 3, Self, toward the target" $_cards'),
        Perk('$_add $_one +0 "$_strengthen, Self" $_card'),
        Perk('$_add $_one +0 $_stun $_card'),
        Perk('$_add $_one +1 $_wound $_card'),
        Perk('$_add $_two $_rolling "$_shield 1, Self" $_cards'),
        Perk('$_add $_two $_rolling "$_heal 1, Self" $_cards'),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one +0 $_card'),
        Perk('$_ignoreNegativeItemEffectsAndRemove $_one +0 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.brightspark: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_consume$_wildElement to $_addLowercase +2 $_attack" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one -2 $_card with $_one -2 "$_recover $_one random $_card from your discard pile" $_card',
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "$_heal 1, Affect $_one Ally within $_range 2" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "$_shield 1, Affect $_one Ally within $_range 2" $_card',
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +2 $_wildElement $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one +1 "$_strengthen, Affect $_one Ally within $_range 2" $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one $_rolling "$_push 1 or $_pull 1, $_air" $_card and $_one $_rolling "$_immobilize, $_ice" $_card',
        ),
        Perk(
          '$_add $_one $_rolling "$_heal 1, $_range 3, $_light" $_card and $_one $_rolling "$_pierce 2, $_fire" $_card',
        ),
        Perk(
          '$_add $_three $_rolling "$_consume$_wildElement : $_wildElement" $_cards',
        ),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one -1 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.chieftain: [
      Perks([
        Perk('$_replace $_one -1 $_card with $_one +0 $_poison $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, Chieftain" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, Affect all summoned allies owned" $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one -2 $_card with $_one -2 "$_bless, Self" $_card'),
        Perk(
          '$_replace $_two +0 $_cards with $_one +0 "$_immobilize and $_push 1" $_card',
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one "+X, where X is the number of summoned allies you own" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_two +1 "$_rolling +1, if summon is attacking" $_cards',
        ),
        Perk('$_add $_one +0 $_wound, $_pierce 1 $_card'),
        Perk('$_add $_one +1 $_earth $_card', quantity: 2),
        Perk(
          '$_add $_two $_rolling "$_pierce 2, ignore $_retaliate on the target" $_cards',
        ),
        Perk('$_ignoreNegativeScenarioEffectsAndAdd $_one +1 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.fireKnight: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_strengthen, Ally" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_two +0 "+2 if you are on Ladder" $_cards',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +1 $_fire $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk('$_replace $_two +1 $_cards with $_one +2 $_fire $_card'),
        Perk('$_replace $_two +1 $_cards with $_one +2 $_wound $_card'),
        Perk('$_add $_one +1 "$_strengthen, Ally" $_card'),
        Perk(
          '$_add $_two $_rolling "$_heal 1, $_range 1" $_cards',
          quantity: 2,
        ),
        Perk('$_add $_two $_rolling $_wound $_cards'),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_one $_rolling $_fire $_card'),
        Perk(
          '$_ignoreNegativeScenarioEffectsAndAdd $_one $_rolling $_fire $_card',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.hollowpact: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 2, Self" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +0 VOIDSIGHT $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one -2 $_earth $_card and $_two +2 $_dark $_cards',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one -2 $_stun $_card and $_one +0 VOIDSIGHT $_card',
        ),
        Perk(
          '$_replace $_one -2 $_card with $_one +0 $_disarm $_card and $_one -1 $_wildElement $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one $_rolling +1 VOID $_card and $_one $_rolling -1 $_curse $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +1 $_cards with $_one +3 "$_regenerate, Self" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "Create a Void pit in an empty hex within $_range 2" $_card',
          quantity: 2,
        ),
        Perk(
          '$_ignoreNegativeScenarioEffectsAndAdd $_one +0 "$_ward, Self" $_card',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.mirefoot: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          '$_replace $_two +0 $_cards with $_two "+X, where X is the $_poison value of the target" $_cards',
          quantity: 2,
        ),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk(
          '$_replace $_one +0 $_card with $_two $_rolling "Create difficult terrain in the hex occupied by the target" $_cards',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +0 $_wound 2 $_card',
          quantity: 2,
        ),
        Perk(
          '$_add four $_rolling +0 "+1 if the target occupies difficult terrain" $_cards',
        ),
        Perk(
          '$_add $_two $_rolling "$_invisible, Self, if you occupy difficult terrain" $_cards',
        ),
        Perk(
          'Gain "Poison Dagger" (Item 011). You may carry $_one additional $_oneHand item with "Dagger" in its name',
        ),
        Perk(
          'Ignore damage, $_negative conditions, and modifiers from Events, and $_removeLowercase $_one -1 $_card',
        ),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one -1 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.chainguard: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +1 Shackle $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "+2 if the target is Shackled" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one $_rolling "$_shield 1, Self" $_card',
          quantity: 2,
        ),
        Perk('$_add $_two $_rolling "$_retaliate 1, Self" $_cards'),
        Perk('$_add $_three $_rolling SWING 3 $_cards'),
        Perk('$_replace $_one +1 $_card with $_one +2 $_wound $_card'),
        Perk('$_add $_one +1 "$_disarm if the target is Shackled" $_card'),
        Perk(
          '$_add $_one +1 "Create a 2 $_damage trap in an empty hex within $_range 2" $_card',
        ),
        Perk('$_add $_two $_rolling "$_heal 1, Self" $_cards'),
        Perk('$_add $_one +2 Shackle $_card', quantity: 2),
        Perk('$_ignoreNegativeItemEffectsAndRemove $_one +0 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.hierophant: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_two +0 $_cards with $_one $_rolling $_light $_card'),
        Perk('$_replace $_two +0 $_cards with $_one $_rolling $_earth $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_curse $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_shield 1, Ally" $_card',
        ),
        Perk(
          '$_replace $_one -2 $_card with $_one -1 "Give $_one Ally a \'Prayer\' ability $_card" and $_one +0 $_card',
        ),
        Perk('$_replace $_one +1 $_card with $_one +3 $_card', quantity: 2),
        Perk(
          '$_add $_two $_rolling "$_heal 1, Self or Ally" $_cards',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_wound, $_muddle $_card', quantity: 2),
        Perk('At the start of your first turn each $_scenario, gain $_bless'),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one +0 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.luminary: [
      Perks([
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_ice $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_fire $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_light $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_dark $_card'),
        Perk(
          '$_replace $_one -2 $_card with $_one -2 "Perform $_one Glow ability" $_card',
        ),
        Perk('$_add $_one +0 $_wildElement $_card', quantity: 2),
        Perk('$_add $_one $_rolling +1 "$_heal 1, Self" $_card', quantity: 2),
        Perk(
          '$_add $_one "$_poison, target all enemies in the depicted LUMINARY_HEXES area" $_card',
          quantity: 2,
        ),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one +0 $_card'),
        Perk(
          '$_ignoreNegativeItemEffectsAndAdd $_one $_rolling "$_consume$_wildElement : $_wildElement" $_card',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.spiritCaller: [
      Perks([
        Perk(
          '$_replace $_one -2 $_card with $_one -1 $_card and $_one +1 $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "+2 if a Spirit performed the attack" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_card and $_one $_rolling $_poison $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_air $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_dark $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +1 $_pierce 2 $_card'),
        Perk('$_add $_three $_rolling $_pierce 3 $_cards'),
        Perk('$_add $_one +1 $_curse $_card'),
        Perk('$_add $_one $_rolling ADD $_targetDiamond $_card'),
        Perk('$_replace $_one +1 $_card with $_one +2 $_push 2 $_card'),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one +0 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.starslinger: [
      Perks([
        Perk(
          '$_replace $_two +0 $_cards with $_one $_rolling "$_heal 1, Self" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -2 $_card with $_one -1 "$_invisible, Self" $_card',
        ),
        Perk('$_replace $_two -1 $_cards with $_one +0 $_dark $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +1 $_light $_card',
          quantity: 2,
        ),
        Perk('$_add $_one $_rolling $_loot 1 $_card'),
        Perk(
          '$_add $_one +1 "+3 if you are at full health" $_card',
          quantity: 2,
        ),
        Perk('$_add $_two $_rolling $_immobilize $_cards'),
        Perk('$_add $_one +1 "$_heal 1, $_range 3" $_card', quantity: 2),
        Perk(
          '$_add $_two $_rolling "Force the target to perform a \'$_move 1\' ability" $_cards',
        ),
        Perk('$_add $_two $_rolling "$_heal 1, $_range 1" $_cards'),
        Perk('$_ignoreNegativeScenarioEffectsAndRemove $_one +0 $_card'),
      ], variant: Variant.base),
    ],
    ClassCodes.ruinmaw: [
      Perks([
        Perk(
          '$_replace $_one -2 $_card with $_one -1 $_rupture and $_wound $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wound $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_rupture $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_add +3 instead if the target has $_rupture or $_wound" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one $_rolling "$_heal 1, Self, $_empower" $_card',
          quantity: 3,
        ),
        Perk(
          'Once each $_scenario, become SATED after collecting your 5th loot token',
        ),
        Perk(
          'Become SATED each time you lose a $_card to negate suffering damage',
        ),
        Perk(
          'Whenever $_one of your abilities causes at least $_one enemy to gain $_rupture, immediately after that ability perform "$_move 1"',
        ),
        Perk(
          '$_ignoreNegativeScenarioEffects, and $_removeLowercase $_one -1 $_card',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.thornreaper: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one $_rolling "+1 if $_light is Strong or Waning" $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          'Add three $_rolling "+1 if $_light is Strong or Waning" cards',
          quantity: 2,
        ),
        Perk('$_add $_two $_rolling $_light $_cards'),
        Perk(
          '$_add $_three $_rolling "$_earth if $_light is Strong or Waning" $_cards',
        ),
        Perk(
          '$_add $_one "Create hazardous terrain in $_one hex within $_range 1" $_card',
        ),
        Perk(
          'Add one $_rolling "On the next attack targeting you while occupying hazardous terrain, discard this card to gain $_retaliate 3" card',
          quantity: 2,
        ),
        Perk(
          'Add one $_rolling "On the next attack targeting you while occupying hazardous terrain, discard this card to gain $_shield 3" card',
          quantity: 2,
        ),
        Perk(
          '$_ignoreNegativeItemEffectsAndAdd $_one $_rolling "+1 if $_light is Strong or Waning" $_card',
        ),
        Perk(
          'Gain $_shield 1 while you occupy hazardous terrain',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.vanquisher: [
      Perks([
        Perk('Replace two -1 cards with one +0 $_muddle card'),
        Perk('Replace two -1 cards with one -1 "$_heal 2, Self" card'),
        Perk('Replace one -2 card with one -1 $_poison $_wound card'),
        Perk(
          '$_replace one +0 card with one +1 "$_heal 1, Self" card',
          quantity: 2,
        ),
        Perk(
          'Replace two +0 cards with one +0 $_curse card and one +0 $_immobilize card',
        ),
        Perk('Replace one +1 card with one +2 $_fire/$_air card', quantity: 2),
        Perk('Replace one +2 card with one $_rolling "Gain one RAGE" card'),
        Perk(
          'Add one +1 "$_retaliate 1, Self" card and one $_rolling $_pierce 3 card',
          quantity: 2,
        ),
        Perk('Add one +0 "$_bless, Self" card'),
        Perk('Add two +1 "+2 instead if you suffer 1 damage" cards'),
        Perk('Add one +2 "+3 instead if you suffer 1 damage" card'),
        Perk('$_ignoreNegativeItemEffectsAndRemove one -1 card'),
      ], variant: Variant.base),
    ],
  };
}
