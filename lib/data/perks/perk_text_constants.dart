/// Shared text constants for perk definitions across all game editions.
///
/// These constants are used to build consistent perk text strings.
class PerkTextConstants {
  // Action verbs
  static const add = 'Add';
  static const addLowercase = 'add';
  static const remove = 'Remove';
  static const removeLowercase = 'remove';
  static const replace = 'Replace';

  // Numbers
  static const one = 'one';
  static const two = 'two';
  static const three = 'three';
  static const four = 'four';
  static String xp(int num) => 'xp$num';

  // Words as numbers
  static const plusZero = 'pluszero';
  static const plusOne = 'plusone';
  static const plusTwo = 'plustwo';

  // Card-related terms
  static const card = 'card';
  static const cards = 'cards';
  static const rolling = 'Rolling';
  static const loss = 'LOSS';
  static const shuffle = 'SHUFFLE';
  static const nullCard = 'NULL';

  // Effects and conditions
  static const damage = 'DAMAGE';
  static const immobilize = 'IMMOBILIZE';
  static const regenerate = 'REGENERATE';
  static const retaliate = 'RETALIATE';
  static const shield = 'SHIELD';
  static const ward = 'WARD';
  static const push = 'PUSH';
  static const pull = 'PULL';
  static const targetCircle = 'TARGET_CIRCLE';
  static const targetDiamond = 'TARGET_DIAMOND';
  static const pierce = 'PIERCE';
  static const stun = 'STUN';
  static const disarm = 'DISARM';
  static const muddle = 'MUDDLE';
  static const wound = 'WOUND';
  static const heal = 'HEAL';
  static const curse = 'CURSE';
  static const bless = 'BLESS';
  static const strengthen = 'STRENGTHEN';
  static const project = 'PROJECT';
  static const barrierPlus = 'BARRIER_PLUS';
  static const poison = 'POISON';
  static const critters = 'CRITTERS';
  static const invisible = 'INVISIBLE';
  static const impair = 'IMPAIR';
  static const brittle = 'BRITTLE';
  static const rupture = 'RUPTURE';
  static const enfeeble = 'ENFEEBLE';
  static const empower = 'EMPOWER';
  static const safeguard = 'SAFEGUARD';

  static const attack = 'ATTACK';
  static const range = 'RANGE';
  static const move = 'MOVE';
  static const teleport = 'TELEPORT';
  static const flying = 'FLYING';
  static const loot = 'LOOT';
  static const recover = 'RECOVER';
  static const refresh = 'REFRESH';
  static const spent = 'SPENT';
  static const section = 'SECTION';

  // Class specific
  static const tear = 'TEAR'; // TODO: add this asset for NIGHTSHROUD
  static const supplies = 'SUPPLIES'; // TODO: add this asset for QUARTERMASTER
  static const song = 'SONG'; // TODO: add this asset for SOOTHSINGER
  static const prescription =
      'PRESCRIPTION'; // TODO: add this asset for SAWBONES
  static const doom = 'DOOM'; // TODO: add this asset for DOOMSTALKER
  static const bear = 'BEAR'; // TODO: add this asset for WILDFURY
  static const command = 'COMMAND'; // TODO: add this asset for WILDFURY
  static const rift = 'RIFT'; // TODO: add this asset for CASSANDRA
  static const resolve = 'RESOLVE'; // TODO: replace when real asset comes out
  static const berserker = 'Berserker';
  static const doomstalker = 'Doomstalker';
  static const bladeswarm = 'Bladeswarm';
  static const hail = 'HAIL';
  static const reaver = 'REAVER';
  static const ritualist = 'RITUALIST';
  static const conqueror = 'CONQUEROR';
  static const vialWild = 'Vial_Wild';
  static const experiment = 'EXPERIMENT';

  // Elements
  static const fire = 'FIRE';
  static const light = 'LIGHT';
  static const dark = 'DARK';
  static const earth = 'EARTH';
  static const air = 'AIR';
  static const ice = 'ICE';
  static const wildElement = 'Wild_Element';
  static const consume = 'consume_';

  // Equipment slots
  static const body = 'Body';
  static const pocket = 'Pocket';
  // static const head = 'Head';
  static const oneHand = 'One_Hand';
  static const twoHand = 'Two_Hand';

  // Scenario and Item related
  static const negative = 'negative';
  static const scenario = 'scenario';
  static const atTheStartOfEachScenario = 'At the start of each $scenario';
  static const atTheEndOfEachScenario = 'At the end of each $scenario';
  static const ignoreItemMinusOneEffects =
      'Ignore item item_minus_one effects';
  static const ignoreItemMinusOneEffectsAndAdd =
      'Ignore item item_minus_one effects and $addLowercase';
  static const ignoreItemMinusOneEffectsAndRemove =
      'Ignore item item_minus_one effects and $removeLowercase';
  static const ignoreNegativeItemEffects = 'Ignore $negative item effects';
  static const ignoreNegativeItemEffectsAndAdd =
      'Ignore $negative item effects and add';
  static const ignoreNegativeItemEffectsAndRemove =
      'Ignore $negative item effects and remove';
  static const ignoreNegativeScenarioEffects =
      'Ignore $negative $scenario effects';
  static const ignoreNegativeScenarioEffectsAndAdd =
      'Ignore $negative $scenario effects and add';
  static const ignoreNegativeScenarioEffectsAndRemove =
      'Ignore $negative $scenario effects and $removeLowercase';
  static const ignoreScenarioEffects = 'Ignore $scenario effects';
  static const ignoreScenarioEffectsAndAdd =
      'Ignore $scenario effects and $addLowercase';
  static const ignoreScenarioEffectsAndRemove =
      'Ignore $scenario effects and remove';
  static const onceEachScenario = 'Once each $scenario';
  static const oncePerScenario = 'Once per $scenario';

  // Rest-related
  static const wheneverYouLongRest = 'Whenever you long rest';
  static const wheneverYouShortRest = 'Whenever you short rest';
}
