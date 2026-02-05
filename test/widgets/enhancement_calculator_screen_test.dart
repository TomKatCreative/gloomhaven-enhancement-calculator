import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/enhancement_calculator_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/cost_display.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/expandable_cost_chip.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_helpers.dart';

/// Sets up SharedPrefs and returns a fully wired calculator screen widget.
Future<Widget> buildCalculatorScreen({
  GameEdition edition = GameEdition.gloomhaven,
  bool partyBoon = false,
  bool enhancerLvl2 = false,
  bool enhancerLvl3 = false,
  bool enhancerLvl4 = false,
  bool hailsDiscount = false,
  bool temporaryEnhancementMode = false,
}) async {
  final values = <String, Object>{
    'gameEdition': edition.index,
    'showRetiredCharacters': true,
  };
  if (partyBoon) values['partyBoon'] = true;
  if (hailsDiscount) values['hailsDiscount'] = true;
  if (temporaryEnhancementMode) values['temporaryEnhancementMode'] = true;
  if (enhancerLvl2) {
    values['enhancerLvl1'] = true;
    values['enhancerLvl2'] = true;
  }
  if (enhancerLvl3) {
    values['enhancerLvl1'] = true;
    values['enhancerLvl2'] = true;
    values['enhancerLvl3'] = true;
  }
  if (enhancerLvl4) {
    values['enhancerLvl1'] = true;
    values['enhancerLvl2'] = true;
    values['enhancerLvl3'] = true;
    values['enhancerLvl4'] = true;
  }
  SharedPreferences.setMockInitialValues(values);
  await SharedPrefs().init();

  final themeProvider = MockThemeProvider();
  final charactersModel = CharactersModel(
    databaseHelper: FakeDatabaseHelper(),
    themeProvider: themeProvider,
    showRetired: true,
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EnhancementCalculatorModel>(
        create: (_) => EnhancementCalculatorModel(),
      ),
      ChangeNotifierProvider<CharactersModel>.value(value: charactersModel),
      ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        dividerTheme: const DividerThemeData(color: Colors.grey),
      ),
      home: const Scaffold(body: EnhancementCalculatorScreen()),
    ),
  );
}

/// Lightweight SharedPrefs setup without widget building (for model-only checks).
Future<void> _setupPrefsOnly({
  GameEdition edition = GameEdition.gloomhaven,
}) async {
  SharedPreferences.setMockInitialValues({
    'gameEdition': edition.index,
    'showRetiredCharacters': true,
  });
  await SharedPrefs().init();
}

void main() {
  group('EnhancementCalculatorScreen', () {
    group('Section headers', () {
      testWidgets('Enhancement header visible', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('Enhancement'), findsOneWidget);
      });

      testWidgets('Card details header visible', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('Card details'), findsOneWidget);
      });

      testWidgets('Discounts header visible', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        // May need scrolling
        final discountsFinder = find.text('Discounts');
        await tester.ensureVisible(discountsFinder);
        await tester.pumpAndSettle();
        expect(discountsFinder, findsOneWidget);
      });
    });

    group('Enhancement Type Card', () {
      testWidgets('info button disabled when no enhancement selected', (
        tester,
      ) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        // The first IconButton in the tree is the enhancement type info button
        final iconButtons = find.byType(IconButton);
        expect(iconButtons, findsWidgets);

        final firstInfoButton = tester.widget<IconButton>(iconButtons.first);
        expect(firstInfoButton.onPressed, isNull);
      });
    });

    group('Card Level Section', () {
      testWidgets('card level label shows "Card level: 1" initially', (
        tester,
      ) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('Card level: 1'), findsOneWidget);
      });

      testWidgets('cost displays present', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.byType(CostDisplay), findsWidgets);
      });
    });

    group('Previous Enhancements Section', () {
      testWidgets('previous enhancements label visible', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('Previous enhancements'), findsOneWidget);
      });

      testWidgets('segmented button with None, 1, 2, 3 visible', (
        tester,
      ) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('None'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('tapping segmented button changes previous enhancements', (
        tester,
      ) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        final model = tester
            .element(find.byType(EnhancementCalculatorScreen))
            .read<EnhancementCalculatorModel>();
        expect(model.previousEnhancements, 2);
      });
    });

    group('Modifier Toggles', () {
      testWidgets('multiple targets switch visible in GH', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('Multiple targets'), findsOneWidget);
      });

      testWidgets('multiple targets switch visible in FH', (tester) async {
        await tester.pumpWidget(
          await buildCalculatorScreen(edition: GameEdition.frosthaven),
        );
        await tester.pumpAndSettle();

        expect(find.text('Multiple targets'), findsOneWidget);
      });

      testWidgets('lost toggle hidden in GH', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        // In GH, the lost toggle subtitle text should not appear
        expect(find.text('Lost action'), findsNothing);
        expect(find.text('Lost & non-persistent'), findsNothing);
      });

      testWidgets('persistent toggle hidden in GH', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.text('Persistent'), findsNothing);
      });

      testWidgets('persistent toggle hidden in GH2E', (tester) async {
        await tester.pumpWidget(
          await buildCalculatorScreen(edition: GameEdition.gloomhaven2e),
        );
        await tester.pumpAndSettle();

        expect(find.text('Persistent'), findsNothing);
      });
    });

    group('Discounts Section', () {
      testWidgets('Temporary Enhancement toggle visible in GH', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        final finder = find.textContaining('Temporary enhancements');
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        expect(finder, findsOneWidget);
      });

      testWidgets("Hail's Discount toggle visible in GH", (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        final finder = find.textContaining("Hail's discount");
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        expect(finder, findsOneWidget);
      });

      testWidgets('Party Boon toggle visible in GH', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        final finder = find.textContaining('Scenario 114 reward');
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        expect(finder, findsOneWidget);
      });

      testWidgets('Party Boon configured for GH2E via model', (tester) async {
        // GH2E renders SVG-based toggles (lost action) that need real assets,
        // so verify edition support via model instead of widget rendering
        await _setupPrefsOnly(edition: GameEdition.gloomhaven2e);
        expect(GameEdition.gloomhaven2e.supportsPartyBoon, isTrue);
      });

      testWidgets('Party Boon toggle hidden in FH', (tester) async {
        await tester.pumpWidget(
          await buildCalculatorScreen(edition: GameEdition.frosthaven),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Scenario 114 reward'), findsNothing);
      });

      testWidgets('Building 44 configured for FH via model', (tester) async {
        // FH renders SVG-based toggles (lost + persistent) that need real assets,
        // so verify edition support via model instead of widget rendering
        await _setupPrefsOnly(edition: GameEdition.frosthaven);
        expect(GameEdition.frosthaven.hasEnhancerLevels, isTrue);
      });

      testWidgets('Building 44 hidden in GH', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.textContaining('Building 44'), findsNothing);
      });

      testWidgets('Building 44 hidden in GH2E', (tester) async {
        // GH2E has SVG toggles that prevent full rendering, but we can verify
        // the edition flag that controls Building 44 visibility
        await _setupPrefsOnly(edition: GameEdition.gloomhaven2e);
        expect(GameEdition.gloomhaven2e.hasEnhancerLevels, isFalse);
      });

      testWidgets('toggling temporary enhancement recalculates cost', (
        tester,
      ) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        // Set previous enhancements to 1 first
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        final model = tester
            .element(find.byType(EnhancementCalculatorScreen))
            .read<EnhancementCalculatorModel>();
        expect(model.totalCost, 75);

        // Tap temporary enhancement toggle
        final tempFinder = find.textContaining('Temporary enhancements');
        await tester.ensureVisible(tempFinder);
        await tester.pumpAndSettle();
        await tester.tap(tempFinder);
        await tester.pumpAndSettle();

        expect(model.temporaryEnhancementMode, isTrue);
        // 75 - 20 = 55, then ceil(55 * 0.8) = ceil(44) = 44
        expect(model.totalCost, 44);
      });

      testWidgets("toggling Hail's discount recalculates cost", (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        // Set previous enhancements to 1
        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        // Tap Hail's discount
        final hailsFinder = find.textContaining("Hail's discount");
        await tester.ensureVisible(hailsFinder);
        await tester.pumpAndSettle();
        await tester.tap(hailsFinder);
        await tester.pumpAndSettle();

        final model = tester
            .element(find.byType(EnhancementCalculatorScreen))
            .read<EnhancementCalculatorModel>();
        expect(model.hailsDiscount, isTrue);
      });
    });

    group('Cost Chip', () {
      testWidgets('cost chip hidden when showCost is false', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        expect(find.byType(ExpandableCostChip), findsNothing);
      });

      testWidgets('cost chip appears when previous enhancements selected', (
        tester,
      ) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('1'));
        await tester.pumpAndSettle();

        expect(find.byType(ExpandableCostChip), findsOneWidget);
      });

      testWidgets('cost chip shows total cost', (tester) async {
        await tester.pumpWidget(await buildCalculatorScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('2'));
        await tester.pumpAndSettle();

        // 2 previous enhancements = 150g
        expect(find.text('150g'), findsWidgets);
      });
    });
  });
}
