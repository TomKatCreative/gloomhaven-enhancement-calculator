/// Enhancement calculator state management with delegated cost calculation.
///
/// [EnhancementCalculatorModel] is a thin state management layer that
/// persists calculator inputs via [SharedPrefs] and delegates all cost
/// computation to [EnhancementCostCalculator].
///
/// ## Architecture
///
/// ```
/// UI ← watches → EnhancementCalculatorModel (state + persistence)
///                         ↓ delegates
///                 EnhancementCostCalculator (pure computation)
/// ```
///
/// The model caches an [EnhancementCostCalculator] instance, invalidating
/// it on any state change. Computed properties ([totalCost], [showCost],
/// [getCalculationBreakdown]) delegate to the cached calculator.
///
/// ## State Persistence
///
/// All calculator state is persisted via [SharedPrefs] for session continuity.
///
/// See also:
/// - [EnhancementCostCalculator] for calculation logic and cost flow
/// - [Enhancement] for enhancement definitions
/// - [GameEdition] for edition-specific rules
/// - `docs/viewmodels_reference.md` for full documentation
library;

import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/calculation_step.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement_cost_calculator.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

/// Manages enhancement calculator state and delegates cost calculations
/// to [EnhancementCostCalculator].
///
/// Use [calculateCost] to recalculate after state changes.
/// Use [getCalculationBreakdown] to get step-by-step cost breakdown for UI.
class EnhancementCalculatorModel with ChangeNotifier {
  EnhancementCalculatorModel() {
    // Eagerly build calculator so totalCost/showCost are correct from start
    _invalidateCalculator();
  }

  // ===========================================================================
  // Cached calculator
  // ===========================================================================

  EnhancementCostCalculator? _cachedCalculator;

  EnhancementCostCalculator get _calculator =>
      _cachedCalculator ??= _buildCalculator();

  void _invalidateCalculator() => _cachedCalculator = null;

  EnhancementCostCalculator _buildCalculator() {
    final ed = SharedPrefs().gameEdition;
    return EnhancementCostCalculator(
      edition: ed,
      enhancement: _enhancement,
      cardLevel: _cardLevel,
      previousEnhancements: _previousEnhancements,
      multipleTargets: _multipleTargets,
      lostNonPersistent: _lostNonPersistent,
      persistent: _persistent,
      temporaryEnhancementMode: _temporaryEnhancementMode,
      hailsDiscount: _hailsDiscount,
      partyBoon: ed.supportsPartyBoon && SharedPrefs().partyBoon,
      enhancerLvl2: ed.hasEnhancerLevels && SharedPrefs().enhancerLvl2,
      enhancerLvl3: ed.hasEnhancerLevels && SharedPrefs().enhancerLvl3,
      enhancerLvl4: ed.hasEnhancerLevels && SharedPrefs().enhancerLvl4,
    );
  }

  // ===========================================================================
  // State fields (persisted via SharedPrefs setters)
  // ===========================================================================

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

  // ===========================================================================
  // Computed properties (delegated to calculator)
  // ===========================================================================

  /// The final calculated total cost.
  int get totalCost => _calculator.totalCost;

  /// Whether there is any input to display a cost for.
  bool get showCost => _calculator.showCost;

  /// Returns the current game edition from SharedPrefs.
  GameEdition get edition => SharedPrefs().gameEdition;

  /// Returns true if Enhancer Level 2 affects the enhancement cost.
  bool get enhancerLvl2Applies =>
      edition.hasEnhancerLevels &&
      SharedPrefs().enhancerLvl2 &&
      enhancement != null;

  /// Returns true if Enhancer Level 3 affects the card level cost.
  bool get enhancerLvl3Applies =>
      edition.hasEnhancerLevels && SharedPrefs().enhancerLvl3 && cardLevel > 0;

  /// Returns true if Enhancer Level 4 affects the previous enhancements cost.
  bool get enhancerLvl4Applies =>
      edition.hasEnhancerLevels &&
      SharedPrefs().enhancerLvl4 &&
      previousEnhancements > 0;

  // ===========================================================================
  // Sheet expansion state (ephemeral UI state, not persisted)
  // ===========================================================================

  /// Whether the cost chip is expanded (used to hide FAB).
  bool _isSheetExpanded = false;

  bool get isSheetExpanded => _isSheetExpanded;

  set isSheetExpanded(bool value) {
    if (_isSheetExpanded != value) {
      _isSheetExpanded = value;
      notifyListeners();
    }
  }

  // ===========================================================================
  // State property getters and setters
  // ===========================================================================

  int get cardLevel => _cardLevel;

  set cardLevel(int cardLevel) {
    SharedPrefs().targetCardLvl = cardLevel;
    _cardLevel = cardLevel;
    calculateCost();
  }

  int get previousEnhancements => _previousEnhancements;

  set previousEnhancements(int previousEnhancements) {
    SharedPrefs().previousEnhancements = previousEnhancements;
    _previousEnhancements = previousEnhancements;
    calculateCost();
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

  // ===========================================================================
  // Thin wrappers (delegate to calculator, preserve public API)
  // ===========================================================================

  /// Computes the base enhancement cost with multipliers and flat discounts.
  ///
  /// Accepts an arbitrary [enhancement] to support cost preview in the
  /// enhancement type selector screen.
  int enhancementCost(Enhancement? enhancement) =>
      _calculator.enhancementCost(enhancement);

  /// Computes the card level penalty for a given [level].
  int cardLevelPenalty(int level) => _calculator.cardLevelPenalty(level);

  /// Computes the previous enhancements penalty.
  int previousEnhancementsPenalty(int previousEnhancements) =>
      _calculator.previousEnhancementsPenalty(previousEnhancements);

  /// Returns a detailed breakdown of how the total cost is calculated.
  List<CalculationStep> getCalculationBreakdown() => _calculator.breakdown;

  /// Whether the given [enhancement] is eligible for multi-target multiplier.
  static bool eligibleForMultipleTargets(
    Enhancement enhancement, {
    required GameEdition edition,
  }) => EnhancementCostCalculator.eligibleForMultipleTargets(
    enhancement,
    edition: edition,
  );

  // ===========================================================================
  // State mutation methods
  // ===========================================================================

  /// Invalidates the cached calculator and optionally notifies listeners.
  ///
  /// Call this after external state changes (e.g. EnhancerDialog writing
  /// directly to SharedPrefs) to pick up the new values.
  void calculateCost({bool notify = true}) {
    _invalidateCalculator();
    if (notify) {
      notifyListeners();
    }
  }

  /// Resets all calculator state to defaults and clears SharedPrefs.
  void resetCost() {
    _cardLevel = 0;
    _previousEnhancements = 0;
    _enhancement = null;
    _multipleTargets = false;
    _disableMultiTargetsSwitch = false;
    _lostNonPersistent = false;
    _persistent = false;
    SharedPrefs().remove('targetCardLvl');
    SharedPrefs().remove('enhancementsOnTargetAction');
    SharedPrefs().remove('enhancementType');
    SharedPrefs().remove('disableMultiTargetsSwitch');
    SharedPrefs().remove('multipleTargetsSelected');
    SharedPrefs().remove('enhancementCost');
    SharedPrefs().remove('lostNonPersistent');
    SharedPrefs().remove('persistent');
    _invalidateCalculator();
    notifyListeners();
  }

  /// Re-reads all fields from SharedPrefs and recalculates.
  ///
  /// Call this after a backup restore to sync the model with the
  /// newly imported SharedPreferences values.
  void reloadFromPrefs() {
    _cardLevel = SharedPrefs().targetCardLvl;
    _previousEnhancements = SharedPrefs().previousEnhancements;

    final enhancementIndex = SharedPrefs().enhancementTypeIndex;
    if (enhancementIndex > 0 &&
        enhancementIndex < EnhancementData.enhancements.length) {
      _enhancement = EnhancementData.enhancements[enhancementIndex];
    } else {
      _enhancement = null;
    }

    _multipleTargets = SharedPrefs().multipleTargetsSwitch;
    _lostNonPersistent = SharedPrefs().lostNonPersistent;
    _persistent = SharedPrefs().persistent;
    _disableMultiTargetsSwitch = SharedPrefs().disableMultiTargetSwitch;
    _temporaryEnhancementMode = SharedPrefs().temporaryEnhancementMode;
    _hailsDiscount = SharedPrefs().hailsDiscount;

    calculateCost();
  }

  /// Handles edition change with modifier validation.
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

  /// Handles enhancement selection with edition-specific validation.
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
}
