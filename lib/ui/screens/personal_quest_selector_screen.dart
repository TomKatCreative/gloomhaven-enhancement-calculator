/// Full-page screen for selecting a Personal Quest.
///
/// Displays all available quests grouped by [GameEdition], with search
/// functionality. Each quest shows its number, title, and unlock reward.
///
/// ## Features
/// - **Search**: Filters quests by title or number
/// - **Section headers**: Groups quests by [GameEdition.displayName]
/// - **Current quest highlight**: Shows selected quest with highlight styling
/// - **Remove action**: Remove button on selected quest's tile
///
/// ## Layout
/// ```
/// ┌─────────────────────────────────────┐
/// │ [←]  [🔍 Search...]                 │  ← AppBar with search
/// ├─────────────────────────────────────┤
/// │ ──────── Gloomhaven ────────        │  ← Section header
/// │ Seeker of Xorn           [PH] [⊖]  │  ← selected quest with remove
/// │ 510                                 │  ← subtitle
/// │ Merchant Class                [QM]  │
/// │ 511                                 │
/// │ ...                                 │
/// └─────────────────────────────────────┘
/// ```
///
/// ## Invocation
/// ```dart
/// final result = await PersonalQuestSelectorScreen.show(
///   context,
///   currentQuest: character.personalQuest,
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/confirmation_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_search_app_bar.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/search_section_header.dart';

/// Result type for the personal quest selector.
sealed class PQSelectorResult {}

/// A quest was selected.
class PQSelected extends PQSelectorResult {
  PQSelected(this.quest);
  final PersonalQuest quest;
}

/// The user chose to remove the current quest.
class PQRemoved extends PQSelectorResult {}

/// A full-page screen for selecting personal quests.
class PersonalQuestSelectorScreen extends StatefulWidget {
  /// The currently assigned quest, if any. Used for highlight styling.
  final PersonalQuest? currentQuest;

  /// Optional edition filter. If null, shows all quests.
  final GameEdition? edition;

  const PersonalQuestSelectorScreen({
    super.key,
    this.currentQuest,
    this.edition,
  });

  /// Shows the personal quest selector as a full page route.
  ///
  /// Returns a [PQSelectorResult] or `null` if cancelled.
  static Future<PQSelectorResult?> show(
    BuildContext context, {
    PersonalQuest? currentQuest,
    GameEdition? edition,
  }) {
    return Navigator.push<PQSelectorResult>(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalQuestSelectorScreen(
          currentQuest: currentQuest,
          edition: edition,
        ),
      ),
    );
  }

  @override
  State<PersonalQuestSelectorScreen> createState() =>
      _PersonalQuestSelectorScreenState();
}

class _PersonalQuestSelectorScreenState
    extends State<PersonalQuestSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  /// Returns quests filtered by edition and search query.
  List<PersonalQuest> get _filteredQuests {
    final available = widget.edition != null
        ? PersonalQuestsRepository.getByEdition(widget.edition!)
        : PersonalQuestsRepository.quests;

    if (_searchQuery.isEmpty) return available;

    final query = _searchQuery.toLowerCase();
    return available
        .where(
          (q) =>
              q.title.toLowerCase().contains(query) ||
              q.number.toString().contains(query),
        )
        .toList();
  }

  /// Groups filtered quests into sections by [GameEdition.displayName].
  List<(String title, List<PersonalQuest> items)> get _sections {
    final quests = _filteredQuests;
    final sections = <(String, List<PersonalQuest>)>[];
    String? currentTitle;
    List<PersonalQuest> currentItems = [];

    for (final q in quests) {
      final title = q.edition.displayName;
      if (title != currentTitle) {
        if (currentTitle != null) {
          sections.add((currentTitle, currentItems));
        }
        currentTitle = title;
        currentItems = [];
      }
      currentItems.add(q);
    }
    if (currentTitle != null) {
      sections.add((currentTitle, currentItems));
    }
    return sections;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GHCSearchAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        searchQuery: _searchQuery,
        onChanged: (value) => setState(() => _searchQuery = value),
        onClear: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            for (final (title, items) in _sections)
              SliverMainAxisGroup(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SearchSectionHeaderDelegate(title: title),
                  ),
                  SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final quest = items[index];
                      final isSelected = widget.currentQuest?.id == quest.id;
                      return _buildQuestTile(
                        context,
                        quest,
                        isSelected: isSelected,
                      );
                    },
                  ),
                ],
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: largePadding)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTile(
    BuildContext context,
    PersonalQuest quest, {
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      title: Text(quest.title, style: theme.textTheme.bodyLarge),
      subtitle: Text(quest.number.toString()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: theme.colorScheme.error,
              ),
              onPressed: () => _confirmRemove(context),
            ),
          _buildUnlockIcon(context, quest),
        ],
      ),
      onTap: () => _onQuestTap(context, quest, isSelected: isSelected),
    );
  }

  Future<void> _onQuestTap(
    BuildContext context,
    PersonalQuest quest, {
    required bool isSelected,
  }) async {
    // Tapping the already-selected quest dismisses with no result
    if (isSelected) {
      Navigator.pop(context);
      return;
    }

    // If changing from an existing quest, confirm first
    if (widget.currentQuest != null) {
      final l10n = AppLocalizations.of(context);
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: l10n.changePersonalQuest,
        content: Text(l10n.changePersonalQuestBody),
        confirmLabel: l10n.change,
        cancelLabel: l10n.cancel,
      );
      if (confirmed != true || !context.mounted) return;
    }

    if (context.mounted) {
      Navigator.pop(context, PQSelected(quest));
    }
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.removePersonalQuest,
      content: Text(l10n.removePersonalQuestBody),
      confirmLabel: l10n.remove,
      cancelLabel: l10n.cancel,
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(context, PQRemoved());
    }
  }

  Widget _buildUnlockIcon(BuildContext context, PersonalQuest quest) {
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
      return SizedBox(
        width: iconSizeMedium,
        height: iconSizeMedium,
        child: Center(
          child: Text(
            'X',
            style: TextStyle(
              fontFamily: 'PirataOne',
              fontWeight: FontWeight.normal,
              fontSize: iconSizeMedium,
              height: 1,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
