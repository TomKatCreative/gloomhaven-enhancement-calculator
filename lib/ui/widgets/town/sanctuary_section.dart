import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/world.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';

/// Displays sanctuary donation progress with +10 / -10 stepper controls.
class SanctuarySection extends StatelessWidget {
  const SanctuarySection({
    super.key,
    required this.world,
    required this.isEditMode,
    required this.onIncrement,
    required this.onDecrement,
  });

  final World world;
  final bool isEditMode;

  /// Returns `true` when the donation just reached [maxDonatedGold].
  final Future<bool> Function() onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final progress = (world.donatedGold / maxDonatedGold).clamp(0.0, 1.0);
    final isComplete = world.donatedGold >= maxDonatedGold;

    return SectionCard(
      title: l10n.donatedGold,
      icon: Icons.paid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount display
          Row(
            children: [
              Text(
                '${world.donatedGold} / $maxDonatedGold ${l10n.gold.toLowerCase()}',
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
          // Edit mode stepper
          if (isEditMode) ...[
            const SizedBox(height: mediumPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: world.donatedGold > 0 ? onDecrement : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: largePadding),
                IconButton.filled(
                  onPressed: world.donatedGold < maxDonatedGold
                      ? onIncrement
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
