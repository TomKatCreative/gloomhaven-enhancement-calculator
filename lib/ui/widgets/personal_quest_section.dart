/// Collapsible section displaying a character's Personal Quest and progress.
///
/// Shows the quest title, unlock reward, and requirement progress. In edit
/// mode, allows changing the quest and adjusting progress via +/- buttons.
///
/// ## View Mode
/// - Quest title with unlock class icon
/// - Requirements list with progress text (e.g., "12/20")
///
/// ## Edit Mode
/// - Tappable quest title to change PQ
/// - +/- buttons for each requirement's progress
/// - Prompt to select a quest if none assigned
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/personal_quest_selector_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/strikethrough_text.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class PersonalQuestSection extends StatelessWidget {
  const PersonalQuestSection({required this.character, super.key});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<CharactersModel>();
    final quest = character.personalQuest;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: theme.colorScheme.primary,
          onExpansionChanged: (value) =>
              SharedPrefs().personalQuestExpanded = value,
          initiallyExpanded: SharedPrefs().personalQuestExpanded,
          title: Text(AppLocalizations.of(context).personalQuest),
          children: [
            if (quest != null)
              _QuestContent(character: character, quest: quest, model: model)
            else if (model.isEditMode && !character.isRetired)
              _NoQuestPrompt(character: character, model: model)
            else
              Padding(
                padding: const EdgeInsets.all(largePadding),
                child: Text(
                  AppLocalizations.of(context).noPersonalQuest,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoQuestPrompt extends StatelessWidget {
  const _NoQuestPrompt({required this.character, required this.model});
  final Character character;
  final CharactersModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(largePadding),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        onTap: () => _selectQuest(context),
        child: Container(
          padding: const EdgeInsets.all(mediumPadding),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: dividerThickness,
            ),
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: iconSizeSmall,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: smallPadding),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).selectPersonalQuest,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          InkWell(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            onTap: isEditMode ? () => _changeQuest(context) : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    quest.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (quest.unlockClassCode != null) ...[
                  const SizedBox(width: smallPadding),
                  SizedBox(
                    width: iconSizeMedium,
                    height: iconSizeMedium,
                    child: ClassIconSvg(
                      playerClass: PlayerClasses.playerClasses.firstWhere(
                        (c) => c.classCode == quest.unlockClassCode,
                      ),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else if (quest.unlockEnvelope != null) ...[
                  const SizedBox(width: smallPadding),
                  Icon(
                    Icons.mail_outline,
                    size: iconSizeMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
                if (isEditMode) ...[
                  const SizedBox(width: smallPadding),
                  Icon(
                    Icons.edit,
                    size: iconSizeSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
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
            child: isComplete
                ? StrikethroughText(
                    requirement.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Text(
                    requirement.description,
                    style: theme.textTheme.bodyMedium,
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
                  ? () => model.updatePersonalQuestProgress(
                      character,
                      index,
                      progress - 1,
                    )
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
                  ? () => model.updatePersonalQuestProgress(
                      character,
                      index,
                      progress + 1,
                    )
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
}
