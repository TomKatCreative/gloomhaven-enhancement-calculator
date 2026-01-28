import 'package:gloomhaven_enhancement_calc/data/perks/perk_text_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

/// Perk definitions for Mercenary Pack classes (2025).
///
/// Includes: Anaphi, Cassandra, Hail, Satha
class MercenaryPacksPerks {
  // Alias for constants to keep perk definitions readable
  static const _add = PerkTextConstants.add;
  static const _one = PerkTextConstants.one;
  static const _two = PerkTextConstants.two;
  static const _card = PerkTextConstants.card;
  static const _cards = PerkTextConstants.cards;
  static const _replace = PerkTextConstants.replace;
  static const _remove = PerkTextConstants.remove;
  static const _rolling = PerkTextConstants.rolling;

  // Effects and conditions
  static const _damage = PerkTextConstants.damage;
  static const _poison = PerkTextConstants.poison;
  static const _stun = PerkTextConstants.stun;
  static const _invisible = PerkTextConstants.invisible;
  static const _strengthen = PerkTextConstants.strengthen;
  static const _bless = PerkTextConstants.bless;
  static const _wound = PerkTextConstants.wound;
  static const _immobilize = PerkTextConstants.immobilize;
  static const _muddle = PerkTextConstants.muddle;
  static const _heal = PerkTextConstants.heal;
  static const _safeguard = PerkTextConstants.safeguard;
  static const _shield = PerkTextConstants.shield;
  static const _ward = PerkTextConstants.ward;
  static const _disarm = PerkTextConstants.disarm;
  static const _pull = PerkTextConstants.pull;

  // Actions
  static const _attack = PerkTextConstants.attack;
  static const _move = PerkTextConstants.move;
  static const _range = PerkTextConstants.range;
  static const _targetCircle = PerkTextConstants.targetCircle;
  static const _section = PerkTextConstants.section;
  static const _plusOne = PerkTextConstants.plusOne;

  // Elements
  static const _air = PerkTextConstants.air;
  static const _dark = PerkTextConstants.dark;
  static const _light = PerkTextConstants.light;
  static const _ice = PerkTextConstants.ice;
  static const _wildElement = PerkTextConstants.wildElement;

  // Class-specific
  static const _rift = PerkTextConstants.rift;
  static const _resolve = PerkTextConstants.resolve;
  static const _hail = PerkTextConstants.hail;

  // Scenario-related
  static const _scenario = PerkTextConstants.scenario;
  static const _ignoreScenarioEffectsAndRemove =
      PerkTextConstants.ignoreScenarioEffectsAndRemove;
  static const _ignoreScenarioEffectsAndAdd =
      PerkTextConstants.ignoreScenarioEffectsAndAdd;
  static const _ignoreItemMinusOneEffects =
      PerkTextConstants.ignoreItemMinusOneEffects;
  static const _onceEachScenario = PerkTextConstants.onceEachScenario;
  static const _wheneverYouLongRest = PerkTextConstants.wheneverYouLongRest;
  static const _wheneverYouShortRest = PerkTextConstants.wheneverYouShortRest;

  static final Map<String, List<Perks>> perks = {
    ClassCodes.anaphi: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_poison $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "Add $_plusOne $_attack when drawn by a summon" $_card',
          quantity: 2,
        ),
        Perk('$_replace $_one +0 $_card with $_one +0 $_stun $_card'),
        Perk(
          '$_replace $_one +1 $_card with $_one +1 "$_invisible, self" $_card',
          quantity: 2,
        ),
        Perk('$_add $_one +2 $_air/$_dark $_card', quantity: 3),
        Perk(
          '$_add $_one +2 "$_strengthen, $_targetCircle 1 of your summons" $_card',
          quantity: 2,
        ),
        Perk('$_ignoreScenarioEffectsAndRemove $_one +0 $_card'),
        Perk('$_wheneverYouLongRest, you may $_air/$_dark'),
        Perk(
          '$_onceEachScenario, during your turn, all enemies adjacent to a wall suffer $_damage 1',
        ),
        Perk(
          'At the start of the first round of each $_scenario, after all ability cards have been revealed, control one enemy within $_range 5: $_move 2',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.cassandra: [
      Perks([
        Perk('$_remove $_one -2 $_card'),
        Perk('$_remove $_two -1 $_cards'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 "$_bless, $_targetCircle self or 1 ally" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 "Add $_plusOne $_attack if the top card of the monster attack modifier deck is revealed" $_card',
          quantity: 3,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +2 $_light/$_dark $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one +1 "Place this card in your active area. When you next place a $_rift, discard this card to place another $_rift within $_range 1 of it" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk(
          '$_wheneverYouLongRest, you may read one unread $_section from the current $_scenario\'s "Section Links"',
        ),
        Perk(
          'Whenever you place a $_rift, you may perform "$_pull 1, $_targetCircle 1 ally or enemy, $_range 1" as if you occupied a hex containing a $_rift',
          quantity: 2,
          grouped: true,
        ),
        Perk(
          'Whenever a deck is shuffled, you may set aside all revealed cards from that deck and place them back on top after shuffling',
          quantity: 2,
          grouped: true,
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.hail: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_wound or $_immobilize $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +1 $_wildElement $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 $_poison or $_muddle $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one +0 $_card with $_one +1 "$_heal 1, $_targetCircle 1 ally" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk('$_add $_one +1 $_stun $_card', quantity: 2),
        Perk(
          '$_add $_one +3 "$_safeguard, $_targetCircle 1 ally" $_card',
          quantity: 2,
        ),
        Perk('$_ignoreScenarioEffectsAndAdd $_two +1 $_cards'),
        Perk('$_wheneverYouShortRest, you may choose which $_card to lose'),
        Perk(
          'Your and your allies\' enhancements cost five gold less and whenever an ally enhances a $_card, you gain five gold',
        ),
        Perk(
          '$_add $_one +1 "$_hail gains 1 $_resolve" $_card to the monster attack modifier deck',
        ),
      ], variant: Variant.base),
    ],
    ClassCodes.satha: [
      Perks([
        Perk('$_replace $_one -2 $_card with $_one +0 $_card'),
        Perk(
          '$_replace $_one -1 $_card with $_one "$_shield 1" $_rolling $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_one -1 $_card with $_one +0 $_ice $_card',
          quantity: 2,
        ),
        Perk(
          '$_replace $_two +0 $_cards with $_one +1 "$_heal 1, $_targetCircle 1 ally and self" $_card',
          quantity: 2,
        ),
        Perk('$_replace $_two +1 $_cards with $_two +2 $_cards'),
        Perk(
          '$_add $_one +0 "Grant one ally within $_range 3: $_attack 2 $_range 3 or $_attack 3" $_card',
          quantity: 2,
        ),
        Perk(
          '$_add $_one $_disarm $_rolling and $_one +0 "Grant one ally within $_range 3: $_move 2" $_rolling $_card',
          quantity: 2,
        ),
        Perk('$_add $_two "$_ward, $_range 1" $_rolling $_cards', quantity: 2),
        Perk(
          '$_ignoreItemMinusOneEffects and whenever you would gain $_stun, prevent the condition',
        ),
        Perk(
          '$_wheneverYouLongRest, perform: $_strengthen, $_targetCircle 1 ally, $_range 3',
        ),
        Perk('All initiative values may be discussed freely and precisely'),
        Perk(
          'The first time each $_scenario that you or an ally exhaust, perform: $_heal 3, $_targetCircle all, $_ward, $_strengthen',
        ),
      ], variant: Variant.base),
    ],
  };
}
