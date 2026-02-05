import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

import 'fake_database_helper.dart';

/// Sets up SharedPreferences with mock values for testing.
///
/// Must be called at the start of each test that uses SharedPrefs.
/// Uses [SharedPreferences.setMockInitialValues] to avoid platform channel issues.
Future<void> setupSharedPreferences({
  bool showRetiredCharacters = true,
  bool darkTheme = false,
  int initialPage = 0,
}) async {
  SharedPreferences.setMockInitialValues({
    'showRetiredCharacters': showRetiredCharacters,
    'darkTheme': darkTheme,
    'initialPage': initialPage,
  });
  await SharedPrefs().init();
}

/// Creates a [CharactersModel] configured for testing.
///
/// Returns a model with:
/// - [FakeDatabaseHelper] for in-memory database operations
/// - [MockThemeProvider] for theme updates
/// - Configurable [showRetired] setting
CharactersModel createTestCharactersModel({
  FakeDatabaseHelper? databaseHelper,
  ThemeProvider? themeProvider,
  bool showRetired = true,
}) {
  return CharactersModel(
    databaseHelper: databaseHelper ?? FakeDatabaseHelper(),
    themeProvider: themeProvider ?? MockThemeProvider(),
    showRetired: showRetired,
  );
}

/// A mock [ThemeProvider] for testing theme color updates.
///
/// Tracks the last seed color set, allowing tests to verify
/// theme synchronization with character colors.
///
/// Note: This extends ThemeProvider and requires SharedPrefs to be initialized
/// before construction. Use [setupSharedPreferences] first.
class MockThemeProvider extends ThemeProvider {
  Color? lastSeedColor;
  int updateCount = 0;

  MockThemeProvider()
    : super(
        initialSeedColor: const Color(0xff4e7ec1),
        initialDarkMode: false,
        initialDefaultFonts: false,
      );

  @override
  void updateSeedColor(Color color) {
    lastSeedColor = color;
    updateCount++;
    // Don't call super to avoid SharedPrefs dependencies in tests
    notifyListeners();
  }

  /// Resets tracking state for test isolation.
  void reset() {
    lastSeedColor = null;
    updateCount = 0;
  }
}

/// Wraps a widget with necessary providers for widget testing.
///
/// Provides:
/// - [ThemeProvider] for theme access
/// - [CharactersModel] for character state
/// - [MaterialApp] wrapper for navigation and theming
///
/// Example:
/// ```dart
/// await tester.pumpWidget(
///   wrapWithProviders(
///     charactersModel: model,
///     child: MyWidget(),
///   ),
/// );
/// ```
Widget wrapWithProviders({
  required Widget child,
  CharactersModel? charactersModel,
  ThemeProvider? themeProvider,
}) {
  final theme = themeProvider ?? MockThemeProvider();
  final characters =
      charactersModel ?? createTestCharactersModel(themeProvider: theme);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ChangeNotifierProvider<CharactersModel>.value(value: characters),
    ],
    child: MaterialApp(home: child),
  );
}

/// Extension methods for common test assertions.
extension CharactersModelTestExtensions on CharactersModel {
  /// Returns the list of UUIDs for all visible characters.
  List<String> get visibleUuids => characters.map((c) => c.uuid).toList();

  /// Returns whether the current character is the one with the given UUID.
  bool isCurrentCharacter(String uuid) => currentCharacter?.uuid == uuid;
}
