import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';

/// Displays prosperity level with checkmark progress and edit controls.
class ProsperitySection extends StatelessWidget {
  const ProsperitySection({
    super.key,
    required this.campaign,
    required this.isEditMode,
    required this.onIncrement,
    required this.onDecrement,
    this.embedded = false,
  });

  final Campaign campaign;
  final bool isEditMode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// When true, renders just the inner content without a [SectionCard] wrapper.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = _ProsperityContent(
      campaign: campaign,
      isEditMode: isEditMode,
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
    required this.onIncrement,
    required this.onDecrement,
  });

  final Campaign campaign;
  final bool isEditMode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nextLevel = campaign.checkmarksForNextLevel;
    final currentThreshold = campaign.checkmarksForCurrentLevel;

    // Progress within the current level bracket
    final progressInBracket = nextLevel != null
        ? (campaign.prosperityCheckmarks - currentThreshold)
        : 0;
    final bracketSize = nextLevel != null ? (nextLevel - currentThreshold) : 1;
    final progress = nextLevel != null
        ? (progressInBracket / bracketSize).clamp(0.0, 1.0)
        : 1.0;

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
              '${campaign.prosperityCheckmarks} ${l10n.checkmarks}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: smallPadding),
        // Progress bar toward next level
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: smallPadding,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        if (nextLevel != null) ...[
          const SizedBox(height: tinyPadding),
          Text(
            '${campaign.prosperityCheckmarks}/$nextLevel',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        // Edit mode stepper
        if (isEditMode) ...[
          const SizedBox(height: mediumPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: campaign.prosperityCheckmarks > 0
                    ? onDecrement
                    : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: largePadding),
              IconButton.filled(
                onPressed: onIncrement,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
