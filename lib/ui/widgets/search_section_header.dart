import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
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
/// A [SliverPersistentHeaderDelegate] that pins a [SearchSectionHeader] to
/// the top of a [CustomScrollView].
///
/// Uses a solid `colorScheme.surface` background so list items don't show
/// through the pinned header.
///
/// Used by:
/// - [ClassSelectorScreen] — sticky category headers
/// - [EnhancementTypeSelectorScreen] — sticky category headers with icons
class SearchSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String? assetKey;

  const SearchSectionHeaderDelegate({required this.title, this.assetKey});

  // largePadding(16) + iconSizeMedium(26) + smallPadding(8) = 50
  static const _height = largePadding + iconSizeMedium + smallPadding;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: _height,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SearchSectionHeader(title: title, assetKey: assetKey),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchSectionHeaderDelegate oldDelegate) =>
      title != oldDelegate.title || assetKey != oldDelegate.assetKey;
}

class SearchSectionHeader extends StatelessWidget {
  /// The section title to display.
  final String title;

  /// Optional asset key for a [ThemedSvg] icon displayed before the title.
  /// Keys are defined in `lib/utils/asset_config.dart`.
  final String? assetKey;

  const SearchSectionHeader({super.key, required this.title, this.assetKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        largePadding,
        largePadding,
        largePadding,
        smallPadding,
      ),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.dividerTheme.color)),
          const SizedBox(width: mediumPadding),
          if (assetKey != null) ...[
            ThemedSvg(
              assetKey: assetKey!,
              width: iconSizeSmall,
              height: iconSizeSmall,
            ),
            const SizedBox(width: smallPadding),
          ],
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.contrastedPrimary,
            ),
          ),
          const SizedBox(width: mediumPadding),
          Expanded(child: Divider(color: theme.dividerTheme.color)),
        ],
      ),
    );
  }
}
