import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

/// A reusable confirmation dialog with customizable content and actions.
///
/// Displays a title, scrollable content, and up to two action buttons.
/// Commonly used for warnings, confirmations, and informational messages.
///
/// ## Example Usage
///
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Delete Character?',
///   content: Text('This action cannot be undone.'),
///   confirmLabel: 'Delete',
///   cancelLabel: 'Cancel',
/// );
///
/// if (confirmed == true) {
///   // User confirmed
/// }
/// ```
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.title,
    required this.content,
    this.confirmLabel = 'Continue',
    this.cancelLabel = 'Cancel',
    this.showCancel = true,
  });

  /// Optional title displayed at the top of the dialog.
  /// If null, no title is shown.
  final String? title;

  /// Main content of the dialog. Wrapped in a SingleChildScrollView.
  final Widget content;

  /// Label for the confirm/primary action button.
  final String confirmLabel;

  /// Label for the cancel/secondary action button.
  final String cancelLabel;

  /// Whether to show the cancel button. Defaults to true.
  final bool showCancel;

  /// Shows the confirmation dialog and returns the user's choice.
  ///
  /// Returns:
  /// - `true` if the user pressed the confirm button
  /// - `false` if the user pressed the cancel button
  /// - `null` if the user dismissed the dialog without choosing
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    required Widget content,
    String confirmLabel = 'Continue',
    String cancelLabel = 'Cancel',
    bool showCancel = true,
  }) {
    return showDialog<bool?>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        showCancel: showCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: title != null
          ? Center(
              child: Text(
                title!,
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            )
          : null,
      content: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.dialogMaxWidth(context),
        ),
        child: SingleChildScrollView(child: content),
      ),
      actions: <Widget>[
        if (showCancel)
          TextButton(
            child: Text(cancelLabel),
            onPressed: () => Navigator.pop(context, false),
          ),
        TextButton(
          child: Text(
            confirmLabel,
            style: TextStyle(color: theme.contrastedPrimary),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
