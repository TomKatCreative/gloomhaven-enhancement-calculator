import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/home.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  late EnhancementCalculatorModel enhancementModel;
  late int homeBuilds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'initialPage': kCalculatorPageIndex,
      'showUpdate450Dialog': false,
    });
    await SharedPrefs().init();
    homeBuilds = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is Home) homeBuilds++;
    };
  });

  tearDown(() => debugOnRebuildDirtyWidget = null);

  Future<void> pumpHome(WidgetTester tester) async {
    final themeProvider = MockThemeProvider();
    enhancementModel = EnhancementCalculatorModel();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<AppModel>(create: (_) => AppModel()),
          ChangeNotifierProvider<CharactersModel>(
            create: (_) =>
                createTestCharactersModel(themeProvider: themeProvider),
          ),
          ChangeNotifierProvider<EnhancementCalculatorModel>.value(
            value: enhancementModel,
          ),
          ChangeNotifierProvider<TownModel>(
            create: (_) => TownModel(databaseHelper: FakeDatabaseHelper()),
          ),
        ],
        child: MaterialApp(
          theme: themeProvider.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Home(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Home rebuild scope', () {
    testWidgets('a calculator change that keeps the FAB state does not '
        'rebuild Home', (tester) async {
      await pumpHome(tester);
      // Make the cost visible first, so the next change leaves showCost alone.
      enhancementModel.cardLevel = 1;
      await tester.pumpAndSettle();
      expect(enhancementModel.showCost, isTrue);
      homeBuilds = 0;

      enhancementModel.cardLevel = 3;
      await tester.pumpAndSettle();

      expect(enhancementModel.showCost, isTrue);
      expect(homeBuilds, 0);
    });

    testWidgets('a calculator change that hides the FAB rebuilds Home once', (
      tester,
    ) async {
      await pumpHome(tester);
      enhancementModel.cardLevel = 1;
      await tester.pumpAndSettle();
      homeBuilds = 0;

      enhancementModel.isSheetExpanded = true;
      await tester.pumpAndSettle();

      expect(homeBuilds, 1);
    });
  });
}
