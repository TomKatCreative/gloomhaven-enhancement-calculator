import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// A label row with an icon, used for section headers.
///
/// Can be used standalone for non-text-field sections (sliders, toggles).
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.icon,
    this.svgAssetKey,
    this.textStyle,
    this.iconSize,
  }) : assert(
         icon != null || svgAssetKey != null,
         'Either icon or svgAssetKey must be provided',
       );

  /// The label text to display.
  final String label;

  /// Material icon to display before the label.
  final IconData? icon;

  /// SVG asset key to display before the label (alternative to [icon]).
  final String? svgAssetKey;

  /// Custom text style for the label. If null, uses labelLarge.
  final TextStyle? textStyle;

  /// Custom icon size. If null, uses iconSizeSmall.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final size = iconSize ?? iconSizeSmall;

    return Row(
      children: [
        if (icon != null)
          Icon(icon, size: size, color: theme.colorScheme.onSurfaceVariant),
        if (svgAssetKey != null)
          ThemedSvg(
            assetKey: svgAssetKey!,
            width: size,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        const SizedBox(width: smallPadding),
        Text(label, style: textStyle ?? defaultStyle),
      ],
    );
  }
}
