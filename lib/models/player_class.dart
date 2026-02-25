/// Player class definitions and related enums.
///
/// A [PlayerClass] defines a character class with its attributes, colors,
/// and variant support. Classes are defined in [PlayerClasses] and
/// referenced by [Character] instances.
///
/// ## Variants
///
/// Classes can have multiple variants (editions) with different perks:
/// - [Variant.base] - Original version
/// - [Variant.frosthavenCrossover] - Frosthaven crossover rules
/// - [Variant.gloomhaven2E] - Gloomhaven 2nd Edition (may have different name)
/// - [Variant.v2], [Variant.v3], [Variant.v4] - Additional versions
///
/// ## Categories
///
/// Classes belong to a [ClassCategory] indicating their source:
/// - [ClassCategory.gloomhaven] - Original base game
/// - [ClassCategory.jawsOfTheLion] - Starter set
/// - [ClassCategory.frosthaven] - Sequel with masteries
/// - [ClassCategory.mercenaryPacks] - Standalone character packs
///
/// See also:
/// - [Character] for character instances
/// - `docs/models_reference.md` for full documentation
library;

import 'package:gloomhaven_enhancement_calc/data/perks/perks_repository.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';

/// The game edition or expansion that a class belongs to.
enum ClassCategory {
  /// Original Gloomhaven base game classes
  gloomhaven,

  /// Jaws of the Lion starter set classes
  jawsOfTheLion,

  /// Frosthaven sequel classes (have masteries)
  frosthaven,

  /// Crimson Scales fan expansion classes
  crimsonScales,

  /// User-created custom classes
  custom,

  /// Standalone mercenary pack classes (use title instead of race)
  mercenaryPacks,
}

/// Class variant representing different edition versions.
///
/// Some classes have different names, perks, or rules across editions.
/// For example, "Brute" in base Gloomhaven becomes "Bruiser" in GH2E.
enum Variant { base, frosthavenCrossover, gloomhaven2E, v2, v3, v4 }

/// Defines a player character class with attributes, colors, and variants.
///
/// Each class has:
/// - Basic identity: [name], [race], [classCode]
/// - Visual theming: [primaryColor], [secondaryColor]
/// - Game metadata: [category], [locked], [traits]
/// - Variant support: [variantNames] for edition-specific names
///
/// ## Mercenary Packs
///
/// Classes with [ClassCategory.mercenaryPacks] must have a non-null [title]
/// and display differently (title only, no race shown).
class PlayerClass {
  final String race;
  final String name;
  String classCode;
  final ClassCategory category;
  final int primaryColor;
  final String? title;
  final Map<Variant, String>? variantNames;
  final int? secondaryColor;
  final bool locked;
  final List<String> traits;
  final int handSize;
  final Map<Variant, int>? variantHandSizes;

  PlayerClass({
    required this.race,
    required this.name,
    required this.classCode,
    required this.category,
    required this.primaryColor,
    required this.handSize,
    this.title,
    this.variantNames,
    this.secondaryColor = 0xff4e7ec1,
    this.locked = false,
    this.traits = const [],
    this.variantHandSizes,
  }) : assert(
         (category == ClassCategory.mercenaryPacks) == (title != null),
         'title must be non-null if and only if category is mercenaryPacks',
       );

  /// Returns the perk lists for this class from [PerksRepository].
  static List<Perks>? perkListByClassCode(String classCode) =>
      PerksRepository.perksMap[classCode];

  /// Get the display name for a specific variant.
  String getDisplayName(Variant variant) {
    // Check if there's an override for this variant
    if (variantNames != null && variantNames!.containsKey(variant)) {
      return variantNames![variant]!;
    }
    // Fall back to base name
    return name;
  }

  /// Get the full display name
  String getFullDisplayName(Variant variant) {
    // Mercenary Pack classes have a preset name and title - race is not shown
    if (category == ClassCategory.mercenaryPacks && title != null) {
      return ' ${title!}';
    }
    return '$race ${getDisplayName(variant)}';
  }

  /// Check if this class has a custom name for the given variant
  bool hasVariantName(Variant variant) {
    return variantNames?.containsKey(variant) ?? false;
  }

  /// Get the hand size for a specific variant, falling back to [handSize].
  int getHandSize(Variant variant) {
    if (variantHandSizes != null && variantHandSizes!.containsKey(variant)) {
      return variantHandSizes![variant]!;
    }
    return handSize;
  }

  /// Get a combined display name for search/selection (e.g., "Brute/Bruiser")
  /// Shows all unique variant names separated by "/"
  String getCombinedDisplayNames({String? delimeter}) {
    if (variantNames == null || variantNames!.isEmpty) {
      return name;
    }

    // Get all unique names (base + variants)
    final Set<String> allNames = <String>{name};
    allNames.addAll(variantNames!.values);

    return allNames.join(delimeter ?? ' / ');
  }
}
