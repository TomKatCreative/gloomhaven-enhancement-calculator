import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// A reusable section header widget for search/selector screens.
///
/// Renders a centered title with optional icon, flanked by horizontal dividers:
/// ```
/// ─────────── [Icon] Title ───────────
/// ```
///
/// Used by:
/// - [ClassSelectorScreen] - Groups classes by [ClassCategory]
/// - [EnhancementTypeSelector] - Groups enhancements by [EnhancementCategory]
///
/// ## Usage
/// ```dart
/// SearchSectionHeader(
///   title: 'Gloomhaven',
///   assetKey: 'MOVE', // Optional icon from asset_config.dart
/// )
/// ```
class SearchSectionHeader extends StatelessWidget {
  /// The section title to display.
  final String title;

  /// Optional asset key for a [ThemedSvg] icon displayed before the title.
  /// Keys are defined in `lib/utils/asset_config.dart`.
  final String? assetKey;

  const SearchSectionHeader({
    super.key,
    required this.title,
    this.assetKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.dividerTheme.color)),
          const SizedBox(width: 12),
          if (assetKey != null) ...[
            ThemedSvg(assetKey: assetKey!, width: 24, height: 24),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: theme.dividerTheme.color)),
        ],
      ),
    );
  }
}
