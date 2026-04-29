import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('InfoDialog', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'gameEdition': GameEdition.frosthaven.index,
      });
      await SharedPrefs().init();
    });

    /// Wraps the dialog launcher with EnhancementCalculatorModel ABOVE the
    /// MaterialApp so dialogs (which open in an overlay) can still resolve
    /// the provider via the same root context.
    Widget buildHost(void Function(BuildContext) onTap) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(
            value: MockThemeProvider(),
          ),
          ChangeNotifierProvider<EnhancementCalculatorModel>(
            create: (_) => EnhancementCalculatorModel(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => onTap(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> openDialog(
      WidgetTester tester, {
      String? title,
      RichText? message,
      EnhancementCategory? category,
    }) async {
      await tester.pumpWidget(
        buildHost((context) {
          showDialog<void>(
            context: context,
            builder: (_) =>
                InfoDialog(title: title, message: message, category: category),
          );
        }),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('title/message mode renders the supplied title text', (
      tester,
    ) async {
      const title = 'Custom Info Title';
      await openDialog(
        tester,
        title: title,
        message: RichText(
          text: const TextSpan(text: 'body', style: TextStyle()),
        ),
      );

      // Title is a plain Text widget.
      expect(find.text(title), findsOneWidget);
    });

    testWidgets(
      'title/message mode wires the supplied RichText into the dialog body',
      (tester) async {
        final message = RichText(
          key: const ValueKey('info-msg'),
          text: const TextSpan(text: 'body', style: TextStyle()),
        );

        await openDialog(tester, title: 'T', message: message);

        // The exact RichText instance should be present in the tree.
        expect(find.byKey(const ValueKey('info-msg')), findsOneWidget);
      },
    );

    testWidgets('Got it! button dismisses the dialog', (tester) async {
      await openDialog(
        tester,
        title: 'Hello',
        message: RichText(
          text: const TextSpan(text: 'world', style: TextStyle()),
        ),
      );

      expect(find.byType(InfoDialog), findsOneWidget);

      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      expect(find.byType(InfoDialog), findsNothing);
    });

    testWidgets('category mode shows the "Eligible for" header', (
      tester,
    ) async {
      await openDialog(tester, category: EnhancementCategory.posEffect);

      expect(find.text('Eligible for'), findsOneWidget);
    });
  });
}
