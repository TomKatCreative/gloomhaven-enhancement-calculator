import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/strings.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/enhancer_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class DiscountsGroupCard extends StatefulWidget {
  final dynamic edition;
  final EnhancementCalculatorModel enhancementCalculatorModel;
  final bool darkTheme;
  final VoidCallback onSettingChanged;

  const DiscountsGroupCard({
    super.key,
    required this.edition,
    required this.enhancementCalculatorModel,
    required this.darkTheme,
    required this.onSettingChanged,
  });

  @override
  State<DiscountsGroupCard> createState() => _DiscountsGroupCardState();
}

class _DiscountsGroupCardState extends State<DiscountsGroupCard> {
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
