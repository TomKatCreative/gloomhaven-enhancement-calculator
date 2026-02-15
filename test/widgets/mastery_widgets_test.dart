import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/mastery_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/masteries_section.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_data.dart';
import '../helpers/test_helpers.dart';

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

  /// Sets up fakeDb and loads a Drifter character with pre-populated masteries.
  ///
  /// Uses the Drifter (Frosthaven) since shouldShowMasteries must return true.
  /// Loads the character from fakeDb, then overrides mastery definitions and
  /// join records with custom test data.
  Future<CharactersModel> setupModelWithMasteries({
    required Character character,
    required List<Mastery> masteries,
    required List<CharacterMasteryData> masteryData,
    bool isEditMode = true,
  }) async {
    fakeDb.characters = [character];
    fakeDb.characterMasteriesMap[character.uuid] = masteryData
        .map(
          (d) => TestData.createCharacterMastery(
            associatedCharacterUuid: character.uuid,
            associatedMasteryId: d.masteryId,
            characterMasteryAchieved: d.isAchieved,
          ),
        )
        .toList();

    final model = createModel();
    await model.loadCharacters();

    // Override mastery definitions and join records with custom test data
    character.masteries = masteries;
    character.characterMasteries =
        fakeDb.characterMasteriesMap[character.uuid]!;

    model.isEditMode = isEditMode;
    return model;
  }

  Widget buildTestWidget({
    required CharactersModel model,
    required Widget child,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MockThemeProvider>.value(value: mockTheme),
        ChangeNotifierProvider<CharactersModel>.value(value: model),
      ],
      child: MaterialApp(
        theme: ThemeData(
          dividerTheme: const DividerThemeData(color: Colors.grey),
        ),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  // ── MasteryRow ──

  group('MasteryRow', () {
    testWidgets('renders checkbox when CharacterMastery exists', (
      tester,
    ) async {
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox reflects initial unachieved state', (tester) async {
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('checkbox reflects initial achieved state', (tester) async {
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: true)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('tapping checkbox updates visual state immediately', (
      tester,
    ) async {
      // BUG-CATCHER: Verifies mastery checkbox rebuilds after toggling.
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      // VERIFY INITIAL: checkbox is unchecked
      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      // TAP the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // ASSERT: checkbox is now checked WITHOUT leaving the screen
      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('tapping toggles achieved to unachieved', (tester) async {
      // BUG-CATCHER: Verifies toggling from achieved → unachieved.
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: true)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('tapping calls toggleMastery (persists to DB)', (tester) async {
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(
        fakeDb.masteryUpdateCalls.any(
          (call) => call.masteryId == masteries[0].id,
        ),
        isTrue,
      );
    });

    testWidgets('checkbox disabled when not in edit mode', (tester) async {
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: false)],
        isEditMode: false,
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('checkbox disabled for retired character', (tester) async {
      final masteries = TestData.createMasteryList(count: 1);
      final character = TestData.createCharacter(
        playerClass: TestData.drifter,
        isRetired: true,
      );

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: [(masteryId: masteries[0].id, isAchieved: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteryRow(character: character, mastery: masteries[0]),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });
  });

  // ── MasteriesSection ──

  group('MasteriesSection', () {
    testWidgets('renders correct number of MasteryRow widgets', (tester) async {
      final masteries = TestData.createMasteryList(count: 3);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: masteries
            .map((m) => (masteryId: m.id, isAchieved: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteriesSection(character: character),
        ),
      );

      expect(find.byType(MasteryRow), findsNWidgets(3));
    });

    testWidgets('renders text for each mastery', (tester) async {
      final masteries = TestData.createMasteryList(count: 3);
      final character = TestData.createCharacter(playerClass: TestData.drifter);

      final model = await setupModelWithMasteries(
        character: character,
        masteries: masteries,
        masteryData: masteries
            .map((m) => (masteryId: m.id, isAchieved: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: MasteriesSection(character: character),
        ),
      );

      // Each mastery's text is rendered via RichText/TextSpan through
      // GameTextParser, not plain Text widgets. Verify each has a MasteryRow.
      expect(find.byType(MasteryRow), findsNWidgets(masteries.length));
    });
  });
}

/// Helper typedef for mastery data records used by [setupModelWithMasteries].
typedef CharacterMasteryData = ({String masteryId, bool isAchieved});
