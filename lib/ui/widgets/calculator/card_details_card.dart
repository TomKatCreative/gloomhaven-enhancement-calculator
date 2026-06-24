import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class CardDetailsGroupCard extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const CardDetailsGroupCard({
    super.key,
    required this.edition,
    required this.model,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SectionCard(
      title: l10n.cardDetails,
      icon: Icons.style_rounded,
      contentPadding: const EdgeInsets.only(bottom: smallPadding),
      child: Column(
        children: [
          _CardLevelSection(
            edition: edition,
            model: model,
            darkTheme: darkTheme,
          ),
          const GHCDivider(indent: true),
          _PreviousEnhancementsSection(
            edition: edition,
            model: model,
            darkTheme: darkTheme,
          ),
          const GHCDivider(indent: true),
          _MultipleTargetsToggle(
            edition: edition,
            model: model,
            darkTheme: darkTheme,
          ),
          if (edition.hasLostModifier) ...[
            const GHCDivider(indent: true),
            _LossNonPersistentToggle(
              edition: edition,
              model: model,
              darkTheme: darkTheme,
            ),
          ],
          if (edition.hasPersistentModifier) ...[
            const GHCDivider(indent: true),
            _PersistentToggle(model: model, darkTheme: darkTheme),
          ],
        ],
      ),
    );
  }
}

/// Card level section with slider and cost display.
class _CardLevelSection extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const _CardLevelSection({
    required this.edition,
    required this.model,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partyBoon = model.partyBoonApplies;
    final enhancerLvl3 = model.enhancerLvl3Applies;
    final level = model.cardLevel;
    final baseCost = 25 * level;
    final actualCost = model.cardLevelPenalty(level);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => InfoDialog(
                    title: Strings.cardLevelInfoTitle,
                    message: Strings.cardLevelInfoBody(
                      context,
                      darkTheme,
                      edition: edition,
                      partyBoon: partyBoon,
                      enhancerLvl3: enhancerLvl3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: largePadding),
              Flexible(
                child: Text(
                  '${AppLocalizations.of(context).cardLevel}: ${level == 0 ? '1/X' : level + 1}',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          CardLevelBody(model: model),
          Padding(
            padding: const EdgeInsets.only(
              left: 48 + largePadding,
              top: smallPadding,
              bottom: smallPadding,
            ),
            child: CostDisplay(
              config: CostDisplayConfig(
                baseCost: baseCost,
                discountedCost: actualCost != baseCost ? actualCost : null,
                marker: costMarker({
                  '\u00A7': partyBoon, // §
                  '*': model.enhancerLvl3Applies,
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Previous enhancements section with segmented button and cost display.
class _PreviousEnhancementsSection extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const _PreviousEnhancementsSection({
    required this.edition,
    required this.model,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enhancerLvl4 = model.enhancerLvl4Applies;
    final selected = model.previousEnhancements;
    final baseCost = 75 * selected;
    final actualCost = model.previousEnhancementsPenalty(selected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => InfoDialog(
                    title: Strings.previousEnhancementsInfoTitle,
                    message: Strings.previousEnhancementsInfoBody(
                      context,
                      darkTheme,
                      edition: edition,
                      enhancerLvl4: enhancerLvl4,
                      temporaryEnhancementMode: model.temporaryEnhancementMode,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: largePadding),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).previousEnhancements,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          PreviousEnhancementsBody(model: model),
          Padding(
            padding: const EdgeInsets.only(
              left: 48 + largePadding,
              top: smallPadding,
              bottom: smallPadding,
            ),
            child: CostDisplay(
              config: CostDisplayConfig(
                baseCost: baseCost,
                discountedCost: actualCost != baseCost ? actualCost : null,
                marker: costMarker({
                  '\u2020': model.temporaryEnhancementMode, // †
                  '*': model.enhancerLvl4Applies,
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Multiple targets toggle row.
class _MultipleTargetsToggle extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const _MultipleTargetsToggle({
    required this.edition,
    required this.model,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleGroupRow(
      item: ToggleGroupItem(
        infoConfig: InfoButtonConfig.titleMessage(
          title: Strings.multipleTargetsInfoTitle,
          message: Strings.multipleTargetsInfoBody(
            context,
            edition: edition,
            enhancerLvl2: model.enhancerLvl2Applies,
            darkMode: darkTheme,
          ),
        ),
        title: AppLocalizations.of(context).multipleTargets,
        value: model.multipleTargets,
        enabled: !model.disableMultiTargetsSwitch,
        onChanged: (value) => model.multipleTargets = value,
      ),
    );
  }
}

/// Lost/non-persistent action toggle row (FH) or just Lost (GH2E).
class _LossNonPersistentToggle extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const _LossNonPersistentToggle({
    required this.edition,
    required this.model,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleGroupRow(
      item: ToggleGroupItem(
        infoConfig: InfoButtonConfig.titleMessage(
          title: Strings.lostNonPersistentInfoTitle(edition: edition),
          message: Strings.lostNonPersistentInfoBody(
            context,
            edition,
            darkTheme,
          ),
        ),
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemedSvg(assetKey: 'LOSS', width: iconSizeLarge),
            if (edition.hasPersistentModifier) ...[
              const SizedBox(width: largePadding),
              SizedBox(
                width: iconSizeLarge + 16,
                height: iconSizeLarge + 11,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ThemedSvg(assetKey: 'PERSISTENT', width: iconSizeLarge),
                    Positioned(
                      right: 5,
                      child: ThemedSvg(
                        assetKey: 'NOT',
                        width: iconSizeLarge + 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        subtitle: Strings.lostNonPersistentInfoTitle(edition: edition),
        value: model.lostNonPersistent,
        enabled:
            !model.persistent &&
            (edition.hasPersistentModifier ||
                model.enhancement?.category !=
                    EnhancementCategory.summonPlusOne),
        onChanged: (value) => model.lostNonPersistent = value,
      ),
    );
  }
}

/// Persistent action toggle row.
class _PersistentToggle extends StatelessWidget {
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const _PersistentToggle({required this.model, required this.darkTheme});

  @override
  Widget build(BuildContext context) {
    return ToggleGroupRow(
      item: ToggleGroupItem(
        infoConfig: InfoButtonConfig.titleMessage(
          title: Strings.persistentInfoTitle,
          message: Strings.persistentInfoBody(context, darkTheme),
        ),
        titleWidget: ThemedSvg(assetKey: 'PERSISTENT', width: iconSizeLarge),
        subtitle: AppLocalizations.of(context).persistent,
        value: model.persistent,
        enabled:
            model.enhancement?.category != EnhancementCategory.summonPlusOne &&
            !model.lostNonPersistent,
        onChanged: (value) => model.persistent = value,
      ),
    );
  }
}

/// Enhancement Type selector card.
