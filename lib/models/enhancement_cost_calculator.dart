/// Pure, immutable enhancement cost calculator with zero external dependencies.
///
/// [EnhancementCostCalculator] performs all cost calculation logic for the
/// enhancement calculator, separated from state management and persistence.
///
/// ## Usage
///
/// ```dart
/// final calc = EnhancementCostCalculator(
///   edition: GameEdition.frosthaven,
///   enhancement: someEnhancement,
///   cardLevel: 2,
///   previousEnhancements: 1,
///   multipleTargets: true,
/// );
/// print(calc.totalCost);       // Final computed cost
/// print(calc.breakdown);       // Step-by-step breakdown
/// ```
///
/// ## Cost Calculation Flow
///
/// 1. **Base Enhancement Cost** - From [Enhancement.cost]
/// 2. **Multipliers** - Applied to base cost
///    - Multiple Targets (×2)
///    - Lost/Non-Persistent (×0.5) - GH2E/FH
///    - Persistent (×3) - FH only
/// 3. **Discounts** - Applied after multipliers
///    - Enhancer L2 discount (-10g, FH)
///    - Hail's discount (-5g)
/// 4. **Card Level Penalty** - 25g × level
///    - Apply Party Boon discount (GH/GH2E)
///    - Apply Enhancer L3 discount (FH)
/// 5. **Previous Enhancements Penalty** - 75g × count
///    - Apply Enhancer L4 discount (FH)
/// 6. **Temporary Enhancement Mode** - -20g + ×0.8
/// 7. **Final** - max(0, total)
///
/// See also:
/// - [Enhancement] for enhancement definitions
/// - [GameEdition] for edition-specific rules
/// - [EnhancementCalculatorModel] for state management wrapper
library;

import 'package:gloomhaven_enhancement_calc/models/calculation_step.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';

/// Immutable, pure computation class for enhancement cost calculations.
///
/// All fields are final. Construct a new instance when inputs change.
/// Methods are pure functions with no side effects.
class EnhancementCostCalculator {
  const EnhancementCostCalculator({
    required this.edition,
    this.enhancement,
    this.cardLevel = 0,
    this.previousEnhancements = 0,
    this.multipleTargets = false,
    this.lostNonPersistent = false,
    this.persistent = false,
    this.temporaryEnhancementMode = false,
    this.hailsDiscount = false,
    this.partyBoon = false,
    this.enhancerLvl2 = false,
    this.enhancerLvl3 = false,
    this.enhancerLvl4 = false,
  });

  /// The game edition determining calculation rules.
  final GameEdition edition;

  /// The currently selected enhancement, or null if none selected.
  final Enhancement? enhancement;

  /// Card level above 1 (0 = level 1, 1 = level 2, etc.).
  final int cardLevel;

  /// Number of previous enhancements on the target action.
  final int previousEnhancements;

  /// Whether the enhancement targets multiple targets.
  final bool multipleTargets;

  /// Whether the action is lost and non-persistent (GH2E/FH: halves cost).
  final bool lostNonPersistent;

  /// Whether the action is persistent (FH only: triples cost).
  final bool persistent;

  /// Whether temporary enhancement mode is active.
  final bool temporaryEnhancementMode;

  /// Whether Hail's discount (-5g) is active.
  final bool hailsDiscount;

  /// Whether party boon is active (GH/GH2E: -5g/level on card level).
  final bool partyBoon;

  /// Whether Enhancer Level 2 is active (FH: -10g on base cost).
  final bool enhancerLvl2;

  /// Whether Enhancer Level 3 is active (FH: -10g/level on card level).
  final bool enhancerLvl3;

  /// Whether Enhancer Level 4 is active (FH: -25g/enh on prev enhancements).
  final bool enhancerLvl4;

  /// Whether there is any input to display a cost for.
  bool get showCost =>
      cardLevel != 0 || previousEnhancements != 0 || enhancement != null;

  /// Computes the base enhancement cost with multipliers and flat discounts.
  ///
  /// Accepts an arbitrary [enh] to support cost preview in the enhancement
  /// type selector screen (which shows costs for all enhancements, not just
  /// the currently selected one).
  int enhancementCost(Enhancement? enh) {
    if (enh == null) {
      return 0;
    }
    int cost = enh.cost(edition: edition);
    if (multipleTargets && eligibleForMultipleTargets(enh, edition: edition)) {
      cost *= 2;
    }
    // Lost action modifier: GH2E and FH
    if (edition.hasLostModifier && lostNonPersistent) {
      cost = (cost / 2).round();
    }
    // Persistent action modifier: FH only
    if (edition.hasPersistentModifier && persistent) {
      cost *= 3;
    }
    // Enhancer level 2: FH only
    if (edition.hasEnhancerLevels && enhancerLvl2) {
      cost -= 10;
    }
    // Hail's Discount
    if (hailsDiscount) {
      cost -= 5;
    }
    return cost.isNegative ? 0 : cost;
  }

  /// Computes the card level penalty for a given [level].
  ///
  /// Base: 25g × level, with optional discounts:
  /// - Party Boon (GH/GH2E): -5g/level
  /// - Enhancer L3 (FH): -10g/level
  int cardLevelPenalty(int level) {
    if (level == 0) {
      return 0;
    }
    int penalty = 25 * level;
    if (edition.supportsPartyBoon) {
      // Party boon: GH and GH2E
      if (partyBoon) {
        penalty -= 5 * level;
      }
    } else if (edition.hasEnhancerLevels && enhancerLvl3) {
      // Enhancer level 3: FH only
      penalty -= 10 * level;
    }
    return penalty;
  }

  /// Computes the previous enhancements penalty.
  ///
  /// Base: 75g × count, with optional discounts:
  /// - Enhancer L4 (FH): -25g/enh
  /// - Temporary Enhancement Mode: -20g flat
  int previousEnhancementsPenalty(int prevEnhancements) {
    if (prevEnhancements == 0) {
      return 0;
    }
    int penalty = 75 * prevEnhancements;
    if (edition.hasEnhancerLevels && enhancerLvl4) {
      // Enhancer level 4: FH only
      penalty -= 25 * prevEnhancements;
    }
    if (temporaryEnhancementMode) {
      penalty -= 20;
    }
    return penalty;
  }

  /// The final calculated total cost.
  int get totalCost {
    int cost = enhancementCost(enhancement);
    cost += cardLevelPenalty(cardLevel);
    cost += previousEnhancementsPenalty(previousEnhancements);
    if (temporaryEnhancementMode) {
      cost = (cost * 0.8).ceil();
    }
    return cost;
  }

  /// Returns a detailed breakdown of how the total cost is calculated.
  ///
  /// The breakdown follows this order:
  /// 1. Base cost (from enhancement type)
  /// 2. Multipliers (multi-target ×2, lost ÷2, persistent ×3)
  /// 3. Discounts (Enhancer L2 -10g, Hail's -5g)
  /// 4. Penalties (card level, previous enhancements)
  /// 5. Temporary enhancement mode (×0.8 rounded up)
  List<CalculationStep> get breakdown {
    final steps = <CalculationStep>[];

    if (enhancement == null && cardLevel == 0 && previousEnhancements == 0) {
      return steps;
    }

    int runningTotal = 0;

    // Section 1: Base cost (from enhancement type)
    runningTotal = _addBaseCostStep(steps);

    // Section 2: Multipliers (multi-target, lost, persistent)
    runningTotal = _addMultiplierSteps(steps, runningTotal);

    // Section 3: Discounts (Enhancer L2, Hail's)
    runningTotal = _addDiscountSteps(steps, runningTotal);

    // Ensure enhancement cost doesn't go negative before penalties
    if (runningTotal < 0) {
      runningTotal = 0;
    }

    // Section 4: Penalties (card level, previous enhancements)
    runningTotal = _addCardLevelStep(steps, runningTotal);
    runningTotal = _addPreviousEnhancementsStep(steps, runningTotal);

    // Section 5: Temporary enhancement mode (×0.8 rounded up)
    runningTotal = _addTempEnhancementStep(steps, runningTotal);

    return steps;
  }

  /// Whether the given [enh] is eligible for multi-target multiplier.
  static bool eligibleForMultipleTargets(
    Enhancement enh, {
    required GameEdition edition,
  }) {
    final name = enh.name.toLowerCase();
    // Hex is never eligible for multi-target in any edition
    if (name.contains('hex')) {
      return false;
    }
    // In GH, all types except hex are eligible
    if (edition.multiTargetAppliesToAll) {
      return true;
    }
    // In GH2E and FH, target and elements are not eligible
    return !name.contains('target') && !name.contains('element');
  }

  // ===========================================================================
  // Private breakdown builders
  // ===========================================================================

  /// Adds the base cost step for the selected enhancement.
  /// Returns the base cost, or 0 if no enhancement is selected.
  int _addBaseCostStep(List<CalculationStep> steps) {
    if (enhancement == null) {
      return 0;
    }

    final baseCost = enhancement!.cost(edition: edition);
    final isPlusOne =
        enhancement!.category == EnhancementCategory.charPlusOne ||
        enhancement!.category == EnhancementCategory.summonPlusOne ||
        enhancement!.category == EnhancementCategory.target;
    final enhancementName = isPlusOne
        ? '+1 ${enhancement!.name}'
        : enhancement!.name;

    steps.add(
      CalculationStep(
        description: 'Base cost ($enhancementName)',
        value: baseCost,
        formula: '${baseCost}g',
      ),
    );

    return baseCost;
  }

  /// Adds multiplier steps: multi-target (×2), lost (÷2), persistent (×3).
  /// Returns the modified running total.
  int _addMultiplierSteps(List<CalculationStep> steps, int runningTotal) {
    if (enhancement == null) {
      return runningTotal;
    }

    // Multi-target multiplier (×2)
    if (multipleTargets &&
        eligibleForMultipleTargets(enhancement!, edition: edition)) {
      runningTotal *= 2;
      steps.add(
        CalculationStep(
          description: 'Multiple targets',
          value: runningTotal,
          formula: '×2',
        ),
      );
    }

    // Lost action modifier (÷2, rounded) - GH2E and FH only
    if (edition.hasLostModifier && lostNonPersistent) {
      runningTotal = (runningTotal / 2).round();
      // In FH, clarify "non-persistent" since persistent modifier exists
      // In GH2E, just say "Lost action" since there's no persistent concept
      final lostDescription = edition.hasPersistentModifier
          ? 'Lost action (non-persistent)'
          : 'Lost action';
      steps.add(
        CalculationStep(
          description: lostDescription,
          value: runningTotal,
          formula: '÷2',
        ),
      );
    }

    // Persistent modifier (×3) - FH only
    if (edition.hasPersistentModifier && persistent) {
      runningTotal *= 3;
      steps.add(
        CalculationStep(
          description: 'Persistent action',
          value: runningTotal,
          formula: '×3',
        ),
      );
    }

    return runningTotal;
  }

  /// Adds discount steps: Enhancer Level 2 (-10g), Hail's (-5g).
  /// Returns the modified running total.
  int _addDiscountSteps(List<CalculationStep> steps, int runningTotal) {
    if (enhancement == null) {
      return runningTotal;
    }

    // Enhancer Level 2 discount (-10g) - FH only
    if (edition.hasEnhancerLevels && enhancerLvl2) {
      runningTotal -= 10;
      steps.add(
        CalculationStep(
          description: 'Enhancer Level 2',
          value: runningTotal,
          formula: '−10g',
        ),
      );
    }

    // Hail's Discount (-5g)
    if (hailsDiscount) {
      runningTotal -= 5;
      steps.add(
        CalculationStep(
          description: "Hail's Discount",
          value: runningTotal,
          formula: '−5g',
        ),
      );
    }

    return runningTotal;
  }

  /// Adds the card level penalty step.
  /// Returns the modified running total.
  int _addCardLevelStep(List<CalculationStep> steps, int runningTotal) {
    if (cardLevel <= 0) {
      return runningTotal;
    }

    const int basePerLevel = 25;
    int discountPerLevel = 0;
    String? modifier;

    // Apply party boon discount (GH/GH2E)
    if (edition.supportsPartyBoon && partyBoon) {
      discountPerLevel = 5;
      modifier = 'Party Boon: −${discountPerLevel}g/level';
    }
    // Apply Enhancer L3 discount (FH)
    else if (edition.hasEnhancerLevels && enhancerLvl3) {
      discountPerLevel = 10;
      modifier = 'Enhancer L3: −${discountPerLevel}g/level';
    }

    final effectivePerLevel = basePerLevel - discountPerLevel;
    final levelPenalty = effectivePerLevel * cardLevel;

    String formula;
    if (discountPerLevel > 0) {
      formula = '(${basePerLevel}g − ${discountPerLevel}g) × $cardLevel';
    } else {
      formula = '${basePerLevel}g × $cardLevel';
    }
    runningTotal += levelPenalty;

    steps.add(
      CalculationStep(
        description: 'Card level ${cardLevel + 1}',
        value: runningTotal,
        formula: formula,
        modifier: modifier,
      ),
    );

    return runningTotal;
  }

  /// Adds the previous enhancements penalty step.
  /// Returns the modified running total.
  int _addPreviousEnhancementsStep(
    List<CalculationStep> steps,
    int runningTotal,
  ) {
    if (previousEnhancements <= 0) {
      return runningTotal;
    }

    const int basePerEnhancement = 75;
    int discountPerEnhancement = 0;
    final modifiers = <String>[];

    // Apply Enhancer L4 discount (FH)
    if (edition.hasEnhancerLevels && enhancerLvl4) {
      discountPerEnhancement = 25;
      modifiers.add('Enhancer L4: −${discountPerEnhancement}g/enh.');
    }

    final effectivePerEnhancement = basePerEnhancement - discountPerEnhancement;
    int enhancementPenalty = effectivePerEnhancement * previousEnhancements;

    // Apply temporary enhancement discount (-20g if at least 1 prev enhancement)
    if (temporaryEnhancementMode) {
      enhancementPenalty -= 20;
      modifiers.add('Temp. Enh.: −20g');
    }

    String formula;
    if (discountPerEnhancement > 0) {
      formula =
          '(${basePerEnhancement}g − ${discountPerEnhancement}g) × $previousEnhancements${temporaryEnhancementMode ? ' − 20g' : ''}';
    } else {
      formula =
          '${basePerEnhancement}g × $previousEnhancements${temporaryEnhancementMode ? ' − 20g' : ''}';
    }
    runningTotal += enhancementPenalty;

    steps.add(
      CalculationStep(
        description:
            '$previousEnhancements previous enhancement${previousEnhancements > 1 ? 's' : ''}',
        value: runningTotal,
        formula: formula,
        modifier: modifiers.isNotEmpty ? modifiers.join('\n') : null,
      ),
    );

    return runningTotal;
  }

  /// Adds the temporary enhancement mode step (×0.8 rounded up).
  /// Returns the final total.
  int _addTempEnhancementStep(List<CalculationStep> steps, int runningTotal) {
    if (!temporaryEnhancementMode) {
      return runningTotal;
    }

    final preTempTotal = runningTotal;
    runningTotal = (runningTotal * 0.8).ceil();
    steps.add(
      CalculationStep(
        description: 'Temporary Enhancement (×0.8↑)',
        value: runningTotal,
        formula: '${preTempTotal}g × 0.8 = ${runningTotal}g',
      ),
    );

    return runningTotal;
  }
}
