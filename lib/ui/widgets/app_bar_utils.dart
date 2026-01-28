import 'package:flutter/material.dart';

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
