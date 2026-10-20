import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/enhancement_icon.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/cost_display.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/enhancement_type_selector_screen.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';

/// The body content for the Enhancement Type selector card.
///
/// Contains a tappable button that opens [EnhancementTypeSelectorScreen] for
/// selecting enhancement types, and displays the current selection with its cost inline.
class EnhancementTypeBody extends StatelessWidget {
  final EnhancementCalculatorModel model;
  final GameEdition edition;

  /// Optional cost configuration to display inline with the enhancement.
  final CostDisplayConfig? costConfig;

  const EnhancementTypeBody({
    super.key,
    required this.model,
    required this.edition,
    this.costConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enhancement = model.enhancement;

    return InkWell(
      onTap: () => EnhancementTypeSelectorScreen.show(
        context,
        currentSelection: enhancement,
        edition: edition,
        onSelected: model.enhancementSelected,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: enhancement != null
            ? _buildSelectedEnhancement(context, enhancement)
            : Text(
                AppLocalizations.of(context).type,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
      ),
    );
  }

  Widget _buildSelectedEnhancement(
    BuildContext context,
    Enhancement enhancement,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        EnhancementIcon(enhancement: enhancement, size: iconSizeLarge),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            enhancement.name,
            style: theme.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (costConfig != null) ...[
          const SizedBox(width: 12),
          CostDisplay(config: costConfig!),
        ],
      ],
    );
  }
}
