import 'package:gloomhaven_enhancement_calc/data/perks/perks_crimson_scales.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_custom.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_frosthaven.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_gloomhaven.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_jaws_of_the_lion.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_mercenary_packs.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';

/// Aggregates all perk definitions from edition-specific files.
///
/// This repository combines perks from:
/// - Gloomhaven (19 classes + Diviner)
/// - Jaws of the Lion (4 classes)
/// - Frosthaven (17 classes)
/// - Mercenary Packs (4 classes)
/// - Crimson Scales (16 classes)
/// - Custom classes (12 classes)
class PerksRepository {
  /// Combined map of all perks indexed by class code.
  static final Map<String, List<Perks>> perksMap = {
    ...GloomhavenPerks.perks,
    ...JawsOfTheLionPerks.perks,
    ...FrosthavenPerks.perks,
    ...MercenaryPacksPerks.perks,
    ...CrimsonScalesPerks.perks,
    ...CustomPerks.perks,
  };
}
