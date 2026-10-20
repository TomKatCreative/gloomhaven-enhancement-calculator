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
/// Every public mutation notifies listeners exactly once. Side effects such
/// as clearing the persistent modifier go through private `_write*` helpers,
/// which persist and assign without notifying.
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
/// Use [getCalculationBreakdown] to get step-by-step cost breakdown for UI.
class EnhancementCalculatorModel with ChangeNotifier {
  EnhancementCalculatorModel() {
    // Eagerly build calculator so totalCost/showCost are correct from start
    _invalidateCalculator();
  }

  /// Reads the persisted enhancement selection by its stable
  /// [Enhancement.key], returning null for a missing or unknown key.
  ///
  /// Falls back to the legacy `enhancementType` list index for users who
  /// haven't run this version yet, and migrates it to a key. The index is
  /// range-checked: older app versions shipped a longer enhancement list, and
  /// indexing directly would throw a `RangeError` while this model is
  /// constructed — since the model is built above the app's [Scaffold], that
  /// surfaces as a blank/grey screen with no app bar.
  static Enhancement? _enhancementFromPrefs() {
    final key = SharedPrefs().enhancementKey;
    if (key != null) return EnhancementData.byKey(key);

    final index = SharedPrefs().enhancementTypeIndex;
    SharedPrefs().enhancementTypeIndex = null;
    if (index != null &&
        index > 0 &&
        index < EnhancementData.enhancements.length) {
      final enhancement = EnhancementData.enhancements[index];
      SharedPrefs().enhancementKey = enhancement.key;
      return enhancement;
    }
    return null;
  }

  // ===========================================================================
  // Cached calculator
  // ===========================================================================

  EnhancementCostCalculator? _cachedCalculator;

  EnhancementCostCalculator get _calculator =>
      _cachedCalculator ??= _buildCalculator();

  void _invalidateCalculator() => _cachedCalculator = null;

  /// Invalidates the cached calculator and notifies listeners once.
  void _changed() {
    _invalidateCalculator();
    notifyListeners();
  }

  EnhancementCostCalculator _buildCalculator() {
    return EnhancementCostCalculator(
      edition: _gameEdition,
      enhancement: _enhancement,
      cardLevel: _cardLevel,
      previousEnhancements: _previousEnhancements,
      multipleTargets: _multipleTargets,
      lostNonPersistent: _lostNonPersistent,
      persistent: _persistent,
      temporaryEnhancementMode: _temporaryEnhancementMode,
      hailsDiscount: _hailsDiscount,
      partyBoon: _gameEdition.supportsPartyBoon && _partyBoon,
      enhancerLvl2: _gameEdition.hasEnhancerLevels && _enhancerLvl2,
      enhancerLvl3: _gameEdition.hasEnhancerLevels && _enhancerLvl3,
      enhancerLvl4: _gameEdition.hasEnhancerLevels && _enhancerLvl4,
    );
  }

  // ===========================================================================
  // State fields (persisted via SharedPrefs setters)
  // ===========================================================================

  GameEdition _gameEdition = SharedPrefs().gameEdition;

  bool _partyBoon = SharedPrefs().partyBoon;

  bool _enhancerLvl2 = SharedPrefs().enhancerLvl2;

  bool _enhancerLvl3 = SharedPrefs().enhancerLvl3;

  bool _enhancerLvl4 = SharedPrefs().enhancerLvl4;

  int _cardLevel = SharedPrefs().targetCardLvl;

  int _previousEnhancements = SharedPrefs().previousEnhancements;

  Enhancement? _enhancement = _enhancementFromPrefs();

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

  /// Returns the current game edition.
  GameEdition get edition => _gameEdition;

  set gameEdition(GameEdition value) {
    SharedPrefs().gameEdition = value;
    _gameEdition = value;
    gameVersionToggled();
  }

  /// Returns the party boon state.
  bool get partyBoon => _partyBoon;

  set partyBoon(bool value) {
    SharedPrefs().partyBoon = value;
    _partyBoon = value;
    _changed();
  }

  /// Returns the enhancer level 2 state.
  bool get enhancerLvl2 => _enhancerLvl2;

  set enhancerLvl2(bool value) => _setEnhancerLevel(2, value);

  /// Returns the enhancer level 3 state.
  bool get enhancerLvl3 => _enhancerLvl3;

  set enhancerLvl3(bool value) => _setEnhancerLevel(3, value);

  /// Returns the enhancer level 4 state.
  bool get enhancerLvl4 => _enhancerLvl4;

  set enhancerLvl4(bool value) => _setEnhancerLevel(4, value);

  /// Sets enhancer [level] and keeps the others consistent: each level needs
  /// the ones below it, so turning one on turns on every lower level and
  /// turning one off turns off every higher level. All four levels are
  /// persisted (level 1 has no toggle but is kept for backups).
  ///
  /// The untouched levels come from SharedPrefs rather than the cache, so a
  /// restore that wrote new levels without [reloadFromPrefs] isn't undone.
  void _setEnhancerLevel(int level, bool value) {
    bool resolve(int other, bool current) {
      if (other == level) return value;
      if (value && other < level) return true;
      if (!value && other > level) return false;
      return current;
    }

    final prefs = SharedPrefs();
    prefs.enhancerLvl1 = resolve(1, prefs.enhancerLvl1);
    prefs.enhancerLvl2 = _enhancerLvl2 = resolve(2, prefs.enhancerLvl2);
    prefs.enhancerLvl3 = _enhancerLvl3 = resolve(3, prefs.enhancerLvl3);
    prefs.enhancerLvl4 = _enhancerLvl4 = resolve(4, prefs.enhancerLvl4);
    _changed();
  }

  /// Whether the party boon currently affects cost calculation.
  bool get partyBoonApplies => _gameEdition.supportsPartyBoon && _partyBoon;

  /// Whether any enhancer building upgrades are active.
  bool get hasAnyEnhancerUpgrades =>
      _enhancerLvl2 || _enhancerLvl3 || _enhancerLvl4;

  /// Returns true if Enhancer Level 2 affects the enhancement cost.
  bool get enhancerLvl2Applies =>
      _gameEdition.hasEnhancerLevels && _enhancerLvl2 && enhancement != null;

  /// Returns true if Enhancer Level 3 affects the card level cost.
  bool get enhancerLvl3Applies =>
      _gameEdition.hasEnhancerLevels && _enhancerLvl3 && cardLevel > 0;

  /// Returns true if Enhancer Level 4 affects the previous enhancements cost.
  bool get enhancerLvl4Applies =>
      _gameEdition.hasEnhancerLevels &&
      _enhancerLvl4 &&
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
    _changed();
  }

  int get previousEnhancements => _previousEnhancements;

  set previousEnhancements(int previousEnhancements) {
    SharedPrefs().previousEnhancements = previousEnhancements;
    _previousEnhancements = previousEnhancements;
    _changed();
  }

  Enhancement? get enhancement => _enhancement;

  bool get multipleTargets => _multipleTargets;

  set multipleTargets(bool value) {
    _writeMultipleTargets(value);
    _changed();
  }

  bool get disableMultiTargetsSwitch => _disableMultiTargetsSwitch;

  bool get temporaryEnhancementMode => _temporaryEnhancementMode;

  set temporaryEnhancementMode(bool value) {
    SharedPrefs().temporaryEnhancementMode = value;
    _temporaryEnhancementMode = value;
    _changed();
  }

  bool get hailsDiscount => _hailsDiscount;

  set hailsDiscount(bool value) {
    SharedPrefs().hailsDiscount = value;
    _hailsDiscount = value;
    _changed();
  }

  bool get lostNonPersistent => _lostNonPersistent;

  set lostNonPersistent(bool value) {
    if (value) {
      _writePersistent(false);
    }
    _writeLost(value);
    _changed();
  }

  bool get persistent => _persistent;

  set persistent(bool value) {
    if (value) {
      _writeLost(false);
    }
    _writePersistent(value);
    _changed();
  }

  // ===========================================================================
  // Private writers (persist and assign without notifying)
  // ===========================================================================

  void _writeEnhancement(Enhancement enhancement) {
    SharedPrefs().enhancementKey = enhancement.key;
    _enhancement = enhancement;
  }

  void _writeMultipleTargets(bool value) {
    SharedPrefs().multipleTargetsSwitch = value;
    _multipleTargets = value;
  }

  void _writeDisableMultiTargets(bool value) {
    SharedPrefs().disableMultiTargetSwitch = value;
    _disableMultiTargetsSwitch = value;
  }

  void _writeLost(bool value) {
    SharedPrefs().lostNonPersistent = value;
    _lostNonPersistent = value;
  }

  void _writePersistent(bool value) {
    SharedPrefs().persistent = value;
    _persistent = value;
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

  /// Resets all calculator state to defaults and clears SharedPrefs.
  void resetCost() {
    _cardLevel = 0;
    _previousEnhancements = 0;
    _enhancement = null;
    _multipleTargets = false;
    _disableMultiTargetsSwitch = false;
    _lostNonPersistent = false;
    _persistent = false;
    SharedPrefs().resetCalculatorInputs();
    _changed();
  }

  /// Re-reads all fields from SharedPrefs and recalculates.
  ///
  /// Call this after a backup restore to sync the model with the
  /// newly imported SharedPreferences values.
  void reloadFromPrefs() {
    _gameEdition = SharedPrefs().gameEdition;
    _partyBoon = SharedPrefs().partyBoon;
    _enhancerLvl2 = SharedPrefs().enhancerLvl2;
    _enhancerLvl3 = SharedPrefs().enhancerLvl3;
    _enhancerLvl4 = SharedPrefs().enhancerLvl4;
    _cardLevel = SharedPrefs().targetCardLvl;
    _previousEnhancements = SharedPrefs().previousEnhancements;

    _enhancement = _enhancementFromPrefs();

    _multipleTargets = SharedPrefs().multipleTargetsSwitch;
    _lostNonPersistent = SharedPrefs().lostNonPersistent;
    _persistent = SharedPrefs().persistent;
    _disableMultiTargetsSwitch = SharedPrefs().disableMultiTargetSwitch;
    _temporaryEnhancementMode = SharedPrefs().temporaryEnhancementMode;
    _hailsDiscount = SharedPrefs().hailsDiscount;

    _changed();
  }

  /// Handles edition change with modifier validation.
  void gameVersionToggled() {
    // Clear persistent if switching to an edition that doesn't support it
    if (!_gameEdition.hasPersistentModifier && _persistent) {
      _writePersistent(false);
    }

    // Clear lostNonPersistent if switching to an edition that doesn't support it
    if (!_gameEdition.hasLostModifier && _lostNonPersistent) {
      _writeLost(false);
    }

    final selected = _enhancement;
    if (selected != null) {
      _applyEnhancement(selected);
    }
    _changed();
  }

  /// Handles enhancement selection with edition-specific validation.
  void enhancementSelected(Enhancement selectedEnhancement) {
    _applyEnhancement(selectedEnhancement);
    _changed();
  }

  /// Applies [selectedEnhancement] and its side effects without notifying.
  void _applyEnhancement(Enhancement selectedEnhancement) {
    final edition = _gameEdition;

    // Handle the case where the user has an enhancement selected that's not
    // available in the current edition (e.g., Disarm in GH2E/FH, Ward in GH)
    if (!EnhancementData.isAvailableInEdition(selectedEnhancement, edition)) {
      _enhancement = null;
      SharedPrefs().clearEnhancementSelection();
      return;
    }

    final eligible = eligibleForMultipleTargets(
      selectedEnhancement,
      edition: edition,
    );
    if (selectedEnhancement.category == EnhancementCategory.target) {
      // Target always targets multiple: the multiplier applies in GH only
      _writeMultipleTargets(eligible);
      _writeDisableMultiTargets(true);
    } else if (!eligible) {
      // Hex, and elements outside GH
      _writeMultipleTargets(false);
      _writeDisableMultiTargets(true);
    } else {
      _writeDisableMultiTargets(false);
    }

    if (selectedEnhancement.category == EnhancementCategory.summonPlusOne) {
      _writePersistent(false);
      // GH2E: "not a summon action" - summon stats never get lost discount
      // FH: Lost discount can apply if action is lost but not persistent
      if (!edition.hasPersistentModifier) {
        _writeLost(false);
      }
    }
    _writeEnhancement(selectedEnhancement);
  }
}
