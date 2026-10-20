import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

class Enhancement {
  final EnhancementCategory category;
  final String name;
  final int ghCost;
  final int? fhCost;
  final String assetKey;

  /// Editions this enhancement does not exist in. Empty means every edition.
  final Set<GameEdition> excludedEditions;

  Enhancement(
    this.category,
    this.name, {
    required this.assetKey,
    this.ghCost = 0,
    this.fhCost,
    this.excludedEditions = const {},
  });

  /// Stable identifier used to persist the selection. Unlike a position in
  /// [EnhancementData.enhancements], it survives reordering of that list.
  String get key => '${category.name}:$name';

  /// Whether this is a +1 to a stat (character, summon or target), shown with
  /// a +1 badge and labelled "+1 Name".
  bool get isPlusOne =>
      category == EnhancementCategory.charPlusOne ||
      category == EnhancementCategory.summonPlusOne ||
      category == EnhancementCategory.target;

  /// Whether this enhancement exists in [edition].
  bool isAvailableIn(GameEdition edition) =>
      !excludedEditions.contains(edition);

  int cost({required GameEdition edition}) {
    switch (edition) {
      case GameEdition.gloomhaven:
      // JotL has no enhancement system and never reaches the calculator;
      // fall back to Gloomhaven costs for exhaustiveness.
      case GameEdition.jawsOfTheLion:
        return ghCost;
      case GameEdition.gloomhaven2e:
        // GH2E costs mostly match FH, fall back to GH if neither specified
        return fhCost ?? ghCost;
      case GameEdition.frosthaven:
        return fhCost ?? ghCost;
    }
  }
}
