import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/world.dart';

/// Bottom sheet selector for switching between worlds.
class WorldSelector extends StatelessWidget {
  const WorldSelector({
    super.key,
    required this.worlds,
    required this.activeWorld,
    required this.onWorldSelected,
    required this.onCreateWorld,
  });

  final List<World> worlds;
  final World? activeWorld;
  final ValueChanged<World> onWorldSelected;
  final VoidCallback onCreateWorld;

  /// Shows the world selector as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<World> worlds,
    required World? activeWorld,
    required ValueChanged<World> onWorldSelected,
    required VoidCallback onCreateWorld,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => WorldSelector(
        worlds: worlds,
        activeWorld: activeWorld,
        onWorldSelected: onWorldSelected,
        onCreateWorld: onCreateWorld,
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
                Text(l10n.selectWorld, style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onCreateWorld();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.create),
                ),
              ],
            ),
          ),
          const Divider(height: dividerThickness),
          ...worlds.map(
            (world) => ListTile(
              leading: Icon(
                Icons.public,
                color: world.id == activeWorld?.id
                    ? theme.colorScheme.primary
                    : null,
              ),
              title: Text(world.name),
              subtitle: Text(world.edition.displayName),
              selected: world.id == activeWorld?.id,
              onTap: () {
                Navigator.pop(context);
                onWorldSelected(world);
              },
            ),
          ),
          const SizedBox(height: smallPadding),
        ],
      ),
    );
  }
}
