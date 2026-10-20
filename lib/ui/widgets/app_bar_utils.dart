import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

/// Shared utilities for AppBar styling across the app.
class AppBarUtils {
  /// Returns the surface color with an 8% primary tint overlay.
  ///
  /// This creates the consistent tinted AppBar background used throughout
  /// the app for pushed routes.
  static Color getTintedBackground(ColorScheme colorScheme) {
    return Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.08),
      colorScheme.surface,
    );
  }
}

/// Fades a background from `surface` to [AppBarUtils.getTintedBackground]
/// while [tinted] is true, and back when it turns false.
///
/// [builder] gets the blended colour and the tint progress (0–1). Give this
/// widget a key (e.g. the character's UUID) so that, when the content it sits
/// over changes, it jumps straight to the new state instead of fading from
/// the old one.
class ScrollTintBuilder extends StatelessWidget {
  const ScrollTintBuilder({
    super.key,
    required this.tinted,
    required this.builder,
    this.child,
  });

  final bool tinted;
  final Widget Function(
    BuildContext context,
    Color background,
    double progress,
    Widget? child,
  )
  builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: tinted ? 1.0 : 0.0),
      duration: tintAnimationDuration,
      curve: Curves.easeInOut,
      builder: (context, progress, child) => builder(
        context,
        Color.lerp(
          colorScheme.surface,
          AppBarUtils.getTintedBackground(colorScheme),
          progress,
        )!,
        progress,
        child,
      ),
      child: child,
    );
  }
}
