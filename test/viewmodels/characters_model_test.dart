import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
