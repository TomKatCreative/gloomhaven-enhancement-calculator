import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';

import '../helpers/test_data.dart';

void main() {
  group('Character Model - Retirement', () {
    group('Constructor defaults', () {
      test('isRetired defaults to false', () {
        final character = TestData.createCharacter();

        expect(character.isRetired, isFalse);
      });

      test('isRetired can be set to true in constructor', () {
        final character = TestData.createCharacter(isRetired: true);

        expect(character.isRetired, isTrue);
      });
    });

    group('fromMap', () {
      test('parses IsRetired=1 as true', () {
        final map = _createCharacterMap(isRetired: 1);

        final character = Character.fromMap(map);

        expect(character.isRetired, isTrue);
      });

      test('parses IsRetired=0 as false', () {
        final map = _createCharacterMap(isRetired: 0);

        final character = Character.fromMap(map);

        expect(character.isRetired, isFalse);
      });
    });

    group('toMap', () {
      test('serializes isRetired=true as 1', () {
        final character = TestData.createCharacter(isRetired: true);

        final map = character.toMap();

        expect(map[columnIsRetired], equals(1));
      });

      test('serializes isRetired=false as 0', () {
        final character = TestData.createCharacter(isRetired: false);

        final map = character.toMap();

        expect(map[columnIsRetired], equals(0));
      });
    });

    group('getEffectiveColor', () {
      test('returns white for retired character in dark mode', () {
        final character = TestData.createCharacter(isRetired: true);

        final color = character.getEffectiveColor(Brightness.dark);

        expect(color, equals(Colors.white));
      });

      test('returns black for retired character in light mode', () {
        final character = TestData.createCharacter(isRetired: true);

        final color = character.getEffectiveColor(Brightness.light);

        expect(color, equals(Colors.black));
      });

      test('returns class primary color for active character in dark mode', () {
        final character = TestData.createCharacter(isRetired: false);
        final expectedColor = Color(character.playerClass.primaryColor);

        final color = character.getEffectiveColor(Brightness.dark);

        expect(color, equals(expectedColor));
      });

      test(
        'returns class primary color for active character in light mode',
        () {
          final character = TestData.createCharacter(isRetired: false);
          final expectedColor = Color(character.playerClass.primaryColor);

          final color = character.getEffectiveColor(Brightness.light);

          expect(color, equals(expectedColor));
        },
      );
    });
  });

  group('Character Model - Maximum Perks', () {
    test('includes previousRetirements in calculation', () {
      final characterNoRetirements = TestData.createCharacter(
        previousRetirements: 0,
      );
      final characterWithRetirements = TestData.createCharacter(
        previousRetirements: 2,
      );

      final perksNoRetirements = Character.maximumPerks(characterNoRetirements);
      final perksWithRetirements = Character.maximumPerks(
        characterWithRetirements,
      );

      // With 2 retirements, should have 2 more perks available
      expect(perksWithRetirements - perksNoRetirements, equals(2));
    });

    test('includes achieved masteries in calculation', () {
      final masteries = [
        TestData.createCharacterMastery(characterMasteryAchieved: true),
        TestData.createCharacterMastery(
          associatedMasteryId: 'mastery-2',
          characterMasteryAchieved: true,
        ),
        TestData.createCharacterMastery(
          associatedMasteryId: 'mastery-3',
          characterMasteryAchieved: false,
        ),
      ];

      final characterWithMasteries = TestData.createCharacter(
        characterMasteries: masteries,
      );
      final characterWithoutMasteries = TestData.createCharacter();

      final perksWithMasteries = Character.maximumPerks(characterWithMasteries);
      final perksWithoutMasteries = Character.maximumPerks(
        characterWithoutMasteries,
      );

      // 2 achieved masteries should add 2 perks
      expect(perksWithMasteries - perksWithoutMasteries, equals(2));
    });

    test('includes level in calculation', () {
      // Level 1 = 0 XP, Level 2 = 45 XP
      final level1Character = TestData.createCharacter(xp: 0);
      final level2Character = TestData.createCharacter(xp: 45);

      final perksLevel1 = Character.maximumPerks(level1Character);
      final perksLevel2 = Character.maximumPerks(level2Character);

      // Level 2 should have 1 more perk than level 1
      expect(perksLevel2 - perksLevel1, equals(1));
    });

    test('includes checkmarks in calculation', () {
      // 3 checkmarks = 1 perk, 6 checkmarks = 2 perks
      final char0Checks = TestData.createCharacter(checkMarks: 0);
      final char3Checks = TestData.createCharacter(checkMarks: 3);
      final char6Checks = TestData.createCharacter(checkMarks: 6);

      final perks0 = Character.maximumPerks(char0Checks);
      final perks3 = Character.maximumPerks(char3Checks);
      final perks6 = Character.maximumPerks(char6Checks);

      expect(perks3 - perks0, equals(1));
      expect(perks6 - perks3, equals(1));
    });
  });

  group('Character Model - Level Calculation', () {
    test('level 1 at 0 XP', () {
      expect(Character.level(0), equals(1));
    });

    test('level 2 at 45 XP', () {
      expect(Character.level(45), equals(2));
    });

    test('level 9 at 500 XP', () {
      expect(Character.level(500), equals(9));
    });

    test('level 9 at XP above 500', () {
      expect(Character.level(999), equals(9));
    });
  });
}

/// Creates a map representing a character row from the database.
Map<String, dynamic> _createCharacterMap({
  int id = 1,
  String uuid = 'test-uuid',
  String name = 'Test Character',
  String classCode = ClassCodes.brute,
  int previousRetirements = 0,
  int xp = 0,
  int gold = 0,
  String notes = '',
  int checkMarks = 0,
  int isRetired = 0,
  String variant = 'base',
}) {
  return {
    columnCharacterId: id,
    columnCharacterUuid: uuid,
    columnCharacterName: name,
    columnCharacterClassCode: classCode,
    columnPreviousRetirements: previousRetirements,
    columnCharacterXp: xp,
    columnCharacterGold: gold,
    columnCharacterNotes: notes,
    columnCharacterCheckMarks: checkMarks,
    columnIsRetired: isRetired,
    columnVariant: variant,
    columnResourceHide: 0,
    columnResourceMetal: 0,
    columnResourceLumber: 0,
    columnResourceArrowvine: 0,
    columnResourceAxenut: 0,
    columnResourceRockroot: 0,
    columnResourceFlamefruit: 0,
    columnResourceCorpsecap: 0,
    columnResourceSnowthistle: 0,
  };
}
