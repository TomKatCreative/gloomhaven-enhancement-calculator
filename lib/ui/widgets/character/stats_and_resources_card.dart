import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/checkmarks_and_retirements_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/party_assignment_row.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/stats_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';

class StatsAndResourcesCard extends StatefulWidget {
  const StatsAndResourcesCard({
    required this.sectionKey,
    required this.character,
    super.key,
  });

  final GlobalKey? sectionKey;
  final Character character;

  @override
  State<StatsAndResourcesCard> createState() => _StatsAndResourcesCardState();
}

class _StatsAndResourcesCardState extends State<StatsAndResourcesCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = context.read<CharactersModel>().generalExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final model = context.watch<CharactersModel>();
    final canEdit = model.isEditMode && !widget.character.isRetired;

    return CollapsibleSectionCard(
      sectionKey: widget.sectionKey,
      title: kTownSheetEnabled
          ? l10n.general
          : _isExpanded ||
                !widget.character.showResources ||
                widget.character.isJawsOfTheLion
          ? l10n.stats
          : l10n.statsAndResources,
      icon: Icons.badge_rounded,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (value) {
        context.read<CharactersModel>().generalExpanded = value;
        setState(() => _isExpanded = value);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            largePadding,
            0,
            largePadding,
            largePadding,
          ),
          child: Column(
            children: [
              if (kTownSheetEnabled) ...[
                PartyAssignmentRow(character: widget.character),
                const Divider(height: largePadding * 2),
              ],
              StatsSection(character: widget.character),
              if (canEdit) ...[
                SizedBox(height: largePadding),
                CheckmarksAndRetirementsRow(character: widget.character),
              ],
              // Resources is a Frosthaven concept, so it can be hidden
              // per-character. Hiding never clears the stored counts, and an
              // "add" button restores it from edit mode. JotL has no resources
              // at all, so the section (and its add button) are never offered.
              if (widget.character.isJawsOfTheLion)
                const SizedBox.shrink()
              else if (widget.character.showResources) ...[
                const Divider(height: largePadding * 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: smallPadding),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: iconSizeSmall,
                        color: theme.contrastedPrimary,
                      ),
                      const SizedBox(width: smallPadding),
                      Expanded(
                        child: Text(
                          l10n.resources,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.contrastedPrimary,
                          ),
                        ),
                      ),
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          iconSize: iconSizeSmall,
                          color: theme.contrastedPrimary,
                          tooltip: l10n.removeResources,
                          onPressed: () {
                            widget.character.showResources = false;
                            context.read<CharactersModel>().updateCharacter(
                              widget.character,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: smallPadding),
                ResourcesContent(character: widget.character),
              ] else if (canEdit) ...[
                const Divider(height: largePadding * 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addResources),
                    onPressed: () {
                      widget.character.showResources = true;
                      context.read<CharactersModel>().updateCharacter(
                        widget.character,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
