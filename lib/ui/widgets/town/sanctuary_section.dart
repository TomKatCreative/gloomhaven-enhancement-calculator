import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';

/// Displays sanctuary donation progress with +10/+1/-1/-10 stepper controls.
class SanctuarySection extends StatelessWidget {
  const SanctuarySection({
    super.key,
    required this.campaign,
    required this.isEditMode,
    required this.onIncrement,
    required this.onDecrement,
    required this.onIncrementSmall,
    required this.onDecrementSmall,
    this.embedded = false,
  });

  final Campaign campaign;
  final bool isEditMode;

  /// Returns `true` when the donation just reached [maxDonatedGold].
  final Future<bool> Function() onIncrement;
  final VoidCallback onDecrement;
  final Future<bool> Function() onIncrementSmall;
  final VoidCallback onDecrementSmall;

  /// When true, renders just the inner content without a [SectionCard] wrapper.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = _SanctuaryContent(
      campaign: campaign,
      isEditMode: isEditMode,
      onIncrement: onIncrement,
      onDecrement: onDecrement,
      onIncrementSmall: onIncrementSmall,
      onDecrementSmall: onDecrementSmall,
    );

    if (embedded) {
      return content;
    }

    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.donatedGold,
      icon: Icons.paid,
      child: content,
    );
  }
}

class _SanctuaryContent extends StatelessWidget {
  const _SanctuaryContent({
    required this.campaign,
    required this.isEditMode,
    required this.onIncrement,
    required this.onDecrement,
    required this.onIncrementSmall,
    required this.onDecrementSmall,
  });

  final Campaign campaign;
  final bool isEditMode;
  final Future<bool> Function() onIncrement;
  final VoidCallback onDecrement;
  final Future<bool> Function() onIncrementSmall;
  final VoidCallback onDecrementSmall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = (campaign.donatedGold / maxDonatedGold).clamp(0.0, 1.0);
    final isComplete = campaign.donatedGold >= maxDonatedGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount display
        Row(
          children: [
            Text(
              '${campaign.donatedGold} / $maxDonatedGold ${l10n.gold.toLowerCase()}',
              style: theme.textTheme.headlineSmall,
            ),
            const Spacer(),
            if (isComplete)
              Icon(
                Icons.check_circle,
                size: iconSizeMedium,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
        const SizedBox(height: smallPadding),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: smallPadding,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        // Edit mode stepper: -10, -1, +1, +10
        if (isEditMode) ...[
          const SizedBox(height: mediumPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                ),
                onPressed: campaign.donatedGold > 0 ? onDecrement : null,
                icon: const Icon(Icons.remove, size: iconSizeTiny),
                label: const Text('10'),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                ),
                onPressed: campaign.donatedGold > 0 ? onDecrementSmall : null,
                icon: const Icon(Icons.remove, size: iconSizeTiny),
                label: const Text('1'),
              ),
              const SizedBox(width: mediumPadding),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                ),
                onPressed: campaign.donatedGold < maxDonatedGold
                    ? onIncrementSmall
                    : null,
                icon: const Icon(Icons.add, size: iconSizeTiny),
                label: const Text('1'),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                ),
                onPressed: campaign.donatedGold < maxDonatedGold
                    ? onIncrement
                    : null,
                icon: const Icon(Icons.add, size: iconSizeTiny),
                label: const Text('10'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
