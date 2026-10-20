import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';

/// The large faded class icon behind the character sheet's header.
///
/// It is drawn twice: once by the character screen, behind everything so it
/// shows through the transparent header and nav bar, and once inside
/// [CharacterHeaderDelegate], whose opaque background would otherwise cover
/// it. Both copies use this widget so they line up exactly.
///
/// Must be a direct child of a [Stack] (it returns a [Positioned]).
class ClassIconBackdrop extends StatelessWidget {
  const ClassIconBackdrop({
    super.key,
    required this.character,
    required this.headerHeight,
    required this.collapseProgress,
  });

  /// Offsets that let the icon bleed past the top-right corner.
  static const double _right = -32;
  static const double _top = -45;
  static const double _extraHeight = 75;
  static const double _width = 260;

  /// Opacity with the header fully expanded; fades to 0 as it collapses.
  static const double maxOpacity = 0.15;

  final Character character;

  /// The header's expanded height (the chip bar is added on top).
  final double headerHeight;

  /// How far the header has collapsed, 0 (expanded) to 1 (collapsed).
  final double collapseProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      right: _right,
      top: _top,
      height: headerHeight + chipBarHeight + _extraHeight,
      width: _width,
      child: Opacity(
        opacity: (maxOpacity * (1 - collapseProgress)).clamp(0.0, maxOpacity),
        child: ClassIconSvg(
          playerClass: character.playerClass,
          color: ColorUtils.ensureContrast(
            character.getEffectiveColor(theme.brightness),
            theme.colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
