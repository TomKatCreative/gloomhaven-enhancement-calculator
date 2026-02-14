import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/town/stepper_buttons.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

/// Displays sanctuary donation progress with a Syncfusion slider and ± buttons.
class SanctuarySection extends StatelessWidget {
  const SanctuarySection({
    super.key,
    required this.campaign,
    required this.isEditMode,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
    this.embedded = false,
  });

  final Campaign campaign;
  final bool isEditMode;

  /// Called when the slider is dragged (snaps to 10-gold increments).
  final ValueChanged<int> onChanged;

  /// Increment by 1 gold. Returns `true` when just reached [maxDonatedGold].
  final Future<bool> Function() onIncrement;

  /// Decrement by 1 gold.
  final VoidCallback onDecrement;

  /// When true, renders just the inner content without a [SectionCard] wrapper.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = _SanctuaryContent(
      campaign: campaign,
      isEditMode: isEditMode,
      onChanged: onChanged,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
    );

    if (embedded) {
      return content;
    }

    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.sanctuaryDonations,
      icon: Icons.paid,
      child: content,
    );
  }
}

class _SanctuaryContent extends StatelessWidget {
  const _SanctuaryContent({
    required this.campaign,
    required this.isEditMode,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Campaign campaign;
  final bool isEditMode;
  final ValueChanged<int> onChanged;
  final Future<bool> Function() onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = campaign.donatedGold >= maxDonatedGold;

    final slider = SfSlider(
      min: 0.0,
      max: 100.0,
      value: campaign.donatedGold.toDouble(),
      interval: 10,
      minorTicksPerInterval: 5,
      stepSize: isEditMode ? 10 : null,
      showTicks: true,
      showLabels: true,
      activeColor: theme.colorScheme.primary,
      onChanged: isEditMode
          ? (dynamic value) => onChanged((value as double).round())
          : (_) {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount display
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${campaign.donatedGold} / $maxDonatedGold',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isComplete ? theme.colorScheme.primary : null,
            ),
          ),
        ),
        const SizedBox(height: smallPadding),
        // Donation slider — interactive in edit mode, visual-only otherwise
        if (isEditMode) slider else IgnorePointer(child: slider),
        // Edit mode ± buttons for fine-grained adjustments
        if (isEditMode) ...[
          const SizedBox(height: mediumPadding),
          StepperButtons(
            onDecrement: campaign.donatedGold > 0 ? onDecrement : null,
            onIncrement: campaign.donatedGold < maxDonatedGold
                ? onIncrement
                : null,
          ),
        ],
      ],
    );
  }
}
