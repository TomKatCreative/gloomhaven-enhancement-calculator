import 'package:gloomhaven_enhancement_calc/data/perks/perk_text_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Perk definitions for Gloomhaven classes.
///
/// Includes:
/// - Starting classes (Brute, Tinkerer, Spellweaver, Scoundrel, Cragheart, Mindthief)
/// - Unlockable classes (Sunkeeper, Quartermaster, Summoner, Nightshroud, Plagueherald,
///   Berserker, Soothsinger, Doomstalker, Sawbones, Elementalist, Beast Tyrant)
/// - Envelope X (Bladeswarm)
/// - Forgotten Circles (Diviner)
class GloomhavenPerks {
  // Short aliases for PerkTextConstants to keep perk definitions readable
  static const _add = PerkTextConstants.add;
  static const _addLowercase = PerkTextConstants.addLowercase;
  static const _remove = PerkTextConstants.remove;
  static const _replace = PerkTextConstants.replace;
  static const _one = PerkTextConstants.one;
  static const _two = PerkTextConstants.two;
  static const _three = PerkTextConstants.three;
  static const _four = PerkTextConstants.four;
  static const _plusZero = PerkTextConstants.plusZero;
  static const _plusOne = PerkTextConstants.plusOne;
  static const _plusTwo = PerkTextConstants.plusTwo;
  static const _card = PerkTextConstants.card;
  static const _cards = PerkTextConstants.cards;
  static const _rolling = PerkTextConstants.rolling;
  static const _loss = PerkTextConstants.loss;
  static const _shuffle = PerkTextConstants.shuffle;
  static const _null = PerkTextConstants.nullCard;
  static const _damage = PerkTextConstants.damage;
  static const _immobilize = PerkTextConstants.immobilize;
  static const _regenerate = PerkTextConstants.regenerate;
  static const _retaliate = PerkTextConstants.retaliate;
  static const _shield = PerkTextConstants.shield;
  static const _ward = PerkTextConstants.ward;
  static const _push = PerkTextConstants.push;
  static const _pull = PerkTextConstants.pull;
  static const _targetCircle = PerkTextConstants.targetCircle;
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
  static const _brittle = PerkTextConstants.brittle;
  static const _safeguard = PerkTextConstants.safeguard;
  static const _attack = PerkTextConstants.attack;
  static const _range = PerkTextConstants.range;
  static const _move = PerkTextConstants.move;
  static const _teleport = PerkTextConstants.teleport;
  static const _flying = PerkTextConstants.flying;
  static const _loot = PerkTextConstants.loot;
  static const _recover = PerkTextConstants.recover;
  static const _refresh = PerkTextConstants.refresh;
  static const _fire = PerkTextConstants.fire;
  static const _light = PerkTextConstants.light;
  static const _dark = PerkTextConstants.dark;
  static const _earth = PerkTextConstants.earth;
  static const _air = PerkTextConstants.air;
  static const _ice = PerkTextConstants.ice;
  static const _wildElement = PerkTextConstants.wildElement;
  static const _consume = PerkTextConstants.consume;
  static const _body = PerkTextConstants.body;
  static const _pocket = PerkTextConstants.pocket;
  static const _oneHand = PerkTextConstants.oneHand;
  static const _twoHand = PerkTextConstants.twoHand;
  static const _negative = PerkTextConstants.negative;
  static const _scenario = PerkTextConstants.scenario;
  static const _tear = PerkTextConstants.tear;
  static const _supplies = PerkTextConstants.supplies;
  static const _song = PerkTextConstants.song;
  static const _prescription = PerkTextConstants.prescription;
  static const _doom = PerkTextConstants.doom;
  static const _bear = PerkTextConstants.bear;
  static const _command = PerkTextConstants.command;
  static const _berserker = PerkTextConstants.berserker;
  static const _doomstalker = PerkTextConstants.doomstalker;
  static const _bladeswarm = PerkTextConstants.bladeswarm;
  static const _atTheStartOfEachScenario =
      PerkTextConstants.atTheStartOfEachScenario;
  static const _atTheEndOfEachScenario =
      PerkTextConstants.atTheEndOfEachScenario;
  static const _ignoreItemMinusOneEffects =
      PerkTextConstants.ignoreItemMinusOneEffects;
  static const _ignoreItemMinusOneEffectsAndAdd =
      PerkTextConstants.ignoreItemMinusOneEffectsAndAdd;
  static const _ignoreItemMinusOneEffectsAndRemove =
      PerkTextConstants.ignoreItemMinusOneEffectsAndRemove;
  static const _ignoreNegativeItemEffects =
      PerkTextConstants.ignoreNegativeItemEffects;
  static const _ignoreNegativeItemEffectsAndAdd =
      PerkTextConstants.ignoreNegativeItemEffectsAndAdd;
  static const _ignoreNegativeScenarioEffects =
      PerkTextConstants.ignoreNegativeScenarioEffects;
  static const _ignoreNegativeScenarioEffectsAndAdd =
      PerkTextConstants.ignoreNegativeScenarioEffectsAndAdd;
  static const _ignoreScenarioEffects = PerkTextConstants.ignoreScenarioEffects;
  static const _ignoreScenarioEffectsAndAdd =
      PerkTextConstants.ignoreScenarioEffectsAndAdd;
  static const _ignoreScenarioEffectsAndRemove =
      PerkTextConstants.ignoreScenarioEffectsAndRemove;
  static const _onceEachScenario = PerkTextConstants.onceEachScenario;
  static const _wheneverYouLongRest = PerkTextConstants.wheneverYouLongRest;
  static const _wheneverYouShortRest = PerkTextConstants.wheneverYouShortRest;

  static String xp(int num) => 'xp$num';

  static final Map<String, List<Perks>> perks = {
    // BRUTE/BRUISER
    ClassCodes.brute: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_remove $_one -1 $_card and $_addLowercase $_one +1 $_card'),
        Perk('$_add $_two +1 $_cards', quantity: 2),
        Perk('$_add $_one +3 $_card'),
        Perk('$_add $_three $_rolling $_push 1 $_cards', quantity: 2),
        Perk('$_add $_two $_rolling $_pierce 3 $_cards'),
        Perk('$_add $_one $_rolling $_stun $_card', quantity: 2),
        Perk(
          '$_add $_one $_rolling $_disarm $_card and $_one $_rolling $_muddle $_card',
        ),
        Perk('$_add $_one $_rolling ADD $_targetDiamond $_card', quantity: 2),
        Perk('$_add $_one +1 "$_shield  Self" $_card'),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_one +1 $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('Replace one -1 card with one +1 card', quantity: 2),
        Perk(
          'Replace one -1 card with three +0 $_push 1 $_rolling cards',
          quantity: 2,
        ),
        Perk('$_replace two +0 cards with two +0 $_pierce 3 $_rolling cards'),
        Perk('$_replace one +0 card with two +1 cards', quantity: 2),
        Perk(
          '$_replace one +0 card with one +0 "$_plusOne $_targetCircle" $_rolling card',
          quantity: 2,
        ),
        Perk('Add one +0 $_stun $_rolling card', quantity: 2),
        Perk(
          'Add one +0 $_disarm $_rolling card and one +0 $_muddle $_rolling card',
        ),
        Perk('$_add $_one +3 card'),
        Perk('$_ignoreItemMinusOneEffectsAndAdd $_one +1 "$_shield 1" card'),
        Perk(
          '**Rested and Ready:** $_wheneverYouLongRest, add +1 $_move to your first move ability the following round',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          '$_replace $_one -1 $_card with $_one "$_shield 1" $_rolling $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one "Add this card to your '
          'active area. On the next attack targeting you performed by an '
          'adjacent enemy, discard this card to gain $_retaliate 2 for the '
          'attack" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk('$_add $_one +1 "$_heal 2, self" $_card', quantity: 2),
        Perk('$_add $_one +2 $_push 2 $_card', quantity: 2),
        Perk('$_add $_one +3 $_card'),
        Perk(
          '$_add $_one $_disarm $_rolling and $_one $_muddle $_rolling $_card',
        ),
        Perk('$_ignoreItemMinusOneEffectsAndAdd $_two +1 $_cards'),
        Perk(
          '$_onceEachScenario, during your turn, you may perform: $_loot 1, if this ability loots at least one money token, you may $_refresh one $_body item',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          '$_wheneverYouLongRest, $_addLowercase $_plusOne $_move to your first move ability the following round',
        ),
        Perk(
          'Each character gains advantage on their first attack during the first round of each scenario',
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // TINKERER
    ClassCodes.tinkerer: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_add $_two +1 $_cards'),
        Perk('$_add $_one +3 $_card'),
        Perk('$_add $_two $_rolling $_fire $_cards'),
        Perk('$_add $_three $_rolling $_muddle $_cards'),
        Perk('$_add $_one +1 $_wound $_card', quantity: 2),
        Perk('$_add $_one +1 $_immobilize $_card', quantity: 2),
        Perk('$_add $_one +1 $_heal 2 $_card', quantity: 2),
        Perk('$_add $_one +0 ADD $_targetDiamond $_card'),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards'),
        Perk('Replace one -1 card with one +1 card', quantity: 2),
        Perk('Replace one -2 card with one +0 card'),
        Perk('Replace one +0 card with one +0 "$_plusOne $_targetCircle" card'),
        Perk('Replace one +0 card with one +1 $_wound card', quantity: 2),
        Perk('Replace one +0 card with one +1 $_immobilize card', quantity: 2),
        Perk('Replace two +0 cards with three +0 $_muddle $_rolling cards'),
        Perk('Add one +3 card'),
        Perk('Add two +1 "$_heal 2, self" cards'),
        Perk('$_ignoreScenarioEffectsAndAdd two +0 $_fire $_rolling cards'),
        Perk(
          '**Rejuvenating Vapor:** $_wheneverYouLongRest, you may perform "$_heal 2, $_range 3"',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, $_targetCircle 1 ally" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_wound $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_poison $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one +2 "$_strengthen, $_targetCircle 1 ally" $_card',
          quantity: 3,
        ),
        Perk(
          '$_ignoreScenarioEffectsAndAdd $_one +0 "$_heal 1, $_targetCircle 1 ally" $_card',
        ),
        Perk(
          '$_onceEachScenario, one adjacent ally may use one of your *potion* $_pocket items during their turn without it becoming $_loss',
        ),
        Perk(
          'Whenever you perform an action with $_loss, you may $_wildElement',
        ),
        Perk(
          '$_wheneverYouLongRest, you may perform: $_heal 2, $_range 3',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SPELLWEAVER
    ClassCodes.spellweaver: [
      Perks([
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk('$_add $_two +1 $_cards', quantity: 2),
        Perk('$_add $_one +0 $_stun $_card'),
        Perk('$_add $_one +1 $_wound $_card'),
        Perk('$_add $_one +1 $_immobilize $_card'),
        Perk('$_add $_one +1 $_curse $_card'),
        Perk('$_add $_one +2 $_fire $_card', quantity: 2),
        Perk('$_add $_one +2 $_ice $_card', quantity: 2),
        Perk('$_add $_one $_rolling $_earth and $_one $_rolling $_air $_card'),
        Perk('$_add $_one $_rolling $_light and $_one $_rolling $_dark $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('Remove one -2 card'),
        Perk('Replace one -1 card with one +1 card', quantity: 2),
        Perk(
          'Replace one -1 card with one +0 $_air $_rolling card and one +0 $_earth $_rolling card',
        ),
        Perk(
          'Replace one -1 card with one +0 $_light $_rolling card and one +0 $_dark $_rolling card',
        ),
        Perk('Replace one +0 card with one +1 $_wound card'),
        Perk('Replace one +0 card with one +1 $_immobilize card'),
        Perk('Replace one +0 card with one +1 $_stun card'),
        Perk('Replace one +0 card with one +1 $_curse card'),
        Perk('Add one +2 $_fire card', quantity: 2),
        Perk('Add one +2 $_ice card', quantity: 2),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Etheric Bond:** $_wheneverYouShortRest, if *Reviving Ether* is in your discard pile, first return it to your hand',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wildElement $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_add $_plusTwo $_attack if drawn during an action with $_loss" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_curse $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_stun $_card', quantity: 2),
        Perk('$_add $_one +2 $_fire/$_ice $_card', quantity: 2),
        Perk('$_ignoreScenarioEffectsAndRemove $_one +0 $_card'),
        Perk(
          '$_onceEachScenario, when you would suffer $_damage, you may gain $_invisible and $_stun to negate the $_damage',
        ),
        Perk(
          '$_wheneverYouShortRest, if *Reviving Ether* is in your discard pile, first $_recover it',
        ),
        Perk(
          'At the end of each of your turns during which you performed an action with $_loss, gain $_bless',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SCOUNDREL
    ClassCodes.scoundrel: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_two $_rolling +1 $_cards', quantity: 2),
        Perk('$_add $_two $_rolling $_pierce 3 $_cards'),
        Perk('$_add $_two $_rolling $_poison $_cards', quantity: 2),
        Perk('$_add $_two $_rolling $_muddle $_cards'),
        Perk('$_add $_one $_rolling $_invisible $_card'),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards'),
        Perk('Replace one -1 card with one +1 card'),
        Perk(
          'Replace one -1 card with two +0 $_poison $_rolling cards',
          quantity: 2,
        ),
        Perk('Replace one -2 card with one +0 card'),
        Perk('Replace one +0 card with one +2 card', quantity: 2),
        Perk(
          'Replace two +0 cards with one +0 $_muddle $_rolling card and one +0 $_pierce 3 $_rolling card',
          quantity: 2,
        ),
        Perk('Add two +1 $_rolling cards', quantity: 2),
        Perk('Add one +0 "$_invisible, self", $_rolling card'),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Cloak of Invisibility:** $_onceEachScenario, during your turn, perform "$_invisible, self"',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      // SILENT KNIFE
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "Gain one money token if this attack targeted an adjacent enemy" $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk(
          '$_replace $_one +1 $_card with $_one +1 "$_invisible, self" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_disarm $_card', quantity: 2),
        Perk(
          'At the end of each of your rests, you may place one of your money tokens in the hex occupied by an enemy within $_range 3 to perform: $_attack 1, $_targetCircle that enemy, $_range 3',
        ),
        Perk(
          'Whenever you complete a city event, draw an attack modifier card as though you were performing an $_attack 4. Gain an amount of gold equal to the $_damage the attack would have dealt',
        ),
        Perk(
          '$_onceEachScenario, during your turn, you may perform: $_invisible, self',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // CRAGHEART
    ClassCodes.cragheart: [
      Perks([
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk('$_add $_one -2 $_card and $_two +2 $_cards'),
        Perk('$_add $_one +1 $_immobilize $_card', quantity: 2),
        Perk('$_add $_one +2 $_muddle $_card', quantity: 2),
        Perk('$_add $_two $_rolling $_push 2 $_cards'),
        Perk('$_add $_two $_rolling $_earth $_cards', quantity: 2),
        Perk('$_add $_two $_rolling $_air $_cards'),
        Perk(_ignoreNegativeItemEffects),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('Replace one -1 card with one +1 card', quantity: 3),
        Perk('Replace one +0 card with two +0 $_push 2 $_rolling cards'),
        Perk('Replace one +0 card with one +1 $_immobilize card', quantity: 2),
        Perk('Replace one +0 card with one +2 card', quantity: 2),
        Perk(
          'Add one +2 $_muddle card and one +0 $_air $_rolling card',
          quantity: 2,
        ),
        Perk('Add four +0 $_earth $_rolling cards'),
        Perk(_ignoreItemMinusOneEffects),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Earthquakes:** Whenever a new room is revealed, control all enemies in the newly revealed room: $_move 1, this movement must end in an empty hex',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "Create one 1-hex obstacle tile in an empty hex adjacent to the target" $_rolling $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_two +1 $_push 1 $_cards',
          quantity: 2,
        ),
        Perk('$_add $_one +2 $_immobilize $_card', quantity: 3),
        Perk('$_ignoreScenarioEffectsAndAdd $_one $_muddle $_rolling $_card'),
        Perk(_ignoreItemMinusOneEffects),
        Perk(
          'Once each $_scenario, during your turn, you may destroy one 1-hex obstacle within $_range 5 to $_teleport to the hex it occupied',
        ),
        Perk(
          'At the end of each of your rests, you may destroy one 1-hex obstacle within $_range 3 to $_earth',
        ),
        Perk(
          'Whenever a new room is revealed, control all enemies in the newly revealed room: $_move 1, this movement must end in an empty hex',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // MINDTHIEF
    ClassCodes.mindthief: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_add $_one +2 $_ice $_card', quantity: 2),
        Perk('$_add $_two $_rolling +1 $_cards', quantity: 2),
        Perk('$_add $_three $_rolling $_pull 1 $_cards'),
        Perk('$_add $_three $_rolling $_muddle $_cards'),
        Perk('$_add $_two $_rolling $_immobilize $_cards'),
        Perk('$_add $_one $_rolling $_stun $_card'),
        Perk(
          '$_add $_one $_rolling $_disarm $_card and $_one $_rolling $_muddle $_card',
        ),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards'),
        Perk(
          'Replace one -1 card with one +0 $_immobilize $_rolling card',
          quantity: 2,
        ),
        Perk('Replace one -2 card with one +0 card'),
        Perk('Replace two +0 cards with three +0 $_push 1 $_rolling cards'),
        Perk('Replace two +0 cards with three +0 $_muddle $_rolling cards'),
        Perk('Replace two +1 cards with two +2 cards'),
        Perk('Add one +2 $_ice card', quantity: 2),
        Perk('Add two +1 $_rolling cards', quantity: 2),
        Perk('Add one +0 $_stun $_rolling card'),
        Perk(
          'Add one +0 $_disarm $_rolling card and one +0 $_muddle $_rolling card',
        ),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Lying Low:** You are considered to be last in initiative order when determining monster focus',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk(
          '$_replace $_two -1 $_cards with $_one +0 "After the attack ability, control the target: $_move 1" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "Add $_plusOne $_attack for each $_negative condition the target has" $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_two +1 $_immobilize $_cards'),
        Perk('$_add $_one +2 $_ice $_card', quantity: 3),
        Perk('$_add $_one "$_invisible, self" $_rolling $_card', quantity: 2),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_rolling $_card'),
        Perk(
          'Whenever you control the attack of an enemy, you may have the enemy use your attack modifier deck',
        ),
        Perk(
          'You are considered to be last in initiative order when determining monster focus',
        ),
        Perk(
          'At the end of each of your rests, you may $_consume$_ice/$_dark to control one enemy within $_range 5: $_attack 1',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SUNKEEPER
    ClassCodes.sunkeeper: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card'),
        Perk('$_add $_two $_rolling +1 $_cards', quantity: 2),
        Perk('$_add $_two $_rolling $_heal 1 $_cards', quantity: 2),
        Perk('$_add $_one $_rolling $_stun $_card'),
        Perk('$_add $_two $_rolling $_light $_cards', quantity: 2),
        Perk('$_add $_two $_rolling "$_shield 1, Self" $_cards'),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_two +1 $_cards'),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('Remove four +0 cards'),
        Perk(
          'Replace one -1 card with two +0 $_light $_rolling cards',
          quantity: 2,
        ),
        Perk(
          'Replace one -1 card with one +0 "$_shield 1" $_rolling card',
          quantity: 2,
        ),
        Perk('Replace one +0 card with one +2 card'),
        Perk('Add two +1 $_rolling cards', quantity: 2),
        Perk('Add one +0 $_stun $_rolling card'),
        Perk('Add two +0 "$_heal 1, self" $_rolling cards', quantity: 2),
        Perk('$_ignoreItemMinusOneEffects, and add two +1 cards'),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Shielding Light:** Whenever one of your heals would cause an ally\'s current hit point value to increase beyond their maximum hit point value, that ally gains $_ward',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_two +0 $_light $_cards',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_shield 1" $_rolling $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_two +1 "$_heal 1, $_range 3" $_cards', quantity: 2),
        Perk(
          '$_add $_one -1 "You or an adjacent ally may $_recover one level 1 card from the discard pile" $_card',
        ),
        Perk('$_add $_one $_stun $_rolling $_card'),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_card'),
        Perk('$_ignoreItemMinusOneEffectsAndRemove $_one -1 $_card'),
        Perk(
          'Whenever you open one or more doors during your turn, gain $_shield 1, $_retaliate 1 for the round',
          quantity: 2,
          grouped: true,
        ),
        Perk('$_wheneverYouLongRest, you may $_light'),
        Perk(
          'Whenever one of your heals would cause an ally\'s current hit point value to increase beyond their maximum hit point value, that ally gains $_ward',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // QUARTERMASTER
    ClassCodes.quartermaster: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_two $_rolling +1 $_cards', quantity: 2),
        Perk('$_add $_three $_rolling $_muddle $_cards'),
        Perk('$_add $_two $_rolling $_pierce 3 $_cards'),
        Perk('$_add $_one $_rolling $_stun $_card'),
        Perk('$_add $_one $_rolling ADD $_targetDiamond $_card'),
        Perk('$_add $_one +0 "$_recover an item" $_card', quantity: 3),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_two +1 $_cards'),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards', quantity: 2),
        Perk('Replace two +0 cards with two +0 $_pierce 3 $_rolling cards'),
        Perk('Replace one +0 card with one +0 "$_plusOne $_targetCircle" card'),
        Perk('Replace one +0 card with one +2 card', quantity: 2),
        Perk('Add one +0 "$_recover one item" card', quantity: 3),
        Perk('Add two +1 $_rolling cards', quantity: 2),
        Perk('Add one +0 $_stun $_rolling card'),
        Perk('$_ignoreItemMinusOneEffects, and add two +1 cards'),
        Perk(
          '**Well Supplied:** $_onceEachScenario, during your turn, if you have a persistent Quartermaster ability card in your active area, you may recover up to four cards from your discard pile',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk(
          '$_replace $_two -1 $_cards with $_one +0 $_muddle $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +0 "Gain 10 $_supplies" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_two $_pierce 3 $_rolling $_cards',
        ),
        Perk(
          '$_replace $_one +1 $_card with $_two +0 "Gain the *Barbed Strip* or *Iron Plate* item" $_cards',
          quantity: 2,
        ),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk(
          '$_add $_one "Gain the *Scroll of Relocation* or *Sharpened Dirk* item" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_add $_one $_stun $_rolling $_card', quantity: 2),
        Perk('$_ignoreItemMinusOneEffectsAndRemove $_one +0 $_card'),
        Perk('You may bring one additional $_pocket item into each $_scenario'),
        Perk(
          'Your party may purchase items from each faction as though the items\' costs were five gold less and your reputation with that faction was two greater',
        ),
        Perk(
          '$_wheneverYouLongRest, gain 10 $_supplies',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SUMMONER/SOULTETHER
    ClassCodes.summoner: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk('$_add $_one +2 $_card', quantity: 2),
        Perk('$_add $_two $_rolling $_wound $_cards'),
        Perk('$_add $_two $_rolling $_poison $_cards'),
        Perk('$_add $_two $_rolling $_heal 1 $_cards', quantity: 3),
        Perk('$_add $_one $_rolling $_fire and $_one $_rolling $_air $_card'),
        Perk('$_add $_one $_rolling $_dark and $_one $_rolling $_earth $_card'),
        Perk('$_ignoreNegativeScenarioEffectsAndAdd $_two +1 $_cards'),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards'),
        Perk('Replace one -1 card with one +1 card', quantity: 3),
        Perk('Replace one -2 card with one +0 card'),
        Perk(
          'Replace two +0 cards with one +0 $_fire $_rolling card and one +0 $_earth $_rolling card',
        ),
        Perk(
          'Replace two +0 cards with one +0 $_air $_rolling card and one +0 $_dark $_rolling card',
        ),
        Perk('Replace two +1 cards with two +2 cards'),
        Perk('Add two +0 $_wound $_rolling cards'),
        Perk('Add two +0 $_poison $_rolling cards'),
        Perk('Add three +0 "$_heal 1, self" $_rolling cards', quantity: 2),
        Perk('$_ignoreScenarioEffectsAndAdd two +1 cards'),
        Perk(
          '**Phase Out:** $_onceEachScenario, during ordering of initiative, after all ability cards have been revealed, all your summons gain $_invisible',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "After the attack ability, grant one of your summons: $_teleport 2" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_invisible, $_targetCircle 1 of your summons" $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_two $_wound $_rolling $_cards'),
        Perk('$_replace $_one +0 $_card with $_two $_poison $_rolling $_cards'),
        Perk('$_replace $_two +1 $_cards with $_two +1 $_curse $_cards'),
        Perk('$_add $_one +2 $_fire/$_air $_card'),
        Perk('$_add $_one +2 $_fire/$_dark $_card'),
        Perk('$_add $_one +2 $_air/$_dark $_card'),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk(
          'At the beginning of each round in which you long rest, all your summons gain $_shield 1 for the round',
        ),
        Perk(
          '$_onceEachScenario, during your turn, $_teleport one of your summons to an empty hex adjacent to you',
        ),
        Perk(
          '$_onceEachScenario, during ordering of initiative, after all ability cards have been revealed, all your summons gain $_invisible',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // NIGHTSHROUD
    ClassCodes.nightshroud: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove four +0 $_cards'),
        Perk('$_add $_one -1 $_dark $_card', quantity: 2),
        Perk(
          '$_replace $_one -1 $_dark $_card with $_one +1 $_dark $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +1 $_invisible $_card', quantity: 2),
        Perk('$_add $_three $_rolling $_muddle $_cards', quantity: 2),
        Perk('$_add $_two $_rolling $_heal 1 $_cards'),
        Perk('$_add $_two $_rolling $_curse $_cards'),
        Perk('$_add $_one $_rolling ADD $_targetDiamond $_card'),
        Perk('$_ignoreNegativeScenarioEffectsAndAdd $_two +1 $_cards'),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards', quantity: 2),
        Perk('Replace one -2 card with one -1 $_dark card'),
        Perk(
          'Replace one +0 card with one +0 "$_plusOne $_targetCircle" $_rolling card',
        ),
        Perk(
          'Replace two +0 cards with three +0 $_muddle $_rolling cards',
          quantity: 2,
        ),
        Perk('Replace one +1 card with one +1 $_invisible card', quantity: 2),
        Perk('Add one +1 $_dark card', quantity: 2),
        Perk('Add two +0 $_curse $_rolling cards'),
        Perk('Add two +0 "$_heal 1, self" $_rolling cards'),
        Perk('$_ignoreScenarioEffectsAndAdd two +1 cards'),
        Perk(
          '**Empowering Night:** At the start of the scenario, you may discard two cards to add a card with an action containing a persistent symbol from your pool to your hand and immediately play it, performing that action',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk(
          '$_replace $_one -1 $_card with $_two "After the attack ability, grant one adjacent ally or self: $_teleport 2" $_rolling $_cards',
        ),
        Perk('$_replace $_one $_null $_card with $_one -2 $_shuffle $_card'),
        Perk(
          '$_replace $_two +0 $_cards with $_two +1 "If this attack kills the target, shuffle one $_curse card into the monster attack modifier deck" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 $_dark $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +1 $_card with $_one +0 "Place one $_tear in a hex adjacent to the target" $_card',
          quantity: 2,
        ),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk('$_wheneverYouLongRest, you may $_dark'),
        Perk(
          '$_onceEachScenario, during your turn, place one $_tear in an adjacent hex',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'If a $_curse causes an enemy to deal no $_damage during its attack, that enemy suffers $_damage 3',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // PLAGUEHERALD
    ClassCodes.plagueherald: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_two +1 $_cards'),
        Perk('$_add $_one +1 $_air $_card', quantity: 3),
        Perk('$_add $_three $_rolling $_poison $_cards'),
        Perk('$_add $_two $_rolling $_curse $_cards'),
        Perk('$_add $_two $_rolling $_immobilize $_cards'),
        Perk('$_add $_one $_rolling $_stun $_card', quantity: 2),
        Perk('$_ignoreNegativeScenarioEffectsAndAdd $_one +1 $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('Remove one -2 card'),
        Perk('Replace one -1 card with one +1 card', quantity: 3),
        Perk('Replace one +0 card with one +2 card', quantity: 2),
        Perk('Add three +1 $_air cards'),
        Perk('Add three +0 $_poison $_rolling cards'),
        Perk('Add two +0 $_immobilize $_rolling cards'),
        Perk('Add one +0 $_stun $_rolling card', quantity: 2),
        Perk('Add two +0 $_curse $_rolling cards'),
        Perk('$_ignoreScenarioEffectsAndAdd one +1 card'),
        Perk(
          '**Xorn\'s Boon:** $_onceEachScenario, during your turn, cause each enemy that has $_poison to suffer $_damage 1 and gain $_muddle and each ally who has $_poison to suffer $_damage 1 and gain $_strengthen',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "Give the target or one enemy within $_range 2 of the target $_brittle" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_curse $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card',
          quantity: 2,
        ),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk('$_add $_one +1 $_stun $_card', quantity: 2),
        Perk(
          '$_add $_three +0 "Give the target or one enemy within $_range 2 of the target $_poison" $_rolling $_cards',
        ),
        Perk('$_add $_two "$_heal 1, $_targetCircle 1 ally" $_rolling $_cards'),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_card'),
        Perk('You have $_flying'),
        Perk(
          'Whenever you heal from a long rest, you may remove $_poison from one ally to add $_plusOne $_heal',
        ),
        Perk(
          '$_onceEachScenario, when an enemy that has $_brittle would die, first control that enemy and have it perform the abilities on its ability card, adding $_brittle to all its attacks, then it dies',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // BERSERKER
    ClassCodes.berserker: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 2),
        Perk(
          '$_replace $_one +0 $_card with $_one $_rolling +2 $_card',
          quantity: 2,
        ),
        Perk('$_add $_two $_rolling $_wound $_cards', quantity: 2),
        Perk('$_add $_one $_rolling $_stun $_card', quantity: 2),
        Perk('$_add $_one $_rolling +1 $_disarm $_card'),
        Perk('$_add $_two $_rolling $_heal 1 $_cards'),
        Perk('$_add $_one +2 $_fire $_card', quantity: 2),
        Perk(_ignoreNegativeItemEffects),
      ], variant: Variant.base),
      Perks([
        Perk('Remove two -1 cards'),
        Perk('Replace one -1 card with one +1 card', quantity: 2),
        Perk(
          'Replace one +0 card with two +0 $_wound $_rolling cards',
          quantity: 2,
        ),
        Perk('Replace one +1 card with one +2 $_rolling card', quantity: 2),
        Perk('Add one +2 $_fire card', quantity: 2),
        Perk('Add one +0 $_stun $_rolling card', quantity: 2),
        Perk('Add one +1 $_disarm $_rolling card'),
        Perk('Add two +0 "$_heal 1, self" $_rolling cards'),
        Perk(_ignoreItemMinusOneEffects),
        Perk(
          '**Rapid Recovery:** Whenever you heal from a long rest, add $_plusOne $_heal',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_heal 1, self" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "You may suffer $_damage 2 to add $_plusTwo $_attack" $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_two $_wound $_rolling $_cards'),
        Perk('$_add $_one +2 $_fire $_card', quantity: 2),
        Perk('$_add $_one $_stun $_rolling $_card'),
        Perk(
          '$_add $_one 2x "Suffer $_damage equal to half your current hit point value (rounded down)" $_card',
        ),
        Perk('$_ignoreItemMinusOneEffectsAndAdd $_one +1 $_card'),
        Perk('Whenever you heal from a long rest, $_addLowercase +1 $_heal'),
        Perk(
          '$_onceEachScenario, when $_damage from an attack would reduce your current hit point value to less than 1, instead set your current hit point value to 1 and perform: $_attack 2, $_targetCircle the attacker',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'At the end of each of your turns, you may control all adjacent enemies: $_attack $_plusZero, $_targetCircle $_berserker',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SOOTHSINGER
    ClassCodes.soothsinger: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card'),
        Perk('$_replace $_two +1 $_cards with $_one +4 $_card', quantity: 2),
        Perk('$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_disarm $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_wound $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_poison $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_curse $_card'),
        Perk('$_replace $_one +0 $_card with $_one +3 $_muddle $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_stun $_card'),
        Perk('$_add $_three $_rolling +1 $_cards'),
        Perk('$_add $_two $_rolling $_curse $_cards', quantity: 2),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_stun $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_immobilize $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_disarm $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_wound $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_poison $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_curse $_card'),
        Perk('$_replace $_one +0 $_card with $_one +3 $_muddle $_card'),
        Perk('$_replace $_two +1 $_cards with $_one +4 $_card', quantity: 2),
        Perk('$_add $_three +1 $_rolling $_cards'),
        Perk('$_add $_three +0 $_curse $_rolling $_cards'),
        Perk(
          '**Storyteller:** $_atTheEndOfEachScenario, each character in that scenario gains 8 experience if you successfully completed your battle goal',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk(
          '$_replace $_one -2 $_card with $_one -2 "$_bless, $_targetCircle 2" $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "Skip moving your character tokens on active $_song at the end of this round" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_stun $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "$_strengthen, $_targetCircle 1 ally" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card and $_one +1 $_card with $_two +2 $_cards',
          quantity: 2,
        ),
        Perk(
          '$_add $_one "Grant one ally: $_move 2 or $_attack 2" $_rolling $_card',
          quantity: 3,
        ),
        Perk('$_add $_three $_curse $_rolling $_cards'),
        Perk(
          '$_atTheEndOfEachScenario, each character in that scenario gains ${xp(8)} if you completed your battle goal',
        ),
        Perk(
          'Whenever you perform a $_song action, if you have any unused Notes, gain one Note of your choice in addition to any other Note gained that round',
        ),
        Perk(
          'During ordering of initiative in rounds in which you declare a long rest, gain one Note of your choice, and each of your allies may decrease their initiative by 10',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // DOOMSTALKER
    ClassCodes.doomstalker: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_replace $_two +0 $_cards with $_two +1 $_cards', quantity: 3),
        Perk('$_add $_two $_rolling +1 $_cards', quantity: 2),
        Perk('$_add $_one +2 $_muddle $_card'),
        Perk('$_add $_one +1 $_poison $_card'),
        Perk('$_add $_one +1 $_wound $_card'),
        Perk('$_add $_one +1 $_immobilize $_card'),
        Perk('$_add $_one +0 $_stun $_card'),
        Perk('$_add $_one $_rolling ADD $_targetDiamond $_card', quantity: 2),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 4),
        Perk(
          '$_replace $_one +0 $_card with $_one +0 "$_plusOne $_targetCircle" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_poison $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_muddle $_card'),
        Perk('$_add $_two +1 $_rolling $_cards', quantity: 2),
        Perk('$_ignoreScenarioEffectsAndAdd one +1 $_immobilize card'),
        Perk(
          '**Marked for the Hunt:** At the beginning of each round in which you long rest, you may choose one ally to gain the benefits of any of your active Dooms as if the Dooms were in that ally\'s active area for the round',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one -1 "$_doomstalker performs: $_attack 2, $_range 5" $_card',
          quantity: 3,
        ),
        Perk('$_replace $_two +0 $_cards with $_two +1 $_cards', quantity: 2),
        Perk(
          '$_add $_one +0 "Grant one of your summons adjacent to the target: $_attack $_plusZero" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +3 $_card', quantity: 2),
        Perk('$_add $_one $_stun $_rolling $_card', quantity: 2),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_rolling $_card'),
        Perk(
          '$_atTheStartOfEachScenario, reveal the top $_card of each monster ability $_card deck in the $_scenario',
        ),
        Perk(
          '$_wheneverYouLongRest, after you $_recover your $_cards from your discard pile, you may play one $_card from your hand to perform a $_doom action of the card',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'On each of your summons\' turns, you may have them skip their turn and instead perform $_move $_plusZero treating you as their focus',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // SAWBONES
    ClassCodes.sawbones: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_one $_rolling +2 $_card', quantity: 2),
        Perk('$_add $_one +1 $_immobilize $_card', quantity: 2),
        Perk('$_add $_two $_rolling $_wound $_cards', quantity: 2),
        Perk('$_add $_one $_rolling $_stun $_card'),
        Perk('$_add $_one $_rolling $_heal 3 $_card', quantity: 2),
        Perk('$_add $_one +0 "$_recover an item" $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wound $_rolling $_card',
          quantity: 3,
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_immobilize $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +0 "$_recover one item" $_card'),
        Perk('$_add $_one +2 $_rolling $_card', quantity: 2),
        Perk('$_add $_one +0 $_stun $_rolling $_card'),
        Perk('$_add $_one +0 "$_heal 3, self" $_rolling $_card', quantity: 2),
        Perk(
          '**Revitalizing Medicine:** Whenever an ally performs the Heal ability of *Medical Pack* or *Large Medical Pack*, that character may first remove one negative condition',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk(
          '$_replace $_one -2 $_card with $_one -2 "Give one adjacent ally or self one medical pack" $_card',
        ),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "You may gain $_disarm to add $_stun" $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_two +1 "Add $_plusOne $_attack if an ally has an active $_prescription" $_cards',
          quantity: 2,
        ),
        Perk('$_add $_one "$_heal 3, $_range 1" $_rolling $_card', quantity: 2),
        Perk(
          'Add $_plusOne $_heal to all heal abilities on "Medical Pack" ability cards',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'Each City Phase after completing a scenario, your or one ally\'s donation to the Sanctuary of the Great Oak is free',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'At the end of each of your rests, if an ally has an active $_prescription, gain one "Medical Pack" ability card and move the token on one ally\'s active $_prescription backward one slot',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // ELEMENTALIST
    ClassCodes.elementalist: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_three +0 $_fire $_cards'),
        Perk('$_add $_three +0 $_ice $_cards'),
        Perk('$_add $_three +0 $_air $_cards'),
        Perk('$_add $_three +0 $_earth $_cards'),
        Perk(
          '$_replace $_two +0 $_cards with $_one +0 $_fire $_card and $_one +0 $_earth $_card',
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +0 $_ice $_card and $_one +0 $_air $_card',
        ),
        Perk('$_add $_two +1 $_push 1 $_cards'),
        Perk('$_add $_one +1 $_wound $_card'),
        Perk('$_add $_one +0 $_stun $_card'),
        Perk('$_add $_one +0 ADD $_targetDiamond $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card'),
        Perk('$_remove $_four +0 $_cards'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_plusOne $_targetCircle" $_card',
        ),
        Perk('$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_wound $_card'),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk('$_add $_four +0 $_fire $_cards'),
        Perk('$_add $_four +0 $_ice $_cards'),
        Perk('$_add $_four +0 $_air $_cards'),
        Perk('$_add $_four +0 $_earth $_cards'),
        Perk(_ignoreScenarioEffects),
        Perk(
          '**Elemental Proficiency:** $_atTheStartOfEachScenario and whenever you long rest, $_wildElement',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk('$_replace $_one -1 $_card with $_one +0 $_fire/$_air $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_fire/$_earth $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_ice/$_air $_card'),
        Perk('$_replace $_one -1 $_card with $_one +0 $_ice/$_earth $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_fire/$_ice $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_air/$_earth $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_light/$_dark $_card',
          quantity: 2,
        ),
        Perk('$_add $_two $_wildElement $_rolling $_cards', quantity: 2),
        Perk(
          '$_ignoreScenarioEffectsAndAdd $_one $_wildElement $_rolling $_card',
        ),
        Perk('$_atTheStartOfEachScenario, you may $_wildElement'),
        Perk('$_wheneverYouLongRest, $_consume$_wildElement : $_wildElement'),
        Perk(
          '$_fire, $_ice, $_air, and $_earth do not wane at the end of each round',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // BEAST TYRANT
    ClassCodes.beastTyrant: [
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk('$_add $_one +1 $_wound $_card', quantity: 2),
        Perk('$_add $_one +1 $_immobilize $_card', quantity: 2),
        Perk('$_add $_two $_rolling $_heal 1 $_cards', quantity: 3),
        Perk('$_add $_two $_rolling $_earth $_cards'),
        Perk(_ignoreNegativeScenarioEffects),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_card', quantity: 3),
        Perk('$_replace $_one +0 $_card with $_one +2 $_card', quantity: 2),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_wound $_card',
          quantity: 2,
        ),
        Perk('$_add $_two +1 $_immobilize $_cards'),
        Perk('$_add $_two +0 "$_heal 1, self" $_rolling $_cards', quantity: 3),
        Perk(
          '$_ignoreScenarioEffectsAndAdd $_two +0 $_earth $_rolling $_cards',
        ),
        Perk(
          '**Bear Treat:** During each round in which you long rest, at initiative 99, you may skip the bear\'s normal turn to Command: "$_move 3; $_loot 1; If the loot ability was performed: $_heal 3, self"',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.frosthavenCrossover),
      // WILDFURY
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one "$_heal 2, $_targetCircle $_bear" $_rolling $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_wound $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 "Add $_plusOne $_attack if the Wildfury and $_bear are within $_range 4 of each other" $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +2 $_card with $_one +4 $_card'),
        Perk('$_add $_two +1 $_air/$_earth $_cards', quantity: 2),
        Perk('$_add $_one +2 $_push $_card', quantity: 2),
        Perk(
          '$_ignoreScenarioEffectsAndAdd $_one +1 "$_safeguard, $_targetCircle 1 ally" $_card',
        ),
        Perk(
          'Whenever $_bear is attacked, treat any 2x attack modifier $_card the enemy draws as +0 instead',
        ),
        Perk(
          '$_onceEachScenario, during your turn, $_command: $_move 4.\nIf $_bear exits a hex adjacent to you during this movement, you may $_teleport to an empty hex adjacent to $_bear at the end of the movement',
        ),
        Perk(
          'At the start or end of each of your long rests, you may $_air/$_earth and reduce your current hit point value by X (X must be at least 1) to $_command: $_heal X, self',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // BLADESWARM (Envelope X)
    ClassCodes.bladeswarm: [
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk('$_remove four +0 $_cards'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_air $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_earth $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_light $_card'),
        Perk('$_replace $_one -1 $_card with $_one +1 $_dark $_card'),
        Perk('$_add $_two $_rolling $_heal 1 $_cards', quantity: 2),
        Perk('$_add $_one +1 $_wound $_card', quantity: 2),
        Perk('$_add $_one +1 $_poison $_card', quantity: 2),
        Perk('$_add $_one +2 $_muddle $_card'),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_one +1 $_card'),
        Perk('$_ignoreNegativeScenarioEffectsAndAdd $_one +1 $_card'),
      ], variant: Variant.base),
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wound $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_poison $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +1 $_air $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_earth $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_light $_card'),
        Perk('$_replace $_one +0 $_card with $_one +1 $_dark $_card'),
        Perk('$_add $_one +2 $_muddle $_card', quantity: 2),
        Perk('$_add $_two $_heal 1 $_rolling $_cards', quantity: 2),
        Perk('$_ignoreNegativeItemEffectsAndAdd $_one +1 $_card'),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_card'),
        Perk(
          '**Spinning Up:** At the start of your first turn each scenario, you may play one card from your hand to perform a persistent loss action of that card',
        ),
      ], variant: Variant.frosthavenCrossover),
      Perks([
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wound $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_poison $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_air/$_dark $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 $_earth/$_light $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +0 "$_add $_plusOne for each card with $_loss in $_bladeswarm\'s active area" $_card',
          quantity: 2,
        ),
        Perk('$_ignoreScenarioEffectsAndAdd $_one +1 $_card'),
        Perk('$_ignoreItemMinusOneEffectsAndAdd $_one +1 $_card'),
        Perk(
          '$_wheneverYouLongRest, you may $_teleport to the hex occupied by one of your summons and simultaneously $_teleport that summon to the hex you occupied',
        ),
        Perk(
          '$_onceEachScenario, when you perform an action with $_loss, you may immediately play one card from your hand to perform an action with $_loss of the card',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'You may additionally bring four $_oneHand items, two $_twoHand items, or two $_oneHand items and one $_twoHand item into each $_scenario',
          quantity: 3,
          grouped: true,
        ),
      ], variant: Variant.gloomhaven2E),
    ],
    // DIVINER (Forgotten Circles)
    ClassCodes.diviner: [
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_two +1 $_cards with $_one +3 "$_shield 1, Self" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_shield 1, Affect any Ally" $_card',
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_dark $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_light $_card'),
        Perk('$_replace $_one +0 $_card with $_one +3 $_muddle $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_curse $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 "$_regenerate, Self" $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +1 "$_heal 2, Affect any Ally" $_card',
        ),
        Perk('$_add $_two $_rolling "$_heal 1, Self" $_cards'),
        Perk('$_add $_two $_rolling $_curse $_cards'),
        Perk('$_ignoreNegativeScenarioEffectsAndAdd $_two +1 $_cards'),
      ], variant: Variant.base),
      Perks([
        Perk('$_remove $_two -1 $_cards', quantity: 2),
        Perk('$_remove $_one -2 $_card'),
        Perk(
          '$_replace $_two +1 $_cards with $_one +3 "SHIELD 1" $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "Any ally gains SHIELD 1" $_card',
        ),
        Perk('$_replace $_one +0 $_card with $_one +2 $_dark $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_light $_card'),
        Perk('$_replace $_one +0 $_card with $_one +3 $_muddle $_card'),
        Perk('$_replace $_one +0 $_card with $_one +2 $_curse $_card'),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 "$_regenerate, self" $_card',
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +1 "$_heal 2, $_targetCircle 1 ally" $_card',
        ),
        Perk('$_add $_two +0 $_curse $_rolling $_cards'),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk(
          '**Tip the Scales:** Whenever you rest, you may look at the top card of one attack modifier deck, then you may $_consume$_light/$_dark to place one card on the bottom of the deck',
        ),
      ], variant: Variant.frosthavenCrossover),
    ],
  };
}
