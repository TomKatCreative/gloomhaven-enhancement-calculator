import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

/// Renders a player class icon with proper theming.
///
/// Uses the class's [PlayerClass.classCode] as the asset key (which maps to
/// the appropriate SVG in `asset_config.dart`) and applies the class's
/// [PlayerClass.primaryColor] by default.
///
/// ## Usage
///
/// ```dart
/// // Basic usage - uses class primary color
/// ClassIconSvg(playerClass: myClass, width: 24)
///
/// // With custom color override
/// ClassIconSvg(playerClass: myClass, width: 24, color: Colors.red)
/// ```
class ClassIconSvg extends StatelessWidget {
  /// The player class whose icon should be rendered.
  final PlayerClass playerClass;

  /// Optional width for the icon.
  final double? width;

  /// Optional height for the icon.
  final double? height;

  /// Optional color override. Defaults to [PlayerClass.primaryColor].
  final Color? color;

  const ClassIconSvg({
    super.key,
    required this.playerClass,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedSvg(
      assetKey: playerClass.classCode,
      width: width,
      height: height,
      color: color ?? Color(playerClass.primaryColor),
    );
  }
}
