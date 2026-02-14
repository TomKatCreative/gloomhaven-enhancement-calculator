import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/resource.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final Color iconColor;
  final int count;
  final VoidCallback? onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.iconColor,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        border: Border.all(
          color: onTap != null
              ? iconColor.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: onTap != null ? dividerThickness : hairlineThickness,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = constraints.maxHeight / 2;
            return Stack(
              children: [
                // Resource icon — bottom center
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: smallPadding,
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: ThemedSvg(
                      assetKey: resource.icon,
                      width: iconSize,
                      color: iconColor.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                // Resource name — top center
                Positioned(
                  top: tinyPadding,
                  left: tinyPadding,
                  right: tinyPadding,
                  child: AutoSizeText(
                    resource.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Count badge — bottom right
                Positioned(
                  right: tinyPadding,
                  bottom: tinyPadding,
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
