/// Retirement celebration flow: confetti, snackbar, and confirmation dialog.
///
/// Called when a character completes their personal quest. Shows a confetti
/// burst, then a snackbar with a "Retire" action that opens a confirmation
/// dialog.
library;

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

/// Guards against showing duplicate retirement snackbars.
@visibleForTesting
bool isRetirementSnackBarVisible = false;

/// Shows a retirement celebration: confetti burst + snackbar with Retire action.
void showRetirementSnackBar(
  BuildContext context,
  Character character,
  CharactersModel model,
) {
  if (isRetirementSnackBarVisible) return;
  isRetirementSnackBarVisible = true;
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  _showConfetti(context);
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text(l10n.personalQuestComplete),
          action: SnackBarAction(
            label: l10n.retire,
            textColor: ColorUtils.ensureContrast(
              theme.colorScheme.primary,
              theme.colorScheme.inverseSurface,
            ),
            onPressed: () => _showRetirementDialog(context, character, model),
          ),
        ),
      )
      .closed
      .then((_) => isRetirementSnackBarVisible = false);
}

void _showConfetti(BuildContext context) {
  final overlay = Overlay.of(context);
  final controller = ConfettiController(duration: const Duration(seconds: 1));
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Align(
      alignment: Alignment.bottomCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirection: -pi / 2,
        emissionFrequency: 0.8,
        maxBlastForce: 60,
        minBlastForce: 30,
        blastDirectionality: BlastDirectionality.explosive,
      ),
    ),
  );
  overlay.insert(entry);
  controller.play();
  // Remove overlay after particles settle
  Future.delayed(const Duration(seconds: 6), () {
    entry.remove();
    controller.dispose();
  });
}

Future<void> _showRetirementDialog(
  BuildContext context,
  Character character,
  CharactersModel model,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await ConfirmationDialog.show(
    context: context,
    title: l10n.personalQuestComplete,
    content: Text(l10n.personalQuestCompleteBody(character.name)),
    confirmLabel: l10n.retire,
    cancelLabel: l10n.notYet,
  );
  if (confirmed == true && context.mounted) {
    await model.retireCurrentCharacter();
    if (context.mounted) {
      context.read<AppModel>().updateTheme();
    }
  }
}
