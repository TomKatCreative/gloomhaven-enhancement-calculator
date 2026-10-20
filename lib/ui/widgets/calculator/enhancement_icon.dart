import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/element_stack_icon.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// The icon for an [Enhancement], drawn in a [size] square.
///
/// "Element" shows the stacked element icon, and +1 stat enhancements
/// ([Enhancement.isPlusOne]) carry a +1 badge. The icon always uses
/// `onSurface`, never an inherited [IconTheme] tint such as a selected
/// [ListTile]'s primary colour.
class EnhancementIcon extends StatelessWidget {
  final Enhancement enhancement;
  final double size;

  const EnhancementIcon({
    super.key,
    required this.enhancement,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      child: enhancement.name == 'Element'
          ? ElementStackIcon(size: size)
          : ThemedSvg(
              assetKey: enhancement.assetKey,
              width: size,
              height: size,
              showPlusOneOverlay: enhancement.isPlusOne,
            ),
    );
  }
}
