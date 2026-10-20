/// What a [CalculationStep] represents. The UI maps each kind to localized
/// text, so the calculator itself stays free of display strings.
enum CalculationStepKind {
  baseCost,
  multipleTargets,
  lostAction,
  lostNonPersistentAction,
  persistentAction,
  enhancerLevel2,
  hailsDiscount,
  cardLevel,
  previousEnhancements,
  temporaryEnhancement,
}

/// A discount applied within a step (e.g. Party Boon on the card level step).
enum CalculationModifierKind {
  partyBoon,
  enhancerLevel3,
  enhancerLevel4,
  temporaryEnhancement,
}

/// A discount of [amount] gold applied within a [CalculationStep].
class CalculationModifier {
  final CalculationModifierKind kind;
  final int amount;

  const CalculationModifier(this.kind, this.amount);
}

/// Represents a single step in the enhancement cost calculation breakdown.
///
/// Each step shows how the cost is built up from base cost through
/// multipliers, discounts, and penalties.
class CalculationStep {
  /// What this step represents.
  final CalculationStepKind kind;

  /// The value at this step (running total or the modifier value)
  final int value;

  /// Optional formula showing how this value was calculated (e.g., "x2", "+75g")
  final String? formula;

  /// The enhancement's display name, for [CalculationStepKind.baseCost].
  final String? enhancementName;

  /// The printed card level for [CalculationStepKind.cardLevel], or the
  /// number of enhancements for [CalculationStepKind.previousEnhancements].
  final int? count;

  /// Discounts applied within this step, in display order.
  final List<CalculationModifier> modifiers;

  const CalculationStep({
    required this.kind,
    required this.value,
    this.formula,
    this.enhancementName,
    this.count,
    this.modifiers = const [],
  });
}
