import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

/// A dialog for solving envelope puzzles (Envelope X and Envelope V).
///
/// Prompts the user to enter a solution/password and validates it against
/// the expected answer before allowing confirmation.
///
/// ## Example Usage
///
/// ```dart
/// final solved = await EnvelopePuzzleDialog.show(
///   context: context,
///   promptText: AppLocalizations.of(context).enterSolution,
///   inputLabel: AppLocalizations.of(context).solution,
///   correctAnswer: 'bladeswarm',
///   successButtonText: AppLocalizations.of(context).solve,
/// );
///
/// if (solved == true) {
///   // Puzzle was solved correctly
/// }
/// ```
class EnvelopePuzzleDialog extends StatefulWidget {
  const EnvelopePuzzleDialog({
    super.key,
    required this.promptText,
    required this.inputLabel,
    required this.correctAnswer,
    required this.successButtonText,
  });

  /// The text displayed above the input field explaining what to enter.
  final String promptText;

  /// The label for the text input field.
  final String inputLabel;

  /// The correct answer (case-insensitive, trimmed).
  final String correctAnswer;

  /// The label for the success/confirm button.
  final String successButtonText;

  /// Shows the envelope puzzle dialog and returns the result.
  ///
  /// Returns:
  /// - `true` if the user entered the correct answer and confirmed
  /// - `false` if the user cancelled
  /// - `null` if the dialog was dismissed
  static Future<bool?> show({
    required BuildContext context,
    required String promptText,
    required String inputLabel,
    required String correctAnswer,
    required String successButtonText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => EnvelopePuzzleDialog(
        promptText: promptText,
        inputLabel: inputLabel,
        correctAnswer: correctAnswer,
        successButtonText: successButtonText,
      ),
    );
  }

  @override
  State<EnvelopePuzzleDialog> createState() => _EnvelopePuzzleDialogState();
}

class _EnvelopePuzzleDialogState extends State<EnvelopePuzzleDialog> {
  bool _isSolved = false;

  void _onTextChanged(String value) {
    setState(() {
      _isSolved =
          value.toLowerCase().trim() == widget.correctAnswer.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      content: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.dialogMaxWidth(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.promptText),
            const SizedBox(height: smallPadding),
            TextField(
              autofocus: true,
              onChanged: _onTextChanged,
              decoration: InputDecoration(labelText: widget.inputLabel),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context).cancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          onPressed: _isSolved ? () => Navigator.of(context).pop(true) : null,
          child: Text(
            widget.successButtonText,
            style: TextStyle(
              color: _isSolved ? theme.contrastedPrimary : theme.disabledColor,
            ),
          ),
        ),
      ],
    );
  }
}
