import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

import '../helpers/test_data.dart';

void main() {
  group('Character Model - Constructor & Defaults', () {
    test('gold defaults to 0', () {
      final character = TestData.createCharacter();

      expect(character.gold, equals(0));
    });

    test('xp defaults to 0', () {
      final character = TestData.createCharacter();

      expect(character.xp, equals(0));
    });

    test('checkMarks defaults to 0', () {
      final character = TestData.createCharacter();

      expect(character.checkMarks, equals(0));
    });

    test('notes defaults to placeholder text', () {
      final character = Character(
        uuid: 'test',
        name: 'Test',
        playerClass: TestData.brute,
      );

      expect(character.notes, equals('Items, reminders, wishlist...'));
    });

    test('variant defaults to Variant.base', () {
      final character = TestData.createCharacter();

      expect(character.variant, equals(Variant.base));
    });

    test('all Frosthaven resources default to 0', () {
      final character = TestData.createCharacter();

      expect(character.resourceHide, equals(0));
      expect(character.resourceMetal, equals(0));
      expect(character.resourceLumber, equals(0));
      expect(character.resourceArrowvine, equals(0));
      expect(character.resourceAxenut, equals(0));
      expect(character.resourceRockroot, equals(0));
      expect(character.resourceFlamefruit, equals(0));
      expect(character.resourceCorpsecap, equals(0));
      expect(character.resourceSnowthistle, equals(0));
    });

    test('isRetired defaults to false', () {
      final character = TestData.createCharacter();

      expect(character.isRetired, isFalse);
    });

    test('isRetired can be set to true in constructor', () {
      final character = TestData.createCharacter(isRetired: true);

      expect(character.isRetired, isTrue);
    });
  });

  group('Character Model - Database Serialization', () {
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

      test('deserializes all core fields correctly', () {
        final map = _createCharacterMap(
          id: 42,
          uuid: 'test-uuid-42',
          name: 'My Brute',
          classCode: ClassCodes.brute,
          previousRetirements: 3,
          xp: 150,
          gold: 75,
          notes: 'Some notes',
          checkMarks: 6,
          isRetired: 1,
          variant: 'base',
        );

        final character = Character.fromMap(map);

        expect(character.id, equals(42));
        expect(character.uuid, equals('test-uuid-42'));
        expect(character.name, equals('My Brute'));
        expect(character.playerClass.classCode, equals(ClassCodes.brute));
        expect(character.previousRetirements, equals(3));
        expect(character.xp, equals(150));
        expect(character.gold, equals(75));
        expect(character.notes, equals('Some notes'));
        expect(character.checkMarks, equals(6));
        expect(character.isRetired, isTrue);
        expect(character.variant, equals(Variant.base));
      });

      test('handles variant serialization for frosthavenCrossover', () {
        final map = _createCharacterMap(variant: 'frosthavenCrossover');

        final character = Character.fromMap(map);

        expect(character.variant, equals(Variant.frosthavenCrossover));
      });

      test('handles variant serialization for gloomhaven2E', () {
        final map = _createCharacterMap(variant: 'gloomhaven2E');

        final character = Character.fromMap(map);

        expect(character.variant, equals(Variant.gloomhaven2E));
      });

      test('handles legacy characters without UUID (falls back to ID)', () {
        final map = _createCharacterMap(id: 99);
        map.remove(columnCharacterUuid);

        final character = Character.fromMap(map);

        expect(character.uuid, equals('99'));
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

      test('serializes all core fields correctly', () {
        final character = TestData.createCharacter(
          uuid: 'serial-test',
          name: 'Serial Tester',
          xp: 200,
          gold: 50,
          checkMarks: 9,
          previousRetirements: 2,
        );
        character.id = 10;
        character.notes = 'Test notes';

        final map = character.toMap();

        expect(map[columnCharacterId], equals(10));
        expect(map[columnCharacterUuid], equals('serial-test'));
        expect(map[columnCharacterName], equals('Serial Tester'));
        expect(map[columnCharacterClassCode], equals(ClassCodes.brute));
        expect(map[columnPreviousRetirements], equals(2));
        expect(map[columnCharacterXp], equals(200));
        expect(map[columnCharacterGold], equals(50));
        expect(map[columnCharacterNotes], equals('Test notes'));
        expect(map[columnCharacterCheckMarks], equals(9));
        expect(map[columnVariant], equals('base'));
      });
    });

    test('toMap/fromMap round-trip preserves all data', () {
      final original = TestData.createCharacter(
        uuid: 'round-trip',
        name: 'Round Trip',
        xp: 275,
        gold: 100,
        checkMarks: 12,
        previousRetirements: 1,
        isRetired: true,
      );
      original.id = 5;
      original.notes = 'Round trip notes';
      original.resourceHide = 3;
      original.resourceMetal = 2;

      final map = original.toMap();
      final restored = Character.fromMap(map);

      expect(restored.uuid, equals(original.uuid));
      expect(restored.name, equals(original.name));
      expect(restored.xp, equals(original.xp));
      expect(restored.gold, equals(original.gold));
      expect(restored.checkMarks, equals(original.checkMarks));
      expect(
        restored.previousRetirements,
        equals(original.previousRetirements),
      );
      expect(restored.isRetired, equals(original.isRetired));
      expect(restored.variant, equals(original.variant));
      expect(
        restored.playerClass.classCode,
        equals(original.playerClass.classCode),
      );
      expect(restored.resourceHide, equals(original.resourceHide));
      expect(restored.resourceMetal, equals(original.resourceMetal));
    });
  });

  group('Character Model - Retirement', () {
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

    test('level 1 at 44 XP (boundary)', () {
      expect(Character.level(44), equals(1));
    });

    test('level 2 at 45 XP (boundary)', () {
      expect(Character.level(45), equals(2));
    });

    test('level 9 at 500 XP', () {
      expect(Character.level(500), equals(9));
    });

    test('level 9 at XP above 500', () {
      expect(Character.level(999), equals(9));
    });

    test('xpForNextLevel returns correct thresholds', () {
      expect(Character.xpForNextLevel(1), equals(45));
      expect(Character.xpForNextLevel(2), equals(95));
      expect(Character.xpForNextLevel(3), equals(150));
      expect(Character.xpForNextLevel(4), equals(210));
      expect(Character.xpForNextLevel(5), equals(275));
      expect(Character.xpForNextLevel(6), equals(345));
      expect(Character.xpForNextLevel(7), equals(420));
      expect(Character.xpForNextLevel(8), equals(500));
    });

    test('xpForNextLevel at max level returns max XP', () {
      // At level 9, there's no next level - should return the last entry (500)
      expect(Character.xpForNextLevel(9), equals(500));
    });
  });

  group('Character Model - Perk Calculations', () {
    test('numOfSelectedPerks counts selected perks correctly', () {
      final character = TestData.createCharacter(
        characterPerks: TestData.createCharacterPerkList(
          count: 5,
          selectedCount: 3,
        ),
      );

      expect(character.numOfSelectedPerks, equals(3));
    });

    test('numOfSelectedPerks returns 0 when no perks selected', () {
      final character = TestData.createCharacter(
        characterPerks: TestData.createCharacterPerkList(
          count: 5,
          selectedCount: 0,
        ),
      );

      expect(character.numOfSelectedPerks, equals(0));
    });

    test('numOfSelectedPerks ignores unselected perks', () {
      final character = TestData.createCharacter(
        characterPerks: TestData.createCharacterPerkList(
          count: 10,
          selectedCount: 2,
        ),
      );

      expect(character.numOfSelectedPerks, equals(2));
    });

    test('checkMarkProgress returns 0 for 0 checkmarks', () {
      final character = TestData.createCharacter(checkMarks: 0);

      expect(character.checkMarkProgress, equals(0));
    });

    test('checkMarkProgress returns 1 for 1 checkmark', () {
      final character = TestData.createCharacter(checkMarks: 1);

      expect(character.checkMarkProgress, equals(1));
    });

    test('checkMarkProgress returns 2 for 2 checkmarks', () {
      final character = TestData.createCharacter(checkMarks: 2);

      expect(character.checkMarkProgress, equals(2));
    });

    test('checkMarkProgress returns 3 for 3 checkmarks (full cycle)', () {
      final character = TestData.createCharacter(checkMarks: 3);

      expect(character.checkMarkProgress, equals(3));
    });

    test('checkMarkProgress returns 1 for 4 checkmarks (new cycle)', () {
      final character = TestData.createCharacter(checkMarks: 4);

      expect(character.checkMarkProgress, equals(1));
    });

    test('pocketItemsAllowed calculation at various levels', () {
      // Level 1 (0 XP) → 1/2 rounded = 1
      expect(TestData.createCharacter(xp: 0).pocketItemsAllowed, equals(1));
      // Level 2 (45 XP) → 2/2 = 1
      expect(TestData.createCharacter(xp: 45).pocketItemsAllowed, equals(1));
      // Level 3 (95 XP) → 3/2 rounded = 2
      expect(TestData.createCharacter(xp: 95).pocketItemsAllowed, equals(2));
      // Level 5 (210 XP) → 5/2 rounded = 3
      expect(TestData.createCharacter(xp: 210).pocketItemsAllowed, equals(3));
      // Level 9 (500 XP) → 9/2 rounded = 5
      expect(TestData.createCharacter(xp: 500).pocketItemsAllowed, equals(5));
    });
  });

  group('Character Model - shouldShowMasteries', () {
    test('returns true for Frosthaven classes', () {
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      expect(character.shouldShowMasteries, isTrue);
    });

    test('returns true for frosthavenCrossover variant', () {
      final character = TestData.createCharacter(
        variant: Variant.frosthavenCrossover,
      );

      expect(character.shouldShowMasteries, isTrue);
    });

    test('returns true for gloomhaven2E variant', () {
      final character = TestData.createCharacter(variant: Variant.gloomhaven2E);

      expect(character.shouldShowMasteries, isTrue);
    });

    test('returns true for mercenaryPacks category', () {
      final character = TestData.createCharacter(playerClass: TestData.hail);

      expect(character.shouldShowMasteries, isTrue);
    });

    test('returns false for base Gloomhaven class with base variant', () {
      final character = TestData.createCharacter(
        playerClass: TestData.brute,
        variant: Variant.base,
      );

      expect(character.shouldShowMasteries, isFalse);
    });
  });

  group('Character Model - Personal Quest', () {
    test('personalQuestId defaults to empty string', () {
      final character = TestData.createCharacter();
      expect(character.personalQuestId, '');
    });

    test('personalQuestProgress defaults to empty list', () {
      final character = TestData.createCharacter();
      expect(character.personalQuestProgress, isEmpty);
    });

    test('personalQuest getter returns null when no quest assigned', () {
      final character = TestData.createCharacter();
      expect(character.personalQuest, isNull);
    });

    test('personalQuest getter resolves quest from repository', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'gh_510';

      final quest = character.personalQuest;
      expect(quest, isNotNull);
      expect(quest!.title, 'Seeker of Xorn');
    });

    test('toMap includes personalQuestId and progress', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'gh_515';
      character.personalQuestProgress = [5];

      final map = character.toMap();
      expect(map[columnCharacterPersonalQuestId], 'gh_515');
      expect(map[columnCharacterPersonalQuestProgress], '[5]');
    });

    test('fromMap parses personalQuestId and progress', () {
      final map = _createCharacterMap(
        personalQuestId: 'gh_512',
        personalQuestProgress: '[100]',
      );

      final character = Character.fromMap(map);
      expect(character.personalQuestId, 'gh_512');
      expect(character.personalQuestProgress, [100]);
    });

    test('fromMap handles missing PQ fields gracefully', () {
      // Simulate a DB row from before v18 migration
      final map = _createCharacterMap();

      final character = Character.fromMap(map);
      expect(character.personalQuestId, '');
      expect(character.personalQuestProgress, isEmpty);
    });

    test('toMap/fromMap round-trip preserves PQ data', () {
      final original = TestData.createCharacter();
      original.id = 1; // id is required for round-trip (DB provides it)
      original.personalQuestId = 'gh_523';
      original.personalQuestProgress = [1, 0, 1, 0, 1, 0];

      final roundTripped = Character.fromMap(original.toMap());
      expect(roundTripped.personalQuestId, original.personalQuestId);
      expect(
        roundTripped.personalQuestProgress,
        original.personalQuestProgress,
      );
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
  String personalQuestId = '',
  String personalQuestProgress = '[]',
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
    columnCharacterPersonalQuestId: personalQuestId,
    columnCharacterPersonalQuestProgress: personalQuestProgress,
  };
}
