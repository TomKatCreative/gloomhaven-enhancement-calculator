import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/app_theme_builder.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/characters_screen.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_data.dart';

/// Character pages are kept alive across swipes, so anything that reaches
/// every mounted page on a swipe costs a full page rebuild per visited
/// character. These tests count rebuilds per page, with the real
/// ThemeProvider driving MaterialApp the way main.dart does.
void main() {
  const pageCount = 4;
  late CharactersModel model;
  late ThemeProvider themeProvider;
  late FakeDatabaseHelper fakeDb;
  late Map<String, int> rebuildsByPage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'showRetiredCharacters': true});
    await SharedPrefs().init();
    rebuildsByPage = {};
  });

  tearDown(() => debugOnRebuildDirtyWidget = null);

  List<Character> createCharacters() => [
    for (var i = 0; i < pageCount; i++)
      TestData.createCharacter(
        uuid: 'c$i',
        name: 'Page $i',
        // Spread across the list so each page has a different color.
        playerClass: PlayerClasses.playerClasses[i * 3],
      )..personalQuestId = 'pq_gh_515',
  ];

  /// Pumps the characters page, visits every character so all pages are
  /// mounted, then settles on the last one and starts counting rebuilds.
  Future<void> pumpAndVisitAll(WidgetTester tester) async {
    fakeDb = FakeDatabaseHelper();
    // Inserting generates each character's perk rows.
    for (final c in createCharacters()) {
      await fakeDb.insertCharacter(c);
    }
    themeProvider = ThemeProvider(
      initialSeedColor: Colors.blue,
      initialDarkMode: false,
      initialDefaultFonts: false,
    );
    model = CharactersModel(
      databaseHelper: fakeDb,
      themeProvider: themeProvider,
      showRetired: true,
    );
    await model.loadCharacters();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<CharactersModel>.value(value: model),
          ChangeNotifierProvider<TownModel>(
            create: (_) => TownModel(databaseHelper: FakeDatabaseHelper()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final theme = context.watch<ThemeProvider>();
            return MaterialApp(
              theme: theme.lightTheme,
              darkTheme: theme.darkTheme,
              themeMode: theme.themeMode,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: CharactersScreen()),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 1; i < pageCount; i++) {
      model.pageController.jumpToPage(i);
      await tester.pumpAndSettle();
    }

    debugOnRebuildDirtyWidget = (element, _) {
      final page = element.findAncestorWidgetOfExactType<CharacterScreen>();
      if (page == null) return;
      final name = page.character.name;
      rebuildsByPage[name] = (rebuildsByPage[name] ?? 0) + 1;
    };
  }

  Character characterAt(int index) => model.characters[index];

  Finder pageOf(Character character) => find.byWidgetPredicate(
    (w) => w is CharacterScreen && w.character.uuid == character.uuid,
    skipOffstage: false,
  );

  ThemeData themeOfPage(WidgetTester tester, int index) {
    return Theme.of(tester.element(pageOf(characterAt(index))));
  }

  Color expectedPrimary(Character character, {bool useDarkMode = false}) {
    final config = ThemeConfig(
      seedColor: character.getEffectiveColor(
        useDarkMode ? Brightness.dark : Brightness.light,
      ),
      useDarkMode: useDarkMode,
      useDefaultFonts: false,
    );
    final theme = useDarkMode
        ? AppThemeBuilder.buildDarkTheme(config)
        : AppThemeBuilder.buildLightTheme(config);
    return theme.colorScheme.primary;
  }

  /// The edit-only controls each page shows, by page name: the quest swap
  /// button, the stats text fields, and enabled perk/mastery checkboxes.
  Map<String, Set<String>> editControlsByPage(WidgetTester tester) {
    bool onPage(Character c, Finder matching) => find
        .descendant(of: pageOf(c), matching: matching, skipOffstage: false)
        .evaluate()
        .isNotEmpty;
    return {
      for (final c in model.characters)
        c.name: {
          if (onPage(
            c,
            find.byIcon(Icons.swap_horiz_rounded, skipOffstage: false),
          ))
            'quest',
          if (onPage(c, find.byType(TextField, skipOffstage: false))) 'stats',
          if (onPage(
            c,
            find.byWidgetPredicate(
              (w) => w is Checkbox && w.onChanged != null,
              skipOffstage: false,
            ),
          ))
            'checkboxes',
        },
    };
  }

  Set<String> pagesInEditMode(WidgetTester tester) => {
    for (final MapEntry(:key, :value) in editControlsByPage(tester).entries)
      if (value.isNotEmpty) key,
  };

  testWidgets('a swipe rebuilds no character page', (tester) async {
    await pumpAndVisitAll(tester);
    final appColorBefore = themeProvider.seedColor;

    model.pageController.jumpToPage(1);
    await tester.pumpAndSettle();

    // The swipe did recolor the app, which used to rebuild every page.
    expect(themeProvider.seedColor, isNot(appColorBefore));
    expect(rebuildsByPage, isEmpty);
  });

  testWidgets('edit mode rebuilds only the current page', (tester) async {
    await pumpAndVisitAll(tester);
    final current = model.currentCharacter!.name;

    model.isEditMode = true;
    await tester.pumpAndSettle();

    expect(rebuildsByPage.keys, [current]);
  });

  testWidgets('a data change still rebuilds the edited page', (tester) async {
    await pumpAndVisitAll(tester);
    final current = model.currentCharacter!;

    await model.updateCharacter(current..gold = 42);
    await tester.pumpAndSettle();

    expect(rebuildsByPage[current.name], greaterThan(0));
  });

  testWidgets('each page is themed with its own character color', (
    tester,
  ) async {
    await pumpAndVisitAll(tester);

    for (var i = 0; i < pageCount; i++) {
      expect(
        themeOfPage(tester, i).colorScheme.primary,
        expectedPrimary(characterAt(i)),
        reason: 'page $i',
      );
    }
    expect(
      expectedPrimary(characterAt(0)),
      isNot(expectedPrimary(characterAt(1))),
    );
  });

  testWidgets('retiring a character recolors its page', (tester) async {
    await pumpAndVisitAll(tester);
    final index = model.characters.indexOf(model.currentCharacter!);

    await model.retireCurrentCharacter();
    await tester.pumpAndSettle();

    expect(characterAt(index).isRetired, isTrue);
    expect(
      themeOfPage(tester, index).colorScheme.primary,
      expectedPrimary(characterAt(index)),
    );
  });

  testWidgets('toggling dark mode re-themes every mounted page', (
    tester,
  ) async {
    await pumpAndVisitAll(tester);

    themeProvider.updateDarkMode(true);
    await tester.pumpAndSettle();

    for (var i = 0; i < pageCount; i++) {
      final theme = themeOfPage(tester, i);
      expect(theme.brightness, Brightness.dark, reason: 'page $i');
      expect(
        theme.colorScheme.primary,
        expectedPrimary(characterAt(i), useDarkMode: true),
        reason: 'page $i',
      );
    }
  });

  testWidgets('swiping away mid-edit leaves no page in edit mode', (
    tester,
  ) async {
    await pumpAndVisitAll(tester);
    final current = model.currentCharacter!;

    model.isEditMode = true;
    await tester.pumpAndSettle();
    // A data edit rebuilds every page; only the current one may edit.
    await model.updateCharacter(current..gold = 42);
    await tester.pumpAndSettle();
    expect(pagesInEditMode(tester), {current.name});
    expect(editControlsByPage(tester)[current.name], {
      'quest',
      'stats',
      'checkboxes',
    });

    model.pageController.jumpToPage(1);
    await tester.pumpAndSettle();

    expect(model.isEditMode, isFalse);
    expect(pagesInEditMode(tester), isEmpty);
  });

  testWidgets('reloading the same characters hands pages the new objects', (
    tester,
  ) async {
    await pumpAndVisitAll(tester);

    // A restore of a backup holding the same characters.
    fakeDb.characters = createCharacters();
    await model.loadCharacters();
    await tester.pumpAndSettle();

    for (final c in model.characters) {
      final page = tester.widget<CharacterScreen>(pageOf(c));
      expect(page.character, same(c), reason: c.name);
    }
  });

  testWidgets('switching fonts re-themes every mounted page', (tester) async {
    await pumpAndVisitAll(tester);
    final fontBefore = themeOfPage(tester, 0).textTheme.bodyMedium?.fontFamily;

    themeProvider.updateDefaultFonts(true);
    await tester.pumpAndSettle();

    for (var i = 0; i < pageCount; i++) {
      final font = themeOfPage(tester, i).textTheme.bodyMedium?.fontFamily;
      expect(font, isNot(fontBefore), reason: 'page $i');
    }
  });

  testWidgets('after a delete, the new current page drives the app bar', (
    tester,
  ) async {
    await pumpAndVisitAll(tester);
    model.pageController.jumpToPage(1);
    await tester.pumpAndSettle();

    await model.deleteCurrentCharacter();
    await tester.pumpAndSettle();
    final current = model.currentCharacter!;
    expect(current.uuid, 'c2');

    await tester.drag(
      find.descendant(
        of: pageOf(current),
        matching: find.byType(CustomScrollView),
      ),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(model.charScrollOffsetNotifier.value, greaterThan(0));
  });
}
