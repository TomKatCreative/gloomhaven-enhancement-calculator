import 'dart:math';
import 'package:flutter/material.dart';

/// Utilities for color manipulation and contrast calculation.
class ColorUtils {
  /// Calculates the contrast ratio between two colors.
  ///
  /// Returns a value between 1 and 21, where higher values indicate
  /// greater contrast. WCAG 2.1 guidelines recommend:
  /// - 4.5:1 for normal text (AA compliance)
  /// - 7:1 for normal text (AAA compliance)
  /// - 3:1 for large text (AA compliance)
  ///
  /// See: https://www.w3.org/TR/WCAG21/#contrast-minimum
  static double contrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final lighter = max(luminance1, luminance2);
    final darker = min(luminance1, luminance2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Ensures sufficient contrast between text and background colors.
  ///
  /// If the contrast ratio is below [minContrastRatio] (default 4.5:1 for WCAG AA),
  /// the text color will be progressively darkened (or lightened for dark backgrounds)
  /// until sufficient contrast is achieved.
  ///
  /// Example:
  /// ```dart
  /// final readableColor = ColorUtils.ensureTextContrast(
  ///   Color(0xffdfddcb), // Light beige
  ///   Colors.white,      // White background
  /// );
  /// // Returns a darker version of the beige that's readable on white
  /// ```
  static Color ensureTextContrast(
    Color textColor,
    Color backgroundColor, {
    double minContrastRatio = 4.5,
  }) {
    // If contrast is already sufficient, return original color
    if (contrastRatio(textColor, backgroundColor) >= minContrastRatio) {
      return textColor;
    }

    // Determine if we should darken or lighten based on background
    final backgroundLuminance = backgroundColor.computeLuminance();
    final shouldDarken = backgroundLuminance > 0.5;

    // Convert to HSL for better color manipulation
    final hsl = HSLColor.fromColor(textColor);

    // Progressively adjust lightness until contrast is sufficient
    double lightness = hsl.lightness;
    const step = 0.05; // 5% adjustment per iteration
    const maxIterations = 20; // Prevent infinite loops

    for (int i = 0; i < maxIterations; i++) {
      if (shouldDarken) {
        lightness -= step;
        if (lightness < 0) lightness = 0;
      } else {
        lightness += step;
        if (lightness > 1) lightness = 1;
      }

      final adjustedColor = hsl.withLightness(lightness).toColor();
      if (contrastRatio(adjustedColor, backgroundColor) >= minContrastRatio) {
        return adjustedColor;
      }

      // If we've hit the limits (pure black or white), return that
      if (lightness <= 0 || lightness >= 1) {
        return adjustedColor;
      }
    }

    // Fallback: return fully darkened or lightened version
    return shouldDarken ? Colors.black : Colors.white;
  }

  /// Returns a color suitable for text display on the given background.
  ///
  /// This is a convenience method that uses the theme's primary color
  /// and ensures it has sufficient contrast against the background.
  ///
  /// Example:
  /// ```dart
  /// final textColor = ColorUtils.readableTextColor(
  ///   theme.colorScheme.primary,
  ///   theme.colorScheme.surface,
  /// );
  /// ```
  static Color readableTextColor(
    Color preferredColor,
    Color backgroundColor,
  ) {
    return ensureTextContrast(preferredColor, backgroundColor);
  }
}
