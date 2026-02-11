import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// Converts prosperity checkmarks to a slider position (1.0–9.0).
///
/// Within a level bracket, interpolates linearly so the thumb shows
/// proportional progress toward the next level.
double _checkmarksToSliderValue(int checkmarks, List<int> thresholds) {
  // Find which bracket we're in
  int level = 1;
  for (int i = thresholds.length - 1; i >= 0; i--) {
    if (checkmarks >= thresholds[i]) {
      level = i + 1;
      break;
    }
  }

  // At max level, return max
  if (level >= thresholds.length) return thresholds.length.toDouble();

  final bracketStart = thresholds[level - 1];
  final bracketEnd = thresholds[level];
  final fraction = (checkmarks - bracketStart) / (bracketEnd - bracketStart);

  return level + fraction;
}

/// Displays prosperity level with checkmark progress and edit controls.
class ProsperitySection extends StatelessWidget {
  const ProsperitySection({
    super.key,
    required this.campaign,
    required this.isEditMode,
    required this.onLevelChanged,
    required this.onIncrement,
    required this.onDecrement,
    this.embedded = false,
  });

  final Campaign campaign;
  final bool isEditMode;
  final ValueChanged<int> onLevelChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// When true, renders just the inner content without a [SectionCard] wrapper.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = _ProsperityContent(
      campaign: campaign,
      isEditMode: isEditMode,
      onLevelChanged: onLevelChanged,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
    );

    if (embedded) {
      return content;
    }

    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.prosperity,
      icon: Icons.location_city,
      child: content,
    );
  }
}

class _ProsperityContent extends StatelessWidget {
  const _ProsperityContent({
    required this.campaign,
    required this.isEditMode,
    required this.onLevelChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Campaign campaign;
  final bool isEditMode;
  final ValueChanged<int> onLevelChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final thresholds = prosperityThresholds[campaign.edition]!;
    final sliderValue = _checkmarksToSliderValue(
      campaign.prosperityCheckmarks,
      thresholds,
    );

    final slider = SfSlider(
      min: 1.0,
      max: 9.0,
      value: sliderValue,
      interval: 1,
      stepSize: isEditMode ? 1 : null,
      showTicks: true,
      showLabels: true,
      activeColor: theme.colorScheme.primary,
      onChanged: isEditMode
          ? (dynamic value) => onLevelChanged((value as double).round())
          : (_) {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level display
        Row(
          children: [
            Text(
              l10n.prosperityLevelN(campaign.prosperityLevel),
              style: theme.textTheme.headlineSmall,
            ),
            const Spacer(),
            Text(
              '${campaign.prosperityCheckmarks} / ${thresholds.last}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: smallPadding),
        // Prosperity slider — interactive in edit mode, visual-only otherwise
        if (isEditMode) slider else IgnorePointer(child: slider),
        // Edit mode stepper for fine-grained checkmark adjustments
        if (isEditMode) ...[
          const SizedBox(height: mediumPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: campaign.prosperityCheckmarks > 1
                    ? onDecrement
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: largePadding),
              IconButton.filled(
                onPressed:
                    campaign.prosperityCheckmarks <
                        prosperityThresholds[campaign.edition]!.last
                    ? onIncrement
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
