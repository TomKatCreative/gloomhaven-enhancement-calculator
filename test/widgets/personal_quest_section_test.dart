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
    isRetirementSnackBarVisible = false;
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
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Section header
        expect(find.text('Personal Quest'), findsOneWidget);
        // Quest display name
        expect(find.textContaining('515: Lawbringer'), findsOneWidget);
      });

      testWidgets('displays requirement description and progress', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-2');
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [12];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Requirement text (rendered as RichText via GameTextParser)
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is RichText &&
                w.text.toPlainText().contains(
                  'Kill twenty Bandits or Cultists',
                ),
          ),
          findsOneWidget,
        );
        // Progress text: 12/20
        expect(find.text('12/20'), findsOneWidget);
      });

      testWidgets('shows check_circle when requirement is complete', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-3');
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_523';
        character.personalQuestProgress = [1, 0, 1, 0, 0, 1];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('523: Aberrant Slayer'), findsOneWidget);
        // Should show 3 complete (check_circle) and 3 incomplete
        expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
        expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
      });

      testWidgets('shows envelope icon in header for envelope quests', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-6');
        // Quest 513 unlocks Envelope X
        character.personalQuestId = 'pq_gh_513';
        character.personalQuestProgress = [0, 0];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Icon should be in the header row
        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      });
    });

    group('no quest assigned', () {
      testWidgets('shows select button in view mode', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-7');
        // No quest assigned (personalQuestId defaults to '')

        final model = await setupModel(character: character, isEditMode: false);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Should show OutlinedButton with select text
        expect(find.text('Select a Personal Quest'), findsOneWidget);
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('shows select button in edit mode', (tester) async {
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

        // Should show same OutlinedButton as view mode
        expect(find.text('Select a Personal Quest'), findsOneWidget);
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('renders nothing for retired character in edit mode', (
        tester,
      ) async {
        final character = TestData.createCharacter(
          uuid: 'test-pq-retired-no-quest',
          isRetired: true,
        );

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.text('Select a Personal Quest'), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
      });
    });

    group('edit mode', () {
      testWidgets('shows +/- buttons for requirements', (tester) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final character = TestData.createCharacter(uuid: 'test-pq-9');
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
      });

      testWidgets('+ button increments progress', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-11');
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_515';
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
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [15];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Should show quest content but NOT edit controls
        expect(find.textContaining('515: Lawbringer'), findsOneWidget);
        expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
        expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
      });

      testWidgets(
        'shows text field instead of +/- buttons for high-target requirements',
        (tester) async {
          tester.view.physicalSize = const Size(800, 600);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final character = TestData.createCharacter(uuid: 'test-pq-hi-1');
          // Quest 512 (Greed is Good) - target 200
          character.personalQuestId = 'pq_gh_512';
          character.personalQuestProgress = [50];

          final model = await setupModel(
            character: character,
            isEditMode: true,
          );
          await tester.pumpWidget(
            buildTestWidget(model: model, character: model.characters.first),
          );
          await tester.pumpAndSettle();

          // Should show a TextField, not +/- buttons
          expect(find.byType(TextField), findsOneWidget);
          expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
          expect(find.byIcon(Icons.add_circle_outline), findsNothing);
          // Should show "/" and target as separate text widgets
          expect(find.text('/'), findsOneWidget);
          expect(find.text('200'), findsOneWidget);
        },
      );

      testWidgets('text field updates progress for high-target requirements', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final character = TestData.createCharacter(uuid: 'test-pq-hi-2');
        character.personalQuestId = 'pq_gh_512';
        character.personalQuestProgress = [50];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Clear and type new value
        await tester.enterText(find.byType(TextField), '120');
        await tester.pumpAndSettle();

        // Progress should be updated in the model
        expect(model.characters.first.personalQuestProgress[0], 120);
      });

      testWidgets('text field shows check_circle when value meets target', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final character = TestData.createCharacter(uuid: 'test-pq-hi-3');
        character.personalQuestId = 'pq_gh_512';
        character.personalQuestProgress = [200];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      });

      testWidgets('tapping swap button opens confirmation dialog', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-16');
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Tap the swap IconButton
        await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
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
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Tap swap button to open dialog
        await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Quest should still be displayed
        expect(find.textContaining('515: Lawbringer'), findsOneWidget);
        expect(find.text('5/20'), findsOneWidget);
      });
    });

    group('retirement prompt', () {
      testWidgets(
        'shows retirement snackbar when quest transitions to complete',
        (tester) async {
          final character = TestData.createCharacter(uuid: 'test-pq-retire-1');
          character.personalQuestId = 'pq_gh_515'; // 1 req: kill 20
          character.personalQuestProgress = [19]; // one away

          final model = await setupModel(
            character: character,
            isEditMode: true,
          );
          await tester.pumpWidget(
            buildTestWidget(model: model, character: model.characters.first),
          );
          await tester.pumpAndSettle();

          // Tap the + button to go from 19 to 20 (completing the quest)
          await tester.tap(find.byIcon(Icons.add_circle_outline).last);
          await tester.pumpAndSettle();

          // Snackbar with short message and Retire action
          expect(find.byType(SnackBar), findsOneWidget);
          expect(find.text('Personal quest complete!'), findsOneWidget);
          expect(find.text('Retire'), findsOneWidget);
        },
      );

      testWidgets('tapping Retire in snackbar opens confirmation dialog', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-retire-2');
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [19];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Complete the quest
        await tester.tap(find.byIcon(Icons.add_circle_outline).last);
        await tester.pumpAndSettle();

        // Tap Retire in snackbar to open dialog
        await tester.tap(find.text('Retire'));
        await tester.pumpAndSettle();

        // Confirmation dialog should appear with full message
        expect(find.text('Not Yet'), findsOneWidget);
        expect(find.textContaining('must retire'), findsOneWidget);
      });

      testWidgets('Not Yet in dialog keeps character active', (tester) async {
        final character = TestData.createCharacter(uuid: 'test-pq-retire-3');
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [19];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Complete the quest → snackbar → Retire → dialog
        await tester.tap(find.byIcon(Icons.add_circle_outline).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retire'));
        await tester.pumpAndSettle();

        // Tap Not Yet
        await tester.tap(find.text('Not Yet'));
        await tester.pumpAndSettle();

        expect(model.currentCharacter!.isRetired, isFalse);
      });

      testWidgets('confirming Retire in dialog retires the character', (
        tester,
      ) async {
        final character = TestData.createCharacter(uuid: 'test-pq-retire-4');
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [19];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Complete the quest → snackbar → Retire → dialog → Retire
        await tester.tap(find.byIcon(Icons.add_circle_outline).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retire'));
        await tester.pumpAndSettle();

        // Dialog has two Retire texts (title area + confirm button); tap the button
        await tester.tap(find.text('Retire').last);
        await tester.pumpAndSettle();

        expect(model.currentCharacter!.isRetired, isTrue);
      });

      testWidgets(
        'does not show snackbar when progress changes on already-complete quest',
        (tester) async {
          final character = TestData.createCharacter(uuid: 'test-pq-retire-5');
          // Quest 523 has 6 binary requirements
          character.personalQuestId = 'pq_gh_523';
          // All complete
          character.personalQuestProgress = [1, 1, 1, 1, 1, 1];

          final model = await setupModel(
            character: character,
            isEditMode: true,
          );
          await tester.pumpWidget(
            buildTestWidget(model: model, character: model.characters.first),
          );
          await tester.pumpAndSettle();

          // Decrement requirement 0 from 1 to 0 (quest becomes incomplete)
          await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
          await tester.pumpAndSettle();

          // No snackbar should appear
          expect(find.byType(SnackBar), findsNothing);

          // Now increment it back to 1 (quest becomes complete again)
          await tester.tap(find.byIcon(Icons.add_circle_outline).first);
          await tester.pumpAndSettle();

          // Snackbar SHOULD appear because it transitioned from incomplete to complete
          expect(find.byType(SnackBar), findsOneWidget);
        },
      );

      testWidgets(
        'does not show duplicate snackbar when isRetirementSnackBarVisible is true',
        (tester) async {
          final character = TestData.createCharacter(uuid: 'test-pq-dedup');
          character.personalQuestId = 'pq_gh_515';
          character.personalQuestProgress = [19];

          final model = await setupModel(
            character: character,
            isEditMode: true,
          );
          await tester.pumpWidget(
            buildTestWidget(model: model, character: model.characters.first),
          );
          await tester.pumpAndSettle();

          // Complete the quest (19 → 20)
          await tester.tap(find.byIcon(Icons.add_circle_outline).last);
          await tester.pumpAndSettle();

          // First snackbar should appear
          expect(find.byType(SnackBar), findsOneWidget);
          // The flag should now be true
          expect(isRetirementSnackBarVisible, isTrue);

          // Decrement back to 19 then increment again to 20
          await tester.tap(find.byIcon(Icons.remove_circle_outline));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.add_circle_outline).last);
          await tester.pumpAndSettle();

          // Should still only show one snackbar (guard prevents duplicate)
          expect(find.byType(SnackBar), findsOneWidget);
        },
      );

      testWidgets('retirement dialog includes character name in body', (
        tester,
      ) async {
        final character = TestData.createCharacter(
          uuid: 'test-pq-retire-6',
          name: 'TestHero',
        );
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [19];

        final model = await setupModel(character: character, isEditMode: true);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Complete quest → snackbar → Retire → dialog
        await tester.tap(find.byIcon(Icons.add_circle_outline).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retire'));
        await tester.pumpAndSettle();

        expect(find.textContaining('TestHero'), findsOneWidget);
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
        character.personalQuestId = 'pq_gh_515';
        character.personalQuestProgress = [5];

        final model = await setupModel(character: character);
        await tester.pumpWidget(
          buildTestWidget(model: model, character: model.characters.first),
        );
        await tester.pumpAndSettle();

        // Header should be visible
        expect(find.text('Personal Quest'), findsOneWidget);
        // Content should be collapsed - quest name not visible
        expect(find.textContaining('515: Lawbringer'), findsNothing);
      });
    });
  });
}
