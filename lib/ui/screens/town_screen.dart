import 'package:flutter/material.dart';

import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

class TownScreen extends StatelessWidget {
  const TownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.castle_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(l10n.town, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.comingSoon,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
