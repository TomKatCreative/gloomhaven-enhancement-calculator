import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
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

      expect(find.byIcon(Icons.assist_walker), findsNothing);
      expect(find.byIcon(Icons.directions_walk), findsNothing);
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

      // Before retiring: shows assist_walker
      expect(find.byIcon(Icons.assist_walker), findsOneWidget);

      // Tap to retire
      await tester.tap(find.byIcon(Icons.assist_walker));
      await tester.pumpAndSettle();

      // After retiring: edit mode is turned off, so button is hidden
      // This is expected behavior - retiring turns off edit mode
      expect(find.byIcon(Icons.assist_walker), findsNothing);
      expect(find.byIcon(Icons.directions_walk), findsNothing);
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

      final tooltip = find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'Unretire',
      );
      expect(tooltip, findsOneWidget);
    });
  });
}

/// Builds a minimal test app with the AppBar containing retire button.
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
    child: MaterialApp(home: Scaffold(appBar: _TestAppBar())),
  );
}

/// A simplified version of the AppBar that contains just the retire button.
/// This isolates the retirement functionality for testing.
class _TestAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final isEditMode = context.select<CharactersModel, bool>(
      (m) => m.isEditMode,
    );
    final currentCharacter = context.watch<CharactersModel>().currentCharacter;
    final charactersModel = context.read<CharactersModel>();

    return AppBar(
      title: const Text('Test'),
      actions: [
        if (isEditMode && currentCharacter != null)
          Tooltip(
            message: currentCharacter.isRetired ? 'Unretire' : 'Retire',
            child: IconButton(
              icon: Icon(
                currentCharacter.isRetired
                    ? Icons.directions_walk
                    : Icons.assist_walker,
              ),
              onPressed: () async {
                await charactersModel.retireCurrentCharacter();
              },
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
