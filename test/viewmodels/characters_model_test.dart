import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/character_perk.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Ensure Flutter binding is initialized for ThemeProvider
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDatabaseHelper fakeDb;
  late MockThemeProvider mockTheme;

  setUp(() async {
    // Initialize SharedPreferences with mock values before each test
    SharedPreferences.setMockInitialValues({
      'showRetiredCharacters': true,
      'darkTheme': false,
      'initialPage': 0,
      'primaryClassColor': 0xff4e7ec1,
    });
    await SharedPrefs().init();

    fakeDb = FakeDatabaseHelper();
    mockTheme = MockThemeProvider();
  });

  tearDown(() {
    fakeDb.reset();
    mockTheme.reset();
  });

  CharactersModel createModel({bool showRetired = true}) {
    return CharactersModel(
      databaseHelper: fakeDb,
      themeProvider: mockTheme,
      showRetired: showRetired,
    );
  }

  group('retireCurrentCharacter', () {
    test('toggles isRetired from false to true', () async {
      final character = TestData.createCharacter(isRetired: false);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.retireCurrentCharacter();

      expect(model.currentCharacter!.isRetired, isTrue);
    });

    test('toggles isRetired from true to false (unretire)', () async {
      final character = TestData.createCharacter(isRetired: true);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.retireCurrentCharacter();

      expect(model.currentCharacter!.isRetired, isFalse);
    });

    test('persists change to database', () async {
      final character = TestData.createCharacter(uuid: 'persist-test');
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.retireCurrentCharacter();

      expect(fakeDb.updateCalls, contains('persist-test'));
    });

    test('sets edit mode to false', () async {
      final character = TestData.createCharacter();
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await model.retireCurrentCharacter();

      expect(model.isEditMode, isFalse);
    });

    test('notifies listeners', () async {
      final character = TestData.createCharacter();
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      await model.retireCurrentCharacter();

      expect(notified, isTrue);
    });

    test('does nothing when currentCharacter is null', () async {
      final model = createModel();
      // Don't load any characters, so currentCharacter is null

      // Should not throw
      await model.retireCurrentCharacter();

      expect(fakeDb.updateCalls, isEmpty);
    });
  });

  group('toggleShowRetired', () {
    test('flips showRetired from true to false', () async {
      fakeDb.characters = TestData.createMixedCharacters();
      final model = createModel(showRetired: true);
      await model.loadCharacters();

      model.toggleShowRetired();

      expect(model.showRetired, isFalse);
    });

    test('flips showRetired from false to true', () async {
      fakeDb.characters = TestData.createMixedCharacters();
      final model = createModel(showRetired: false);
      await model.loadCharacters();

      model.toggleShowRetired();

      expect(model.showRetired, isTrue);
    });

    test('just toggles flag when character list is empty', () async {
      fakeDb.characters = [];
      final model = createModel(showRetired: true);
      await model.loadCharacters();

      model.toggleShowRetired();

      expect(model.showRetired, isFalse);
      // No navigation errors
    });

    test('navigates to provided character when specified', () async {
      final chars = TestData.createMixedCharacters();
      final retiredChar = chars[1]; // Retired character
      fakeDb.characters = chars;
      final model = createModel(showRetired: false);
      await model.loadCharacters();

      model.toggleShowRetired(character: retiredChar);

      expect(model.showRetired, isTrue);
      expect(model.currentCharacter?.uuid, equals(retiredChar.uuid));
    });

    test('stays on active character when hiding retired', () async {
      // [Active, Retired, Active]
      final chars = TestData.createMixedCharacters();
      fakeDb.characters = chars;
      final model = createModel(showRetired: true);
      await model.loadCharacters();
      // Navigate to first active character (index 0)
      model.jumpToPage(0);

      model.toggleShowRetired(); // Hide retired

      // Should still be on the first active character
      expect(model.currentCharacter?.uuid, equals('test-1'));
    });
  });

  group('characters getter', () {
    test('returns all characters when showRetired is true', () async {
      fakeDb.characters = TestData.createMixedCharacters();
      final model = createModel(showRetired: true);
      await model.loadCharacters();

      expect(model.characters.length, equals(3));
    });

    test('filters retired characters when showRetired is false', () async {
      fakeDb.characters = TestData.createMixedCharacters();
      final model = createModel(showRetired: false);
      await model.loadCharacters();

      expect(model.characters.length, equals(2));
      expect(model.characters.every((c) => !c.isRetired), isTrue);
    });

    test(
      'returns empty list when all are retired and showRetired is false',
      () async {
        fakeDb.characters = TestData.createAllRetiredCharacters();
        final model = createModel(showRetired: false);
        await model.loadCharacters();

        expect(model.characters, isEmpty);
      },
    );
  });

  group('Navigation when toggling retired visibility', () {
    test('finds next non-retired character when current is retired', () async {
      // Setup: [Active1, Retired(current), Active2]
      final chars = [
        TestData.createCharacter(uuid: 'active-1', isRetired: false),
        TestData.createCharacter(uuid: 'retired-1', isRetired: true),
        TestData.createCharacter(uuid: 'active-2', isRetired: false),
      ];
      fakeDb.characters = chars;
      final model = createModel(showRetired: true);
      await model.loadCharacters();

      // Directly set current character since jumpToPage doesn't work in unit tests
      // (PageController has no clients without a real PageView widget)
      model.currentCharacter = chars[1]; // Retired character

      model.toggleShowRetired(); // Hide retired

      // Should navigate to next non-retired (Active2)
      expect(model.currentCharacter?.uuid, equals('active-2'));
    });

    test(
      'falls back to last non-retired when current is last retired',
      () async {
        // Setup: [Active1, Active2, Retired(current)]
        final chars = [
          TestData.createCharacter(uuid: 'active-1', isRetired: false),
          TestData.createCharacter(uuid: 'active-2', isRetired: false),
          TestData.createCharacter(uuid: 'retired-1', isRetired: true),
        ];
        fakeDb.characters = chars;
        final model = createModel(showRetired: true);
        await model.loadCharacters();

        // Directly set current character
        model.currentCharacter = chars[2]; // Last retired character

        model.toggleShowRetired(); // Hide retired

        // Should fall back to last non-retired (Active2)
        expect(model.currentCharacter?.uuid, equals('active-2'));
      },
    );

    test('returns index 0 when all characters are retired', () async {
      final chars = TestData.createAllRetiredCharacters();
      fakeDb.characters = chars;
      final model = createModel(showRetired: true);
      await model.loadCharacters();

      model.toggleShowRetired(); // Hide retired

      // Characters list is now empty, currentCharacter should be null
      expect(model.characters, isEmpty);
      expect(model.currentCharacter, isNull);
    });
  });

  group('Theme updates on retirement', () {
    test('updates theme to neutral color when retiring', () async {
      final character = TestData.createCharacter(isRetired: false);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      mockTheme.reset(); // Clear initial update

      await model.retireCurrentCharacter();

      expect(mockTheme.lastSeedColor, isNotNull);
      // Retired characters should use white (dark mode) or black (light mode)
      // Since our mock defaults to light mode, expect black
      expect(mockTheme.lastSeedColor, equals(Colors.black));
    });

    test('updates theme to class color when unretiring', () async {
      final character = TestData.createCharacter(isRetired: true);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      mockTheme.reset(); // Clear initial update

      await model.retireCurrentCharacter(); // Unretire

      expect(mockTheme.lastSeedColor, isNotNull);
      expect(
        mockTheme.lastSeedColor,
        equals(Color(character.playerClass.primaryColor)),
      );
    });
  });

  group('retiredCharactersAreHidden', () {
    test(
      'returns true when showRetired is false and characters exist',
      () async {
        fakeDb.characters = TestData.createMixedCharacters();
        final model = createModel(showRetired: false);
        await model.loadCharacters();

        expect(model.retiredCharactersAreHidden, isTrue);
      },
    );

    test('returns false when showRetired is true', () async {
      fakeDb.characters = TestData.createMixedCharacters();
      final model = createModel(showRetired: true);
      await model.loadCharacters();

      expect(model.retiredCharactersAreHidden, isFalse);
    });

    test('returns false when character list is empty', () async {
      fakeDb.characters = [];
      final model = createModel(showRetired: false);
      await model.loadCharacters();

      expect(model.retiredCharactersAreHidden, isFalse);
    });
  });

  group('createCharacter', () {
    test('creates character and adds to list', () async {
      final model = createModel();
      await model.loadCharacters();
      expect(model.characters, isEmpty);

      await model.createCharacter('New Hero', TestData.brute);

      expect(model.characters.length, equals(1));
      expect(model.characters.first.name, equals('New Hero'));
    });

    test('sets created character as currentCharacter', () async {
      final model = createModel();
      await model.loadCharacters();

      await model.createCharacter('Current Hero', TestData.brute);

      expect(model.currentCharacter, isNotNull);
      expect(model.currentCharacter!.name, equals('Current Hero'));
    });

    test('assigns UUID to created character', () async {
      final model = createModel();
      await model.loadCharacters();

      await model.createCharacter('UUID Hero', TestData.brute);

      expect(model.currentCharacter!.uuid, isNotEmpty);
      expect(model.currentCharacter!.uuid, isNot(equals('test-1')));
    });

    test('persists character to database (insertCharacter called)', () async {
      final model = createModel();
      await model.loadCharacters();

      await model.createCharacter('Persisted Hero', TestData.brute);

      // Character should be in fakeDb.characters (inserted by insertCharacter)
      expect(fakeDb.characters.length, equals(1));
      expect(fakeDb.characters.first.name, equals('Persisted Hero'));
    });

    test(
      'calculates starting gold correctly for Gloomhaven edition (15 * (level + 1))',
      () async {
        final model = createModel();
        await model.loadCharacters();

        // Level 1, Gloomhaven: 15 * (1 + 1) = 30
        await model.createCharacter(
          'GH Hero',
          TestData.brute,
          initialLevel: 1,
          edition: GameEdition.gloomhaven,
        );

        expect(model.currentCharacter!.gold, equals(30));
      },
    );

    test(
      'calculates starting gold correctly for GH2E edition (10 * prosperity + 15)',
      () async {
        final model = createModel();
        await model.loadCharacters();

        // Prosperity 3, GH2E: 10 * 3 + 15 = 45
        await model.createCharacter(
          'GH2E Hero',
          TestData.brute,
          edition: GameEdition.gloomhaven2e,
          prosperityLevel: 3,
        );

        expect(model.currentCharacter!.gold, equals(45));
      },
    );

    test(
      'calculates starting gold correctly for Frosthaven edition (10 * prosperity + 20)',
      () async {
        final model = createModel();
        await model.loadCharacters();

        // Prosperity 4, Frosthaven: 10 * 4 + 20 = 60
        await model.createCharacter(
          'FH Hero',
          TestData.drifter,
          edition: GameEdition.frosthaven,
          prosperityLevel: 4,
        );

        expect(model.currentCharacter!.gold, equals(60));
      },
    );

    test('sets correct XP for starting level', () async {
      final model = createModel();
      await model.loadCharacters();

      // Level 3 starts at 95 XP
      await model.createCharacter(
        'Level 3 Hero',
        TestData.brute,
        initialLevel: 3,
      );

      expect(model.currentCharacter!.xp, equals(95));
      expect(Character.level(model.currentCharacter!.xp), equals(3));
    });

    test('loads perks after creation', () async {
      final model = createModel();
      await model.loadCharacters();

      await model.createCharacter('Perk Hero', TestData.brute);

      // Brute should have perks loaded
      expect(model.currentCharacter!.characterPerks, isNotEmpty);
    });

    test('loads masteries after creation (for Frosthaven class)', () async {
      final model = createModel();
      await model.loadCharacters();

      await model.createCharacter('FH Hero', TestData.drifter);

      // Drifter is a Frosthaven class, should have masteries
      expect(model.currentCharacter!.shouldShowMasteries, isTrue);
    });

    test('notifies listeners after creation', () async {
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      await model.createCharacter('Notify Hero', TestData.brute);

      expect(notified, isTrue);
    });
  });

  group('deleteCurrentCharacter', () {
    test('removes character from list', () async {
      fakeDb.characters = [TestData.createCharacter()];
      final model = createModel();
      await model.loadCharacters();

      await model.deleteCurrentCharacter();

      expect(model.characters, isEmpty);
    });

    test('calls database deleteCharacter', () async {
      final character = TestData.createCharacter(uuid: 'delete-me');
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.deleteCurrentCharacter();

      expect(fakeDb.deleteCalls, contains('delete-me'));
    });

    test('sets isEditMode to false', () async {
      fakeDb.characters = [TestData.createCharacter()];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await model.deleteCurrentCharacter();

      expect(model.isEditMode, isFalse);
    });

    test('sets next character as current after deletion', () async {
      fakeDb.characters = [
        TestData.createCharacter(uuid: 'first', name: 'First'),
        TestData.createCharacter(uuid: 'second', name: 'Second'),
      ];
      final model = createModel();
      await model.loadCharacters();
      // current should be first (index 0)
      expect(model.currentCharacter!.uuid, equals('first'));

      await model.deleteCurrentCharacter();

      expect(model.currentCharacter!.uuid, equals('second'));
    });

    test(
      'sets currentCharacter to null when deleting last character',
      () async {
        fakeDb.characters = [TestData.createCharacter()];
        final model = createModel();
        await model.loadCharacters();

        await model.deleteCurrentCharacter();

        expect(model.currentCharacter, isNull);
      },
    );

    test('notifies listeners', () async {
      fakeDb.characters = [TestData.createCharacter()];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      await model.deleteCurrentCharacter();

      expect(notified, isTrue);
    });
  });

  group('updateCharacter', () {
    test('persists changes to database', () async {
      final character = TestData.createCharacter(uuid: 'update-me');
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      character.gold = 999;
      await model.updateCharacter(character);

      expect(fakeDb.updateCalls, contains('update-me'));
    });

    test('notifies listeners', () async {
      final character = TestData.createCharacter();
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      await model.updateCharacter(character);

      expect(notified, isTrue);
    });
  });

  group('increaseCheckmark', () {
    test('increments checkMarks by 1', () async {
      final character = TestData.createCharacter(checkMarks: 5);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      model.increaseCheckmark(model.currentCharacter!);

      expect(model.currentCharacter!.checkMarks, equals(6));
    });

    test('persists to database', () async {
      final character = TestData.createCharacter(
        uuid: 'check-up',
        checkMarks: 0,
      );
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      model.increaseCheckmark(model.currentCharacter!);

      expect(fakeDb.updateCalls, contains('check-up'));
    });

    test('does not exceed maximum (18)', () async {
      final character = TestData.createCharacter(checkMarks: 18);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      model.increaseCheckmark(model.currentCharacter!);

      expect(model.currentCharacter!.checkMarks, equals(18));
    });

    test('notifies listeners', () async {
      final character = TestData.createCharacter(checkMarks: 0);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      model.increaseCheckmark(model.currentCharacter!);
      // increaseCheckmark calls updateCharacter without await,
      // so we need to let the async operation complete
      await Future.microtask(() {});

      expect(notified, isTrue);
    });
  });

  group('decreaseCheckmark', () {
    test('decrements checkMarks by 1', () async {
      final character = TestData.createCharacter(checkMarks: 5);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      model.decreaseCheckmark(model.currentCharacter!);

      expect(model.currentCharacter!.checkMarks, equals(4));
    });

    test('persists to database', () async {
      final character = TestData.createCharacter(
        uuid: 'check-down',
        checkMarks: 3,
      );
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      model.decreaseCheckmark(model.currentCharacter!);

      expect(fakeDb.updateCalls, contains('check-down'));
    });

    test('does not go below 0', () async {
      final character = TestData.createCharacter(checkMarks: 0);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      model.decreaseCheckmark(model.currentCharacter!);

      expect(model.currentCharacter!.checkMarks, equals(0));
    });

    test('notifies listeners when decremented', () async {
      final character = TestData.createCharacter(checkMarks: 1);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      model.decreaseCheckmark(model.currentCharacter!);
      // decreaseCheckmark calls updateCharacter without await,
      // so we need to let the async operation complete
      await Future.microtask(() {});

      expect(notified, isTrue);
    });
  });

  group('togglePerk', () {
    test('sets perk isSelected to true', () async {
      final character = TestData.createCharacter(uuid: 'perk-toggle');
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      final perks = model.currentCharacter!.characterPerks;
      if (perks.isEmpty) {
        // Create manual perks if the class has none loaded
        final manualPerks = TestData.createCharacterPerkList(
          characterUuid: 'perk-toggle',
          count: 3,
        );
        model.currentCharacter!.characterPerks = manualPerks;
      }

      final targetPerk = model.currentCharacter!.characterPerks.first;

      await model.togglePerk(
        characterPerks: model.currentCharacter!.characterPerks,
        perk: targetPerk,
        value: true,
      );

      expect(targetPerk.characterPerkIsSelected, isTrue);
    });

    test('sets perk isSelected to false (deselect)', () async {
      final perks = [
        CharacterPerk('test-1', 'perk-0', true),
        CharacterPerk('test-1', 'perk-1', false),
      ];
      final character = TestData.createCharacter(characterPerks: perks);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.togglePerk(
        characterPerks: perks,
        perk: perks.first,
        value: false,
      );

      expect(perks.first.characterPerkIsSelected, isFalse);
    });

    test('persists perk change to database', () async {
      final perks = [CharacterPerk('test-1', 'perk-0', false)];
      final character = TestData.createCharacter(characterPerks: perks);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.togglePerk(
        characterPerks: perks,
        perk: perks.first,
        value: true,
      );

      expect(fakeDb.perkUpdateCalls.length, equals(1));
      expect(fakeDb.perkUpdateCalls.first.perkId, equals('perk-0'));
      expect(fakeDb.perkUpdateCalls.first.value, isTrue);
    });

    test('updates correct perk in characterPerks list', () async {
      final perks = [
        CharacterPerk('test-1', 'perk-0', false),
        CharacterPerk('test-1', 'perk-1', false),
        CharacterPerk('test-1', 'perk-2', false),
      ];
      final character = TestData.createCharacter(characterPerks: perks);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.togglePerk(
        characterPerks: perks,
        perk: perks[1],
        value: true,
      );

      expect(perks[0].characterPerkIsSelected, isFalse);
      expect(perks[1].characterPerkIsSelected, isTrue);
      expect(perks[2].characterPerkIsSelected, isFalse);
    });

    test('notifies listeners', () async {
      final perks = [CharacterPerk('test-1', 'perk-0', false)];
      final character = TestData.createCharacter(characterPerks: perks);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      await model.togglePerk(
        characterPerks: perks,
        perk: perks.first,
        value: true,
      );

      expect(notified, isTrue);
    });
  });

  group('toggleMastery', () {
    test('sets mastery achieved to true', () async {
      final masteries = [
        TestData.createCharacterMastery(
          associatedCharacterUuid: 'test-1',
          associatedMasteryId: 'mastery-0',
        ),
      ];
      final character = TestData.createCharacter(characterMasteries: masteries);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.toggleMastery(
        characterMasteries: masteries,
        mastery: masteries.first,
        value: true,
      );

      expect(masteries.first.characterMasteryAchieved, isTrue);
    });

    test('sets mastery achieved to false', () async {
      final masteries = [
        TestData.createCharacterMastery(
          associatedCharacterUuid: 'test-1',
          associatedMasteryId: 'mastery-0',
          characterMasteryAchieved: true,
        ),
      ];
      final character = TestData.createCharacter(characterMasteries: masteries);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.toggleMastery(
        characterMasteries: masteries,
        mastery: masteries.first,
        value: false,
      );

      expect(masteries.first.characterMasteryAchieved, isFalse);
    });

    test('persists mastery change to database', () async {
      final masteries = [
        TestData.createCharacterMastery(
          associatedCharacterUuid: 'test-1',
          associatedMasteryId: 'mastery-0',
        ),
      ];
      final character = TestData.createCharacter(characterMasteries: masteries);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.toggleMastery(
        characterMasteries: masteries,
        mastery: masteries.first,
        value: true,
      );

      expect(fakeDb.masteryUpdateCalls.length, equals(1));
      expect(fakeDb.masteryUpdateCalls.first.masteryId, equals('mastery-0'));
      expect(fakeDb.masteryUpdateCalls.first.value, isTrue);
    });

    test('updates correct mastery in characterMasteries list', () async {
      final masteries = [
        TestData.createCharacterMastery(associatedMasteryId: 'mastery-0'),
        TestData.createCharacterMastery(associatedMasteryId: 'mastery-1'),
      ];
      final character = TestData.createCharacter(characterMasteries: masteries);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      await model.toggleMastery(
        characterMasteries: masteries,
        mastery: masteries[1],
        value: true,
      );

      expect(masteries[0].characterMasteryAchieved, isFalse);
      expect(masteries[1].characterMasteryAchieved, isTrue);
    });

    test('notifies listeners', () async {
      final masteries = [
        TestData.createCharacterMastery(associatedMasteryId: 'mastery-0'),
      ];
      final character = TestData.createCharacter(characterMasteries: masteries);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      await model.toggleMastery(
        characterMasteries: masteries,
        mastery: masteries.first,
        value: true,
      );

      expect(notified, isTrue);
    });
  });

  group('onPageChanged', () {
    test('updates currentCharacter to character at new index', () async {
      fakeDb.characters = TestData.createAllActiveCharacters();
      final model = createModel();
      await model.loadCharacters();

      model.onPageChanged(1);

      expect(model.currentCharacter?.uuid, equals('test-2'));
    });

    test('sets isEditMode to false', () async {
      fakeDb.characters = TestData.createAllActiveCharacters();
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      model.onPageChanged(1);

      expect(model.isEditMode, isFalse);
    });

    test('persists page index to SharedPrefs', () async {
      fakeDb.characters = TestData.createAllActiveCharacters();
      final model = createModel();
      await model.loadCharacters();

      model.onPageChanged(1);

      expect(SharedPrefs().initialPage, equals(1));
    });

    test('sets isScrolledToTop to true', () async {
      fakeDb.characters = TestData.createAllActiveCharacters();
      final model = createModel();
      await model.loadCharacters();
      model.isScrolledToTop = false;

      model.onPageChanged(1);

      expect(model.isScrolledToTop, isTrue);
    });

    test('syncs theme color to new character class color', () async {
      // Use two different classes to verify theme changes
      fakeDb.characters = [
        TestData.createCharacter(
          uuid: 'test-1',
          name: 'Brute',
          playerClass: TestData.brute,
        ),
        TestData.createCharacter(
          uuid: 'test-2',
          name: 'Tinkerer',
          playerClass: TestData.tinkerer,
        ),
      ];
      final model = createModel();
      await model.loadCharacters();
      mockTheme.reset();

      model.onPageChanged(1);

      expect(mockTheme.lastSeedColor, isNotNull);
      expect(
        mockTheme.lastSeedColor,
        equals(Color(TestData.tinkerer.primaryColor)),
      );
    });

    test('notifies listeners', () async {
      fakeDb.characters = TestData.createAllActiveCharacters();
      final model = createModel();
      await model.loadCharacters();

      var notified = false;
      model.addListener(() => notified = true);

      model.onPageChanged(1);

      expect(notified, isTrue);
    });
  });

  group('loadCharacters', () {
    test('loads characters from database', () async {
      fakeDb.characters = TestData.createMixedCharacters();
      final model = createModel();

      await model.loadCharacters();

      expect(model.characters.length, equals(3));
    });

    test('loads perks for each character', () async {
      // Use a class that has perks defined in PerksRepository
      fakeDb.characters = [TestData.createCharacter()];
      // Pre-populate characterPerks to simulate existing data
      fakeDb.characterPerks['test-1'] = TestData.createCharacterPerkList(
        characterUuid: 'test-1',
        count: 3,
      );
      final model = createModel();

      await model.loadCharacters();

      expect(model.currentCharacter!.characterPerks, isNotEmpty);
    });

    test('sets currentCharacter from SharedPrefs initialPage', () async {
      SharedPreferences.setMockInitialValues({
        'showRetiredCharacters': true,
        'darkTheme': false,
        'initialPage': 1,
        'primaryClassColor': 0xff4e7ec1,
      });
      await SharedPrefs().init();

      fakeDb.characters = TestData.createAllActiveCharacters();
      final model = createModel();

      await model.loadCharacters();

      expect(model.currentCharacter?.uuid, equals('test-2'));
    });

    test('handles empty database gracefully', () async {
      fakeDb.characters = [];
      final model = createModel();

      await model.loadCharacters();

      expect(model.characters, isEmpty);
      expect(model.currentCharacter, isNull);
    });

    test('notifies listeners', () async {
      fakeDb.characters = [TestData.createCharacter()];
      final model = createModel();

      var notified = false;
      model.addListener(() => notified = true);

      await model.loadCharacters();

      expect(notified, isTrue);
    });
  });

  group('isEditMode', () {
    test('defaults to false', () {
      final model = createModel();

      expect(model.isEditMode, isFalse);
    });

    test('setting to true notifies listeners', () async {
      final model = createModel();

      var notified = false;
      model.addListener(() => notified = true);

      model.isEditMode = true;

      expect(model.isEditMode, isTrue);
      expect(notified, isTrue);
    });

    test('setting to false notifies listeners', () async {
      final model = createModel();
      model.isEditMode = true;

      var notified = false;
      model.addListener(() => notified = true);

      model.isEditMode = false;

      expect(model.isEditMode, isFalse);
      expect(notified, isTrue);
    });
  });
}
