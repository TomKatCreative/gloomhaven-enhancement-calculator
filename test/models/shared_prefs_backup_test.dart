import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

Future<void> _initPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  await SharedPrefs().init();
}

void main() {
  group('SharedPrefs Backup', () {
    group('exportForBackup', () {
      test('returns correct categorized map with all expected keys', () async {
        await _initPrefs({
          'darkTheme': true,
          'useDefaultFonts': true,
          'primaryClassColor': 0xffff0000,
          'showRetiredCharacters': false,
          'hideCustomClassesWarningMessage': true,
          'envelopeX': true,
          'envelopeV': false,
          'gameEdition': GameEdition.frosthaven.index,
          'enhancementType': 3,
          'enhancementsOnTargetAction': 2,
          'targetCardLvl': 4,
          'disableMultiTargetsSwitch': true,
          'multipleTargetsSelected': true,
          'temporaryEnhancementMode': true,
          'partyBoon': true,
          'lostNonPersistent': true,
          'persistent': false,
          'hailsDiscount': true,
          'enhancerLvl1': true,
          'enhancerLvl2': true,
          'enhancerLvl3': false,
          'enhancerLvl4': false,
        });

        final result = SharedPrefs().exportForBackup();

        // Verify top-level categories
        expect(result.containsKey('settings'), isTrue);
        expect(result.containsKey('calculator'), isTrue);
        expect(result.containsKey('enhancerLevels'), isTrue);
        expect(result.containsKey('classUnlocks'), isTrue);

        // Verify settings
        final settings = result['settings'] as Map<String, dynamic>;
        expect(settings['darkTheme'], isTrue);
        expect(settings['useDefaultFonts'], isTrue);
        expect(settings['primaryClassColor'], 0xffff0000);
        expect(settings['showRetiredCharacters'], isFalse);
        expect(settings['hideCustomClassesWarningMessage'], isTrue);
        expect(settings['envelopeX'], isTrue);
        expect(settings['envelopeV'], isFalse);

        // Verify calculator
        final calculator = result['calculator'] as Map<String, dynamic>;
        expect(calculator['gameEdition'], GameEdition.frosthaven.index);
        expect(calculator['enhancementType'], 3);
        expect(calculator['enhancementsOnTargetAction'], 2);
        expect(calculator['targetCardLvl'], 4);
        expect(calculator['disableMultiTargetsSwitch'], isTrue);
        expect(calculator['multipleTargetsSelected'], isTrue);
        expect(calculator['temporaryEnhancementMode'], isTrue);
        expect(calculator['partyBoon'], isTrue);
        expect(calculator['lostNonPersistent'], isTrue);
        expect(calculator['persistent'], isFalse);
        expect(calculator['hailsDiscount'], isTrue);

        // Verify enhancer levels
        final enhancerLevels = result['enhancerLevels'] as Map<String, dynamic>;
        expect(enhancerLevels['enhancerLvl1'], isTrue);
        expect(enhancerLevels['enhancerLvl2'], isTrue);
        expect(enhancerLevels['enhancerLvl3'], isFalse);
        expect(enhancerLevels['enhancerLvl4'], isFalse);

        // Verify class unlocks only contains locked classes
        final classUnlocks = result['classUnlocks'] as Map<String, dynamic>;
        final lockedClasses = PlayerClasses.playerClasses
            .where((pc) => pc.locked)
            .toList();
        expect(classUnlocks.length, lockedClasses.length);
        // Brute is not locked, so shouldn't be in the map
        expect(classUnlocks.containsKey(ClassCodes.brute), isFalse);
        // Sunkeeper is locked
        expect(classUnlocks.containsKey(ClassCodes.sunkeeper), isTrue);
      });

      test('exports default values when no prefs are set', () async {
        await _initPrefs();

        final result = SharedPrefs().exportForBackup();

        final settings = result['settings'] as Map<String, dynamic>;
        expect(settings['darkTheme'], isFalse);
        expect(settings['useDefaultFonts'], isFalse);

        final calculator = result['calculator'] as Map<String, dynamic>;
        expect(calculator['gameEdition'], GameEdition.gloomhaven.index);
        expect(calculator['enhancementType'], 0);
      });
    });

    group('importFromBackup', () {
      test('applies all settings', () async {
        await _initPrefs();
        final prefs = SharedPrefs();

        prefs.importFromBackup({
          'settings': {
            'darkTheme': true,
            'useDefaultFonts': true,
            'primaryClassColor': 0xffaabbcc,
            'showRetiredCharacters': false,
            'hideCustomClassesWarningMessage': true,
            'envelopeX': true,
            'envelopeV': true,
          },
          'calculator': {
            'gameEdition': GameEdition.gloomhaven2e.index,
            'enhancementType': 5,
            'enhancementsOnTargetAction': 3,
            'targetCardLvl': 2,
            'disableMultiTargetsSwitch': true,
            'multipleTargetsSelected': true,
            'temporaryEnhancementMode': true,
            'partyBoon': true,
            'lostNonPersistent': true,
            'persistent': true,
            'hailsDiscount': true,
          },
          'enhancerLevels': {
            'enhancerLvl1': true,
            'enhancerLvl2': true,
            'enhancerLvl3': true,
            'enhancerLvl4': true,
          },
          'classUnlocks': {
            ClassCodes.sunkeeper: true,
            ClassCodes.quartermaster: true,
          },
        });

        // Settings
        expect(prefs.darkTheme, isTrue);
        expect(prefs.useDefaultFonts, isTrue);
        expect(prefs.primaryClassColor, 0xffaabbcc);
        expect(prefs.showRetiredCharacters, isFalse);
        expect(prefs.hideCustomClassesWarningMessage, isTrue);
        expect(prefs.envelopeX, isTrue);
        expect(prefs.envelopeV, isTrue);

        // Calculator
        expect(prefs.gameEdition, GameEdition.gloomhaven2e);
        expect(prefs.enhancementTypeIndex, 5);
        expect(prefs.previousEnhancements, 3);
        expect(prefs.targetCardLvl, 2);
        expect(prefs.disableMultiTargetSwitch, isTrue);
        expect(prefs.multipleTargetsSwitch, isTrue);
        expect(prefs.temporaryEnhancementMode, isTrue);
        expect(prefs.partyBoon, isTrue);
        expect(prefs.lostNonPersistent, isTrue);
        expect(prefs.persistent, isTrue);
        expect(prefs.hailsDiscount, isTrue);

        // Enhancer levels
        expect(prefs.enhancerLvl1, isTrue);
        expect(prefs.enhancerLvl2, isTrue);
        expect(prefs.enhancerLvl3, isTrue);
        expect(prefs.enhancerLvl4, isTrue);

        // Class unlocks
        expect(prefs.getPlayerClassIsUnlocked(ClassCodes.sunkeeper), isTrue);
        expect(
          prefs.getPlayerClassIsUnlocked(ClassCodes.quartermaster),
          isTrue,
        );
      });

      test('round-trip preserves all values', () async {
        await _initPrefs({
          'darkTheme': true,
          'useDefaultFonts': true,
          'primaryClassColor': 0xff112233,
          'showRetiredCharacters': false,
          'hideCustomClassesWarningMessage': true,
          'envelopeX': true,
          'envelopeV': false,
          'gameEdition': GameEdition.frosthaven.index,
          'enhancementType': 7,
          'enhancementsOnTargetAction': 1,
          'targetCardLvl': 3,
          'disableMultiTargetsSwitch': false,
          'multipleTargetsSelected': false,
          'temporaryEnhancementMode': true,
          'partyBoon': false,
          'lostNonPersistent': true,
          'persistent': false,
          'hailsDiscount': true,
          'enhancerLvl1': true,
          'enhancerLvl2': true,
          'enhancerLvl3': true,
          'enhancerLvl4': false,
          ClassCodes.sunkeeper: true,
        });

        final prefs = SharedPrefs();
        final exported = prefs.exportForBackup();

        // Modify prefs to different values
        prefs.darkTheme = false;
        prefs.gameEdition = GameEdition.gloomhaven;
        prefs.enhancementTypeIndex = 0;
        prefs.targetCardLvl = 0;
        prefs.hailsDiscount = false;
        prefs.setPlayerClassIsUnlocked(ClassCodes.sunkeeper, false);

        // Import the exported data
        prefs.importFromBackup(exported);

        // Verify original values restored
        expect(prefs.darkTheme, isTrue);
        expect(prefs.gameEdition, GameEdition.frosthaven);
        expect(prefs.enhancementTypeIndex, 7);
        expect(prefs.targetCardLvl, 3);
        expect(prefs.hailsDiscount, isTrue);
        expect(prefs.getPlayerClassIsUnlocked(ClassCodes.sunkeeper), isTrue);
      });

      test('missing categories does not crash and leaves unmentioned keys '
          'unchanged', () async {
        await _initPrefs({
          'darkTheme': true,
          'gameEdition': GameEdition.frosthaven.index,
          'enhancerLvl1': true,
        });

        final prefs = SharedPrefs();

        // Import with only settings — no calculator, enhancerLevels, or
        // classUnlocks
        prefs.importFromBackup({
          'settings': {'darkTheme': false},
        });

        // Settings applied
        expect(prefs.darkTheme, isFalse);

        // Calculator and enhancer levels unchanged
        expect(prefs.gameEdition, GameEdition.frosthaven);
        expect(prefs.enhancerLvl1, isTrue);
      });

      test('empty map does not crash', () async {
        await _initPrefs({'darkTheme': true});
        final prefs = SharedPrefs();

        prefs.importFromBackup({});

        // Nothing changed
        expect(prefs.darkTheme, isTrue);
      });

      test('class unlocks round-trip resets classes not in backup', () async {
        await _initPrefs({
          ClassCodes.sunkeeper: true,
          ClassCodes.quartermaster: true,
        });
        final prefs = SharedPrefs();

        // Export — both classes unlocked
        final exported = prefs.exportForBackup();

        // Unlock an extra class
        prefs.setPlayerClassIsUnlocked(ClassCodes.summoner, true);

        // Import original export — summoner should be re-locked
        prefs.importFromBackup(exported);

        expect(prefs.getPlayerClassIsUnlocked(ClassCodes.sunkeeper), isTrue);
        expect(
          prefs.getPlayerClassIsUnlocked(ClassCodes.quartermaster),
          isTrue,
        );
        expect(prefs.getPlayerClassIsUnlocked(ClassCodes.summoner), isFalse);
      });

      test('enhancer levels bypass cascade — writes exact values', () async {
        await _initPrefs();
        final prefs = SharedPrefs();

        // Import inconsistent state: lvl4=true but lvl1=false
        // Without cascade bypass, setting lvl4=true would set lvl1-3=true
        prefs.importFromBackup({
          'enhancerLevels': {
            'enhancerLvl1': false,
            'enhancerLvl2': false,
            'enhancerLvl3': false,
            'enhancerLvl4': true,
          },
        });

        expect(prefs.enhancerLvl1, isFalse);
        expect(prefs.enhancerLvl2, isFalse);
        expect(prefs.enhancerLvl3, isFalse);
        expect(prefs.enhancerLvl4, isTrue);
      });

      test('gameEdition out-of-range index falls back to default', () async {
        await _initPrefs();
        final prefs = SharedPrefs();

        prefs.importFromBackup({
          'calculator': {'gameEdition': 999},
        });

        // Should still be the default
        expect(prefs.gameEdition, GameEdition.gloomhaven);
      });

      test('gameEdition negative index falls back to default', () async {
        await _initPrefs();
        final prefs = SharedPrefs();

        prefs.importFromBackup({
          'calculator': {'gameEdition': -1},
        });

        expect(prefs.gameEdition, GameEdition.gloomhaven);
      });
    });
  });
}
