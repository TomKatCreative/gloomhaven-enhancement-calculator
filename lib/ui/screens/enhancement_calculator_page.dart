import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_provider.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/expandable_cost_chip.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/characters_model.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class EnhancementCalculatorPage extends StatefulWidget {
  const EnhancementCalculatorPage({super.key});

  @override
  State<EnhancementCalculatorPage> createState() =>
      _EnhancementCalculatorPageState();
}

class _EnhancementCalculatorPageState extends State<EnhancementCalculatorPage> {
  @override
  Widget build(BuildContext context) {
    final enhancementCalculatorModel = context
        .watch<EnhancementCalculatorModel>();
    // Watch ThemeProvider to rebuild when theme changes
    final themeProvider = context.watch<ThemeProvider>();
    enhancementCalculatorModel.calculateCost(notify: false);
    final darkTheme = themeProvider.useDarkMode;
    final edition = SharedPrefs().gameEdition;

    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: mediumPadding),
          child: ListView(
            controller: context
                .read<CharactersModel>()
                .enhancementCalcScrollController,
            padding: EdgeInsets.only(
              // Extra padding when chip and FAB are present
              bottom: enhancementCalculatorModel.showCost ? 90 : largePadding,
            ),
            children: <Widget>[
              // === ACTION DETAILS ===
              Padding(
                padding: const EdgeInsets.symmetric(vertical: largePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).dividerTheme.color,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: largePadding,
                      ),
                      child: Text(
                        AppLocalizations.of(context).actionDetails,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).dividerTheme.color,
                      ),
                    ),
                  ],
                ),
              ),

              // 1. ENHANCEMENT TYPE
              _EnhancementTypeCard(
                edition: edition,
                model: enhancementCalculatorModel,
              ),

              // 2. CARD LEVEL & PREVIOUS ENHANCEMENTS - grouped card
              _CardDetailsGroupCard(
                edition: edition,
                model: enhancementCalculatorModel,
                darkTheme: darkTheme,
              ),

              // 3. MODIFIERS - grouped card
              _ModifiersGroupCard(
                edition: edition,
                enhancementCalculatorModel: enhancementCalculatorModel,
                darkTheme: darkTheme,
              ),

              // === DISCOUNTS ===
              Padding(
                padding: const EdgeInsets.symmetric(vertical: largePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).dividerTheme.color,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: largePadding,
                      ),
                      child: Text(
                        AppLocalizations.of(context).discounts,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Theme.of(context).dividerTheme.color,
                      ),
                    ),
                  ],
                ),
              ),

              // 5. DISCOUNTS - grouped card
              _DiscountsGroupCard(
                edition: edition,
                enhancementCalculatorModel: enhancementCalculatorModel,
                darkTheme: darkTheme,
                onSettingChanged: () => setState(() {}),
              ),
            ],
          ),
        ),
        // Cost chip overlay
        if (enhancementCalculatorModel.showCost)
          ExpandableCostChip(
            totalCost: enhancementCalculatorModel.totalCost,
            steps: enhancementCalculatorModel.getCalculationBreakdown(),
            enhancement: enhancementCalculatorModel.enhancement,
          ),
      ],
    );
  }
}

/// Card Details group - combines Card Level and Previous Enhancements.
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: mediumPadding),
        child: Column(
          children: [
            _buildCardLevelSection(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: largePadding),
              child: Divider(
                height: 1,
                color: Theme.of(context).dividerTheme.color,
              ),
            ),
            _buildPreviousEnhancementsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLevelSection(BuildContext context) {
    final theme = Theme.of(context);
    final partyBoon = edition.supportsPartyBoon && SharedPrefs().partyBoon;
    final enhancerLvl3 =
        edition.hasEnhancerLevels && SharedPrefs().enhancerLvl3;
    final level = model.cardLevel;
    final baseCost = 25 * level;
    final actualCost = model.cardLevelPenalty(level);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
              Text(
                '${AppLocalizations.of(context).cardLevel}: ${level + 1}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          // Slider body
          CardLevelBody(model: model),
          // Cost display - padded to align with title (icon button width + spacing)
          Padding(
            padding: const EdgeInsets.only(
              left: 48 + largePadding,
              top: mediumPadding,
              bottom: mediumPadding,
            ),
            child: CostDisplay(
              config: CostDisplayConfig(
                baseCost: baseCost,
                discountedCost: actualCost != baseCost ? actualCost : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousEnhancementsSection(BuildContext context) {
    final theme = Theme.of(context);
    final enhancerLvl4 =
        edition.hasEnhancerLevels && SharedPrefs().enhancerLvl4;
    final tempEnhancements = model.temporaryEnhancementMode;
    final selected = model.previousEnhancements;
    final baseCost = 75 * selected;
    final actualCost = model.previousEnhancementsPenalty(selected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
                    ),
                  ),
                ),
              ),
              const SizedBox(width: largePadding),
              Text(
                AppLocalizations.of(context).previousEnhancements,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          // Segmented button body
          PreviousEnhancementsBody(model: model),
          // Cost display - padded to align with title (icon button width + spacing)
          Padding(
            padding: const EdgeInsets.only(left: 48 + largePadding),
            child: CostDisplay(
              config: CostDisplayConfig(
                baseCost: baseCost,
                discountedCost: actualCost != baseCost ? actualCost : null,
                marker: tempEnhancements ? '\u2020' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhancement Type selector card.
class _EnhancementTypeCard extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;

  const _EnhancementTypeCard({required this.edition, required this.model});

  @override
  Widget build(BuildContext context) {
    final enhancement = model.enhancement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: largePadding),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: enhancement != null
                  ? () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          InfoDialog(category: enhancement.category),
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
                        marker: model.hailsDiscount ? '\u2021' : null,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modifiers group card - groups Multi-target, Loss, and Persistent toggles.
class _ModifiersGroupCard extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel enhancementCalculatorModel;
  final bool darkTheme;

  const _ModifiersGroupCard({
    required this.edition,
    required this.enhancementCalculatorModel,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final items = <ToggleGroupItem>[
      // Multi-target
      ToggleGroupItem(
        infoConfig: InfoButtonConfig.titleMessage(
          title: Strings.multipleTargetsInfoTitle,
          message: Strings.multipleTargetsInfoBody(
            context,
            edition: edition,
            enhancerLvl2:
                edition.hasEnhancerLevels && SharedPrefs().enhancerLvl2,
            darkMode: darkTheme,
          ),
        ),
        title: AppLocalizations.of(context).multipleTargets,
        value: enhancementCalculatorModel.multipleTargets,
        enabled: !enhancementCalculatorModel.disableMultiTargetsSwitch,
        onChanged: (value) {
          enhancementCalculatorModel.multipleTargets = value;
        },
      ),

      // Loss Non-Persistent (GH2E and FH only)
      if (edition.hasLostModifier)
        ToggleGroupItem(
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
              ThemedSvg(assetKey: 'LOSS', width: iconSize),
              if (edition.hasPersistentModifier) ...[
                const SizedBox(width: largePadding),
                SizedBox(
                  width: iconSize + 16,
                  height: iconSize + 11,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ThemedSvg(assetKey: 'PERSISTENT', width: iconSize),
                      Positioned(
                        right: 5,
                        child: SvgPicture.asset(
                          'images/ui/not.svg',
                          width: iconSize + 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          subtitle: AppLocalizations.of(context).lossNonPersistent,
          value: enhancementCalculatorModel.lostNonPersistent,
          enabled:
              !enhancementCalculatorModel.persistent &&
              (edition.hasPersistentModifier ||
                  enhancementCalculatorModel.enhancement?.category !=
                      EnhancementCategory.summonPlusOne),
          onChanged: (value) {
            enhancementCalculatorModel.lostNonPersistent = value;
          },
        ),

      // Persistent (FH only)
      if (edition.hasPersistentModifier)
        ToggleGroupItem(
          infoConfig: InfoButtonConfig.titleMessage(
            title: Strings.persistentInfoTitle,
            message: Strings.persistentInfoBody(context, darkTheme),
          ),
          titleWidget: ThemedSvg(assetKey: 'PERSISTENT', width: iconSize),
          subtitle: AppLocalizations.of(context).persistent,
          value: enhancementCalculatorModel.persistent,
          enabled:
              enhancementCalculatorModel.enhancement?.category !=
                  EnhancementCategory.summonPlusOne &&
              !enhancementCalculatorModel.lostNonPersistent,
          onChanged: (value) {
            enhancementCalculatorModel.persistent = value;
          },
        ),
    ];

    return CalculatorToggleGroupCard(items: items);
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
        title: AppLocalizations.of(context).temporaryEnhancement,
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
        title: AppLocalizations.of(context).hailsDiscount,
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
          title: AppLocalizations.of(context).scenario114Reward,
          subtitle: AppLocalizations.of(context).forgottenCirclesSpoilers,
          value: SharedPrefs().partyBoon,
          onChanged: (value) {
            setState(() {
              SharedPrefs().partyBoon = value;
              widget.enhancementCalculatorModel.calculateCost();
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
          title: AppLocalizations.of(context).building44,
          subtitle: AppLocalizations.of(context).frosthavenSpoilers,
          value: _hasAnyEnhancerUpgrades(),
          trailingWidget: Icon(
            Icons.open_in_new,
            size: 30,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
          onTap: () => _showEnhancerDialog(context),
        ),
    ];

    return CalculatorToggleGroupCard(items: items);
  }

  bool _hasAnyEnhancerUpgrades() {
    return SharedPrefs().enhancerLvl2 ||
        SharedPrefs().enhancerLvl3 ||
        SharedPrefs().enhancerLvl4;
  }

  void _showEnhancerDialog(BuildContext context) {
    showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              AppLocalizations.of(context).enhancer,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          content: StatefulBuilder(
            builder: (_, innerSetState) {
              return Container(
                constraints: const BoxConstraints(maxWidth: maxDialogWidth),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEnhancerLevel(
                        context,
                        innerSetState,
                        level: 1,
                        subtitle: AppLocalizations.of(context).buyEnhancements,
                        value: true,
                        enabled: false,
                      ),
                      _buildEnhancerLevel(
                        context,
                        innerSetState,
                        level: 2,
                        subtitle: AppLocalizations.of(
                          context,
                        ).reduceEnhancementCosts,
                        value: SharedPrefs().enhancerLvl2,
                        onChanged: (val) {
                          if (val != null) {
                            innerSetState(() {
                              SharedPrefs().enhancerLvl2 = val;
                              widget.enhancementCalculatorModel.calculateCost();
                            });
                          }
                        },
                      ),
                      _buildEnhancerLevel(
                        context,
                        innerSetState,
                        level: 3,
                        subtitle: AppLocalizations.of(
                          context,
                        ).reduceLevelPenalties,
                        value: SharedPrefs().enhancerLvl3,
                        onChanged: (val) {
                          if (val != null) {
                            innerSetState(() {
                              SharedPrefs().enhancerLvl3 = val;
                              widget.enhancementCalculatorModel.calculateCost();
                            });
                          }
                        },
                      ),
                      _buildEnhancerLevel(
                        context,
                        innerSetState,
                        level: 4,
                        subtitle: AppLocalizations.of(
                          context,
                        ).reduceRepeatPenalties,
                        value: SharedPrefs().enhancerLvl4,
                        onChanged: (val) {
                          if (val != null) {
                            innerSetState(() {
                              SharedPrefs().enhancerLvl4 = val;
                              widget.enhancementCalculatorModel.calculateCost();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).close),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {}); // Refresh to update Building 44 toggle state
      widget.onSettingChanged();
    });
  }

  Widget _buildEnhancerLevel(
    BuildContext context,
    StateSetter innerSetState, {
    required int level,
    required String subtitle,
    required bool value,
    bool enabled = true,
    ValueChanged<bool?>? onChanged,
  }) {
    final isActive = value;

    return CheckboxListTile(
      title: Text(
        _getLevelLabel(context, level),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: SharedPrefs().useDefaultFonts ? 25 : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isActive
              ? null
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 20,
        ),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  String _getLevelLabel(BuildContext context, int level) {
    switch (level) {
      case 1:
        return AppLocalizations.of(context).lvl1;
      case 2:
        return AppLocalizations.of(context).lvl2;
      case 3:
        return AppLocalizations.of(context).lvl3;
      case 4:
        return AppLocalizations.of(context).lvl4;
      default:
        return '';
    }
  }
}
