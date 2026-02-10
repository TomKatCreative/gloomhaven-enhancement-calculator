import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async =>
      _sharedPrefs = await SharedPreferences.getInstance();

  void remove(String key) => _sharedPrefs.remove(key);

  void removeAll() => _sharedPrefs.clear();

  bool get clearSharedPrefs => _sharedPrefs.getBool('clearOldPrefs') ?? true;

  set clearSharedPrefs(bool value) =>
      _sharedPrefs.setBool('clearOldPrefs', value);

  bool get partyBoon => _sharedPrefs.getBool('partyBoon') ?? false;

  set partyBoon(bool value) => _sharedPrefs.setBool('partyBoon', value);

  bool get showRetiredCharacters =>
      _sharedPrefs.getBool('showRetiredCharacters') ?? true;

  set showRetiredCharacters(bool value) =>
      _sharedPrefs.setBool('showRetiredCharacters', value);

  bool get enhancerLvl1 => _sharedPrefs.getBool('enhancerLvl1') ?? false;

  set enhancerLvl1(bool value) {
    if (!value) {
      enhancerLvl2 = false;
      enhancerLvl3 = false;
      enhancerLvl4 = false;
    }
    _sharedPrefs.setBool('enhancerLvl1', value);
  }

  bool get enhancerLvl2 => _sharedPrefs.getBool('enhancerLvl2') ?? false;

  set enhancerLvl2(bool value) {
    if (value) {
      enhancerLvl1 = true;
    } else {
      enhancerLvl3 = false;
      enhancerLvl4 = false;
    }
    _sharedPrefs.setBool('enhancerLvl2', value);
  }

  bool get enhancerLvl3 => _sharedPrefs.getBool('enhancerLvl3') ?? false;

  set enhancerLvl3(bool value) {
    if (value) {
      enhancerLvl2 = true;
      enhancerLvl1 = true;
    } else {
      enhancerLvl4 = false;
    }
    _sharedPrefs.setBool('enhancerLvl3', value);
  }

  bool get enhancerLvl4 => _sharedPrefs.getBool('enhancerLvl4') ?? false;

  set enhancerLvl4(bool value) {
    if (value) {
      enhancerLvl3 = true;
      enhancerLvl2 = true;
      enhancerLvl1 = true;
    }
    _sharedPrefs.setBool('enhancerLvl4', value);
  }

  bool get customClasses => _sharedPrefs.getBool('customClasses') ?? false;

  set customClasses(bool value) => _sharedPrefs.setBool('customClasses', value);

  bool get darkTheme => _sharedPrefs.getBool('darkTheme') ?? false;

  set darkTheme(bool value) => _sharedPrefs.setBool('darkTheme', value);

  int get primaryClassColor =>
      _sharedPrefs.getInt('primaryClassColor') ?? 0xff4e7ec1;

  set primaryClassColor(int value) =>
      _sharedPrefs.setInt('primaryClassColor', value);

  bool get envelopeX => _sharedPrefs.getBool('envelopeX') ?? false;

  set envelopeX(bool value) => _sharedPrefs.setBool('envelopeX', value);

  bool get envelopeV => _sharedPrefs.getBool('envelopeV') ?? false;

  set envelopeV(bool value) => _sharedPrefs.setBool('envelopeV', value);

  int get initialPage => _sharedPrefs.getInt('initialPage') ?? 0;

  set initialPage(int value) => _sharedPrefs.setInt('initialPage', value);

  bool get generalExpanded => _sharedPrefs.getBool('generalExpanded') ?? true;

  set generalExpanded(bool value) =>
      _sharedPrefs.setBool('generalExpanded', value);

  bool get personalQuestExpanded =>
      _sharedPrefs.getBool('personalQuestExpanded') ?? false;

  set personalQuestExpanded(bool value) =>
      _sharedPrefs.setBool('personalQuestExpanded', value);

  bool get questAndNotesExpanded =>
      _sharedPrefs.getBool('questAndNotesExpanded') ?? true;

  set questAndNotesExpanded(bool value) =>
      _sharedPrefs.setBool('questAndNotesExpanded', value);

  int get targetCardLvl => _sharedPrefs.getInt('targetCardLvl') ?? 0;

  set targetCardLvl(int value) => _sharedPrefs.setInt('targetCardLvl', value);

  int get previousEnhancements =>
      _sharedPrefs.getInt('enhancementsOnTargetAction') ?? 0;

  set previousEnhancements(int value) =>
      _sharedPrefs.setInt('enhancementsOnTargetAction', value);

  int get enhancementTypeIndex => _sharedPrefs.getInt('enhancementType') ?? 0;

  set enhancementTypeIndex(int value) =>
      _sharedPrefs.setInt('enhancementType', value);

  bool get disableMultiTargetSwitch =>
      _sharedPrefs.getBool('disableMultiTargetsSwitch') ?? false;

  set disableMultiTargetSwitch(bool value) =>
      _sharedPrefs.setBool('disableMultiTargetsSwitch', value);

  bool get temporaryEnhancementMode =>
      _sharedPrefs.getBool('temporaryEnhancementMode') ?? false;

  set temporaryEnhancementMode(bool value) =>
      _sharedPrefs.setBool('temporaryEnhancementMode', value);

  bool get multipleTargetsSwitch =>
      _sharedPrefs.getBool('multipleTargetsSelected') ?? false;

  set multipleTargetsSwitch(bool value) =>
      _sharedPrefs.setBool('multipleTargetsSelected', value);

  /// Game edition for enhancement calculator
  /// Migrates from legacy gloomhavenMode boolean if present
  GameEdition get gameEdition {
    // Check for new gameEdition key first
    final editionIndex = _sharedPrefs.getInt('gameEdition');
    if (editionIndex != null && editionIndex < GameEdition.values.length) {
      return GameEdition.values[editionIndex];
    }

    // Migrate from legacy gloomhavenMode boolean
    final legacyMode = _sharedPrefs.getBool('gloomhavenMode');
    if (legacyMode != null) {
      final edition = legacyMode
          ? GameEdition.gloomhaven
          : GameEdition.frosthaven;
      // Save migrated value and remove legacy key
      _sharedPrefs.setInt('gameEdition', edition.index);
      _sharedPrefs.remove('gloomhavenMode');
      return edition;
    }

    // Default to Gloomhaven
    return GameEdition.gloomhaven;
  }

  set gameEdition(GameEdition value) =>
      _sharedPrefs.setInt('gameEdition', value.index);

  bool get lostNonPersistent =>
      _sharedPrefs.getBool('lostNonPersistent') ?? false;

  set lostNonPersistent(bool value) =>
      _sharedPrefs.setBool('lostNonPersistent', value);

  bool get persistent => _sharedPrefs.getBool('persistent') ?? false;

  set persistent(bool value) => _sharedPrefs.setBool('persistent', value);

  bool get hideCustomClassesWarningMessage =>
      _sharedPrefs.getBool('hideCustomClassesWarningMessage') ?? false;

  set hideCustomClassesWarningMessage(bool value) =>
      _sharedPrefs.setBool('hideCustomClassesWarningMessage', value);

  bool get showUpdate440Dialog =>
      _sharedPrefs.getBool('showUpdate440Dialog') ?? true;

  set showUpdate440Dialog(bool value) =>
      _sharedPrefs.setBool('showUpdate440Dialog', value);

  bool getPlayerClassIsUnlocked(String classCode) =>
      _sharedPrefs.getBool(classCode) ?? false;

  void setPlayerClassIsUnlocked(String classCode, bool value) {
    _sharedPrefs.setBool(classCode, value);
  }

  bool get useDefaultFonts => _sharedPrefs.getBool('useDefaultFonts') ?? false;

  set useDefaultFonts(bool value) =>
      _sharedPrefs.setBool('useDefaultFonts', value);

  bool get hailsDiscount => _sharedPrefs.getBool('hailsDiscount') ?? false;

  set hailsDiscount(bool value) => _sharedPrefs.setBool('hailsDiscount', value);

  bool get isUSRegion => _sharedPrefs.getBool('isUSRegion') ?? false;

  set isUSRegion(bool value) => _sharedPrefs.setBool('isUSRegion', value);

  // ===========================================================================
  // Element Tracker States
  // Stored as int: 0=gone, 1=strong, 2=waning
  // ===========================================================================

  int get earthState => _sharedPrefs.getInt('elementEarthState') ?? 0;
  set earthState(int value) => _sharedPrefs.setInt('elementEarthState', value);

  int get fireState => _sharedPrefs.getInt('elementFireState') ?? 0;
  set fireState(int value) => _sharedPrefs.setInt('elementFireState', value);

  int get iceState => _sharedPrefs.getInt('elementIceState') ?? 0;
  set iceState(int value) => _sharedPrefs.setInt('elementIceState', value);

  int get lightState => _sharedPrefs.getInt('elementLightState') ?? 0;
  set lightState(int value) => _sharedPrefs.setInt('elementLightState', value);

  int get darkState => _sharedPrefs.getInt('elementDarkState') ?? 0;
  set darkState(int value) => _sharedPrefs.setInt('elementDarkState', value);

  int get airState => _sharedPrefs.getInt('elementAirState') ?? 0;
  set airState(int value) => _sharedPrefs.setInt('elementAirState', value);

  // ===========================================================================
  // Backup Export / Import
  // ===========================================================================

  /// Exports a categorized map of SharedPreferences for inclusion in backups.
  ///
  /// Excluded: clearOldPrefs, initialPage, generalExpanded,
  /// showUpdate*Dialog, isUSRegion, gloomhavenMode (legacy), element tracker.
  Map<String, dynamic> exportForBackup() {
    final classUnlocks = <String, dynamic>{};
    for (final pc in PlayerClasses.playerClasses) {
      if (pc.locked) {
        classUnlocks[pc.classCode] = getPlayerClassIsUnlocked(pc.classCode);
      }
    }

    return {
      'settings': {
        'darkTheme': darkTheme,
        'useDefaultFonts': useDefaultFonts,
        'primaryClassColor': primaryClassColor,
        'showRetiredCharacters': showRetiredCharacters,
        'customClasses': customClasses,
        'hideCustomClassesWarningMessage': hideCustomClassesWarningMessage,
        'envelopeX': envelopeX,
        'envelopeV': envelopeV,
      },
      'calculator': {
        'gameEdition': gameEdition.index,
        'enhancementType': enhancementTypeIndex,
        'enhancementsOnTargetAction': previousEnhancements,
        'targetCardLvl': targetCardLvl,
        'disableMultiTargetsSwitch': disableMultiTargetSwitch,
        'multipleTargetsSelected': multipleTargetsSwitch,
        'temporaryEnhancementMode': temporaryEnhancementMode,
        'partyBoon': partyBoon,
        'lostNonPersistent': lostNonPersistent,
        'persistent': persistent,
        'hailsDiscount': hailsDiscount,
      },
      'enhancerLevels': {
        'enhancerLvl1': enhancerLvl1,
        'enhancerLvl2': enhancerLvl2,
        'enhancerLvl3': enhancerLvl3,
        'enhancerLvl4': enhancerLvl4,
      },
      'classUnlocks': classUnlocks,
    };
  }

  /// Imports SharedPreferences data from a backup map.
  ///
  /// Each category is optional — missing categories are skipped.
  /// Enhancer levels are written directly to bypass cascade logic,
  /// since backup data is already self-consistent.
  void importFromBackup(Map<String, dynamic> data) {
    // Settings
    if (data['settings'] is Map) {
      final s = Map<String, dynamic>.from(data['settings'] as Map);
      if (s.containsKey('darkTheme')) darkTheme = s['darkTheme'] as bool;
      if (s.containsKey('useDefaultFonts')) {
        useDefaultFonts = s['useDefaultFonts'] as bool;
      }
      if (s.containsKey('primaryClassColor')) {
        primaryClassColor = s['primaryClassColor'] as int;
      }
      if (s.containsKey('showRetiredCharacters')) {
        showRetiredCharacters = s['showRetiredCharacters'] as bool;
      }
      if (s.containsKey('customClasses')) {
        customClasses = s['customClasses'] as bool;
      }
      if (s.containsKey('hideCustomClassesWarningMessage')) {
        hideCustomClassesWarningMessage =
            s['hideCustomClassesWarningMessage'] as bool;
      }
      if (s.containsKey('envelopeX')) envelopeX = s['envelopeX'] as bool;
      if (s.containsKey('envelopeV')) envelopeV = s['envelopeV'] as bool;
    }

    // Calculator
    if (data['calculator'] is Map) {
      final c = Map<String, dynamic>.from(data['calculator'] as Map);
      if (c.containsKey('gameEdition')) {
        final idx = c['gameEdition'] as int;
        if (idx >= 0 && idx < GameEdition.values.length) {
          gameEdition = GameEdition.values[idx];
        }
      }
      if (c.containsKey('enhancementType')) {
        enhancementTypeIndex = c['enhancementType'] as int;
      }
      if (c.containsKey('enhancementsOnTargetAction')) {
        previousEnhancements = c['enhancementsOnTargetAction'] as int;
      }
      if (c.containsKey('targetCardLvl')) {
        targetCardLvl = c['targetCardLvl'] as int;
      }
      if (c.containsKey('disableMultiTargetsSwitch')) {
        disableMultiTargetSwitch = c['disableMultiTargetsSwitch'] as bool;
      }
      if (c.containsKey('multipleTargetsSelected')) {
        multipleTargetsSwitch = c['multipleTargetsSelected'] as bool;
      }
      if (c.containsKey('temporaryEnhancementMode')) {
        temporaryEnhancementMode = c['temporaryEnhancementMode'] as bool;
      }
      if (c.containsKey('partyBoon')) partyBoon = c['partyBoon'] as bool;
      if (c.containsKey('lostNonPersistent')) {
        lostNonPersistent = c['lostNonPersistent'] as bool;
      }
      if (c.containsKey('persistent')) persistent = c['persistent'] as bool;
      if (c.containsKey('hailsDiscount')) {
        hailsDiscount = c['hailsDiscount'] as bool;
      }
    }

    // Enhancer levels — bypass cascade logic with direct writes
    if (data['enhancerLevels'] is Map) {
      final e = Map<String, dynamic>.from(data['enhancerLevels'] as Map);
      if (e.containsKey('enhancerLvl1')) {
        _sharedPrefs.setBool('enhancerLvl1', e['enhancerLvl1'] as bool);
      }
      if (e.containsKey('enhancerLvl2')) {
        _sharedPrefs.setBool('enhancerLvl2', e['enhancerLvl2'] as bool);
      }
      if (e.containsKey('enhancerLvl3')) {
        _sharedPrefs.setBool('enhancerLvl3', e['enhancerLvl3'] as bool);
      }
      if (e.containsKey('enhancerLvl4')) {
        _sharedPrefs.setBool('enhancerLvl4', e['enhancerLvl4'] as bool);
      }
    }

    // Class unlocks — reset all locked classes first, then apply backup
    if (data['classUnlocks'] is Map) {
      final u = Map<String, dynamic>.from(data['classUnlocks'] as Map);
      for (final pc in PlayerClasses.playerClasses) {
        if (pc.locked) {
          setPlayerClassIsUnlocked(pc.classCode, false);
        }
      }
      for (final entry in u.entries) {
        setPlayerClassIsUnlocked(entry.key, entry.value as bool);
      }
    }
  }
}
