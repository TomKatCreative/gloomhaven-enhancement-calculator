import 'package:gloomhaven_enhancement_calc/data/perks/perks_crimson_scales.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_custom.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_frosthaven.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_gloomhaven.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_jaws_of_the_lion.dart';
import 'package:gloomhaven_enhancement_calc/data/perks/perks_mercenary_packs.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

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

  /// Returns perk definitions with canonical IDs for a given class and variant.
  ///
  /// This is the single source of truth for perk loading — replaces the
  /// former database query approach.
  static List<Perk> getPerksForCharacter(String classCode, Variant variant) {
    final perksList = perksMap[classCode];
    if (perksList == null) return [];

    final result = <Perk>[];
    for (final perksGroup in perksList) {
      if (perksGroup.variant != variant) continue;

      // Validate that all perk numbers are unique within this group
      assert(() {
        final numbers = perksGroup.perks.map((p) => p.number).toList();
        final unique = numbers.toSet();
        if (unique.length != numbers.length) {
          final duplicates = numbers.where(
            (n) => numbers.where((m) => m == n).length > 1,
          );
          throw StateError(
            'Duplicate perk numbers for $classCode/${perksGroup.variant.name}: '
            '${duplicates.toSet()}',
          );
        }
        return true;
      }());

      for (final perk in perksGroup.perks) {
        perk.variant = perksGroup.variant;
        perk.classCode = classCode;

        final paddedIndex = perk.number.toString().padLeft(2, '0');
        for (int i = 0; i < perk.quantity; i++) {
          // Create a copy so each entry gets its own ID
          final perkCopy = Perk(
            perk.number,
            perk.perkDetails,
            quantity: perk.quantity,
            grouped: perk.grouped,
          );
          perkCopy.classCode = classCode;
          perkCopy.variant = perksGroup.variant;
          perkCopy.perkId =
              '${classCode}_${variant.name}_$paddedIndex${indexToLetter(i)}';
          result.add(perkCopy);
        }
      }
    }
    return result;
  }

  /// Returns canonical perk IDs for a given class and variant.
  ///
  /// Used when creating CharacterPerk join records for a new character.
  static List<String> getPerkIds(String classCode, Variant variant) {
    return getPerksForCharacter(
      classCode,
      variant,
    ).map((p) => p.perkId).toList();
  }
}

/// Converts a 0-based index to a lowercase letter (a, b, c, ...).
///
/// Used for generating unique perk IDs when quantity > 1.
String indexToLetter(int index) {
  if (index < 0) {
    throw ArgumentError('Index must be non-negative');
  }

  const int alphabetSize = 26;
  final int letterCode = 97 + (index % alphabetSize);

  return String.fromCharCode(letterCode);
}
