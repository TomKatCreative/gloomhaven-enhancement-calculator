import 'dart:convert';

import 'package:gloomhaven_enhancement_calc/data/backup_exception.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stored SharedPreferences key for each [SharedPrefs] property, named after
/// the property. Several values differ from their names for historical
/// reasons; they are what's on disk and in backups, so never change one.
abstract final class _Keys {
  static const clearSharedPrefs = 'clearOldPrefs';
  static const partyBoon = 'partyBoon';
  static const showRetiredCharacters = 'showRetiredCharacters';
  static const enhancerLvl1 = 'enhancerLvl1';
  static const enhancerLvl2 = 'enhancerLvl2';
  static const enhancerLvl3 = 'enhancerLvl3';
  static const enhancerLvl4 = 'enhancerLvl4';
  static const darkTheme = 'darkTheme';
  static const primaryClassColor = 'primaryClassColor';
  static const envelopeX = 'envelopeX';
  static const envelopeV = 'envelopeV';
  static const initialPage = 'initialPage';
  static const currentCharacterIndex = 'currentCharacterIndex';
  static const generalExpanded = 'generalExpanded';
  static const questAndNotesExpanded = 'questAndNotesExpanded';
  static const perksAndMasteriesExpanded = 'perksAndMasteriesExpanded';
  static const townDetailsExpanded = 'townDetailsExpanded';
  static const partyDetailsExpanded = 'partyDetailsExpanded';
  static const targetCardLvl = 'targetCardLvl';
  static const previousEnhancements = 'enhancementsOnTargetAction';
  static const enhancementKey = 'enhancementKey';
  static const enhancementTypeIndex = 'enhancementType';
  static const disableMultiTargetSwitch = 'disableMultiTargetsSwitch';
  static const temporaryEnhancementMode = 'temporaryEnhancementMode';
  static const multipleTargetsSwitch = 'multipleTargetsSelected';
  static const gameEdition = 'gameEdition';
  static const legacyGloomhavenMode = 'gloomhavenMode';
  static const lostNonPersistent = 'lostNonPersistent';
  static const persistent = 'persistent';
  static const hideCustomClassesWarningMessage =
      'hideCustomClassesWarningMessage';
  static const showUpdate450Dialog = 'showUpdate450Dialog';
  static const useDefaultFonts = 'useDefaultFonts';
  static const hailsDiscount = 'hailsDiscount';
  static const isUSRegion = 'isUSRegion';
  static const activeCampaignId = 'activeCampaignId';
  static const activePartyId = 'activePartyId';
  static const showAllCharacters = 'showAllCharacters';
}

/// Top-level category names in a backup's prefs map.
abstract final class _Categories {
  static const settings = 'settings';
  static const town = 'town';
  static const calculator = 'calculator';
  static const enhancerLevels = 'enhancerLevels';
  static const classUnlocks = 'classUnlocks';
}

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async =>
      _sharedPrefs = await SharedPreferences.getInstance();

  void _remove(String key) => _sharedPrefs.remove(key);

  void removeAll() => _sharedPrefs.clear();

  bool get clearSharedPrefs =>
      _sharedPrefs.getBool(_Keys.clearSharedPrefs) ?? true;

  set clearSharedPrefs(bool value) =>
      _sharedPrefs.setBool(_Keys.clearSharedPrefs, value);

  bool get partyBoon => _sharedPrefs.getBool(_Keys.partyBoon) ?? false;

  set partyBoon(bool value) => _sharedPrefs.setBool(_Keys.partyBoon, value);

  bool get showRetiredCharacters =>
      _sharedPrefs.getBool(_Keys.showRetiredCharacters) ?? true;

  set showRetiredCharacters(bool value) =>
      _sharedPrefs.setBool(_Keys.showRetiredCharacters, value);

  // Enhancer levels are plain writes. The rule that keeps them consistent
  // (a level implies the ones below it) lives in EnhancementCalculatorModel.

  bool get enhancerLvl1 => _sharedPrefs.getBool(_Keys.enhancerLvl1) ?? false;

  set enhancerLvl1(bool value) =>
      _sharedPrefs.setBool(_Keys.enhancerLvl1, value);

  bool get enhancerLvl2 => _sharedPrefs.getBool(_Keys.enhancerLvl2) ?? false;

  set enhancerLvl2(bool value) =>
      _sharedPrefs.setBool(_Keys.enhancerLvl2, value);

  bool get enhancerLvl3 => _sharedPrefs.getBool(_Keys.enhancerLvl3) ?? false;

  set enhancerLvl3(bool value) =>
      _sharedPrefs.setBool(_Keys.enhancerLvl3, value);

  bool get enhancerLvl4 => _sharedPrefs.getBool(_Keys.enhancerLvl4) ?? false;

  set enhancerLvl4(bool value) =>
      _sharedPrefs.setBool(_Keys.enhancerLvl4, value);

  bool get darkTheme => _sharedPrefs.getBool(_Keys.darkTheme) ?? false;

  set darkTheme(bool value) => _sharedPrefs.setBool(_Keys.darkTheme, value);

  int get primaryClassColor =>
      _sharedPrefs.getInt(_Keys.primaryClassColor) ?? 0xff4e7ec1;

  set primaryClassColor(int value) =>
      _sharedPrefs.setInt(_Keys.primaryClassColor, value);

  bool get envelopeX => _sharedPrefs.getBool(_Keys.envelopeX) ?? false;

  set envelopeX(bool value) => _sharedPrefs.setBool(_Keys.envelopeX, value);

  bool get envelopeV => _sharedPrefs.getBool(_Keys.envelopeV) ?? false;

  set envelopeV(bool value) => _sharedPrefs.setBool(_Keys.envelopeV, value);

  int get initialPage =>
      _sharedPrefs.getInt(_Keys.initialPage) ?? kCharactersPageIndex;

  set initialPage(int value) => _sharedPrefs.setInt(_Keys.initialPage, value);

  int get currentCharacterIndex =>
      _sharedPrefs.getInt(_Keys.currentCharacterIndex) ?? 0;

  set currentCharacterIndex(int value) =>
      _sharedPrefs.setInt(_Keys.currentCharacterIndex, value);

  bool get generalExpanded =>
      _sharedPrefs.getBool(_Keys.generalExpanded) ?? true;

  set generalExpanded(bool value) =>
      _sharedPrefs.setBool(_Keys.generalExpanded, value);

  bool get questAndNotesExpanded =>
      _sharedPrefs.getBool(_Keys.questAndNotesExpanded) ?? true;

  set questAndNotesExpanded(bool value) =>
      _sharedPrefs.setBool(_Keys.questAndNotesExpanded, value);

  bool get perksAndMasteriesExpanded =>
      _sharedPrefs.getBool(_Keys.perksAndMasteriesExpanded) ?? true;

  set perksAndMasteriesExpanded(bool value) =>
      _sharedPrefs.setBool(_Keys.perksAndMasteriesExpanded, value);

  bool get townDetailsExpanded =>
      _sharedPrefs.getBool(_Keys.townDetailsExpanded) ?? true;

  set townDetailsExpanded(bool value) =>
      _sharedPrefs.setBool(_Keys.townDetailsExpanded, value);

  bool get partyDetailsExpanded =>
      _sharedPrefs.getBool(_Keys.partyDetailsExpanded) ?? true;

  set partyDetailsExpanded(bool value) =>
      _sharedPrefs.setBool(_Keys.partyDetailsExpanded, value);

  int get targetCardLvl => _sharedPrefs.getInt(_Keys.targetCardLvl) ?? 0;

  set targetCardLvl(int value) =>
      _sharedPrefs.setInt(_Keys.targetCardLvl, value);

  int get previousEnhancements =>
      _sharedPrefs.getInt(_Keys.previousEnhancements) ?? 0;

  set previousEnhancements(int value) =>
      _sharedPrefs.setInt(_Keys.previousEnhancements, value);

  /// Selected enhancement as an [Enhancement.key]; null means no selection.
  String? get enhancementKey => _sharedPrefs.getString(_Keys.enhancementKey);

  set enhancementKey(String? value) {
    if (value == null) {
      _remove(_Keys.enhancementKey);
    } else {
      _sharedPrefs.setString(_Keys.enhancementKey, value);
    }
  }

  /// Legacy selection stored as a list index, superseded by [enhancementKey];
  /// null when absent. Still read so existing users and old backups keep
  /// their selection; index 0 was ambiguous (Move or no selection) and is
  /// treated as no selection.
  int? get enhancementTypeIndex =>
      _sharedPrefs.getInt(_Keys.enhancementTypeIndex);

  set enhancementTypeIndex(int? value) {
    if (value == null) {
      _remove(_Keys.enhancementTypeIndex);
    } else {
      _sharedPrefs.setInt(_Keys.enhancementTypeIndex, value);
    }
  }

  bool get disableMultiTargetSwitch =>
      _sharedPrefs.getBool(_Keys.disableMultiTargetSwitch) ?? false;

  set disableMultiTargetSwitch(bool value) =>
      _sharedPrefs.setBool(_Keys.disableMultiTargetSwitch, value);

  bool get temporaryEnhancementMode =>
      _sharedPrefs.getBool(_Keys.temporaryEnhancementMode) ?? false;

  set temporaryEnhancementMode(bool value) =>
      _sharedPrefs.setBool(_Keys.temporaryEnhancementMode, value);

  bool get multipleTargetsSwitch =>
      _sharedPrefs.getBool(_Keys.multipleTargetsSwitch) ?? false;

  set multipleTargetsSwitch(bool value) =>
      _sharedPrefs.setBool(_Keys.multipleTargetsSwitch, value);

  /// Game edition for enhancement calculator
  /// Migrates from legacy gloomhavenMode boolean if present
  GameEdition get gameEdition {
    // Check for new gameEdition key first
    final editionIndex = _sharedPrefs.getInt(_Keys.gameEdition);
    if (editionIndex != null && editionIndex < GameEdition.values.length) {
      return GameEdition.values[editionIndex];
    }

    // Migrate from legacy gloomhavenMode boolean
    final legacyMode = _sharedPrefs.getBool(_Keys.legacyGloomhavenMode);
    if (legacyMode != null) {
      final edition = legacyMode
          ? GameEdition.gloomhaven
          : GameEdition.frosthaven;
      // Save migrated value and remove legacy key
      _sharedPrefs.setInt(_Keys.gameEdition, edition.index);
      _remove(_Keys.legacyGloomhavenMode);
      return edition;
    }

    // Default to Gloomhaven
    return GameEdition.gloomhaven;
  }

  set gameEdition(GameEdition value) =>
      _sharedPrefs.setInt(_Keys.gameEdition, value.index);

  bool get lostNonPersistent =>
      _sharedPrefs.getBool(_Keys.lostNonPersistent) ?? false;

  set lostNonPersistent(bool value) =>
      _sharedPrefs.setBool(_Keys.lostNonPersistent, value);

  bool get persistent => _sharedPrefs.getBool(_Keys.persistent) ?? false;

  set persistent(bool value) => _sharedPrefs.setBool(_Keys.persistent, value);

  bool get hideCustomClassesWarningMessage =>
      _sharedPrefs.getBool(_Keys.hideCustomClassesWarningMessage) ?? false;

  set hideCustomClassesWarningMessage(bool value) =>
      _sharedPrefs.setBool(_Keys.hideCustomClassesWarningMessage, value);

  bool get showUpdate450Dialog =>
      _sharedPrefs.getBool(_Keys.showUpdate450Dialog) ?? true;

  set showUpdate450Dialog(bool value) =>
      _sharedPrefs.setBool(_Keys.showUpdate450Dialog, value);

  bool getPlayerClassIsUnlocked(String classCode) =>
      _sharedPrefs.getBool(classCode) ?? false;

  void setPlayerClassIsUnlocked(String classCode, bool value) {
    _sharedPrefs.setBool(classCode, value);
  }

  bool get useDefaultFonts =>
      _sharedPrefs.getBool(_Keys.useDefaultFonts) ?? false;

  set useDefaultFonts(bool value) =>
      _sharedPrefs.setBool(_Keys.useDefaultFonts, value);

  bool get hailsDiscount => _sharedPrefs.getBool(_Keys.hailsDiscount) ?? false;

  set hailsDiscount(bool value) =>
      _sharedPrefs.setBool(_Keys.hailsDiscount, value);

  bool get isUSRegion => _sharedPrefs.getBool(_Keys.isUSRegion) ?? false;

  set isUSRegion(bool value) => _sharedPrefs.setBool(_Keys.isUSRegion, value);

  // ===========================================================================
  // Calculator Reset
  // ===========================================================================

  /// Clears the selected enhancement in both the current and legacy formats.
  void clearEnhancementSelection() {
    enhancementKey = null;
    enhancementTypeIndex = null;
  }

  /// Clears the per-card calculator inputs: card level, previous
  /// enhancements, the selected enhancement, multi-target and the lost and
  /// persistent modifiers.
  ///
  /// Edition, party boon, temporary mode, Hail's discount and enhancer levels
  /// describe the player's campaign rather than the card being enhanced, so
  /// they survive a reset.
  void resetCalculatorInputs() {
    _remove(_Keys.targetCardLvl);
    _remove(_Keys.previousEnhancements);
    clearEnhancementSelection();
    _remove(_Keys.disableMultiTargetSwitch);
    _remove(_Keys.multipleTargetsSwitch);
    _remove(_Keys.lostNonPersistent);
    _remove(_Keys.persistent);
  }

  // ===========================================================================
  // Town / Campaign / Party State
  // ===========================================================================

  String? get activeCampaignId =>
      _sharedPrefs.getString(_Keys.activeCampaignId);

  set activeCampaignId(String? value) {
    if (value == null) {
      _remove(_Keys.activeCampaignId);
    } else {
      _sharedPrefs.setString(_Keys.activeCampaignId, value);
    }
  }

  String? get activePartyId => _sharedPrefs.getString(_Keys.activePartyId);

  set activePartyId(String? value) {
    if (value == null) {
      _remove(_Keys.activePartyId);
    } else {
      _sharedPrefs.setString(_Keys.activePartyId, value);
    }
  }

  bool get showAllCharacters =>
      _sharedPrefs.getBool(_Keys.showAllCharacters) ?? true;

  set showAllCharacters(bool value) =>
      _sharedPrefs.setBool(_Keys.showAllCharacters, value);

  // ===========================================================================
  // Backup Export / Import
  // ===========================================================================

  /// Exports a categorized map of SharedPreferences for inclusion in backups.
  ///
  /// Excluded: clearOldPrefs, initialPage, generalExpanded,
  /// showUpdate*Dialog, isUSRegion, gloomhavenMode (legacy).
  Map<String, dynamic> exportForBackup() {
    final classUnlocks = <String, dynamic>{};
    for (final pc in PlayerClasses.playerClasses) {
      if (pc.locked) {
        classUnlocks[pc.classCode] = getPlayerClassIsUnlocked(pc.classCode);
      }
    }

    return {
      _Categories.settings: {
        _Keys.darkTheme: darkTheme,
        _Keys.useDefaultFonts: useDefaultFonts,
        _Keys.primaryClassColor: primaryClassColor,
        _Keys.showRetiredCharacters: showRetiredCharacters,
        _Keys.hideCustomClassesWarningMessage: hideCustomClassesWarningMessage,
        _Keys.envelopeX: envelopeX,
        _Keys.envelopeV: envelopeV,
        _Keys.showAllCharacters: showAllCharacters,
      },
      if (kTownSheetEnabled)
        _Categories.town: {
          if (activeCampaignId != null)
            _Keys.activeCampaignId: activeCampaignId,
          if (activePartyId != null) _Keys.activePartyId: activePartyId,
        },
      _Categories.calculator: {
        _Keys.gameEdition: gameEdition.index,
        _Keys.enhancementKey: enhancementKey,
        _Keys.previousEnhancements: previousEnhancements,
        _Keys.targetCardLvl: targetCardLvl,
        _Keys.disableMultiTargetSwitch: disableMultiTargetSwitch,
        _Keys.multipleTargetsSwitch: multipleTargetsSwitch,
        _Keys.temporaryEnhancementMode: temporaryEnhancementMode,
        _Keys.partyBoon: partyBoon,
        _Keys.lostNonPersistent: lostNonPersistent,
        _Keys.persistent: persistent,
        _Keys.hailsDiscount: hailsDiscount,
      },
      _Categories.enhancerLevels: {
        _Keys.enhancerLvl1: enhancerLvl1,
        _Keys.enhancerLvl2: enhancerLvl2,
        _Keys.enhancerLvl3: enhancerLvl3,
        _Keys.enhancerLvl4: enhancerLvl4,
      },
      _Categories.classUnlocks: classUnlocks,
    };
  }

  /// Validates and imports SharedPreferences data from a backup map.
  ///
  /// Throws a [BackupException] before writing anything if a value is invalid.
  void importFromBackup(Map<String, dynamic> data) =>
      applyBackupPrefs(BackupPrefs.parse(data));

  /// Writes settings already validated by [BackupPrefs.parse].
  ///
  /// Enhancer levels are written exactly as stored, without re-applying the
  /// calculator's level rule, since backup data is already self-consistent.
  void applyBackupPrefs(BackupPrefs prefs) {
    for (final MapEntry(:key, :value) in prefs.values.entries) {
      switch (value) {
        case bool():
          _sharedPrefs.setBool(key, value);
        case int():
          _sharedPrefs.setInt(key, value);
        case String():
          _sharedPrefs.setString(key, value);
      }
    }
    prefs.removals.forEach(_remove);

    // Class unlocks — reset all locked classes first, then apply backup
    final unlocks = prefs.classUnlocks;
    if (unlocks != null) {
      for (final pc in PlayerClasses.playerClasses) {
        if (pc.locked) {
          setPlayerClassIsUnlocked(
            pc.classCode,
            unlocks[pc.classCode] ?? false,
          );
        }
      }
    }
  }
}

/// The SharedPreferences part of a backup, type-checked and ready to write.
///
/// [parse] does all the validation, so a restore can reject bad settings
/// before it touches the database. [SharedPrefs.applyBackupPrefs] only writes.
class BackupPrefs {
  const BackupPrefs._(this.values, this.removals, this.classUnlocks);

  /// Pref key → validated `bool`, `int` or `String` value to write.
  final Map<String, Object> values;

  /// Pref keys to remove.
  final Set<String> removals;

  /// Locked class code → unlocked; null when the backup has no unlocks.
  /// Classes missing from the map are re-locked on apply.
  final Map<String, bool>? classUnlocks;

  // Highest selectable values in the calculator UI (card_level_body.dart,
  // previous_enhancements_body.dart). Larger values would break its widgets.
  static const _maxTargetCardLvl = 8;
  static const _maxPreviousEnhancements = 3;

  static const _settingsBools = [
    _Keys.darkTheme,
    _Keys.useDefaultFonts,
    _Keys.showRetiredCharacters,
    _Keys.hideCustomClassesWarningMessage,
    _Keys.envelopeX,
    _Keys.envelopeV,
    _Keys.showAllCharacters,
  ];

  static const _calculatorBools = [
    _Keys.disableMultiTargetSwitch,
    _Keys.multipleTargetsSwitch,
    _Keys.temporaryEnhancementMode,
    _Keys.partyBoon,
    _Keys.lostNonPersistent,
    _Keys.persistent,
    _Keys.hailsDiscount,
  ];

  static const _enhancerLevels = [
    _Keys.enhancerLvl1,
    _Keys.enhancerLvl2,
    _Keys.enhancerLvl3,
    _Keys.enhancerLvl4,
  ];

  /// Validates a backup's prefs map. Throws a [BackupException] if any value
  /// has the wrong type.
  ///
  /// Each category is optional, and keys this version doesn't know are
  /// ignored. Out-of-range calculator values (e.g. an edition from a newer
  /// app) are skipped and keep their current value.
  static BackupPrefs parse(Map<String, dynamic> data) {
    final values = <String, Object>{};
    final removals = <String>{};

    final settings = _category(data, _Categories.settings);
    if (settings != null) {
      for (final key in _settingsBools) {
        _put<bool>(values, settings, _Categories.settings, key);
      }
      _put<int>(
        values,
        settings,
        _Categories.settings,
        _Keys.primaryClassColor,
      );
    }

    final town = kTownSheetEnabled ? _category(data, _Categories.town) : null;
    if (town != null) {
      for (final key in [_Keys.activeCampaignId, _Keys.activePartyId]) {
        if (!town.containsKey(key)) continue;
        final id = _typed<String?>(town, _Categories.town, key);
        id == null ? removals.add(key) : values[key] = id;
      }
    }

    final calculator = _category(data, _Categories.calculator);
    if (calculator != null) {
      final edition = _typed<int?>(
        calculator,
        _Categories.calculator,
        _Keys.gameEdition,
      );
      if (edition != null &&
          edition >= 0 &&
          edition < GameEdition.values.length) {
        values[_Keys.gameEdition] = edition;
      }
      // Each format clears the other so the restored selection always wins:
      // the key takes precedence over the legacy index when both are present.
      if (calculator.containsKey(_Keys.enhancementKey)) {
        final key = _typed<String?>(
          calculator,
          _Categories.calculator,
          _Keys.enhancementKey,
        );
        key == null
            ? removals.add(_Keys.enhancementKey)
            : values[_Keys.enhancementKey] = key;
        removals.add(_Keys.enhancementTypeIndex);
      } else if (calculator.containsKey(_Keys.enhancementTypeIndex)) {
        values[_Keys.enhancementTypeIndex] = _typed<int>(
          calculator,
          _Categories.calculator,
          _Keys.enhancementTypeIndex,
        );
        removals.add(_Keys.enhancementKey);
      }
      _putInRange(
        values,
        calculator,
        _Keys.previousEnhancements,
        _maxPreviousEnhancements,
      );
      _putInRange(values, calculator, _Keys.targetCardLvl, _maxTargetCardLvl);
      for (final key in _calculatorBools) {
        _put<bool>(values, calculator, _Categories.calculator, key);
      }
    }

    final enhancerLevels = _category(data, _Categories.enhancerLevels);
    if (enhancerLevels != null) {
      for (final key in _enhancerLevels) {
        _put<bool>(values, enhancerLevels, _Categories.enhancerLevels, key);
      }
    }

    Map<String, bool>? classUnlocks;
    final unlocks = _category(data, _Categories.classUnlocks);
    if (unlocks != null) {
      // Only locked classes this version knows are written; any other key
      // would become a stray pref.
      classUnlocks = {
        for (final pc in PlayerClasses.playerClasses)
          if (pc.locked && unlocks.containsKey(pc.classCode))
            pc.classCode: _typed<bool>(
              unlocks,
              _Categories.classUnlocks,
              pc.classCode,
            ),
      };
    }

    return BackupPrefs._(values, removals, classUnlocks);
  }

  static Map<String, dynamic>? _category(
    Map<String, dynamic> data,
    String name,
  ) {
    final category = data[name];
    if (category == null) return null;
    if (category is! Map) {
      throw BackupException('Invalid backup settings: "$name" is not a map');
    }
    return Map<String, dynamic>.from(category);
  }

  static T _typed<T>(Map<String, dynamic> map, String category, String key) {
    final value = map[key];
    if (value is! T) {
      throw BackupException(
        'Invalid backup setting $category.$key: ${jsonEncode(value)}',
      );
    }
    return value;
  }

  static void _put<T extends Object>(
    Map<String, Object> values,
    Map<String, dynamic> map,
    String category,
    String key,
  ) {
    if (map.containsKey(key)) values[key] = _typed<T>(map, category, key);
  }

  static void _putInRange(
    Map<String, Object> values,
    Map<String, dynamic> calculator,
    String key,
    int max,
  ) {
    if (!calculator.containsKey(key)) return;
    final value = _typed<int>(calculator, _Categories.calculator, key);
    if (value >= 0 && value <= max) values[key] = value;
  }
}
