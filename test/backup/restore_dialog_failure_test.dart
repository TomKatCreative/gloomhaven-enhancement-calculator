import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations_en.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/restore_dialog.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_helpers.dart';
import '../migration/harness/ffi.dart';
import '../migration/harness/harness.dart';
import 'backup_harness.dart';

/// A characters source that fails every load, standing in for restored rows
/// the app can't read.
class _FailingLoadDatabaseHelper extends FakeDatabaseHelper {
  int loads = 0;

  @override
  Future<List<Character>> queryAllCharacters() async {
    loads++;
    throw StateError('load failed');
  }
}

/// Which error message [RestoreDialog.performRestore] shows, depending on
/// whether the backup had already been applied when something failed.
void main() {
  final l10n = AppLocalizationsEn();

  setUpAll(() {
    initMigrationHarness();
    useFfiSqlite();
  });

  setUp(setupSharedPreferences);
  tearDown(closeApp);

  Future<void> runRestore(
    WidgetTester tester,
    String contents,
    FakeDatabaseHelper databaseHelper,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => EnhancementCalculatorModel(),
        child: wrapWithProviders(
          withLocalization: true,
          charactersModel: createTestCharactersModel(
            databaseHelper: databaseHelper,
          ),
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () =>
                    RestoreDialog.performRestore(context, contents),
                child: const Text('Restore'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Restore'));
    // The restore does real SQLite I/O, which fake async time can't drive.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a rejected backup says nothing was changed', (tester) async {
    await tester.runAsync(freshAppDatabase);
    final databaseHelper = _FailingLoadDatabaseHelper();

    await runRestore(tester, 'not json', databaseHelper);

    expect(
      find.textContaining(l10n.restoreErrorMessage('').trim()),
      findsOneWidget,
    );
    expect(databaseHelper.loads, 1, reason: 'characters are reloaded');
  });

  testWidgets('a failure after the restore committed says it was applied', (
    tester,
  ) async {
    final backup = (await tester.runAsync(() async {
      await freshAppDatabase();
      return generate();
    }))!;
    final databaseHelper = _FailingLoadDatabaseHelper();

    await runRestore(tester, backup, databaseHelper);

    expect(
      find.textContaining(l10n.restoreAppliedErrorMessage('').trim()),
      findsOneWidget,
    );
  });
}
