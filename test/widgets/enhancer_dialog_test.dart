import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/enhancer_dialog.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('EnhancerDialog', () {
    late EnhancementCalculatorModel model;

    setUp(() async {
      // Frosthaven is the edition that exposes enhancer levels.
      SharedPreferences.setMockInitialValues({
        'gameEdition': GameEdition.frosthaven.index,
        'enhancerLvl1': true,
        'enhancerLvl2': false,
        'enhancerLvl3': false,
        'enhancerLvl4': false,
      });
      await SharedPrefs().init();
      model = EnhancementCalculatorModel();
    });

    Future<void> openDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          withLocalization: true,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => EnhancerDialog(model: model),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders four enhancer level tiles', (tester) async {
      await openDialog(tester);

      // Each tile shows a "Lvl N" title.
      expect(find.text('Lvl 1'), findsOneWidget);
      expect(find.text('Lvl 2'), findsOneWidget);
      expect(find.text('Lvl 3'), findsOneWidget);
      expect(find.text('Lvl 4'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('level 1 is always checked and not interactive', (
      tester,
    ) async {
      await openDialog(tester);

      final checkboxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList();
      expect(checkboxes, hasLength(4));

      // Level 1 is the first checkbox: checked (true) and disabled
      // (onChanged == null since enabled: false in EnhancerDialog).
      expect(checkboxes[0].value, isTrue);
      expect(checkboxes[0].onChanged, isNull);
    });

    testWidgets('toggling level 2 updates the model', (tester) async {
      await openDialog(tester);

      expect(model.enhancerLvl2, isFalse);

      // Find level 2's checkbox and tap it.
      final lvl2Checkbox = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList()[1];
      lvl2Checkbox.onChanged?.call(true);
      await tester.pumpAndSettle();

      expect(model.enhancerLvl2, isTrue);
    });

    testWidgets('Close button dismisses the dialog', (tester) async {
      await openDialog(tester);

      expect(find.byType(EnhancerDialog), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancerDialog), findsNothing);
    });
  });
}
