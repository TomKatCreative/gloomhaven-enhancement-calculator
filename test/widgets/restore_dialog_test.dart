import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/restore_dialog.dart';

import '../helpers/test_helpers.dart';

/// Tests for the [RestoreDialog] confirmation flow.
///
/// We deliberately do NOT exercise the file-picker / restore code path —
/// `FilePicker.pickFiles()` needs platform channels that aren't available in
/// unit tests. The confirmation dialog
/// itself is the most likely regression surface (button labels, warning
/// text), and that's what these tests cover.
void main() {
  group('RestoreDialog confirmation flow', () {
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
                onPressed: () => RestoreDialog.show(context: context),
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

    testWidgets('shows warning text with Cancel and Continue buttons', (
      tester,
    ) async {
      await openDialog(tester);

      // The l10n key restoreWarning renders as the dialog body. We don't
      // hardcode the wording (translations may shift) — we just assert
      // there's an AlertDialog visible with the expected actions.
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Cancel dismisses without progressing further', (tester) async {
      await openDialog(tester);

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // No new dialog should appear after cancel — the confirmation closes
      // and the flow ends.
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('warning content has the expected structure', (tester) async {
      await openDialog(tester);

      // The warning is wrapped in a Container with a max-width constraint
      // (responsive design). Verify it's not just an empty dialog.
      final alert = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alert.content, isNotNull);
      expect(alert.actions, isNotNull);
      expect(alert.actions, hasLength(2));
    });
  });
}
