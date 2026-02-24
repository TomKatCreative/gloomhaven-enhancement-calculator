import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:provider/provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/masteries_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/perks_section.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';

class PerksAndMasteriesCard extends StatefulWidget {
  const PerksAndMasteriesCard({
    required this.sectionKey,
    required this.masteriesKey,
    required this.character,
    required this.hasMasteries,
    super.key,
  });

  final GlobalKey? sectionKey;
  final GlobalKey masteriesKey;
  final Character character;
  final bool hasMasteries;

  @override
  State<PerksAndMasteriesCard> createState() => _PerksAndMasteriesCardState();
}

class _PerksAndMasteriesCardState extends State<PerksAndMasteriesCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = context.read<CharactersModel>().perksAndMasteriesExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.contrastedPrimary;
    final l10n = AppLocalizations.of(context);

    return CollapsibleSectionCard(
      sectionKey: widget.sectionKey,
      title: _isExpanded
          ? l10n.perks
          : widget.hasMasteries
          ? l10n.perksAndMasteries
          : l10n.perks,
      icon: Icons.workspace_premium_rounded,
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (value) {
        context.read<CharactersModel>().perksAndMasteriesExpanded = value;
        setState(() => _isExpanded = value);
      },
      trailing: _PerksCountBadge(character: widget.character),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Perks content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                smallPadding,
                0,
                largePadding,
                largePadding,
              ),
              child: PerksSection(character: widget.character),
            ),
            // Masteries (if present)
            if (widget.hasMasteries) ...[
              const GHCDivider(indent: true),
              // Masteries header
              Padding(
                key: widget.masteriesKey,
                padding: const EdgeInsets.fromLTRB(
                  largePadding,
                  mediumPadding,
                  mediumPadding,
                  smallPadding,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      size: iconSizeSmall,
                      color: primaryColor,
                    ),
                    const SizedBox(width: smallPadding),
                    Expanded(
                      child: Text(
                        l10n.masteries,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Masteries content
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  smallPadding,
                  0,
                  largePadding,
                  largePadding,
                ),
                child: MasteriesSection(character: widget.character),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PerksCountBadge extends StatelessWidget {
  const _PerksCountBadge({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverLimit =
        character.numOfSelectedPerks > Character.maximumPerks(character);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: smallPadding),
      child: Text(
        '${character.numOfSelectedPerks}/${Character.maximumPerks(character)}',
        style: theme.textTheme.titleLarge?.copyWith(
          color: isOverLimit
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
