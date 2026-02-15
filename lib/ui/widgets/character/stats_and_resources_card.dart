import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
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
    _isExpanded = SharedPrefs().generalExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final model = context.watch<CharactersModel>();

    return CollapsibleSectionCard(
      sectionKey: widget.sectionKey,
      title: kTownSheetEnabled
          ? l10n.general
          : _isExpanded
          ? l10n.stats
          : l10n.statsAndResources,
      icon: Icons.badge_rounded,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (value) {
        SharedPrefs().generalExpanded = value;
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
              if (model.isEditMode && !widget.character.isRetired) ...[
                SizedBox(height: largePadding),
                CheckmarksAndRetirementsRow(character: widget.character),
              ],
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
                  ],
                ),
              ),
              const SizedBox(height: smallPadding),
              ResourcesContent(character: widget.character),
            ],
          ),
        ),
      ],
    );
  }
}
