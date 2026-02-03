import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// A stacked icon showing all 6 elements layered together.
/// Used for the generic "Element" enhancement option.
class ElementStackIcon extends StatelessWidget {
  final double size;

  const ElementStackIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    // Scale factor based on the original 28px icon size
    final scale = size / 28;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            bottom: 5 * scale,
            top: 5 * scale,
            left: 5 * scale,
            child: ThemedSvg(assetKey: 'DARK', width: 10 * scale),
          ),
          Positioned(
            top: 4 * scale,
            left: 7 * scale,
            child: ThemedSvg(assetKey: 'AIR', width: 11 * scale),
          ),
          Positioned(
            top: 3 * scale,
            right: 6 * scale,
            child: ThemedSvg(assetKey: 'ICE', width: 12 * scale),
          ),
          Positioned(
            top: 0,
            right: 2 * scale,
            bottom: 2 * scale,
            child: ThemedSvg(assetKey: 'FIRE', width: 13 * scale),
          ),
          Positioned(
            bottom: 1 * scale,
            right: 4 * scale,
            child: ThemedSvg(assetKey: 'EARTH', width: 14 * scale),
          ),
          Positioned(
            bottom: 0,
            left: 3 * scale,
            child: ThemedSvg(assetKey: 'LIGHT', width: 15 * scale),
          ),
        ],
      ),
    );
  }
}
