import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/character_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/resource_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';

void main() {
  late FakeDatabaseHelper fakeDb;
  late MockThemeProvider mockTheme;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'showRetiredCharacters': true,
      'darkTheme': false,
      'initialPage': 0,
      'primaryClassColor': 0xff4e7ec1,
      'gameEdition': 0,
      'resourcesExpanded': false,
    });
    await SharedPrefs().init();

    fakeDb = FakeDatabaseHelper();
    mockTheme = MockThemeProvider();
  });

  tearDown(() {
    fakeDb.reset();
    mockTheme.reset();
  });

  /// ThemeData with required extensions for CharacterScreen.
  ThemeData testThemeData() {
    return ThemeData(
      dividerTheme: const DividerThemeData(color: Colors.grey),
      extensions: const [
        AppThemeExtension(
          characterPrimary: Color(0xff4e7ec1),
          characterSecondary: Color(0xff4e7ec1),
          characterAccent: Color(0xff4e7ec1),
          contrastedPrimary: Color(0xff4e7ec1),
        ),
      ],
    );
  }

  /// Sets up a CharactersModel with the given character and loads it.
  Future<CharactersModel> setupModel({
    required Character character,
    bool isEditMode = false,
  }) async {
    fakeDb.characters = [character];
    final model = CharactersModel(
      databaseHelper: fakeDb,
      themeProvider: mockTheme,
      showRetired: true,
    );
    await model.loadCharacters();
    model.isEditMode = isEditMode;
    return model;
  }

  /// Builds the CharacterScreen wrapped with providers, localization, and
  /// correct theme data.
  Widget buildTestWidget({
    required CharactersModel model,
    required Character character,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MockThemeProvider>.value(value: mockTheme),
        ChangeNotifierProvider<CharactersModel>.value(value: model),
      ],
      child: MaterialApp(
        theme: testThemeData(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CharacterScreen(character: character)),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Group 1: _NameAndClassSection
  // ────────────────────────────────────────────────────────────────────────

  group('_NameAndClassSection', () {
    testWidgets('view mode shows character name as AutoSizeText', (
      tester,
    ) async {
      final character = TestData.createCharacter(name: 'Grok the Mighty');
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AutoSizeText, 'Grok the Mighty'),
        findsWidgets,
      );
      // No TextFormField for name in view mode
      expect(find.byKey(ValueKey('name_${character.uuid}')), findsNothing);
    });

    testWidgets('edit mode shows name TextFormField with initial value', (
      tester,
    ) async {
      final character = TestData.createCharacter(name: 'Editable Name');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final nameField = find.byKey(ValueKey('name_${character.uuid}'));
      expect(nameField, findsOneWidget);

      final textFormField = tester.widget<TextFormField>(nameField);
      expect(textFormField.initialValue, 'Editable Name');
    });

    testWidgets('name field not editable for retired character', (
      tester,
    ) async {
      final character = TestData.createRetiredCharacter(name: 'Old Warrior');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Should show AutoSizeText, not TextFormField
      expect(find.widgetWithText(AutoSizeText, 'Old Warrior'), findsWidgets);
      expect(find.byKey(ValueKey('name_${character.uuid}')), findsNothing);
    });

    testWidgets('level badge shows correct level for xp=0 (level 1)', (
      tester,
    ) async {
      final character = TestData.createCharacter(xp: 0);
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Level 1 text in the level badge area
      // Find the level text near the class subtitle row
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('level badge shows correct level for xp=95 (level 3)', (
      tester,
    ) async {
      final character = TestData.createCharacter(xp: 95);
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsWidgets);
    });

    testWidgets('class subtitle displays correctly', (tester) async {
      // Brute is "Inox Brute"
      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AutoSizeText, 'Inox Brute'), findsOneWidget);
    });

    testWidgets('traits shown in view mode for Frosthaven class', (
      tester,
    ) async {
      // Drifter is Frosthaven, traits: Outcast, Resourceful, Strong
      final character = TestData.createCharacter(playerClass: TestData.drifter);
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Outcast'), findsOneWidget);
      expect(find.textContaining('Resourceful'), findsOneWidget);
      expect(find.textContaining('Strong'), findsOneWidget);
    });

    testWidgets('traits hidden in edit mode', (tester) async {
      final character = TestData.createCharacter(playerClass: TestData.drifter);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // The traits row containing all three traits should not be present
      expect(
        find.textContaining('Outcast · Resourceful · Strong'),
        findsNothing,
      );
    });

    testWidgets('retired label shown for retired character', (tester) async {
      final character = TestData.createRetiredCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('(retired)'), findsOneWidget);
    });

    testWidgets('retired label hidden for active character', (tester) async {
      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('(retired)'), findsNothing);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Group 2: _StatsSection
  // ────────────────────────────────────────────────────────────────────────

  group('_StatsSection', () {
    testWidgets('view mode shows XP and Gold as Tooltips', (tester) async {
      final character = TestData.createCharacter(xp: 50, gold: 30);
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Find Tooltips with XP and Gold messages
      final xpTooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == 'XP',
      );
      expect(xpTooltip, findsOneWidget);

      final goldTooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == 'Gold',
      );
      expect(goldTooltip, findsOneWidget);

      // Check the actual values are displayed
      expect(find.text('50'), findsWidgets);
      expect(find.text('30'), findsWidgets);
    });

    testWidgets('view mode shows battle goal progress tooltip', (tester) async {
      final character = TestData.createCharacter(checkMarks: 5);
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final battleGoalsTooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == 'Battle goals',
      );
      expect(battleGoalsTooltip, findsOneWidget);

      // checkMarkProgress for 5 checkmarks = 5 % 3 = 2, shown as "2/3"
      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('view mode shows pocket items tooltip', (tester) async {
      // Level 1 (xp=0): pocketItemsAllowed = (1/2).round() = 1
      final character = TestData.createCharacter(xp: 0);
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // pocketItemsAllowed(1) = 1 → "1 pocket item allowed"
      final pocketTooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == '1 pocket item allowed',
      );
      expect(pocketTooltip, findsOneWidget);
    });

    testWidgets('edit mode shows XP TextField with correct initial value', (
      tester,
    ) async {
      final character = TestData.createCharacter(xp: 100, notes: '');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Find TextFields with numeric keyboard (XP and Gold)
      final numericFields = tester
          .widgetList<TextField>(find.byType(TextField))
          .where((tf) => tf.keyboardType == TextInputType.number)
          .toList();
      expect(numericFields.length, 2);

      // XP field is first
      expect(numericFields[0].controller?.text, '100');
    });

    testWidgets('edit mode shows Gold TextField with correct initial value', (
      tester,
    ) async {
      final character = TestData.createCharacter(gold: 75, notes: '');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final numericFields = tester
          .widgetList<TextField>(find.byType(TextField))
          .where((tf) => tf.keyboardType == TextInputType.number)
          .toList();

      // Gold is the second numeric TextField
      expect(numericFields[1].controller?.text, '75');
    });

    testWidgets('XP TextField shows empty string when value is 0', (
      tester,
    ) async {
      final character = TestData.createCharacter(xp: 0, notes: '');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final numericFields = tester
          .widgetList<TextField>(find.byType(TextField))
          .where((tf) => tf.keyboardType == TextInputType.number)
          .toList();
      expect(numericFields[0].controller?.text, '');
    });

    testWidgets('Gold TextField shows empty string when value is 0', (
      tester,
    ) async {
      final character = TestData.createCharacter(gold: 0, notes: '');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final numericFields = tester
          .widgetList<TextField>(find.byType(TextField))
          .where((tf) => tf.keyboardType == TextInputType.number)
          .toList();
      expect(numericFields[1].controller?.text, '');
    });

    testWidgets('XP suffix shows next level threshold', (tester) async {
      // Level 1 (xp=0), next level XP = 45
      final character = TestData.createCharacter(xp: 0);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('/ 45'), findsOneWidget);
    });

    testWidgets('edit mode shows exposure (add/subtract) buttons', (
      tester,
    ) async {
      final character = TestData.createCharacter();
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Two exposure buttons (one for XP, one for Gold)
      expect(find.byIcon(Icons.exposure), findsNWidgets(2));
    });

    testWidgets('stats fields show view mode for retired character', (
      tester,
    ) async {
      final character = TestData.createRetiredCharacter();
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Even in edit mode, retired character shows Tooltips (view mode)
      final xpTooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == 'XP',
      );
      expect(xpTooltip, findsOneWidget);

      // No TextFields
      expect(find.byType(TextField), findsNothing);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Group 3: _CheckmarksAndRetirementsRow
  // ────────────────────────────────────────────────────────────────────────

  group('_CheckmarksAndRetirementsRow', () {
    testWidgets('section visible in edit mode for active character', (
      tester,
    ) async {
      final character = TestData.createCharacter(
        previousRetirements: 2,
        checkMarks: 5,
      );
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('Previous retirements'), findsOneWidget);
      expect(find.text('Battle goals'), findsOneWidget);
    });

    testWidgets('section hidden in view mode', (tester) async {
      final character = TestData.createCharacter(
        previousRetirements: 2,
        checkMarks: 5,
      );
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('Previous retirements'), findsNothing);
    });

    testWidgets('section hidden for retired character even in edit mode', (
      tester,
    ) async {
      final character = TestData.createRetiredCharacter();
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('Previous retirements'), findsNothing);
    });

    testWidgets('previous retirements displays correct count', (tester) async {
      final character = TestData.createCharacter(previousRetirements: 3);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // The retirement count is in the left column
      final previousRetLabel = find.text('Previous retirements');
      expect(previousRetLabel, findsOneWidget);

      // Find '3' as a descendant of the row that contains 'Previous retirements'
      // The retirements column is an Expanded widget containing the count
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('checkmarks displays count with /18 suffix', (tester) async {
      final character = TestData.createCharacter(checkMarks: 7);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('/18'), findsOneWidget);
      expect(find.text('7'), findsWidgets);
    });

    testWidgets('checkmark progress shows correct format', (tester) async {
      // 7 checkmarks: 7 % 3 = 1, so progress = 1
      final character = TestData.createCharacter(checkMarks: 7);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('/3)'), findsOneWidget);
    });

    testWidgets('increment retirement button updates character', (
      tester,
    ) async {
      final character = TestData.createCharacter(
        uuid: 'ret-test',
        previousRetirements: 1,
      );
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Find the add button in the retirements section (left column)
      // The left column has "Previous retirements" label
      // Find the add_box_rounded icons - there are 2 (retirements + checkmarks)
      final addButtons = find.byIcon(Icons.add_box_rounded);
      expect(addButtons, findsNWidgets(2));

      // First add button is for retirements
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      expect(character.previousRetirements, 2);
      expect(fakeDb.updateCalls, contains('ret-test'));
    });

    testWidgets('decrement retirement disabled at 0', (tester) async {
      final character = TestData.createCharacter(previousRetirements: 0);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Find the subtract button - first one is for retirements
      final subtractButtons = find.byIcon(
        Icons.indeterminate_check_box_rounded,
      );
      expect(subtractButtons, findsNWidgets(2));

      final retirementSubtractButton = tester.widget<IconButton>(
        find
            .ancestor(
              of: subtractButtons.first,
              matching: find.byType(IconButton),
            )
            .first,
      );
      expect(retirementSubtractButton.onPressed, isNull);
    });

    testWidgets('increment checkmark calls increaseCheckmark', (tester) async {
      final character = TestData.createCharacter(
        uuid: 'chk-test',
        checkMarks: 5,
      );
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Second add button is for checkmarks
      final addButtons = find.byIcon(Icons.add_box_rounded);
      await tester.tap(addButtons.last);
      // increaseCheckmark doesn't await updateCharacter
      await Future.microtask(() {});
      await tester.pumpAndSettle();

      expect(character.checkMarks, 6);
      expect(fakeDb.updateCalls, contains('chk-test'));
    });

    testWidgets('decrement checkmark calls decreaseCheckmark', (tester) async {
      final character = TestData.createCharacter(
        uuid: 'chk-dec-test',
        checkMarks: 5,
      );
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Second subtract button is for checkmarks
      final subtractButtons = find.byIcon(
        Icons.indeterminate_check_box_rounded,
      );
      await tester.tap(subtractButtons.last);
      await Future.microtask(() {});
      await tester.pumpAndSettle();

      expect(character.checkMarks, 4);
      expect(fakeDb.updateCalls, contains('chk-dec-test'));
    });

    testWidgets('checkmark add disabled at 18', (tester) async {
      final character = TestData.createCharacter(checkMarks: 18);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Last add button is for checkmarks
      final addButtons = find.byIcon(Icons.add_box_rounded);
      final checkmarkAddButton = tester.widget<IconButton>(
        find
            .ancestor(of: addButtons.last, matching: find.byType(IconButton))
            .first,
      );
      expect(checkmarkAddButton.onPressed, isNull);
    });

    testWidgets('checkmark subtract disabled at 0', (tester) async {
      final character = TestData.createCharacter(checkMarks: 0);
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Last subtract button is for checkmarks
      final subtractButtons = find.byIcon(
        Icons.indeterminate_check_box_rounded,
      );
      final checkmarkSubtractButton = tester.widget<IconButton>(
        find
            .ancestor(
              of: subtractButtons.last,
              matching: find.byType(IconButton),
            )
            .first,
      );
      expect(checkmarkSubtractButton.onPressed, isNull);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Group 4: _ResourcesSection
  // ────────────────────────────────────────────────────────────────────────

  group('_ResourcesSection', () {
    testWidgets('resources header visible', (tester) async {
      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resources'), findsOneWidget);
    });

    testWidgets('resources collapsed by default', (tester) async {
      // resourcesExpanded defaults to false in setUp
      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // ResourceCard widgets should not be visible when collapsed
      expect(find.byType(ResourceCard), findsNothing);
    });

    testWidgets('resources expanded when resourcesExpanded is true', (
      tester,
    ) async {
      // Set resourcesExpanded before building
      SharedPreferences.setMockInitialValues({
        'showRetiredCharacters': true,
        'darkTheme': false,
        'initialPage': 0,
        'primaryClassColor': 0xff4e7ec1,
        'gameEdition': 0,
        'resourcesExpanded': true,
      });
      await SharedPrefs().init();

      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Should show 9 ResourceCard widgets
      expect(find.byType(ResourceCard), findsNWidgets(9));
    });

    testWidgets('tapping ExpansionTile toggles resource visibility', (
      tester,
    ) async {
      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Initially collapsed
      expect(find.byType(ResourceCard), findsNothing);

      // Tap the ExpansionTile header to expand
      await tester.tap(find.text('Resources'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.byType(ResourceCard), findsNWidgets(9));
    });

    testWidgets('shows 9 ResourceCard widgets when expanded', (tester) async {
      SharedPreferences.setMockInitialValues({
        'showRetiredCharacters': true,
        'darkTheme': false,
        'initialPage': 0,
        'primaryClassColor': 0xff4e7ec1,
        'gameEdition': 0,
        'resourcesExpanded': true,
      });
      await SharedPrefs().init();

      final character = TestData.createCharacter();
      final model = await setupModel(character: character);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ResourceCard), findsNWidgets(9));
    });

    testWidgets('resource buttons hidden in view mode', (tester) async {
      SharedPreferences.setMockInitialValues({
        'showRetiredCharacters': true,
        'darkTheme': false,
        'initialPage': 0,
        'primaryClassColor': 0xff4e7ec1,
        'gameEdition': 0,
        'resourcesExpanded': true,
      });
      await SharedPrefs().init();

      final character = TestData.createCharacter();
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Scroll to make resource cards visible
      await tester.ensureVisible(find.byType(ResourceCard).first);
      await tester.pumpAndSettle();

      // In view mode, ResourceCard should NOT have InkWell buttons (canEdit=false)
      // The remove_rounded / add_rounded icons are only in _ResourceButtonBar
      expect(find.byIcon(Icons.remove_rounded), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });

    testWidgets('resource buttons hidden for retired character', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'showRetiredCharacters': true,
        'darkTheme': false,
        'initialPage': 0,
        'primaryClassColor': 0xff4e7ec1,
        'gameEdition': 0,
        'resourcesExpanded': true,
      });
      await SharedPrefs().init();

      final character = TestData.createRetiredCharacter();
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(ResourceCard).first);
      await tester.pumpAndSettle();

      // canEdit is false for retired characters
      expect(find.byIcon(Icons.remove_rounded), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });

    testWidgets('resource increment calls updateCharacter', (tester) async {
      SharedPreferences.setMockInitialValues({
        'showRetiredCharacters': true,
        'darkTheme': false,
        'initialPage': 0,
        'primaryClassColor': 0xff4e7ec1,
        'gameEdition': 0,
        'resourcesExpanded': true,
      });
      await SharedPrefs().init();

      final character = TestData.createCharacter(uuid: 'res-test');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Scroll to a resource card and tap the increment button
      await tester.ensureVisible(find.byType(ResourceCard).first);
      await tester.pumpAndSettle();

      // Find add_rounded icons (one per resource card in edit mode)
      final addIcons = find.byIcon(Icons.add_rounded);
      expect(addIcons, findsWidgets);

      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      expect(fakeDb.updateCalls, contains('res-test'));
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Group 5: _NotesSection
  // ────────────────────────────────────────────────────────────────────────

  group('_NotesSection', () {
    testWidgets('notes section hidden when notes empty and not in edit mode', (
      tester,
    ) async {
      final character = TestData.createCharacter(notes: '');
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // "Notes" heading should not appear
      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('notes visible in view mode when notes non-empty', (
      tester,
    ) async {
      final character = TestData.createCharacter(
        notes: 'Remember to buy boots',
      );
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Scroll down to find the notes section
      await tester.ensureVisible(find.text('Remember to buy boots'));
      await tester.pumpAndSettle();

      expect(find.text('Remember to buy boots'), findsOneWidget);
    });

    testWidgets('notes header shown in view mode', (tester) async {
      final character = TestData.createCharacter(notes: 'Some notes here');
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Scroll to find "Notes" header
      await tester.ensureVisible(find.text('Notes'));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('edit mode shows TextFormField even with empty notes', (
      tester,
    ) async {
      final character = TestData.createCharacter(notes: '');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final notesField = find.byKey(ValueKey('notes_${character.uuid}'));

      // Scroll to make the field visible
      await tester.ensureVisible(notesField);
      await tester.pumpAndSettle();

      expect(notesField, findsOneWidget);
    });

    testWidgets('TextFormField has correct initial value', (tester) async {
      final character = TestData.createCharacter(notes: 'My important notes');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final notesField = find.byKey(ValueKey('notes_${character.uuid}'));
      await tester.ensureVisible(notesField);
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(notesField);
      expect(field.initialValue, 'My important notes');
    });

    testWidgets('editing notes calls updateCharacter', (tester) async {
      final character = TestData.createCharacter(uuid: 'notes-test', notes: '');
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      final notesField = find.byKey(ValueKey('notes_${character.uuid}'));
      await tester.ensureVisible(notesField);
      await tester.pumpAndSettle();

      await tester.enterText(notesField, 'New note');
      await tester.pumpAndSettle();

      expect(character.notes, 'New note');
      expect(fakeDb.updateCalls, contains('notes-test'));
    });

    testWidgets('notes not editable for retired character', (tester) async {
      final character = TestData.createRetiredCharacter();
      character.notes = 'Old notes';
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Should show plain Text, not TextFormField
      await tester.ensureVisible(find.text('Old notes'));
      await tester.pumpAndSettle();
      expect(find.text('Old notes'), findsOneWidget);

      // Notes TextFormField should not be present
      expect(find.byKey(ValueKey('notes_${character.uuid}')), findsNothing);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Group 6: Integration
  // ────────────────────────────────────────────────────────────────────────

  group('Integration', () {
    testWidgets('active character in view mode renders all expected sections', (
      tester,
    ) async {
      final character = TestData.createCharacter(
        name: 'Full Test',
        xp: 50,
        gold: 30,
        notes: 'Test notes',
      );
      final model = await setupModel(character: character, isEditMode: false);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Name
      expect(find.widgetWithText(AutoSizeText, 'Full Test'), findsWidgets);
      // Class subtitle
      expect(find.widgetWithText(AutoSizeText, 'Inox Brute'), findsOneWidget);
      // Stats (view mode tooltips)
      expect(
        find.byWidgetPredicate((w) => w is Tooltip && w.message == 'XP'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Gold'),
        findsOneWidget,
      );
      // Resources header
      expect(find.text('Resources'), findsOneWidget);
      // Checkmarks should NOT be visible in view mode
      expect(find.text('Previous retirements'), findsNothing);
    });

    testWidgets('retired character disables all editing', (tester) async {
      final character = TestData.createRetiredCharacter(name: 'Done Hero');
      character.notes = 'Legacy notes';
      final model = await setupModel(character: character, isEditMode: true);

      await tester.pumpWidget(
        buildTestWidget(model: model, character: character),
      );
      await tester.pumpAndSettle();

      // Name is not editable (AutoSizeText, not TextFormField)
      expect(find.widgetWithText(AutoSizeText, 'Done Hero'), findsWidgets);
      expect(find.byKey(ValueKey('name_${character.uuid}')), findsNothing);

      // Stats show view mode (Tooltips present, no TextFields)
      expect(find.byType(TextField), findsNothing);

      // Checkmarks section is hidden
      expect(find.text('Previous retirements'), findsNothing);

      // Retired label is shown
      expect(find.text('(retired)'), findsOneWidget);
    });
  });
}
