import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/conditional_checkbox.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perk_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perks_section.dart';
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

  /// Sets up fakeDb and loads a character with pre-populated perks.
  ///
  /// Loads the character from fakeDb, then overrides perk definitions and
  /// join records with custom test data (since perk definitions are now
  /// loaded from PerksRepository during loadCharacters).
  Future<CharactersModel> setupModelWithPerks({
    required Character character,
    required List<Perk> perks,
    required List<CharacterPerkData> perkData,
    bool isEditMode = true,
  }) async {
    // Populate the fakeDb so loadCharacters can find the data
    fakeDb.characters = [character];
    fakeDb.characterPerks[character.uuid] = perkData
        .map(
          (d) => TestData.createCharacterPerk(
            associatedCharacterUuid: character.uuid,
            associatedPerkId: d.perkId,
            isSelected: d.isSelected,
          ),
        )
        .toList();

    final model = createModel();
    await model.loadCharacters();

    // Override perk definitions and join records with custom test data
    character.perks = perks;
    character.characterPerks = fakeDb.characterPerks[character.uuid]!;

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

  // ── ConditionalCheckbox ──

  group('ConditionalCheckbox', () {
    testWidgets('renders unchecked when value is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalCheckbox(
              value: false,
              isEditMode: true,
              isRetired: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('renders checked when value is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalCheckbox(
              value: true,
              isEditMode: true,
              isRetired: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('tappable when isEditMode=true and isRetired=false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalCheckbox(
              value: false,
              isEditMode: true,
              isRetired: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNotNull);
    });

    testWidgets('disabled when isEditMode=false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalCheckbox(
              value: false,
              isEditMode: false,
              isRetired: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('disabled when isRetired=true even if isEditMode=true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalCheckbox(
              value: false,
              isEditMode: true,
              isRetired: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('tap calls onChanged with correct value', (tester) async {
      bool? receivedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConditionalCheckbox(
              value: false,
              isEditMode: true,
              isRetired: false,
              onChanged: (val) => receivedValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(receivedValue, isTrue);
    });
  });

  // ── PerkRow - Non-Grouped ──

  group('PerkRow - Non-Grouped', () {
    testWidgets('renders correct number of checkboxes', (tester) async {
      final perks = TestData.createPerkList(count: 2);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets('checkbox reflects initial unchecked state', (tester) async {
      final perks = TestData.createPerkList(count: 1);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: [(perkId: perks[0].perkId, isSelected: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('checkbox reflects initial checked state', (tester) async {
      final perks = TestData.createPerkList(count: 1);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: [(perkId: perks[0].perkId, isSelected: true)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('tapping checkbox updates visual state immediately', (
      tester,
    ) async {
      // BUG-CATCHER: This test catches the known bug where perk checkboxes
      // didn't update visually in edit mode until leaving/re-entering.
      final perks = TestData.createPerkList(count: 1);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: [(perkId: perks[0].perkId, isSelected: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
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

    testWidgets('tapping checkbox toggles checked to unchecked', (
      tester,
    ) async {
      // BUG-CATCHER: Same pattern, but toggling from checked → unchecked.
      final perks = TestData.createPerkList(count: 1);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: [(perkId: perks[0].perkId, isSelected: true)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      // VERIFY INITIAL: checkbox is checked
      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      // TAP the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // ASSERT: checkbox is now unchecked
      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('tapping calls togglePerk (persists to DB)', (tester) async {
      final perks = TestData.createPerkList(count: 1);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: [(perkId: perks[0].perkId, isSelected: false)],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(
        fakeDb.perkUpdateCalls.any((call) => call.perkId == perks[0].perkId),
        isTrue,
      );
    });

    testWidgets('checkboxes disabled when not in edit mode', (tester) async {
      final perks = TestData.createPerkList(count: 2);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
        isEditMode: false,
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final cb in checkboxes) {
        expect(cb.onChanged, isNull);
      }
    });

    testWidgets('checkboxes disabled for retired character', (tester) async {
      final perks = TestData.createPerkList(count: 2);
      final character = TestData.createCharacter(isRetired: true);

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final cb in checkboxes) {
        expect(cb.onChanged, isNull);
      }
    });
  });

  // ── PerkRow - Grouped ──

  group('PerkRow - Grouped', () {
    testWidgets('renders correct number of grouped checkboxes', (tester) async {
      final perks = TestData.createPerkList(
        count: 3,
        grouped: true,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('renders checkboxes in bordered container', (tester) async {
      final perks = TestData.createPerkList(
        count: 2,
        grouped: true,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      // Find the Container with BoxDecoration that has a border
      final container = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.border != null;
        }
        return false;
      });
      expect(container, findsOneWidget);
    });

    testWidgets('tapping grouped checkbox updates visual state immediately', (
      tester,
    ) async {
      // BUG-CATCHER: Same pattern as non-grouped
      final perks = TestData.createPerkList(
        count: 2,
        grouped: true,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      // Tap the first checkbox
      final checkboxes = find.byType(Checkbox);
      Checkbox firstCheckbox = tester.widget(checkboxes.first);
      expect(firstCheckbox.value, isFalse);

      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      firstCheckbox = tester.widget(checkboxes.first);
      expect(firstCheckbox.value, isTrue);
    });

    testWidgets('grouped checkboxes disabled when not in edit mode', (
      tester,
    ) async {
      final perks = TestData.createPerkList(
        count: 2,
        grouped: true,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
        isEditMode: false,
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final cb in checkboxes) {
        expect(cb.onChanged, isNull);
      }
    });

    testWidgets('border uses primary color when all perks selected', (
      tester,
    ) async {
      final perks = TestData.createPerkList(
        count: 2,
        grouped: true,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: true))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      // Find the bordered container and check its border color matches primary
      final context = tester.element(find.byType(PerkRow));
      final primaryColor = Theme.of(context).colorScheme.primary;

      final container = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          if (decoration.border is Border) {
            final border = decoration.border as Border;
            return border.top.color == primaryColor;
          }
        }
        return false;
      });
      expect(container, findsOneWidget);
    });

    testWidgets('border color changes based on selection state', (
      tester,
    ) async {
      final perks = TestData.createPerkList(
        count: 2,
        grouped: true,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      // Only 1 of 2 selected (not all)
      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: [
          (perkId: perks[0].perkId, isSelected: true),
          (perkId: perks[1].perkId, isSelected: false),
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerkRow(character: character, perks: perks),
        ),
      );

      // Get border color when not all selected
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.border != null;
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      final borderNotAllSelected = (decoration.border as Border).top.color;

      // Now select the second perk (making all selected)
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();

      final containerAfter = tester.widget<Container>(containerFinder);
      final decorationAfter = containerAfter.decoration as BoxDecoration;
      final borderAllSelected = (decorationAfter.border as Border).top.color;

      // Border color should differ between partial and full selection
      expect(borderNotAllSelected, isNot(equals(borderAllSelected)));
    });
  });

  // ── PerksSection ──

  group('PerksSection', () {
    testWidgets('renders correct number of PerkRow widgets', (tester) async {
      // 3 perks with different details → 3 PerkRow widgets
      final perks = TestData.createPerkList(count: 3);
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
        isEditMode: false,
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerksSection(character: character),
        ),
      );

      expect(find.byType(PerkRow), findsNWidgets(3));
    });

    testWidgets('groups perks with same details into single PerkRow', (
      tester,
    ) async {
      // 3 perks with same text → 1 PerkRow with 3 Checkboxes
      final perks = TestData.createPerkList(
        count: 3,
        sharedDetails: 'Remove two minus one cards',
      );
      final character = TestData.createCharacter();

      final model = await setupModelWithPerks(
        character: character,
        perks: perks,
        perkData: perks
            .map((p) => (perkId: p.perkId, isSelected: false))
            .toList(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          model: model,
          child: PerksSection(character: character),
        ),
      );

      expect(find.byType(PerkRow), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(3));
    });
  });
}

/// Helper typedef for perk data records used by [setupModelWithPerks].
typedef CharacterPerkData = ({String perkId, bool isSelected});
