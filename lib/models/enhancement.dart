import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

class Enhancement {
  final EnhancementCategory category;
  final String name;
  final int ghCost;
  final int? fhCost;
  final String? assetKey;

  Enhancement(
    this.category,
    this.name, {
    this.assetKey,
    this.ghCost = 0,
    this.fhCost,
  });

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
