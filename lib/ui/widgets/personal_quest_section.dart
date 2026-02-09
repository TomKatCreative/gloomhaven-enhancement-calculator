/// Collapsible section displaying a character's Personal Quest and progress.
///
/// Shows the quest title, unlock reward, and requirement progress. In edit
/// mode, allows changing the quest and adjusting progress via +/- buttons.
///
/// ## View Mode
/// - Quest title with unlock class icon in header
/// - Requirements list with progress text (e.g., "12/20")
///
/// ## Edit Mode
/// - Tappable quest title to change PQ
/// - +/- buttons for each requirement's progress
/// - TextFormField selector when no quest assigned
///
/// ## Retirement Prompt
/// When the last requirement is completed, a dialog prompts the player
/// to retire (per official Gloomhaven rules).
library;

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/personal_quest_selector_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/blurred_expansion_container.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/utils/utils.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class PersonalQuestSection extends StatelessWidget {
  const PersonalQuestSection({required this.character, super.key});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CharactersModel>();
    final quest = character.personalQuest;

    // No quest assigned: show select button (hidden for retired characters)
    if (quest == null) {
      if (character.isRetired) return const SizedBox.shrink();
      return Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _SelectQuestButton(character: character, model: model),
      );
    }

    // Quest assigned: show ExpansionTile with blur
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: BlurredExpansionContainer(
        initiallyExpanded: SharedPrefs().personalQuestExpanded,
        onExpansionChanged: (value) =>
            SharedPrefs().personalQuestExpanded = value,
        title: Text(AppLocalizations.of(context).personalQuest),
        children: [
          _QuestContent(character: character, quest: quest, model: model),
        ],
      ),
    );
  }
}

class _SelectQuestButton extends StatelessWidget {
  const _SelectQuestButton({required this.character, required this.model});
  final Character character;
  final CharactersModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(
      context,
    ).extension<AppThemeExtension>()!.contrastedPrimary;
    return OutlinedButton.icon(
      onPressed: () => _selectQuest(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
      ),
      icon: const Icon(Icons.add_rounded, size: iconSizeSmall),
      label: Text(l10n.selectAPersonalQuest),
    );
  }

  Future<void> _selectQuest(BuildContext context) async {
    final quest = await showPersonalQuestSelectorDialog(
      context: context,
      edition: GameEdition.gloomhaven,
    );
    if (quest != null && context.mounted) {
      await model.updatePersonalQuest(character, quest.id);
    }
  }
}

class _QuestContent extends StatelessWidget {
  const _QuestContent({
    required this.character,
    required this.quest,
    required this.model,
  });
  final Character character;
  final PersonalQuest quest;
  final CharactersModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = model.isEditMode && !character.isRetired;

    return Padding(
      padding: const EdgeInsets.only(
        left: largePadding,
        right: largePadding,
        bottom: largePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest title row
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.titleMedium,
                    children: [
                      TextSpan(text: '${quest.number}: ${quest.title}'),
                      if (quest.unlockClassCode != null) ...[
                        const TextSpan(text: ' · '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox(
                            width: iconSizeMedium,
                            height: iconSizeMedium,
                            child: ClassIconSvg(
                              playerClass: PlayerClasses.playerClasses
                                  .firstWhere(
                                    (c) => c.classCode == quest.unlockClassCode,
                                  ),
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ] else if (quest.unlockEnvelope != null) ...[
                        const TextSpan(text: ' · '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.mail_outline,
                            size: iconSizeMedium,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isEditMode)
                IconButton(
                  iconSize: iconSizeSmall,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(tinyPadding),
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _changeQuest(context),
                ),
            ],
          ),
          const SizedBox(height: mediumPadding),
          // Requirements list
          ...List.generate(quest.requirements.length, (index) {
            final req = quest.requirements[index];
            final progress = index < character.personalQuestProgress.length
                ? character.personalQuestProgress[index]
                : 0;
            return _RequirementRow(
              requirement: req,
              progress: progress,
              index: index,
              character: character,
              model: model,
              isEditMode: isEditMode,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _changeQuest(BuildContext context) async {
    // Show warning dialog
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: AppLocalizations.of(context).changePersonalQuest,
      content: Text(AppLocalizations.of(context).changePersonalQuestBody),
      confirmLabel: AppLocalizations.of(context).change,
      cancelLabel: AppLocalizations.of(context).cancel,
    );
    if (confirmed != true || !context.mounted) return;

    final newQuest = await showPersonalQuestSelectorDialog(
      context: context,
      edition: GameEdition.gloomhaven,
    );
    if (newQuest != null && context.mounted) {
      await model.updatePersonalQuest(character, newQuest.id);
    }
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.requirement,
    required this.progress,
    required this.index,
    required this.character,
    required this.model,
    required this.isEditMode,
  });

  final PersonalQuestRequirement requirement;
  final int progress;
  final int index;
  final Character character;
  final CharactersModel model;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = progress >= requirement.target;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: tinyPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: iconSizeSmall,
            color: isComplete
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: smallPadding),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isComplete ? theme.disabledColor : null,
                  ),
                  children: Utils.generateCheckRowDetails(
                    context,
                    requirement.description,
                    theme.brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: smallPadding),
          if (isEditMode) ...[
            IconButton(
              iconSize: iconSizeSmall,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(tinyPadding),
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: progress > 0
                  ? () => _updateProgress(context, progress - 1)
                  : null,
            ),
            SizedBox(
              width: 40,
              child: Text(
                AppLocalizations.of(
                  context,
                ).progressOf(progress, requirement.target),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              iconSize: iconSizeSmall,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(tinyPadding),
              icon: const Icon(Icons.add_circle_outline),
              onPressed: progress < requirement.target
                  ? () => _updateProgress(context, progress + 1)
                  : null,
            ),
          ] else
            Text(
              AppLocalizations.of(
                context,
              ).progressOf(progress, requirement.target),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isComplete
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateProgress(BuildContext context, int newValue) async {
    final justCompleted = await model.updatePersonalQuestProgress(
      character,
      index,
      newValue,
    );
    if (justCompleted && context.mounted) {
      _showRetirementSnackBar(context);
    }
  }

  void _showRetirementSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _showConfetti(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.personalQuestComplete),
        action: SnackBarAction(
          label: l10n.retire,
          onPressed: () => _showRetirementDialog(context),
        ),
      ),
    );
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

  Future<void> _showRetirementDialog(BuildContext context) async {
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
}
