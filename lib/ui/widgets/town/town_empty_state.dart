import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

/// Empty state shown when no campaigns exist.
class TownEmptyState extends StatelessWidget {
  const TownEmptyState({super.key, required this.onCreateCampaign});

  final VoidCallback onCreateCampaign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.noCampaignsYet, style: textTheme.bodyLarge),
            const SizedBox(height: extraLargePadding),
            FilledButton.icon(
              onPressed: onCreateCampaign,
              icon: const Icon(Icons.add),
              label: Text(l10n.createCampaign),
            ),
          ],
        ),
      ),
    );
  }
}
