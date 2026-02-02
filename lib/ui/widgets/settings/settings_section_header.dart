import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

/// A section header widget for grouping related settings.
///
/// Displays a colored title text in the leading position of a ListTile.
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.contrastedPrimary,
        ),
      ),
    );
  }
}
