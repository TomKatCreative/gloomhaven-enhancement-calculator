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

    testWidgets('renders filename field, Cancel, Share, and Save buttons', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('default filename is ghc_backup', (tester) async {
      await openDialog(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'ghc_backup');
    });

    testWidgets('shows .json suffix on filename field', (tester) async {
      await openDialog(tester);

      expect(find.text('.json'), findsOneWidget);
    });

    testWidgets('empty filename shows validation error', (tester) async {
      await openDialog(tester);

      // Clear the filename
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Cannot be empty'), findsOneWidget);
    });

    testWidgets('typing after validation error clears it', (tester) async {
      await openDialog(tester);

      // Trigger validation error
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Cannot be empty'), findsOneWidget);

      // Type something - error should clear
      await tester.enterText(find.byType(TextField), 'my_backup');
      await tester.pumpAndSettle();
      expect(find.text('Cannot be empty'), findsNothing);
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

    testWidgets('all buttons are enabled initially', (tester) async {
      await openDialog(tester);

      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Cancel'),
      );
      final shareButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Share'),
      );
      final saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );

      expect(cancelButton.onPressed, isNotNull);
      expect(shareButton.onPressed, isNotNull);
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('no loading indicator is shown initially', (tester) async {
      await openDialog(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('empty filename does not show loading indicator on Save tap', (
      tester,
    ) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Buttons should remain enabled since validation failed
      final saveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('empty filename does not show loading indicator on Share tap', (
      tester,
    ) async {
      await openDialog(tester);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Share'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      final shareButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Share'),
      );
      expect(shareButton.onPressed, isNotNull);
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
      expect(result!.savedFilename, isNull);
    });
  });
}
