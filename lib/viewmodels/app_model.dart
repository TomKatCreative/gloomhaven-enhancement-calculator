/// App-level state management for navigation and theme preferences.
///
/// [AppModel] is a lightweight ChangeNotifier that handles:
/// - Page navigation state (Characters vs Calculator)
/// - Theme mode (light/dark) preference
/// - Font preference (default vs custom)
///
/// ## Provider Setup
///
/// This model is set up early in the provider tree and has no dependencies
/// on other providers.
///
/// ## State Persistence
///
/// Theme and font preferences are persisted via [SharedPrefs]:
/// - `darkTheme` for theme mode
/// - `useDefaultFonts` for font preference
///
/// See also:
/// - [ThemeProvider] for actual theme data generation
/// - `docs/viewmodels_reference.md` for full documentation
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

/// Manages app-level navigation and theme state.
///
/// This is a lightweight model primarily handling:
/// - Current page index (0=Town, 1=Characters, 2=Enhancements)
/// - Theme mode delegation
/// - Font preference
class AppModel extends ChangeNotifier {
  AppModel() {
    final maxPage = kTownSheetEnabled ? 2 : 1;
    final savedPage = SharedPrefs().initialPage.clamp(0, maxPage);
    _page = savedPage;
    pageController = PageController(initialPage: savedPage);
  }

  late final PageController pageController;
  ThemeMode _themeMode = SharedPrefs().darkTheme
      ? ThemeMode.dark
      : ThemeMode.light;
  bool _useDefaultFonts = SharedPrefs().useDefaultFonts;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  bool get useDefaultFonts => _useDefaultFonts;

  set useDefaultFonts(bool mode) {
    _useDefaultFonts = mode;
    notifyListeners();
  }

  void updateTheme({ThemeMode? themeMode}) {
    if (themeMode != null) {
      _themeMode = themeMode;
    }
    notifyListeners();
  }

  int _page = 0;

  int get page => _page;

  set page(int page) {
    _page = page;
    SharedPrefs().initialPage = page;
    notifyListeners();
  }
}
