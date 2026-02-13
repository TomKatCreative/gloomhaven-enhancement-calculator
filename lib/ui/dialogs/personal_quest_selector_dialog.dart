/// Dialog for selecting a Personal Quest from available quests.
///
/// Displays a scrollable list of quests filtered by edition, showing the
/// quest number, title, and unlock reward (class icon or envelope).
///
/// Returns a [PQSelectorResult] indicating the user's choice, or null if
/// dismissed.
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';

/// Result type for the personal quest selector dialog.
sealed class PQSelectorResult {}

/// A quest was selected.
class PQSelected extends PQSelectorResult {
  PQSelected(this.quest);
  final PersonalQuest quest;
}

/// The user chose to remove the current quest.
class PQRemoved extends PQSelectorResult {}

/// Shows the personal quest selector dialog and returns the result.
///
/// When [currentQuest] is provided, the sheet title displays the current quest
/// name with a remove button instead of the generic "Personal Quest" heading.
Future<PQSelectorResult?> showPersonalQuestSelectorDialog({
  required BuildContext context,
  required GameEdition edition,
  PersonalQuest? currentQuest,
}) {
  final quests = PersonalQuestsRepository.getByEdition(edition);
  return showModalBottomSheet<PQSelectorResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        _PersonalQuestSelectorSheet(quests: quests, currentQuest: currentQuest),
  );
}

class _PersonalQuestSelectorSheet extends StatelessWidget {
  const _PersonalQuestSelectorSheet({
    required this.quests,
    required this.currentQuest,
  });
  final List<PersonalQuest> quests;
  final PersonalQuest? currentQuest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredQuests = currentQuest != null
        ? quests.where((q) => q.id != currentQuest!.id).toList()
        : quests;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(largePadding),
            child: currentQuest != null
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentQuest!.displayName,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => Navigator.pop(context, PQRemoved()),
                      ),
                    ],
                  )
                : Text(
                    AppLocalizations.of(context).personalQuest,
                    style: theme.textTheme.headlineSmall,
                  ),
          ),
          const Divider(height: dividerThickness),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: filteredQuests.length,
              itemBuilder: (context, index) {
                return _PersonalQuestTile(quest: filteredQuests[index]);
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
      onTap: () => Navigator.pop(context, PQSelected(quest)),
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
