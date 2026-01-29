import 'package:gloomhaven_enhancement_calc/data/perks/perk_text_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Perk definitions for Frosthaven classes.
///
/// Includes starting classes (Drifter, Blink Blade, Banner Spear, Deathwalker,
/// Boneshaper, Geminate) and unlockable classes.
class FrosthavenPerks {
  // Aliases for PerkTextConstants to keep perk definitions readable
  static const _add = PerkTextConstants.add;
  static const _addLowercase = PerkTextConstants.addLowercase;
  static const _remove = PerkTextConstants.remove;
  static const _removeLowercase = PerkTextConstants.removeLowercase;
  static const _replace = PerkTextConstants.replace;
  static const _one = PerkTextConstants.one;
  static const _two = PerkTextConstants.two;
  static const _three = PerkTextConstants.three;
  static const _plusOne = PerkTextConstants.plusOne;
  static const _plusTwo = PerkTextConstants.plusTwo;
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
  static const _targetCircle = PerkTextConstants.targetCircle;
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
  static const _impair = PerkTextConstants.impair;
  static const _brittle = PerkTextConstants.brittle;
  static const _attack = PerkTextConstants.attack;
  static const _range = PerkTextConstants.range;
  static const _move = PerkTextConstants.move;
  static const _loot = PerkTextConstants.loot;
  static const _recover = PerkTextConstants.recover;
  static const _spent = PerkTextConstants.spent;
  static const _fire = PerkTextConstants.fire;
  static const _light = PerkTextConstants.light;
  static const _dark = PerkTextConstants.dark;
  static const _earth = PerkTextConstants.earth;
  static const _air = PerkTextConstants.air;
  static const _ice = PerkTextConstants.ice;
  static const _wildElement = PerkTextConstants.wildElement;
  static const _consume = PerkTextConstants.consume;
  static const _oneHand = PerkTextConstants.oneHand;
  static const _twoHand = PerkTextConstants.twoHand;
  static const _negative = PerkTextConstants.negative;
  static const _scenario = PerkTextConstants.scenario;
  static const _atTheStartOfEachScenario =
      PerkTextConstants.atTheStartOfEachScenario;
  static const _ignoreItemMinusOneEffects =
      PerkTextConstants.ignoreItemMinusOneEffects;
  static const _ignoreItemMinusOneEffectsAndAdd =
      PerkTextConstants.ignoreItemMinusOneEffectsAndAdd;
  static const _ignoreItemMinusOneEffectsAndRemove =
      PerkTextConstants.ignoreItemMinusOneEffectsAndRemove;
  static const _ignoreScenarioEffects = PerkTextConstants.ignoreScenarioEffects;
  static const _ignoreScenarioEffectsAndAdd =
      PerkTextConstants.ignoreScenarioEffectsAndAdd;
  static const _ignoreScenarioEffectsAndRemove =
      PerkTextConstants.ignoreScenarioEffectsAndRemove;
  static const _onceEachScenario = PerkTextConstants.onceEachScenario;
  static const _wheneverYouLongRest = PerkTextConstants.wheneverYouLongRest;
  static const _wheneverYouShortRest = PerkTextConstants.wheneverYouShortRest;

  static final Map<String, List<Perks>> perks = {
    // DRIFTER
    ClassCodes.drifter: [
      Perks([
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one +1 $_card with $_two +0 "Move $_one of your character tokens backward $_one slot" $_cards',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_two $_pierce 3 $_rolling $_cards',
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_two $_push 2 $_rolling $_cards',
        ),
        Perk('$_add $_one +3 $_card'),
        Perk('$_add $_one +2 $_immobilize $_card', quantity: 2),
        Perk('$_add $_two "$_heal 1, self" $_rolling $_cards'),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_card'),
        Perk('$_ignoreItemMinusOneEffectsAndAdd $_one +1 $_card'),
        Perk(
          '$_wheneverYouLongRest, you may move $_one of your character tokens backward $_one slot',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'You may bring $_one additional $_oneHand item into each $_scenario',
        ),
        Perk(
          'At the end of each $_scenario, you may discard up to $_two loot $_cards, except *Random Item*, to draw that many new loot $_cards',
        ),
      ], variant: Variant.base),
    ],

    // BLINK BLADE
    ClassCodes.blinkBlade: [
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wound $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one "Place this $_card in your active area. On your next attack, discard this $_card to $_addLowercase $_plusTwo $_attack" $_rolling $_card',
          quantity: 3,
        ),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk('$_add $_one -1 "Gain $_one TIME_TOKEN" $_card', quantity: 2),
        Perk(
          '$_add $_one +2 "$_regenerate, self" $_rolling $_card',
          quantity: 2,
        ),
        Perk(
          '$_wheneverYouShortRest, you may spend $_one unspent $_spent item for no effect to $_recover a different spent item',
        ),
        Perk(
          'At the start of your first turn each $_scenario, you may perform $_move 3',
        ),
        Perk('Whenever you would gain $_immobilize, prevent the condition'),
      ], variant: Variant.base),
    ],

    // BANNER SPEAR
    ClassCodes.bannerSpear: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one "$_shield 1" $_rolling $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_add $_plusOne $_attack for each ally adjacent to the target" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_disarm $_card', quantity: 2),
        Perk('$_add $_one +2 $_push 1 $_card', quantity: 2),
        Perk('$_add $_two +1 $_rolling $_cards', quantity: 2),
        Perk('$_add $_two "$_heal 1, self" $_rolling $_cards', quantity: 2),
        Perk('$_ignoreItemMinusOneEffectsAndRemove $_one -1 $_card'),
        Perk(
          'At the end of each of your long rests, grant $_one ally within $_range 3: $_move 2',
        ),
        Perk(
          'Whenever you open a door with a move ability, $_addLowercase +3 $_move',
        ),
        Perk(
          'Once each $_scenario, during your turn, gain $_shield 2 for the round',
          grouped: true,
          quantity: 2,
        ),
      ], variant: Variant.base),
    ],

    // DEATHWALKER
    ClassCodes.deathwalker: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_curse $_card',
          quantity: 3,
        ),
        Perk('$_add $_one +2 $_dark $_card', quantity: 2),
        Perk(
          '$_add $_one $_disarm $_rolling and $_one $_muddle $_rolling $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_two "$_heal 1, $_targetCircle 1 ally" $_rolling $_cards',
          quantity: 2,
        ),
        Perk(_ignoreScenarioEffects),
        Perk('$_wheneverYouLongRest, you may move $_one SHADOW up to 3 hexes'),
        Perk(
          '$_wheneverYouShortRest, you may $_consume$_dark to perform $_muddle, $_curse, $_range 2 as if you were occupying a hex with a SHADOW',
        ),
        Perk(
          'While you are occupying a hex with a SHADOW, all attacks targeting you gain disadvantage',
        ),
      ], variant: Variant.base),
    ],

    // BONESHAPER
    ClassCodes.boneshaper: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_curse $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_poison $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "Kill the attacking summon to instead $_addLowercase +4" $_card',
          quantity: 3,
        ),
        Perk(
          '$_add $_three "$_heal 1, $_targetCircle Boneshaper" $_rolling $_cards',
          quantity: 2,
        ),
        Perk('$_add $_one +2 $_earth/$_dark $_card', quantity: 3),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk(
          'Immediately before each of your rests, you may kill $_one of your summons to perform $_bless, self',
        ),
        Perk(
          'Once each $_scenario, when any character ally would become exhausted by suffering $_damage, you may suffer $_damage 2 to reduce their hit point value to 1 instead',
        ),
        Perk(
          'At the start of each $_scenario, you may play a level 1 $_card from your hand to perform a summon action of the $_card',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // GEMINATE
    ClassCodes.geminate: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_consume$_wildElement : $_wildElement" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_poison $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_wound $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_two $_pierce 3 $_rolling $_cards',
        ),
        Perk('$_add $_two +1 $_push 3 $_cards'),
        Perk('$_add $_one 2x "$_brittle, self" $_card'),
        Perk('$_add $_one +1 "$_regenerate, self" $_rolling card', quantity: 2),
        Perk(_ignoreScenarioEffects),
        Perk(
          '$_wheneverYouShortRest, you may $_removeLowercase $_one $_negative condition from $_one ally within $_range 3',
        ),
        Perk(
          'Once each $_scenario, when you would give yourself a $_negative condition, prevent the condition',
        ),
        Perk(
          'Whenever you perform an action with a lost icon, you may discard $_one $_card to $_recover $_one card from your discard pile of equal or lower level',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // INFUSER
    ClassCodes.infuser: [
      Perks([
        Perk(
          '$_replace $_one -2 $_card with $_one -1 $_card and $_one -1 $_air $_earth $_dark $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_air/$_earth $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_air/$_dark $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_earth/$_dark $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk(
          '$_replace $_one +0 $_card with $_three "Move one waning element to strong" $_rolling $_cards',
          quantity: 2,
        ),
        Perk(
          '$_add $_two "$_plusOne $_attack for each pair of active INFUSION" $_rolling $_cards',
          quantity: 2,
        ),
        Perk(_ignoreScenarioEffects),
        Perk(
          '$_ignoreItemMinusOneEffects. Whenever you become exhausted, keep all your active bonuses in play, with your summons acting on initiative 99 each round',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '$_wheneverYouShortRest, you may $_consume$_wildElement to $_recover $_one spent $_oneHand or $_twoHand item',
        ),
        Perk(
          'Once each $_scenario, during ordering of initiative, after all ability cards have been revealed, $_wildElement',
        ),
      ], variant: Variant.base),
    ],

    // PYROCLAST
    ClassCodes.pyroclast: [
      Perks([
        Perk('Remove two -1 cards'),
        Perk('Remove one -2 card'),
        Perk('Replace one +0 card with one +1 $_wound card', quantity: 2),
        Perk(
          'Replace one -1 card with one +0 "Create one 1-hex hazardous terrain tile in a featureless hex adjacent to the target" card',
          quantity: 2,
        ),
        Perk(
          'Replace two +0 cards with two $_push 2 $_rolling cards',
          quantity: 2,
        ),
        Perk('Replace two +1 cards with two +2 cards'),
        Perk('Add two +1 $_fire/$_earth cards', quantity: 2),
        Perk('Add two +1 $_muddle $_rolling cards'),
        Perk(_ignoreScenarioEffects),
        Perk(
          '$_wheneverYouLongRest, you may destroy one adjacent obstacle to gain $_ward',
        ),
        Perk(
          '$_wheneverYouShortRest, you may $_consume$_fire to perform $_wound, $_targetCircle 1 enemy occupying or adjacent to hazardous terrain',
        ),
        Perk(
          'You and all allies are unaffected by hazardous terrain you create',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // SHATTERSONG
    ClassCodes.shattersong: [
      Perks([
        Perk('Remove four +0 cards'),
        Perk(
          'Replace two -1 cards with two +0 "Reveal the top card of the target\'s monster ability deck" cards',
          quantity: 2,
        ),
        Perk('Replace one -2 card with one -1 $_stun card'),
        Perk('Replace one +0 card with one +0 $_brittle card', quantity: 2),
        Perk(
          'Replace two +1 cards with two +2 $_air/$_light cards',
          quantity: 2,
        ),
        Perk(
          'Add one "$_heal 2, $_bless, $_targetCircle 1 ally" $_rolling card',
          quantity: 2,
        ),
        Perk('Add one +1 "Gain 1 RESONANCE" card', quantity: 3),
        Perk(_ignoreScenarioEffects),
        Perk(
          '$_wheneverYouShortRest, you may $_consume$_air to perform $_strengthen, $_range 3 and $_consume$_light to perform $_bless, $_range 3',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '$_atTheStartOfEachScenario, you may gain $_brittle to gain 2 RESONANCE',
        ),
        Perk(
          'Whenever a new room is revealed, you may reveal the top card of both the monster attack modifier deck and all allies\' attack modifier decks',
        ),
      ], variant: Variant.base),
    ],

    // TRAPPER
    ClassCodes.trapper: [
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "Create $_one $_heal 2 trap in an empty hex adjacent to the target" card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "Create $_one $_damage 1 trap in an empty hex adjacent to the target" card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_two +0 "Add $_damage 2 or $_heal 2 to a trap within $_range 2 of you" $_cards',
          quantity: 3,
        ),
        Perk(
          '$_replace $_two +1 $_cards with $_two +2 $_immobilize $_cards',
          quantity: 2,
        ),
        Perk(
          '$_add $_two "Add $_push 2 or $_pull 2" $_rolling $_cards',
          quantity: 3,
        ),
        Perk(_ignoreScenarioEffects),
        Perk(
          '$_wheneverYouLongRest, you may create $_one $_damage 1 trap in an adjacent empty hex',
        ),
        Perk(
          'Whenever you enter a hex with a trap, you may choose to not spring the trap',
        ),
        Perk(
          '$_atTheStartOfEachScenario, you may create $_one $_damage 2 trap in an adjacent empty hex',
        ),
      ], variant: Variant.base),
    ],

    // PAIN CONDUIT
    ClassCodes.painConduit: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_replace $_one -2 $_card with $_one -2 $_curse $_curse $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_disarm $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_fire/$_air $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card'),
        Perk('$_replace $_three +1 $_cards with $_three +1 $_curse $_cards'),
        Perk('$_add $_three "$_heal 1, self" $_rolling $_cards', quantity: 2),
        Perk(
          '$_add $_one +0 "Add $_plusOne $_attack for each negative condition you have" $_card',
          quantity: 2,
        ),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk(
          'Each round in which you long rest, you may ignore all negative conditions you have. If you do, they cannot be removed that round',
        ),
        Perk(
          'Whenever you become exhausted, first perform $_curse, $_targetCircle all, $_range 3',
        ),
        Perk(
          'Increase your maximum hit point value by 5',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // SNOWDANCER
    ClassCodes.snowdancer: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, $_targetCircle 1 ally" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_immobilize $_card',
          quantity: 2,
        ),
        Perk('$_add $_two +1 $_ice/$_air $_cards', quantity: 2),
        Perk(
          '$_replace $_two +0 $_cards with $_two "If this action forces the target to move, it suffers $_damage 1" $_rolling $_cards',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_strengthen, $_targetCircle 1 ally" $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one "$_heal 1, $_ward, $_targetCircle 1 ally" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_wheneverYouLongRest, you may $_ice/$_air'),
        Perk(
          '$_wheneverYouShortRest, you may $_consume$_ice to perform $_regenerate, $_range 3 and $_consume$_air to perform $_ward, $_range 3',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '$_atTheStartOfEachScenario, all enemies gain $_muddle. Whenever a new room is revealed, all enemies in the newly revealed room gain $_muddle',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // FROZEN FIST
    ClassCodes.frozenFist: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_disarm $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_shield 1" $_rolling $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_ice/$_earth $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 "Create $_one 1-hex icy terrain tile in a featureless hex adjacent to the target" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +3 $_card'),
        Perk('$_add $_two "$_heal 1, self" $_rolling $_cards', quantity: 3),
        Perk(
          '$_ignoreItemMinusOneEffects, and, whenever you enter icy terrain with a move ability, you may ignore the effect to add $_plusOne $_move',
        ),
        Perk(
          'Whenever you heal from a long rest, you may $_consume$_ice/$_earth to add $_plusTwo $_heal',
        ),
        Perk(
          '$_onceEachScenario, when you would suffer $_damage, you may negate the $_damage',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // HIVE
    ClassCodes.hive: [
      Perks([
        Perk('$_remove $_one -2 $_card and $_one +1 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "After this attack ability, grant one of your summons: $_move 2" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "After this attack ability, TRANSFER" $_card',
          quantity: 3,
        ),
        Perk('$_add $_one +1 "$_heal 1, self" $_card', quantity: 3),
        Perk('$_add $_one +2 $_muddle $_card', quantity: 2),
        Perk('$_add $_two $_poison $_rolling $_cards'),
        Perk('$_add $_two $_wound $_rolling $_cards'),
        Perk(
          '$_wheneverYouLongRest, you may do so on any initiative value, choosing your initiative after all ability cards have been revealed, and you decide how your summons perform their abilities for the round',
          quantity: 2,
          grouped: true,
        ),
        Perk('At the end of each of your short rests, you may TRANSFER'),
        Perk('Whenever you would gain $_wound, prevent the condition'),
      ], variant: Variant.base),
    ],

    // METAL MOSAIC
    ClassCodes.metalMosaic: [
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "PRESSURE_GAIN or PRESSURE_LOSE" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one "$_shield 1" $_rolling $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +0 "The target and all enemies adjacent to it suffer $_damage 1" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one $_pierce 3 $_rolling and $_one "$_retaliate 2" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 "$_heal 2, self" $_card', quantity: 2),
        Perk('$_add $_one +3 $_card'),
        Perk('$_ignoreItemMinusOneEffectsAndAdd two +1 $_cards'),
        Perk('$_wheneverYouLongRest, you may PRESSURE_GAIN or PRESSURE_LOSE'),
        Perk(
          'Whenever you would gain $_poison, you may suffer $_damage 1 to prevent the condition',
        ),
        Perk(
          '$_onceEachScenario, when you would become exhausted, instead gain $_stun and $_invisible, lose all your cards, $_recover four lost cards, and then discard the recovered cards',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // DEEPWRAITH
    ClassCodes.deepwraith: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_one -1 card with one +0 $_disarm card', quantity: 2),
        Perk('Replace one -2 card with one -1 $_stun card'),
        Perk(
          'Replace one +0 card with one +0 "$_invisible, self" card',
          quantity: 2,
        ),
        Perk('Replace two +0 cards with two $_pierce 3 $_rolling cards'),
        Perk('Replace two +1 cards with two +2 cards'),
        Perk('Replace three +1 cards with three +1 $_curse cards'),
        Perk('Add two +1 "Gain 1 TROPHY" cards', quantity: 3),
        Perk('$_ignoreScenarioEffectsAndRemove two +0 cards'),
        Perk(
          '$_wheneverYouLongRest, you may $_loot one adjacent hex. If you gain any loot tokens, gain 1 TROPHY',
        ),
        Perk('$_atTheStartOfEachScenario, gain 2 TROPHY'),
        Perk(
          'While you have $_invisible, gain advantage on all your attacks',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],

    // CRASHING TIDE
    ClassCodes.crashingTide: [
      Perks([
        Perk(
          'Replace one -1 card with two $_pierce 3 $_rolling cards',
          quantity: 2,
        ),
        Perk(
          'Replace one -1 card with one +0 "$_plusOne $_targetCircle" card',
          quantity: 2,
        ),
        Perk(
          'Replace one +0 card with one +1 "$_shield 1" $_rolling card',
          quantity: 2,
        ),
        Perk(
          'Add two +1 "If you performed a TIDE action this round, +2 instead" cards',
          quantity: 2,
        ),
        Perk('Add one +2 $_muddle card', quantity: 2),
        Perk('Add one +1 $_disarm card'),
        Perk('Add two "$_heal 1, self" $_rolling cards', quantity: 2),
        Perk(
          '$_ignoreItemMinusOneEffects, and, whenever you would gain $_impair, prevent the condition',
        ),
        Perk(
          'Whenever you declare a long rest during card selection, gain $_shield 1 for the round',
        ),
        Perk(
          'Gain advantage on all your attacks performed while occupying or targeting enemies occupying water hexes',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],
  };
}
