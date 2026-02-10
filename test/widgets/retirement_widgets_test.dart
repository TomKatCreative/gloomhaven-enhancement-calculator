import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_animated_app_bar.dart';
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

      expect(find.byIcon(Icons.assist_walker), findsNothing);
      expect(find.byIcon(Icons.delete_rounded), findsNothing);
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

      await tester.tap(find.byIcon(Icons.assist_walker));
      await tester.pumpAndSettle();

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

      // After retiring: _handleRetire exits edit mode, so retire/delete
      // buttons are no longer in the app bar.
      // Re-enter edit mode to see the updated icon.
      model.isEditMode = true;
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.byIcon(Icons.assist_walker), findsNothing);
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

/// Builds a minimal test app with GHCAnimatedAppBar in a Scaffold.
/// Sets appModel.page = 1 so retire/delete actions appear when in edit mode.
Widget _buildTestApp({
  required CharactersModel model,
  required MockThemeProvider themeProvider,
}) {
  final appModel = AppModel();
  appModel.page = 1;

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeProvider),
      ChangeNotifierProvider.value(value: model),
      ChangeNotifierProvider.value(value: appModel),
      ChangeNotifierProvider(create: (_) => EnhancementCalculatorModel()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(appBar: GHCAnimatedAppBar()),
    ),
  );
}
