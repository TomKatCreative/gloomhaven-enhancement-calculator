import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/enhancer_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/expandable_cost_chip.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_divider.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class EnhancementCalculatorScreen extends StatefulWidget {
  const EnhancementCalculatorScreen({super.key});

  @override
  State<EnhancementCalculatorScreen> createState() =>
      _EnhancementCalculatorScreenState();
}

class _EnhancementCalculatorScreenState
    extends State<EnhancementCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .watch<EnhancementCalculatorModel>();
    // Watch ThemeProvider to rebuild when theme changes
    final themeProvider = context.watch<ThemeProvider>();
    enhancementCalculatorModel.calculateCost(notify: false);
    final darkTheme = themeProvider.useDarkMode;
    final edition = enhancementCalculatorModel.edition;

    return Stack(
      children: [
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.contentMaxWidth(context),
            ),
            padding: const EdgeInsets.symmetric(horizontal: smallPadding),
            child: ListView(
              controller: context
                  .read<CharactersModel>()
                  .enhancementCalcScrollController,
              padding: EdgeInsets.only(
                // Extra padding when chip and FAB are present
                bottom: enhancementCalculatorModel.showCost ? 90 : largePadding,
              ),
              children: <Widget>[
                const SizedBox(height: mediumPadding),

                // 1. ENHANCEMENT TYPE
                _EnhancementTypeCard(
                  edition: edition,
                  model: enhancementCalculatorModel,
                ),

                const SizedBox(height: mediumPadding),

                // 2. CARD DETAILS & MODIFIERS
                _CardDetailsGroupCard(
                  edition: edition,
                  model: enhancementCalculatorModel,
                  darkTheme: darkTheme,
                ),

                const SizedBox(height: mediumPadding),

                // 3. DISCOUNTS
                _DiscountsGroupCard(
                  edition: edition,
                  enhancementCalculatorModel: enhancementCalculatorModel,
                  darkTheme: darkTheme,
                  onSettingChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ),
        // Cost chip overlay with animated appearance
        AnimatedSwitcher(
          duration: animationDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              alignment: Alignment.bottomCenter,
              child: child,
            );
          },
          child: enhancementCalculatorModel.showCost
              ? ExpandableCostChip(
                  key: const ValueKey('cost-chip'),
                  totalCost: enhancementCalculatorModel.totalCost,
                  steps: enhancementCalculatorModel.getCalculationBreakdown(),
                  enhancement: enhancementCalculatorModel.enhancement,
                  scrollController: context
                      .read<CharactersModel>()
                      .enhancementCalcScrollController,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }
}

/// Card Details group - combines Card Level, Previous Enhancements, and Modifiers.
class _CardDetailsGroupCard extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;
  final bool darkTheme;

  const _CardDetailsGroupCard({
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
                marker: _buildMarker(partyBoon),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the marker string for card level cost.
  /// Combines Party Boon § and Building 44 * markers.
  String? _buildMarker(bool partyBoon) {
    final markers = <String>[];
    if (partyBoon) markers.add('\u00A7'); // §
    if (model.enhancerLvl3Applies) markers.add('*');
    return markers.isEmpty ? null : markers.join();
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
                marker: _buildMarker(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the marker string for previous enhancements cost.
  /// Combines temp † and Building 44 * markers.
  String? _buildMarker() {
    final markers = <String>[];
    if (model.temporaryEnhancementMode) markers.add('\u2020'); // †
    if (model.enhancerLvl4Applies) markers.add('*');
    return markers.isEmpty ? null : markers.join();
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
class _EnhancementTypeCard extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;

  const _EnhancementTypeCard({required this.edition, required this.model});

  /// Builds the marker string for enhancement type cost.
  /// Combines Hail's ‡ and Building 44 * markers.
  String? _buildEnhancementTypeMarker(EnhancementCalculatorModel model) {
    final markers = <String>[];
    if (model.hailsDiscount) markers.add('\u2021'); // ‡
    if (model.enhancerLvl2Applies) markers.add('*');
    return markers.isEmpty ? null : markers.join();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enhancement = model.enhancement;

    return SectionCard(
      title: l10n.actionDetails,
      svgAssetKey: 'ENHANCEMENTS',
      contentPadding: const EdgeInsets.only(
        left: largePadding,
        bottom: largePadding,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: enhancement != null
                ? () => showDialog<void>(
                    context: context,
                    builder: (_) => InfoDialog(category: enhancement.category),
                  )
                : null,
          ),
          const SizedBox(width: largePadding),
          Expanded(
            child: EnhancementTypeBody(
              model: model,
              edition: edition,
              costConfig: enhancement != null
                  ? CostDisplayConfig(
                      baseCost: enhancement.cost(edition: edition),
                      discountedCost: model.enhancementCost(enhancement),
                      marker: _buildEnhancementTypeMarker(model),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Discounts & Settings group card - groups Temp Enhancement, Hail's Discount,
/// Scenario 114 Reward, and Building 44.
class _DiscountsGroupCard extends StatefulWidget {
  final dynamic edition;
  final EnhancementCalculatorModel enhancementCalculatorModel;
  final bool darkTheme;
  final VoidCallback onSettingChanged;

  const _DiscountsGroupCard({
    required this.edition,
    required this.enhancementCalculatorModel,
    required this.darkTheme,
    required this.onSettingChanged,
  });

  @override
  State<_DiscountsGroupCard> createState() => _DiscountsGroupCardState();
}

class _DiscountsGroupCardState extends State<_DiscountsGroupCard> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = <ToggleGroupItem>[
      // Temporary Enhancement (first, after swap)
      ToggleGroupItem(
        infoConfig: InfoButtonConfig.titleMessage(
          title: Strings.temporaryEnhancement,
          message: Strings.temporaryEnhancementInfoBody(
            context,
            widget.darkTheme,
          ),
        ),
        title: '${AppLocalizations.of(context).temporaryEnhancement} \u2020',
        subtitle: AppLocalizations.of(context).variant,
        value: widget.enhancementCalculatorModel.temporaryEnhancementMode,
        onChanged: (value) {
          widget.enhancementCalculatorModel.temporaryEnhancementMode = value;
        },
      ),

      // Hail's Discount
      ToggleGroupItem(
        infoConfig: InfoButtonConfig.titleMessage(
          title: Strings.hailsDiscountTitle,
          message: Strings.hailsDiscountInfoBody(context, widget.darkTheme),
        ),
        title: '${AppLocalizations.of(context).hailsDiscount} \u2021',
        value: widget.enhancementCalculatorModel.hailsDiscount,
        onChanged: (value) {
          widget.enhancementCalculatorModel.hailsDiscount = value;
        },
      ),

      // Scenario 114 Reward (Party Boon) - Gloomhaven/GH2E only
      if (widget.edition.supportsPartyBoon)
        ToggleGroupItem(
          infoConfig: InfoButtonConfig.titleMessage(
            title: Strings.scenario114RewardTitle,
            message: Strings.scenario114RewardInfoBody(
              context,
              widget.darkTheme,
            ),
          ),
          title: '${AppLocalizations.of(context).scenario114Reward} \u00A7',
          subtitle: AppLocalizations.of(context).forgottenCirclesSpoilers,
          value: widget.enhancementCalculatorModel.partyBoon,
          onChanged: (value) {
            setState(() {
              widget.enhancementCalculatorModel.partyBoon = value;
            });
            widget.onSettingChanged();
          },
        ),

      // Building 44 (Enhancer) - Frosthaven only
      if (widget.edition.hasEnhancerLevels)
        ToggleGroupItem(
          infoConfig: InfoButtonConfig.titleMessage(
            title: Strings.building44Title,
            message: Strings.building44InfoBody(context, widget.darkTheme),
          ),
          title: '${AppLocalizations.of(context).building44} \u002A',
          subtitle: AppLocalizations.of(context).frosthavenSpoilers,
          value: widget.enhancementCalculatorModel.hasAnyEnhancerUpgrades,
          trailingWidget: SizedBox(
            width: 60, // Match Switch width for alignment
            child: Center(
              child: Icon(
                Icons.open_in_new,
                size: iconSizeMedium,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          onTap: () => _showEnhancerDialog(context),
        ),
    ];

    final l10n = AppLocalizations.of(context);

    return SectionCard(
      title: l10n.discounts,
      icon: Icons.sell_rounded,
      contentPadding: const EdgeInsets.only(bottom: smallPadding),
      child: CalculatorToggleGroupCard(items: items),
    );
  }

  void _showEnhancerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => EnhancerDialog(model: widget.enhancementCalculatorModel),
    ).then((_) {
      setState(() {}); // Refresh to update Building 44 toggle state
      widget.onSettingChanged();
    });
  }
}
