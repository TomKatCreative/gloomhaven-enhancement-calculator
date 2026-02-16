/// Section displaying a character's Personal Quest and progress.
///
/// Renders quest content inline — the parent widget provides any card wrapper.
///
/// ## View Mode
/// - Quest title with unlock class icon
/// - Requirements list with progress text (e.g., "12/20")
///
/// ## Edit Mode
/// - Tappable quest title to change PQ
/// - +/- buttons for each requirement's progress
/// - Button to select a quest when none assigned
///
/// ## Retirement Prompt
/// When the last requirement is completed, a dialog prompts the player
/// to retire (per official Gloomhaven rules).
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/personal_quest_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/quest_content.dart';
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
      return Padding(
        padding: const EdgeInsets.only(bottom: largePadding),
        child: Center(
          child: _SelectQuestButton(character: character, model: model),
        ),
      );
    }

    return QuestContent(character: character, quest: quest, model: model);
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
    final result = await PersonalQuestSelectorScreen.show(context);
    if (result is PQSelected && context.mounted) {
      await model.updatePersonalQuest(character, result.quest.id);
    }
  }
}
