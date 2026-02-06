import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/backup_dialog.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BackupDialog', () {
    setUp(() async {
      await setupSharedPreferences();
    });

    Future<void> openDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          withLocalization: true,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => BackupDialog.show(context: context),
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

    testWidgets('renders filename field, Cancel and Save buttons', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('default filename contains ghc_backup_ prefix', (tester) async {
      await openDialog(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      final text = textField.controller!.text;
      expect(text, startsWith('ghc_backup_'));
    });

    testWidgets('default filename contains date in expected format', (
      tester,
    ) async {
      await openDialog(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      final text = textField.controller!.text;
      // Format: ghc_backup_YYYY-MM-DD_HH-mm
      expect(
        text,
        matches(RegExp(r'^ghc_backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}$')),
      );
    });

    testWidgets('empty filename shows validation error', (tester) async {
      await openDialog(tester);

      // Clear the filename
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Filename cannot be empty'), findsOneWidget);
    });

    testWidgets('typing after validation error clears it', (tester) async {
      await openDialog(tester);

      // Trigger validation error
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Filename cannot be empty'), findsOneWidget);

      // Type something - error should clear
      await tester.enterText(find.byType(TextField), 'my_backup');
      await tester.pumpAndSettle();
      expect(find.text('Filename cannot be empty'), findsNothing);
    });

    testWidgets('special characters are filtered from filename input', (
      tester,
    ) async {
      await openDialog(tester);

      // Try entering text with special characters
      await tester.enterText(find.byType(TextField), 'test#file<name>');
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final text = textField.controller!.text;
      // The special chars #, <, > should be filtered out
      expect(text, 'testfilename');
    });

    testWidgets('Cancel returns BackupAction.cancelled', (tester) async {
      BackupResult? result;

      await tester.pumpWidget(
        wrapWithProviders(
          withLocalization: true,
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await BackupDialog.show(context: context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.action, BackupAction.cancelled);
      expect(result!.savedPath, isNull);
    });

    testWidgets('no warning icon or Choose location button', (tester) async {
      await openDialog(tester);

      expect(find.byIcon(Icons.warning_rounded), findsNothing);
      expect(find.text('Choose location...'), findsNothing);
    });

    testWidgets('no backup file warning text', (tester) async {
      await openDialog(tester);

      // The old Android-only warning about overwriting files should not exist
      expect(find.textContaining('overwritten'), findsNothing);
    });
  });
}
