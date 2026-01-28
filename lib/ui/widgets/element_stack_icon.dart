import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            child: SvgPicture.asset(
              'images/elements/elem_dark.svg',
              width: 10 * scale,
            ),
          ),
          Positioned(
            top: 4 * scale,
            left: 7 * scale,
            child: SvgPicture.asset(
              'images/elements/elem_air.svg',
              width: 11 * scale,
            ),
          ),
          Positioned(
            top: 3 * scale,
            right: 6 * scale,
            child: SvgPicture.asset(
              'images/elements/elem_ice.svg',
              width: 12 * scale,
            ),
          ),
          Positioned(
            top: 0,
            right: 2 * scale,
            bottom: 2 * scale,
            child: SvgPicture.asset(
              'images/elements/elem_fire.svg',
              width: 13 * scale,
            ),
          ),
          Positioned(
            bottom: 1 * scale,
            right: 4 * scale,
            child: SvgPicture.asset(
              'images/elements/elem_earth.svg',
              width: 14 * scale,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 3 * scale,
            child: SvgPicture.asset(
              'images/elements/elem_light.svg',
              width: 15 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
