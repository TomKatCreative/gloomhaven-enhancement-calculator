import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gloomhaven_enhancement_calc/utils/asset_config.dart';

/// A widget that renders an SVG icon with proper theme-based coloring.
///
/// Takes an asset key (e.g., 'MOVE', 'ATTACK', 'LOSS') which is looked up in
/// [asset_config.dart] to get the file path and theming configuration.
///
/// For icons with [usesCurrentColor], uses [SvgTheme] so only SVG elements
/// with `fill="currentColor"` change based on theme. Other colors are preserved.
///
/// ## Usage
///
/// ```dart
/// ThemedSvg(assetKey: 'MOVE', width: 24)
/// ThemedSvg(assetKey: 'ATTACK', width: 24, color: Colors.red)
/// ThemedSvg(assetKey: 'MOVE', width: 24, showPlusOneOverlay: true)
/// ```
class ThemedSvg extends StatelessWidget {
  /// The asset key to look up in [asset_config.dart].
  ///
  /// Examples: 'MOVE', 'ATTACK', 'LOSS', 'SHIELD', 'Wild_Element'
  final String assetKey;

  /// Optional width for the icon.
  final double? width;

  /// Optional height for the icon.
  final double? height;

  /// Optional custom color to tint the icon.
  /// When provided, overrides theme-based coloring.
  final Color? color;

  /// When true, overlays a +1 badge on the icon.
  /// Used for enhancement icons like ATTACK+1, MOVE+1, etc.
  final bool showPlusOneOverlay;

  const ThemedSvg({
    super.key,
    required this.assetKey,
    this.width,
    this.height,
    this.color,
    this.showPlusOneOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkTheme = theme.brightness == Brightness.dark;
    final config = getAssetConfig(assetKey);
    final fullPath = 'images/${config.pathForTheme(darkTheme)}';
    final effectiveWidth = width != null
        ? width! * config.widthMultiplier
        : null;

    // Respect IconTheme so ThemedSvg adapts to context (e.g. NavigationBar
    // selected/unselected states). Falls back to onSurface.
    final iconColor =
        IconTheme.of(context).color ?? theme.colorScheme.onSurface;

    final icon = _buildThemedIcon(fullPath, effectiveWidth, iconColor, config);

    if (showPlusOneOverlay) {
      final size = width ?? height ?? 24.0;
      final plusOneConfig = getAssetConfig('plus_one');
      return Stack(
        alignment: const Alignment(1.75, -1.75),
        children: [
          icon,
          SvgPicture.asset(
            'images/${plusOneConfig.pathForTheme(darkTheme)}',
            width: size * 0.5,
            height: size * 0.5,
          ),
        ],
      );
    }

    return icon;
  }

  Widget _buildThemedIcon(
    String fullPath,
    double? effectiveWidth,
    Color onSurface,
    AssetConfig config,
  ) {
    // Handle custom color override (takes precedence over all other coloring)
    if (color != null) {
      return SvgPicture.asset(
        fullPath,
        width: effectiveWidth,
        height: height,
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }

    // Use pattern matching on themeMode for type-safe theming
    return switch (config.themeMode) {
      // Use SvgTheme so only parts with fill="currentColor" or
      // stroke="currentColor" change color
      CurrentColorTheme() => SvgPicture(
        SvgAssetLoader(fullPath, theme: SvgTheme(currentColor: onSurface)),
        width: effectiveWidth,
        height: height,
      ),
      // No color modification needed
      _ => SvgPicture.asset(fullPath, width: effectiveWidth, height: height),
    };
  }
}
