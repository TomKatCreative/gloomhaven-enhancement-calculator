import 'package:flutter/material.dart';

/// Extension for character-specific colors and custom theme properties
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color characterPrimary;

  /// Primary color with automatic contrast adjustment for text on surface backgrounds.
  /// Pre-calculated at theme build time for performance.
  final Color contrastedPrimary;

  const AppThemeExtension({
    required this.characterPrimary,
    required this.contrastedPrimary,
  });

  @override
  AppThemeExtension copyWith({
    Color? characterPrimary,
    Color? contrastedPrimary,
  }) {
    return AppThemeExtension(
      characterPrimary: characterPrimary ?? this.characterPrimary,
      contrastedPrimary: contrastedPrimary ?? this.contrastedPrimary,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      characterPrimary: Color.lerp(
        characterPrimary,
        other.characterPrimary,
        t,
      )!,
      contrastedPrimary: Color.lerp(
        contrastedPrimary,
        other.contrastedPrimary,
        t,
      )!,
    );
  }
}

extension ThemeDataContrast on ThemeData {
  /// Gets the primary color with automatic contrast adjustment for text on surface.
  /// Uses the pre-calculated color from AppThemeExtension for performance.
  Color get contrastedPrimary {
    final ext = extension<AppThemeExtension>();
    return ext?.contrastedPrimary ?? colorScheme.primary;
  }
}
