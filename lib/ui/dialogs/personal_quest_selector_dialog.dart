/// Dialog for selecting a Personal Quest from available quests.
///
/// Displays a scrollable list of quests filtered by edition, showing the
/// quest number, title, and unlock reward (class icon or envelope).
///
/// Returns the selected [PersonalQuest] or null if cancelled.
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';

/// Shows the personal quest selector dialog and returns the selected quest.
Future<PersonalQuest?> showPersonalQuestSelectorDialog({
  required BuildContext context,
  required GameEdition edition,
}) {
  final quests = PersonalQuestsRepository.getByEdition(edition);
  return showModalBottomSheet<PersonalQuest>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _PersonalQuestSelectorSheet(quests: quests),
  );
}

class _PersonalQuestSelectorSheet extends StatelessWidget {
  const _PersonalQuestSelectorSheet({required this.quests});
  final List<PersonalQuest> quests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(largePadding),
            child: Text(
              AppLocalizations.of(context).personalQuest,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const Divider(height: dividerThickness),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: quests.length,
              itemBuilder: (context, index) {
                final quest = quests[index];
                return _PersonalQuestTile(quest: quest);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalQuestTile extends StatelessWidget {
  const _PersonalQuestTile({required this.quest});
  final PersonalQuest quest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(quest.displayName, style: theme.textTheme.bodyLarge),
      trailing: _buildUnlockIcon(context),
      onTap: () => Navigator.pop(context, quest),
    );
  }

  Widget _buildUnlockIcon(BuildContext context) {
    if (quest.unlockClassCode != null) {
      final playerClass = PlayerClasses.playerClasses.firstWhere(
        (c) => c.classCode == quest.unlockClassCode,
      );
      return SizedBox(
        width: iconSizeMedium,
        height: iconSizeMedium,
        child: ClassIconSvg(playerClass: playerClass),
      );
    }
    if (quest.unlockEnvelope != null) {
      return Icon(
        Icons.mail_outline,
        size: iconSizeMedium,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
    return const SizedBox.shrink();
  }
}
