import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/ui/dialogs/info_dialog.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

class EnhancementTypeCard extends StatelessWidget {
  final dynamic edition;
  final EnhancementCalculatorModel model;

  const EnhancementTypeCard({
    super.key,
    required this.edition,
    required this.model,
  });

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
                      marker: costMarker({
                        '\u2021': model.hailsDiscount, // ‡
                        '*': model.enhancerLvl2Applies,
                      }),
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
