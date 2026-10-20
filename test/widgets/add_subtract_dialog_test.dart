import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/add_subtract_dialog.dart';

void main() {
  late int? result;

  Future<void> openDialog(
    WidgetTester tester, {
    required String label,
    Locale? locale,
  }) async {
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showDialog<int?>(
              context: context,
              builder: (_) => AddSubtractDialog(10, label),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lowercases ordinary labels', (tester) async {
    await openDialog(tester, label: 'Gold');
    expect(find.text('Adjust gold'), findsOneWidget);
    expect(find.text('Current: 10'), findsOneWidget);
  });

  testWidgets('keeps acronym labels upper case', (tester) async {
    await openDialog(tester, label: 'XP');
    expect(find.text('Adjust XP'), findsOneWidget);
  });

  testWidgets('shows localized text in Portuguese', (tester) async {
    await openDialog(tester, label: 'Ouro', locale: const Locale('pt'));

    expect(find.text('Ajustar ouro'), findsOneWidget);
    expect(
      find.text('Insira um valor para somar ou subtrair do seu ouro atual'),
      findsOneWidget,
    );
    expect(find.text('Atual: 10'), findsOneWidget);
  });

  testWidgets('add returns the sum', (tester) async {
    await openDialog(tester, label: 'Gold');
    await tester.enterText(find.byType(TextField), '5');
    await tester.pump();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();
    expect(result, 15);
  });

  testWidgets('subtract is floored at 0', (tester) async {
    await openDialog(tester, label: 'Gold');
    await tester.enterText(find.byType(TextField), '25');
    await tester.pump();
    await tester.tap(find.byTooltip('Subtract'));
    await tester.pumpAndSettle();
    expect(result, 0);
  });
}
