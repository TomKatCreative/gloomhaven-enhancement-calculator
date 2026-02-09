import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/expandable_fab.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

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

  group('Retire Button Icon', () {
    testWidgets('shows retire icon (assist_walker) for active character', (
      tester,
    ) async {
      final character = TestData.createCharacter(isRetired: false);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      // Find the retire button by its icon
      expect(find.byIcon(Icons.assist_walker), findsOneWidget);
      expect(find.byIcon(Icons.directions_walk), findsNothing);
    });

    testWidgets('shows unretire icon (directions_walk) for retired character', (
      tester,
    ) async {
      final character = TestData.createCharacter(isRetired: true);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.byIcon(Icons.assist_walker), findsNothing);
    });

    testWidgets('retire button not visible when not in edit mode', (
      tester,
    ) async {
      final character = TestData.createCharacter(isRetired: false);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = false;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      // The action buttons are in the tree but not tappable (IgnorePointer)
      // when the FAB is closed
      final ignorePointers = find.ancestor(
        of: find.byIcon(Icons.assist_walker),
        matching: find.byType(IgnorePointer),
      );
      // Find the closest IgnorePointer (the one from _ExpandingActionButton)
      final ignorePointerWidget = tester.widget<IgnorePointer>(
        ignorePointers.first,
      );
      expect(ignorePointerWidget.ignoring, isTrue);
    });

    testWidgets('tapping retire button calls retireCurrentCharacter', (
      tester,
    ) async {
      final character = TestData.createCharacter(
        uuid: 'tap-test',
        isRetired: false,
      );
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      // Tap the retire button
      await tester.tap(find.byIcon(Icons.assist_walker));
      await tester.pumpAndSettle();

      // Verify the character was retired
      expect(model.currentCharacter!.isRetired, isTrue);
      expect(fakeDb.updateCalls, contains('tap-test'));
    });

    testWidgets('icon changes after retiring', (tester) async {
      final character = TestData.createCharacter(isRetired: false);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      // Before retiring: shows assist_walker
      expect(find.byIcon(Icons.assist_walker), findsOneWidget);

      // Tap to retire
      await tester.tap(find.byIcon(Icons.assist_walker));
      await tester.pumpAndSettle();

      // After retiring: edit mode is turned off, so action buttons are
      // not tappable (IgnorePointer). The widget now shows directions_walk
      // since the character is retired.
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      final ignorePointers = find.ancestor(
        of: find.byIcon(Icons.directions_walk),
        matching: find.byType(IgnorePointer),
      );
      final ignorePointerWidget = tester.widget<IgnorePointer>(
        ignorePointers.first,
      );
      expect(ignorePointerWidget.ignoring, isTrue);
    });
  });

  group('Retire Button Tooltip', () {
    testWidgets('shows "Retire" tooltip for active character', (tester) async {
      final character = TestData.createCharacter(isRetired: false);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      // Find the Tooltip with 'Retire' message
      final tooltip = find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'Retire',
      );
      expect(tooltip, findsOneWidget);
    });

    testWidgets('shows "Unretire" tooltip for retired character', (
      tester,
    ) async {
      final character = TestData.createCharacter(isRetired: true);
      fakeDb.characters = [character];
      final model = createModel();
      await model.loadCharacters();
      model.isEditMode = true;

      await tester.pumpWidget(
        _buildTestApp(model: model, themeProvider: mockTheme),
      );
      await tester.pumpAndSettle();

      final tooltip = find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'Unretire',
      );
      expect(tooltip, findsOneWidget);
    });
  });
}

/// Builds a minimal test app with an ExpandableFab containing retire button.
Widget _buildTestApp({
  required CharactersModel model,
  required MockThemeProvider themeProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeProvider),
      ChangeNotifierProvider.value(value: model),
      ChangeNotifierProvider(create: (_) => AppModel()),
      ChangeNotifierProvider(create: (_) => EnhancementCalculatorModel()),
    ],
    child: MaterialApp(home: _TestFabScaffold()),
  );
}

/// A simplified scaffold with the ExpandableFab containing retire/delete buttons.
/// This isolates the retirement functionality for testing.
class _TestFabScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final charactersModel = context.watch<CharactersModel>();
    final isRetired = charactersModel.currentCharacter?.isRetired ?? false;

    return Scaffold(
      floatingActionButton: ExpandableFab(
        isOpen: charactersModel.isEditMode,
        onToggle: (open) => charactersModel.isEditMode = open,
        openIcon: const Icon(Icons.edit_rounded),
        closeIcon: const Icon(Icons.edit_off_rounded),
        children: [
          ActionButton(
            tooltip: isRetired ? 'Unretire' : 'Retire',
            icon: Icon(isRetired ? Icons.directions_walk : Icons.assist_walker),
            onPressed: () async {
              await charactersModel.retireCurrentCharacter();
            },
          ),
          ActionButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_rounded),
            color: Theme.of(context).colorScheme.errorContainer,
            iconColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
