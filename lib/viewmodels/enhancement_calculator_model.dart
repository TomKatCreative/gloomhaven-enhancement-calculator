import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/calculation_step.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

class EnhancementCalculatorModel with ChangeNotifier {
  EnhancementCalculatorModel() {
    // Calculate initial cost based on saved state so showCost is correct
    calculateCost(notify: false);
  }

  int _cardLevel = SharedPrefs().targetCardLvl;

  int _previousEnhancements = SharedPrefs().previousEnhancements;

  Enhancement? _enhancement = SharedPrefs().enhancementTypeIndex != 0
      ? EnhancementData.enhancements[SharedPrefs().enhancementTypeIndex]
      : null;

  bool _multipleTargets = SharedPrefs().multipleTargetsSwitch;

  bool _lostNonPersistent = SharedPrefs().lostNonPersistent;

  bool _persistent = SharedPrefs().persistent;

  bool _disableMultiTargetsSwitch = SharedPrefs().disableMultiTargetSwitch;

  bool _temporaryEnhancementMode = SharedPrefs().temporaryEnhancementMode;

  bool _hailsDiscount = SharedPrefs().hailsDiscount;

  bool showCost = false;

  /// Returns true if Enhancer Level 2 affects the enhancement cost
  bool get enhancerLvl2Applies =>
      edition.hasEnhancerLevels &&
      SharedPrefs().enhancerLvl2 &&
      enhancement != null;

  /// Returns true if Enhancer Level 3 affects the card level cost
  bool get enhancerLvl3Applies =>
      edition.hasEnhancerLevels && SharedPrefs().enhancerLvl3 && cardLevel > 0;

  /// Returns true if Enhancer Level 4 affects the previous enhancements cost
  bool get enhancerLvl4Applies =>
      edition.hasEnhancerLevels &&
      SharedPrefs().enhancerLvl4 &&
      previousEnhancements > 0;

  /// Returns the current game edition from SharedPrefs
  GameEdition get edition => SharedPrefs().gameEdition;

  /// Whether the cost chip is expanded (used to hide FAB)
  bool _isSheetExpanded = false;

  bool get isSheetExpanded => _isSheetExpanded;

  set isSheetExpanded(bool value) {
    if (_isSheetExpanded != value) {
      _isSheetExpanded = value;
      notifyListeners();
    }
  }

  int totalCost = 0;

  int get cardLevel => _cardLevel;

  set cardLevel(int cardLevel) {
    SharedPrefs().targetCardLvl = cardLevel;
    _cardLevel = cardLevel;
    calculateCost();
  }

  int cardLevelPenalty(int level) {
    if (level == 0) {
      return 0;
    }
    int penalty = 25 * level;
    final edition = SharedPrefs().gameEdition;
    if (edition.supportsPartyBoon) {
      // Party boon: GH and GH2E
      if (SharedPrefs().partyBoon) {
        penalty -= 5 * level;
      }
    } else if (edition.hasEnhancerLevels && SharedPrefs().enhancerLvl3) {
      // Enhancer level 3: FH only
      penalty -= 10 * level;
    }
    return penalty;
  }

  int get previousEnhancements => _previousEnhancements;

  set previousEnhancements(int previousEnhancements) {
    SharedPrefs().previousEnhancements = previousEnhancements;
    _previousEnhancements = previousEnhancements;
    calculateCost();
  }

  int previousEnhancementsPenalty(int previousEnhancements) {
    if (previousEnhancements == 0) {
      return 0;
    }
    int penalty = 75 * previousEnhancements;
    final edition = SharedPrefs().gameEdition;
    if (edition.hasEnhancerLevels && SharedPrefs().enhancerLvl4) {
      // Enhancer level 4: FH only
      penalty -= 25 * previousEnhancements;
    }
    if (temporaryEnhancementMode) {
      penalty -= 20;
    }
    return penalty;
  }

  int _temporaryEnhancementMutator(int cost) {
    return (cost * 0.8).ceil();
  }

  Enhancement? get enhancement => _enhancement;

  set enhancement(Enhancement? enhancement) {
    if (enhancement != null) {
      SharedPrefs().enhancementTypeIndex = EnhancementData.enhancements.indexOf(
        enhancement,
      );
    }
    _enhancement = enhancement;
  }

  /// Multiply the cost by 2 if [_multipleTargets]
  /// Halve the cost if [_lostNonPersistent] (GH2E/FH only)
  /// Triple the cost if [_persistent] (FH only)
  /// Subtract 10 gold if [_enhancerLvl2] (FH only)
  /// Subtract 5 gold if [_hailsDiscount]
  int enhancementCost(Enhancement? enhancement) {
    if (enhancement == null) {
      return 0;
    }
    final edition = SharedPrefs().gameEdition;
    int enhancementCost = enhancement.cost(edition: edition);
    if (multipleTargets &&
        eligibleForMultipleTargets(enhancement, edition: edition)) {
      enhancementCost *= 2;
    }
    // Lost action modifier: GH2E and FH
    if (edition.hasLostModifier && lostNonPersistent) {
      enhancementCost = (enhancementCost / 2).round();
    }
    // Persistent action modifier: FH only
    if (edition.hasPersistentModifier && persistent) {
      enhancementCost *= 3;
    }
    // Enhancer level 2: FH only
    if (edition.hasEnhancerLevels && SharedPrefs().enhancerLvl2) {
      enhancementCost -= 10;
    }
    // Hail's Discount
    if (hailsDiscount) {
      enhancementCost -= 5;
    }
    return enhancementCost.isNegative ? 0 : enhancementCost;
  }

  bool get multipleTargets => _multipleTargets;

  set multipleTargets(bool value) {
    SharedPrefs().multipleTargetsSwitch = value;
    _multipleTargets = value;
    calculateCost();
  }

  bool get disableMultiTargetsSwitch => _disableMultiTargetsSwitch;

  set disableMultiTargetsSwitch(bool value) {
    SharedPrefs().disableMultiTargetSwitch = value;
    _disableMultiTargetsSwitch = value;
  }

  bool get temporaryEnhancementMode => _temporaryEnhancementMode;

  set temporaryEnhancementMode(bool value) {
    SharedPrefs().temporaryEnhancementMode = value;
    _temporaryEnhancementMode = value;
    calculateCost();
  }

  bool get hailsDiscount => _hailsDiscount;

  set hailsDiscount(bool value) {
    SharedPrefs().hailsDiscount = value;
    _hailsDiscount = value;
    calculateCost();
  }

  bool get lostNonPersistent => _lostNonPersistent;

  set lostNonPersistent(bool value) {
    if (value) {
      persistent = false;
    }
    SharedPrefs().lostNonPersistent = value;
    _lostNonPersistent = value;
    calculateCost();
  }

  bool get persistent => _persistent;

  set persistent(bool value) {
    if (value) {
      lostNonPersistent = false;
    }
    SharedPrefs().persistent = value;
    _persistent = value;
    calculateCost();
  }

  void resetCost() {
    cardLevel = 0;
    previousEnhancements = 0;
    _enhancement = null;
    multipleTargets = false;
    disableMultiTargetsSwitch = false;
    totalCost = 0;
    showCost = false;
    lostNonPersistent = false;
    persistent = false;
    SharedPrefs().remove('targetCardLvl');
    SharedPrefs().remove('enhancementsOnTargetAction');
    SharedPrefs().remove('enhancementType');
    SharedPrefs().remove('disableMultiTargetsSwitch');
    SharedPrefs().remove('multipleTargetsSelected');
    SharedPrefs().remove('enhancementCost');
    SharedPrefs().remove('disableMultiTargetsSwitch');
    SharedPrefs().remove('lostNonPersistent');
    SharedPrefs().remove('persistent');
    notifyListeners();
  }

  void calculateCost({bool notify = true}) {
    /// get the base cost of the selected enhancement
    totalCost = enhancementCost(enhancement);

    /// add 25g for each [cardLevel] beyond 1
    totalCost += cardLevelPenalty(cardLevel);

    /// add 75g for each [previousEnhancement]
    totalCost += previousEnhancementsPenalty(previousEnhancements);

    /// Temporary Enhancement: if there is at least one previous enhancement,
    /// reduce the cost by 20 gold. Then reduce the entire cost by 20%, rouded
    /// up
    if (temporaryEnhancementMode) {
      totalCost = _temporaryEnhancementMutator(totalCost);
    }

    /// only show cost if there's a price to display
    showCost =
        cardLevel != 0 || previousEnhancements != 0 || enhancement != null;
    if (notify) {
      notifyListeners();
    }
  }

  /// Returns a detailed breakdown of how the total cost is calculated.
  ///
  /// The breakdown follows this order:
  /// 1. Base cost (from enhancement type)
  /// 2. Multipliers (multi-target ×2, lost ÷2, persistent ×3)
  /// 3. Discounts (Enhancer L2 -10g, Hail's -5g)
  /// 4. Penalties (card level, previous enhancements)
  /// 5. Temporary enhancement mode (×0.8 rounded up)
  List<CalculationStep> getCalculationBreakdown() {
    final steps = <CalculationStep>[];
    final edition = SharedPrefs().gameEdition;

    if (enhancement == null && cardLevel == 0 && previousEnhancements == 0) {
      return steps;
    }

    int runningTotal = 0;

    // Section 1: Base cost (from enhancement type)
    runningTotal = _addBaseCostStep(steps, edition);

    // Section 2: Multipliers (multi-target, lost, persistent)
    runningTotal = _addMultiplierSteps(steps, runningTotal, edition);

    // Section 3: Discounts (Enhancer L2, Hail's)
    runningTotal = _addDiscountSteps(steps, runningTotal, edition);

    // Ensure enhancement cost doesn't go negative before penalties
    if (runningTotal < 0) {
      runningTotal = 0;
    }

    // Section 4: Penalties (card level, previous enhancements)
    runningTotal = _addCardLevelStep(steps, runningTotal, edition);
    runningTotal = _addPreviousEnhancementsStep(steps, runningTotal, edition);

    // Section 5: Temporary enhancement mode (×0.8 rounded up)
    runningTotal = _addTempEnhancementStep(steps, runningTotal);

    return steps;
  }

  /// Adds the base cost step for the selected enhancement.
  /// Returns the base cost, or 0 if no enhancement is selected.
  int _addBaseCostStep(List<CalculationStep> steps, GameEdition edition) {
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
  int _addMultiplierSteps(
    List<CalculationStep> steps,
    int runningTotal,
    GameEdition edition,
  ) {
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
  int _addDiscountSteps(
    List<CalculationStep> steps,
    int runningTotal,
    GameEdition edition,
  ) {
    if (enhancement == null) {
      return runningTotal;
    }

    // Enhancer Level 2 discount (-10g) - FH only
    if (edition.hasEnhancerLevels && SharedPrefs().enhancerLvl2) {
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
  int _addCardLevelStep(
    List<CalculationStep> steps,
    int runningTotal,
    GameEdition edition,
  ) {
    if (cardLevel <= 0) {
      return runningTotal;
    }

    const int basePerLevel = 25;
    int discountPerLevel = 0;
    String? modifier;

    // Apply party boon discount (GH/GH2E)
    if (edition.supportsPartyBoon && SharedPrefs().partyBoon) {
      discountPerLevel = 5;
      modifier = 'Party Boon: −${discountPerLevel}g/level';
    }
    // Apply Enhancer L3 discount (FH)
    else if (edition.hasEnhancerLevels && SharedPrefs().enhancerLvl3) {
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
    GameEdition edition,
  ) {
    if (previousEnhancements <= 0) {
      return runningTotal;
    }

    const int basePerEnhancement = 75;
    int discountPerEnhancement = 0;
    final modifiers = <String>[];

    // Apply Enhancer L4 discount (FH)
    if (edition.hasEnhancerLevels && SharedPrefs().enhancerLvl4) {
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

  void gameVersionToggled() {
    final edition = SharedPrefs().gameEdition;

    // Clear persistent if switching to an edition that doesn't support it
    if (!edition.hasPersistentModifier && persistent) {
      persistent = false;
    }

    // Clear lostNonPersistent if switching to an edition that doesn't support it
    if (!edition.hasLostModifier && lostNonPersistent) {
      lostNonPersistent = false;
    }

    if (enhancement != null) {
      enhancementSelected(enhancement!);
    }
    notifyListeners();
  }

  void enhancementSelected(Enhancement selectedEnhancement) {
    final edition = SharedPrefs().gameEdition;

    // Handle the case where the user has an enhancement selected that's not
    // available in the current edition (e.g., Disarm in GH2E/FH, Ward in GH,
    // Regenerate in GH2E)
    if (!EnhancementData.isAvailableInEdition(selectedEnhancement, edition)) {
      _enhancement = null;
      SharedPrefs().remove('enhancementType');
      notifyListeners();
      return;
    }

    switch (selectedEnhancement.category) {
      case EnhancementCategory.target:
        // Target: multi-target applies in GH only
        multipleTargets = edition.multiTargetAppliesToAll;
        disableMultiTargetsSwitch = true;
        break;
      case EnhancementCategory.hex:
        multipleTargets = false;
        disableMultiTargetsSwitch = true;
        break;
      case EnhancementCategory.anyElem:
      case EnhancementCategory.specElem:
        // Elements: multi-target applies in GH only
        if (!edition.multiTargetAppliesToAll) {
          multipleTargets = false;
          disableMultiTargetsSwitch = true;
        } else {
          disableMultiTargetsSwitch = false;
        }
        break;
      case EnhancementCategory.summonPlusOne:
        persistent = false;
        // GH2E: "not a summon action" - summon stats never get lost discount
        // FH: Lost discount can apply if action is lost but not persistent
        if (!edition.hasPersistentModifier) {
          lostNonPersistent = false;
        }
        disableMultiTargetsSwitch = false;
        break;
      default:
        disableMultiTargetsSwitch = false;
        break;
    }
    enhancement = selectedEnhancement;
    calculateCost();
  }

  static bool eligibleForMultipleTargets(
    Enhancement enhancement, {
    required GameEdition edition,
  }) {
    final name = enhancement.name.toLowerCase();
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
}
