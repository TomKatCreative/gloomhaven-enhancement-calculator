/// Quest title, unlock reward, and requirements list for an assigned quest.
///
/// Shows the quest display number, title, and unlock icon (class icon or
/// envelope letter). Below the title, generates one [RequirementRow] per
/// requirement with "Then" locking logic for sequential requirements.
///
/// In edit mode, a swap button lets the player change or remove the quest.
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/personal_quest_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/requirement_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/retirement_prompt.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';

class QuestContent extends StatelessWidget {
  const QuestContent({
    required this.character,
    required this.quest,
    required this.model,
    super.key,
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
        right: mediumPadding,
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
                      TextSpan(text: '${quest.displayNumber}: ${quest.title}'),
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
                        if (quest.unlockEnvelope!.length == 1)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Text(
                              quest.unlockEnvelope!,
                              style: TextStyle(
                                fontFamily: 'PirataOne',
                                fontWeight: FontWeight.normal,
                                fontSize: iconSizeMedium,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        else ...[
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: ThemedSvg(
                              assetKey: 'ENVELOPE',
                              width: iconSizeSmall,
                            ),
                          ),
                          envelopeTextSpan(
                            ' ${quest.unlockEnvelope}',
                            theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
            final isLocked =
                index > 0 &&
                req.description.startsWith('Then ') &&
                quest.requirements
                    .take(index)
                    .indexed
                    .any(
                      (pair) => pair.$1 < character.personalQuestProgress.length
                          ? character.personalQuestProgress[pair.$1] <
                                pair.$2.target
                          : true,
                    );
            return RequirementRow(
              requirement: req,
              progress: progress,
              index: index,
              character: character,
              model: model,
              isEditMode: isEditMode,
              isLocked: isLocked,
              onQuestCompleted: () =>
                  showRetirementSnackBar(context, character, model),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _changeQuest(BuildContext context) async {
    final result = await PersonalQuestSelectorScreen.show(
      context,
      currentQuest: quest,
    );
    if (!context.mounted) return;
    switch (result) {
      case PQSelected(:final quest):
        await model.updatePersonalQuest(character, quest.id);
      case PQRemoved():
        await model.updatePersonalQuest(character, null);
      case null:
        break;
    }
  }
}
