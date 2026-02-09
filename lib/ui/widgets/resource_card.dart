import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/resource.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final Color color;
  final int count;
  final Function() onIncrease;
  final Function() onDecrease;
  final bool canEdit;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.color,
    required this.count,
    required this.onIncrease,
    required this.onDecrease,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background icon - fills the full card
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              child: ThemedSvg(assetKey: resource.icon, color: color),
            ),
          ),
          // Count positioning
          if (canEdit)
            // Edit mode: truly centered in full card
            Center(child: Text('$count'))
          else
            // View mode: centered but offset upward
            Align(
              alignment: const Alignment(0, 0.6),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          // Foreground content layered on top
          Column(
            children: [
              _ResourceHeader(resource: resource),
              if (canEdit) const Spacer(),
              if (canEdit)
                _ResourceButtonBar(
                  onDecrease: onDecrease,
                  onIncrease: onIncrease,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourceHeader extends StatelessWidget {
  final Resource resource;

  const _ResourceHeader({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(tinyPadding),
      child: AutoSizeText(
        resource.name,
        maxLines: 1,
        maxFontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 18,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ResourceButtonBar extends StatelessWidget {
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ResourceButtonBar({
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = theme.colorScheme.inverseSurface.withValues(alpha: 0.7);
    final iconColor = theme.colorScheme.onInverseSurface;

    return SizedBox(
      height: iconSizeMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Material(
              color: buttonColor,
              child: InkWell(
                onTap: onDecrease,
                child: Center(
                  child: Icon(
                    Icons.remove_rounded,
                    color: iconColor,
                    size: iconSizeSmall,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: dividerThickness,
            color: iconColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: Material(
              color: buttonColor,
              child: InkWell(
                onTap: onIncrease,
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: iconColor,
                    size: iconSizeSmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
