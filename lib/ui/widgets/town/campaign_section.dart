import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/section_card.dart';

/// Displays campaign (party) info: reputation tracker and edit controls.
class CampaignSection extends StatelessWidget {
  const CampaignSection({
    super.key,
    required this.campaign,
    required this.isEditMode,
    required this.onIncrementReputation,
    required this.onDecrementReputation,
  });

  final Campaign campaign;
  final bool isEditMode;
  final VoidCallback onIncrementReputation;
  final VoidCallback onDecrementReputation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SectionCard(
      title: campaign.name,
      icon: Icons.groups,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reputation display
          Row(
            children: [
              Text(l10n.reputation, style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                _formatReputation(campaign.reputation),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _reputationColor(campaign.reputation, theme),
                ),
              ),
            ],
          ),
          // Edit mode stepper
          if (isEditMode) ...[
            const SizedBox(height: mediumPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: campaign.reputation > minReputation
                      ? onDecrementReputation
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: largePadding),
                IconButton.filled(
                  onPressed: campaign.reputation < maxReputation
                      ? onIncrementReputation
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

  String _formatReputation(int reputation) {
    if (reputation > 0) return '+$reputation';
    return '$reputation';
  }

  Color _reputationColor(int reputation, ThemeData theme) {
    if (reputation > 0) return Colors.green;
    if (reputation < 0) return theme.colorScheme.error;
    return theme.colorScheme.onSurface;
  }
}
