import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';

/// Bottom sheet selector for switching between campaigns.
class CampaignSelector extends StatelessWidget {
  const CampaignSelector({
    super.key,
    required this.campaigns,
    required this.activeCampaign,
    required this.onCampaignSelected,
    required this.onCreateCampaign,
  });

  final List<Campaign> campaigns;
  final Campaign? activeCampaign;
  final ValueChanged<Campaign> onCampaignSelected;
  final VoidCallback onCreateCampaign;

  /// Shows the campaign selector as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<Campaign> campaigns,
    required Campaign? activeCampaign,
    required ValueChanged<Campaign> onCampaignSelected,
    required VoidCallback onCreateCampaign,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => CampaignSelector(
        campaigns: campaigns,
        activeCampaign: activeCampaign,
        onCampaignSelected: onCampaignSelected,
        onCreateCampaign: onCreateCampaign,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              largePadding,
              largePadding,
              largePadding,
              smallPadding,
            ),
            child: Row(
              children: [
                Text(l10n.selectCampaign, style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onCreateCampaign();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.create),
                ),
              ],
            ),
          ),
          const Divider(height: dividerThickness),
          ...campaigns.map(
            (campaign) => ListTile(
              leading: Icon(
                Icons.public,
                color: campaign.id == activeCampaign?.id
                    ? theme.colorScheme.primary
                    : null,
              ),
              title: Text(campaign.name),
              subtitle: Text(campaign.edition.displayName),
              selected: campaign.id == activeCampaign?.id,
              onTap: () {
                Navigator.pop(context);
                onCampaignSelected(campaign);
              },
            ),
          ),
          const SizedBox(height: smallPadding),
        ],
      ),
    );
  }
}
