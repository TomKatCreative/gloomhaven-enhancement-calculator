import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';

/// Empty state shown when no worlds exist.
class TownEmptyState extends StatelessWidget {
  const TownEmptyState({super.key, required this.onCreateWorld});

  final VoidCallback onCreateWorld;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(extraLargePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.castle_outlined,
              size: iconSizeHero,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: largePadding),
            Text(l10n.noWorldsYet, style: textTheme.bodyLarge),
            const SizedBox(height: extraLargePadding),
            FilledButton.icon(
              onPressed: onCreateWorld,
              icon: const Icon(Icons.add),
              label: Text(l10n.createWorld),
            ),
          ],
        ),
      ),
    );
  }
}
