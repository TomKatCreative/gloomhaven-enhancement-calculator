/// App-level state management for page navigation.
///
/// [AppModel] is a lightweight ChangeNotifier that handles page navigation
/// state (Town vs Characters vs Calculator). Theme mode and font preference
/// live in [ThemeProvider].
///
/// ## Provider Setup
///
/// This model is set up early in the provider tree and has no dependencies
/// on other providers.
///
/// See also:
/// - [ThemeProvider] for actual theme data generation
/// - `docs/viewmodels_reference.md` for full documentation
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';

/// Manages app-level navigation state: the current page index
/// (0=Town, 1=Characters, 2=Enhancements).
class AppModel extends ChangeNotifier {
  AppModel() {
    final maxPage = kTownSheetEnabled ? 2 : 1;
    final savedPage = SharedPrefs().initialPage.clamp(0, maxPage);
    _page = savedPage;
    pageController = PageController(initialPage: savedPage);
  }

  late final PageController pageController;

  int _page = 0;

  int get page => _page;

  set page(int page) {
    _page = page;
    SharedPrefs().initialPage = page;
    notifyListeners();
  }
}
