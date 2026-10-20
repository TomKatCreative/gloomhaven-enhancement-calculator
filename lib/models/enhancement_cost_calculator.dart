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
///    - The enhancement cost is then clamped at 0
/// 4. **Card Level Penalty** - 25g × level
///    - Apply Party Boon discount (GH/GH2E)
///    - Apply Enhancer L3 discount (FH)
/// 5. **Previous Enhancements Penalty** - 75g × count
///    - Apply Enhancer L4 discount (FH)
///    - Apply Temporary Enhancement discount (-20g)
/// 6. **Temporary Enhancement Mode** - total × 0.8, rounded up
///
/// The rule values are the `static const` fields on
/// [EnhancementCostCalculator]. Each step is implemented once and serves both
/// the totals and [EnhancementCostCalculator.breakdown].
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

  // ===========================================================================
  // Cost rules
  // ===========================================================================

  /// Multi-target multiplier on the base cost.
  static const int multiTargetMultiplier = 2;

  /// Lost (non-persistent) divisor on the base cost (GH2E/FH).
  static const int lostDivisor = 2;

  /// Persistent multiplier on the base cost (FH).
  static const int persistentMultiplier = 3;

  /// Enhancer Level 2 flat discount on the base cost (FH).
  static const int enhancerL2Discount = 10;

  /// Hail's flat discount on the base cost.
  static const int hailsDiscountAmount = 5;

  /// Penalty per card level above 1.
  static const int costPerCardLevel = 25;

  /// Party Boon discount per card level (GH/GH2E).
  static const int partyBoonDiscountPerLevel = 5;

  /// Enhancer Level 3 discount per card level (FH).
  static const int enhancerL3DiscountPerLevel = 10;

  /// Penalty per previous enhancement on the action.
  static const int costPerPreviousEnhancement = 75;

  /// Enhancer Level 4 discount per previous enhancement (FH).
  static const int enhancerL4DiscountPerEnhancement = 25;

  /// Temporary enhancement flat discount on the previous-enhancements penalty.
  static const int temporaryEnhancementDiscount = 20;

  /// Temporary enhancement multiplier on the total, rounded up.
  static const double temporaryEnhancementMultiplier = 0.8;

  // ===========================================================================
  // Public API
  // ===========================================================================

  /// Computes the base enhancement cost with multipliers and flat discounts.
  ///
  /// Accepts an arbitrary [enh] to support cost preview in the enhancement
  /// type selector screen (which shows costs for all enhancements, not just
  /// the currently selected one).
  int enhancementCost(Enhancement? enh) => _enhancementCostSteps(enh);

  /// Computes the card level penalty for a given [level].
  ///
  /// Base: [costPerCardLevel] × level, with optional discounts:
  /// - Party Boon (GH/GH2E): [partyBoonDiscountPerLevel]/level
  /// - Enhancer L3 (FH): [enhancerL3DiscountPerLevel]/level
  int cardLevelPenalty(int level) => _cardLevelStep(level, 0);

  /// Computes the previous enhancements penalty.
  ///
  /// Base: [costPerPreviousEnhancement] × count, with optional discounts:
  /// - Enhancer L4 (FH): [enhancerL4DiscountPerEnhancement]/enh
  /// - Temporary Enhancement Mode: [temporaryEnhancementDiscount] flat
  int previousEnhancementsPenalty(int prevEnhancements) =>
      _previousEnhancementsStep(prevEnhancements, 0);

  /// The final calculated total cost.
  int get totalCost => _compute();

  /// Returns a detailed breakdown of how the total cost is calculated.
  ///
  /// The breakdown follows this order:
  /// 1. Base cost (from enhancement type)
  /// 2. Multipliers (multi-target ×2, lost ÷2, persistent ×3)
  /// 3. Discounts (Enhancer L2 -10g, Hail's -5g)
  /// 4. Penalties (card level, previous enhancements)
  /// 5. Temporary enhancement mode (×0.8 rounded up)
  ///
  /// Each step's value is the running total after that step. The enhancement
  /// cost is clamped at 0 before penalties, but no step records the clamp, so
  /// a discount step can show a negative value while [totalCost] counts it
  /// as 0. Read the total from [totalCost], not from the last step.
  List<CalculationStep> get breakdown {
    final steps = <CalculationStep>[];
    if (showCost) _compute(steps);
    return steps;
  }

  /// Whether the given [enh] is eligible for multi-target multiplier.
  static bool eligibleForMultipleTargets(
    Enhancement enh, {
    required GameEdition edition,
  }) {
    // Hex is never eligible for multi-target in any edition
    if (enh.category == EnhancementCategory.hex) {
      return false;
    }
    // In GH, all types except hex are eligible
    if (edition.multiTargetAppliesToAll) {
      return true;
    }
    // In GH2E and FH, target and elements are not eligible
    return enh.category != EnhancementCategory.target &&
        enh.category != EnhancementCategory.specElem &&
        enh.category != EnhancementCategory.anyElem;
  }

  // ===========================================================================
  // Calculation steps
  //
  // These are the only implementation of the cost rules. Each one returns the
  // new running total, and records a breakdown step when given a [steps] list.
  // ===========================================================================

  /// Runs every step in order and returns the total cost.
  int _compute([List<CalculationStep>? steps]) {
    int runningTotal = _enhancementCostSteps(enhancement, steps);
    runningTotal = _cardLevelStep(cardLevel, runningTotal, steps);
    runningTotal = _previousEnhancementsStep(
      previousEnhancements,
      runningTotal,
      steps,
    );
    return _temporaryEnhancementStep(runningTotal, steps);
  }

  /// Base cost, multipliers and discounts for [enh], clamped at 0.
  /// Returns 0 if [enh] is null.
  int _enhancementCostSteps(Enhancement? enh, [List<CalculationStep>? steps]) {
    if (enh == null) {
      return 0;
    }
    int runningTotal = _baseCostStep(enh, steps);
    runningTotal = _multiplierSteps(enh, runningTotal, steps);
    runningTotal = _discountSteps(runningTotal, steps);
    // Ensure enhancement cost doesn't go negative before penalties
    return runningTotal.isNegative ? 0 : runningTotal;
  }

  /// The base cost of [enh] for this edition.
  int _baseCostStep(Enhancement enh, List<CalculationStep>? steps) {
    final baseCost = enh.cost(edition: edition);
    if (steps != null) {
      final enhancementName = enh.isPlusOne ? '+1 ${enh.name}' : enh.name;
      steps.add(
        CalculationStep(
          description: 'Base cost ($enhancementName)',
          value: baseCost,
          formula: '${baseCost}g',
        ),
      );
    }
    return baseCost;
  }

  /// Multipliers: multi-target (×2), lost (÷2), persistent (×3).
  int _multiplierSteps(
    Enhancement enh,
    int runningTotal,
    List<CalculationStep>? steps,
  ) {
    // Multi-target multiplier (×2)
    if (multipleTargets && eligibleForMultipleTargets(enh, edition: edition)) {
      runningTotal *= multiTargetMultiplier;
      steps?.add(
        CalculationStep(
          description: 'Multiple targets',
          value: runningTotal,
          formula: '×$multiTargetMultiplier',
        ),
      );
    }

    // Lost action modifier (÷2, rounded) - GH2E and FH only
    if (edition.hasLostModifier && lostNonPersistent) {
      runningTotal = (runningTotal / lostDivisor).round();
      // In FH, clarify "non-persistent" since persistent modifier exists
      // In GH2E, just say "Lost action" since there's no persistent concept
      steps?.add(
        CalculationStep(
          description: edition.hasPersistentModifier
              ? 'Lost action (non-persistent)'
              : 'Lost action',
          value: runningTotal,
          formula: '÷$lostDivisor',
        ),
      );
    }

    // Persistent modifier (×3) - FH only
    if (edition.hasPersistentModifier && persistent) {
      runningTotal *= persistentMultiplier;
      steps?.add(
        CalculationStep(
          description: 'Persistent action',
          value: runningTotal,
          formula: '×$persistentMultiplier',
        ),
      );
    }

    return runningTotal;
  }

  /// Flat discounts: Enhancer Level 2 (-10g), Hail's (-5g).
  int _discountSteps(int runningTotal, List<CalculationStep>? steps) {
    // Enhancer Level 2 discount (-10g) - FH only
    if (edition.hasEnhancerLevels && enhancerLvl2) {
      runningTotal -= enhancerL2Discount;
      steps?.add(
        CalculationStep(
          description: 'Enhancer Level 2',
          value: runningTotal,
          formula: '−${enhancerL2Discount}g',
        ),
      );
    }

    // Hail's Discount (-5g)
    if (hailsDiscount) {
      runningTotal -= hailsDiscountAmount;
      steps?.add(
        CalculationStep(
          description: "Hail's Discount",
          value: runningTotal,
          formula: '−${hailsDiscountAmount}g',
        ),
      );
    }

    return runningTotal;
  }

  /// Card level penalty for [level] levels above 1.
  int _cardLevelStep(
    int level,
    int runningTotal, [
    List<CalculationStep>? steps,
  ]) {
    if (level <= 0) {
      return runningTotal;
    }

    int discountPerLevel = 0;
    String? modifier;

    // Apply party boon discount (GH/GH2E)
    if (edition.supportsPartyBoon && partyBoon) {
      discountPerLevel = partyBoonDiscountPerLevel;
      modifier = 'Party Boon: −${discountPerLevel}g/level';
    }
    // Apply Enhancer L3 discount (FH)
    else if (edition.hasEnhancerLevels && enhancerLvl3) {
      discountPerLevel = enhancerL3DiscountPerLevel;
      modifier = 'Enhancer L3: −${discountPerLevel}g/level';
    }

    runningTotal += (costPerCardLevel - discountPerLevel) * level;

    steps?.add(
      CalculationStep(
        description: 'Card level ${level + 1}',
        value: runningTotal,
        formula: discountPerLevel > 0
            ? '(${costPerCardLevel}g − ${discountPerLevel}g) × $level'
            : '${costPerCardLevel}g × $level',
        modifier: modifier,
      ),
    );

    return runningTotal;
  }

  /// Penalty for [count] previous enhancements on the action.
  int _previousEnhancementsStep(
    int count,
    int runningTotal, [
    List<CalculationStep>? steps,
  ]) {
    if (count <= 0) {
      return runningTotal;
    }

    int discountPerEnhancement = 0;
    final modifiers = <String>[];

    // Apply Enhancer L4 discount (FH)
    if (edition.hasEnhancerLevels && enhancerLvl4) {
      discountPerEnhancement = enhancerL4DiscountPerEnhancement;
      modifiers.add('Enhancer L4: −${discountPerEnhancement}g/enh.');
    }

    int enhancementPenalty =
        (costPerPreviousEnhancement - discountPerEnhancement) * count;

    // Apply temporary enhancement discount (-20g if at least 1 prev enhancement)
    if (temporaryEnhancementMode) {
      enhancementPenalty -= temporaryEnhancementDiscount;
      modifiers.add('Temp. Enh.: −${temporaryEnhancementDiscount}g');
    }

    runningTotal += enhancementPenalty;

    if (steps != null) {
      final tempSuffix = temporaryEnhancementMode
          ? ' − ${temporaryEnhancementDiscount}g'
          : '';
      steps.add(
        CalculationStep(
          description: '$count previous enhancement${count > 1 ? 's' : ''}',
          value: runningTotal,
          formula: discountPerEnhancement > 0
              ? '(${costPerPreviousEnhancement}g − ${discountPerEnhancement}g) × $count$tempSuffix'
              : '${costPerPreviousEnhancement}g × $count$tempSuffix',
          modifier: modifiers.isNotEmpty ? modifiers.join('\n') : null,
        ),
      );
    }

    return runningTotal;
  }

  /// Temporary enhancement mode (×0.8 rounded up).
  int _temporaryEnhancementStep(
    int runningTotal,
    List<CalculationStep>? steps,
  ) {
    if (!temporaryEnhancementMode) {
      return runningTotal;
    }

    final preTempTotal = runningTotal;
    runningTotal = (runningTotal * temporaryEnhancementMultiplier).ceil();
    steps?.add(
      CalculationStep(
        description: 'Temporary Enhancement (×0.8↑)',
        value: runningTotal,
        formula:
            '${preTempTotal}g × $temporaryEnhancementMultiplier = ${runningTotal}g',
      ),
    );

    return runningTotal;
  }
}
