import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/personal_quest_section.dart';
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
      'personalQuestExpanded': true,
    });
    await SharedPrefs().init();

    fakeDb = FakeDatabaseHelper();
    mockTheme = MockThemeProvider();
  });

  tearDown(() {
    fakeDb.reset();
    mockTheme.reset();
  });

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

  Future<CharactersModel> setupModel({
    required Character character,
    bool isEditMode = false,
  }) async {
    fakeDb.characters = [character];
    fakeDb.perksData = [];
    fakeDb.masteriesData = [];
    final model = CharactersModel(
      databaseHelper: fakeDb,
      themeProvider: mockTheme,
      showRetired: true,
    );
    await model.loadCharacters();
    model.isEditMode = isEditMode;
    return model;
  }

  Widget buildTestWidget({
    required CharactersModel model,
    required Character character,
  }) {
    return wrapWithProviders(
      charactersModel: model,
      themeProvider: mockTheme,
      withLocalization: true,
      themeData: testThemeData(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: PersonalQuestSection(character: character),
        ),
      ),
    );
  }

  group('PersonalQuestSection', () {
    group('with quest assigned', () {
      testWidgets('displays quest title', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-1');
        // Assign quest 515 (Lawbringer) - has 1 requirement: "Kill 20 Bandits or Cultists"
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Section header
        expect(find.text('Personal Quest'), findsOneWidget);
        // Quest display name
        expect(find.text('515 - Lawbringer'), findsOneWidget);
      });

      testWidgets('displays requirement description and progress', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-2');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [12];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Requirement text
        expect(find.text('Kill 20 Bandits or Cultists'), findsOneWidget);
        // Progress text: 12/20
        expect(find.text('12/20'), findsOneWidget);
      });

      testWidgets('shows check_circle when requirement is complete', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-3');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [20]; // target is 20, so complete

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      });

      testWidgets('shows unchecked circle when requirement is incomplete', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-4');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsNothing);
      });

      testWidgets('displays multiple requirements', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-5');
        // Quest 523 (Aberrant Slayer) has 6 requirements (one per demon type)
        character.personalQuestId = 'gh_523';
        character.personalQuestProgress = [1, 0, 1, 0, 0, 1];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.text('523 - Aberrant Slayer'), findsOneWidget);
        // Should show 3 complete (check_circle) and 3 incomplete
        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
        expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
      });

      testWidgets('shows envelope icon for envelope quests', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-6');
        // Quest 513 unlocks Envelope X
        character.personalQuestId = 'gh_513';
        character.personalQuestProgress = [0, 0];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      });
    });

    group('view mode (no quest)', () {
      testWidgets('shows no personal quest message', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-7');
        // No quest assigned (personalQuestId defaults to '')

        final model = await setupModel(character: character, isEditMode: false);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.text('No personal quest selected'), findsOneWidget);
      });
    });

    group('edit mode', () {
      testWidgets('shows select prompt when no quest assigned', (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final character = TestData.createCharacter(uuid: 'test-pq-8');

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.text('Select personal quest...'), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });

      testWidgets('shows +/- buttons for requirements', (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final character = TestData.createCharacter(uuid: 'test-pq-9');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Should have both +/- icons for the requirement
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });

      testWidgets('shows edit icon next to quest title', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-10');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.edit), findsOneWidget);
      });

      testWidgets('+ button increments progress', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-11');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.text('5/20'), findsOneWidget);

        // Tap the + button
        await tester.tap(find.byIcon(Icons.add_circle_outline).last);
        await tester.pumpAndSettle();

        expect(find.text('6/20'), findsOneWidget);
      });

      testWidgets('- button decrements progress', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-12');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.text('5/20'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pumpAndSettle();

        expect(find.text('4/20'), findsOneWidget);
      });

      testWidgets('- button is disabled at 0 progress', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-13');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [0];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Find the minus IconButton and check that onPressed is null
        final minusButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.remove_circle_outline),
        );
        expect(minusButton.onPressed, isNull);
      });

      testWidgets('+ button is disabled at target progress', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-14');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [20]; // target is 20

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Find the plus IconButton and check that onPressed is null
        final plusButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.add_circle_outline),
        );
        expect(plusButton.onPressed, isNull);
      });

      testWidgets('does not show edit controls for retired characters', (
        tester,
      ) async {
        final character = TestData.createCharacter(
          uuid: 'test-pq-15',
          isRetired: true,
        );
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [15];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Should show quest content but NOT edit controls
        expect(find.text('515 - Lawbringer'), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
      });

      testWidgets('tapping quest title opens confirmation dialog', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-16');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Tap the quest title row (InkWell wrapping the Row)
        await tester.tap(find.text('515 - Lawbringer'));
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text('Change Personal Quest?'), findsOneWidget);
        expect(
          find.text(
            'This will replace your current quest and reset all progress.',
          ),
          findsOneWidget,
        );
        expect(find.text('Change'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('cancelling confirmation dialog keeps quest', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-17');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Tap quest title to open dialog
        await tester.tap(find.text('515 - Lawbringer'));
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Quest should still be displayed
        expect(find.text('515 - Lawbringer'), findsOneWidget);
        expect(find.text('5/20'), findsOneWidget);
      });
    });

    group('expansion state', () {
      testWidgets('respects SharedPrefs initial expansion state', (
        tester,
      ) async {
        // Set expansion to false
        SharedPreferences.setMockInitialValues({
          'showRetiredCharacters': true,
          'darkTheme': false,
          'initialPage': 0,
          'personalQuestExpanded': false,
        });
        await SharedPrefs().init();

        final character = TestData.createCharacter(uuid: 'test-pq-18');
        character.personalQuestId = 'gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Header should be visible
        expect(find.text('Personal Quest'), findsOneWidget);
        // Content should be collapsed - quest name not visible
        expect(find.text('515 - Lawbringer'), findsNothing);
      });
    });
  });
}
