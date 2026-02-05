import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// A stacked icon showing all 6 elements layered together.
/// Used for the generic "Element" enhancement option.
class ElementStackIcon extends StatelessWidget {
  final double size;

  const ElementStackIcon({super.key, required this.size});

  /// Element layout configurations: [assetKey, width, top, right, bottom, left]
  /// Values are in the base coordinate system and scaled proportionally.
  /// Elements are listed back-to-front (DARK at back, LIGHT at front).
  static const List<_ElementPosition> _elements = [
    _ElementPosition('DARK', width: 10, top: 5, bottom: 5, left: 5),
    _ElementPosition('AIR', width: 11, top: 4, left: 7),
    _ElementPosition('ICE', width: 12, top: 3, right: 6),
    _ElementPosition('FIRE', width: 13, top: 0, right: 2, bottom: 2),
    _ElementPosition('EARTH', width: 14, bottom: 1, right: 4),
    _ElementPosition('LIGHT', width: 15, bottom: 0, left: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = size / iconSizeLarge;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: _elements.map((e) => e.toPositioned(scale)).toList(),
      ),
    );
  }
}

/// Defines position and size for a single element in the stack.
class _ElementPosition {
  final String assetKey;
  final double width;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const _ElementPosition(
    this.assetKey, {
    required this.width,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  Widget toPositioned(double scale) {
    return Positioned(
      top: top != null ? top! * scale : null,
      right: right != null ? right! * scale : null,
      bottom: bottom != null ? bottom! * scale : null,
      left: left != null ? left! * scale : null,
      child: ThemedSvg(assetKey: assetKey, width: width * scale),
    );
  }
}
