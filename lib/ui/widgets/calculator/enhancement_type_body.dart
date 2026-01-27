import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/enhancement_type_selector.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

/// Icon size for the prominent enhancement type display.
const double _prominentIconSize = 40;

/// The body content for the Enhancement Type selector card.
///
/// Contains a tappable button that opens a bottom sheet for selecting
/// enhancement types, and displays the current selection with its cost.
class EnhancementTypeBody extends StatelessWidget {
  final EnhancementCalculatorModel model;
  final GameEdition edition;

  const EnhancementTypeBody({
    super.key,
    required this.model,
    required this.edition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enhancement = model.enhancement;

    return InkWell(
      onTap: () {
        EnhancementTypeSelector.show(
          context,
          currentSelection: enhancement,
          edition: edition,
          onSelected: (selected) {
            model.enhancementSelected(selected);
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: enhancement != null
                  ? _buildSelectedEnhancement(context, enhancement)
                  : Text(
                      AppLocalizations.of(context).type,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedEnhancement(
    BuildContext context,
    Enhancement enhancement,
  ) {
    final theme = Theme.of(context);
    final isPlusOne =
        enhancement.category == EnhancementCategory.charPlusOne ||
        enhancement.category == EnhancementCategory.target ||
        enhancement.category == EnhancementCategory.summonPlusOne;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (enhancement.assetKey != null) ...[
          _buildEnhancementIcon(enhancement, isPlusOne),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            enhancement.name,
            style: theme.textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancementIcon(Enhancement enhancement, bool isPlusOne) {
    if (enhancement.name == 'Element') {
      // Scale factor from standard iconSize (30) to prominent size (40)
      const scale = _prominentIconSize / 30;
      return SizedBox(
        width: _prominentIconSize,
        height: _prominentIconSize,
        child: Stack(
          children: [
            Positioned(
              bottom: 5 * scale,
              top: 5 * scale,
              left: 5 * scale,
              child: SvgPicture.asset(
                'images/elements/elem_dark.svg',
                width: 10 * scale,
              ),
            ),
            Positioned(
              top: 4 * scale,
              left: 7 * scale,
              child: SvgPicture.asset(
                'images/elements/elem_air.svg',
                width: 11 * scale,
              ),
            ),
            Positioned(
              top: 3 * scale,
              right: 6 * scale,
              child: SvgPicture.asset(
                'images/elements/elem_ice.svg',
                width: 12 * scale,
              ),
            ),
            Positioned(
              top: 0,
              right: 2 * scale,
              bottom: 2 * scale,
              child: SvgPicture.asset(
                'images/elements/elem_fire.svg',
                width: 13 * scale,
              ),
            ),
            Positioned(
              bottom: 1 * scale,
              right: 4 * scale,
              child: SvgPicture.asset(
                'images/elements/elem_earth.svg',
                width: 14 * scale,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 3 * scale,
              child: SvgPicture.asset(
                'images/elements/elem_light.svg',
                width: 15 * scale,
              ),
            ),
          ],
        ),
      );
    }

    return ThemedSvg(
      assetKey: enhancement.assetKey!,
      width: _prominentIconSize,
      showPlusOneOverlay: isPlusOne,
    );
  }
}
