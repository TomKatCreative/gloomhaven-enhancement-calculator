import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/custom_class_warning_dialog.dart';

void main() {
  late bool? result;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefs().init();
    result = null;
  });

  /// Pumps a button that opens the dialog, then opens it.
  Future<void> openDialog(WidgetTester tester, {Locale? locale}) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await CustomClassWarningDialog.show(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows localized text in Portuguese', (tester) async {
    await openDialog(tester, locale: const Locale('pt'));

    expect(find.text('Classes personalizadas'), findsOneWidget);
    expect(find.text('Não mostrar novamente'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Custom classes'), findsNothing);
  });

  testWidgets('Continue returns true', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('Cancel returns false', (tester) async {
    await openDialog(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets("Don't show again persists the preference", (tester) async {
    await openDialog(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(SharedPrefs().hideCustomClassesWarningMessage, isTrue);
  });
}
