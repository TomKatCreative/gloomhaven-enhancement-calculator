import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/personal_quest_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class QuestAndNotesCard extends StatefulWidget {
  const QuestAndNotesCard({
    required this.sectionKey,
    required this.notesKey,
    required this.character,
    super.key,
  });

  final GlobalKey? sectionKey;
  final GlobalKey notesKey;
  final Character character;

  @override
  State<QuestAndNotesCard> createState() => _QuestAndNotesCardState();
}

class _QuestAndNotesCardState extends State<QuestAndNotesCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = SharedPrefs().questAndNotesExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.contrastedPrimary;
    final l10n = AppLocalizations.of(context);
    final model = context.watch<CharactersModel>();
    final hasQuestAssigned = widget.character.personalQuest != null;
    final showQuestSection = hasQuestAssigned || !widget.character.isRetired;
    final hasNotes = widget.character.notes.isNotEmpty || model.isEditMode;

    return CollapsibleSectionCard(
      sectionKey: widget.sectionKey,
      title: _isExpanded ? l10n.personalQuest : l10n.questAndNotes,
      icon: Icons.map_rounded,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (value) {
        SharedPrefs().questAndNotesExpanded = value;
        setState(() => _isExpanded = value);
      },
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quest section
            if (showQuestSection)
              PersonalQuestSection(character: widget.character, embedded: true),
            // Notes section
            if (hasNotes) ...[
              if (showQuestSection) const GHCDivider(indent: true),
              // Notes header (only when PQ section is visible above)
              Padding(
                key: widget.notesKey,
                padding: const EdgeInsets.fromLTRB(
                  largePadding,
                  mediumPadding,
                  mediumPadding,
                  smallPadding,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: smallPadding),
                  child: Row(
                    children: [
                      Icon(
                        Icons.book_rounded,
                        size: iconSizeSmall,
                        color: primaryColor,
                      ),
                      const SizedBox(width: smallPadding),
                      Expanded(
                        child: Text(
                          l10n.notes,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Notes content
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  largePadding,
                  0,
                  largePadding,
                  largePadding,
                ),
                child: _NotesSection(character: widget.character),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    CharactersModel charactersModel = context.read<CharactersModel>();
    final isEditMode =
        context.watch<CharactersModel>().isEditMode && !character.isRetired;

    return isEditMode
        ? TextFormField(
            key: ValueKey('notes_${character.uuid}'),
            initialValue: character.notes,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onChanged: (String value) {
              charactersModel.updateCharacter(character..notes = value);
            },
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).addNotes,
              border: InputBorder.none,
            ),
          )
        : Text(character.notes);
  }
}
