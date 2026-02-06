// Character races
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

class CharacterRaces {
  static const aesther = 'Aesther';
  static const algox = 'Algox';
  static const harrower = 'Harrower';
  static const human = 'Human';
  static const inox = 'Inox';
  static const lurker = 'Lurker';
  static const orchid = 'Orchid';
  static const quatryl = 'Quatryl';
  static const savvas = 'Savvas';
  static const unfettered = 'Unfettered';
  static const valrath = 'Valrath';
  static const vermling = 'Vermling';
}

// Character traits
class CharacterTraits {
  static const arcane = 'Arcane';
  static const armored = 'Armored';
  static const chaotic = 'Chaotic';
  static const educated = 'Educated';
  static const intimidating = 'Intimidating';
  static const nimble = 'Nimble';
  static const outcast = 'Outcast';
  static const persuasive = 'Persuasive';
  static const resourceful = 'Resourceful';
  static const strong = 'Strong';
}

/// Class codes for all character classes across all games
class ClassCodes {
  // Gloomhaven starting classes
  static const brute = 'br';
  static const tinkerer = 'ti';
  static const spellweaver = 'sw';
  static const scoundrel = 'sc';
  static const cragheart = 'ch';
  static const mindthief = 'mt';

  // Gloomhaven unlockable classes
  static const sunkeeper = 'sk';
  static const quartermaster = 'qm';
  static const summoner = 'su';
  static const nightshroud = 'ns';
  static const plagueherald = 'ph';
  static const berserker = 'be';
  static const soothsinger = 'ss';
  static const doomstalker = 'ds';
  static const sawbones = 'sb';
  static const elementalist = 'el';
  static const beastTyrant = 'bt';

  // Envelope X
  static const bladeswarm = 'bs';

  // Forgotten Circles
  static const diviner = 'dv';

  // Jaws of the Lion
  static const demolitionist = 'dl';
  static const hatchet = 'hc';
  static const redGuard = 'rg';
  static const voidwarden = 'vw';

  // Frosthaven starting classes
  static const drifter = 'drifter';
  static const blinkBlade = 'blinkblade';
  static const bannerSpear = 'bannerspear';
  static const deathwalker = 'deathwalker';
  static const boneshaper = 'boneshaper';
  static const geminate = 'geminate';

  // Frosthaven unlockable classes
  static const infuser = 'infuser';
  static const pyroclast = 'pyroclast';
  static const shattersong = 'shattersong';
  static const trapper = 'trapper';
  static const painConduit = 'painconduit';
  static const snowdancer = 'snowdancer';
  static const frozenFist = 'frozenfist';
  static const hive = 'hive';
  static const metalMosaic = 'metalmosaic';
  static const deepwraith = 'deepwraith';
  static const crashingTide = 'crashingtide';

  // Mercenary Packs (2025)
  static const anaphi = 'anaphi';
  static const cassandra = 'cassandra';
  static const hail = 'hail';
  static const satha = 'satha';

  // Crimson Scales
  static const amberAegis = 'aa';
  static const artificer = 'af';
  static const bombard = 'bb';
  static const brightspark = 'bp';
  static const chainguard = 'cg';
  static const chieftain = 'ct';
  static const fireKnight = 'fk';
  static const hierophant = 'hf';
  static const hollowpact = 'hp';
  static const luminary = 'ln';
  static const mirefoot = 'mf';
  static const ruinmaw = 'rm';
  static const spiritCaller = 'scr';
  static const starslinger = 'ssl';
  static const thornreaper = 'thornreaper';
  static const vanquisher = 'vanquisher';

  // Custom classes
  static const brewmaster = 'bm';
  static const frostborn = 'fb';
  static const incarnate = 'incarnate';
  static const rimehearth = 'rimehearth';
  static const rootwhisperer = 'rw';
  static const shardrender = 'shardrender';
  static const tempest = 'tempest';
  static const vimthreader = 'vimthreader';
  static const core = 'core';
  static const dome = 'dome';
  static const skitterclaw = 'skitterclaw';
  static const alchemancer = 'alchemancer';

  // Private constructor to prevent instantiation
  const ClassCodes._();
}

class ClassVariants {
  static Map<Variant, String> classVariants = {
    Variant.base: 'Base',
    Variant.frosthavenCrossover: 'Frosthaven crossover',
    Variant.gloomhaven2E: 'Gloomhaven 2e',
    Variant.v2: 'Version II',
    Variant.v3: 'Version III',
  };
}

// Experience levels
class LevelConstants {
  static const Map<int, int> levelXp = {
    1: 0,
    2: 45,
    3: 95,
    4: 150,
    5: 210,
    6: 275,
    7: 345,
    8: 420,
    9: 500,
  };
}
