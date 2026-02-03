import 'package:flutter/material.dart';

/// Extension for character-specific colors and custom theme properties
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color characterPrimary;
  final Color characterSecondary;
  final Color characterAccent;
  final bool isRetiredCharacter;

  /// Primary color with automatic contrast adjustment for text on surface backgrounds.
  /// Pre-calculated at theme build time for performance.
  final Color contrastedPrimary;

  const AppThemeExtension({
    required this.characterPrimary,
    required this.characterSecondary,
    required this.characterAccent,
    required this.contrastedPrimary,
    this.isRetiredCharacter = false,
  });

  @override
  AppThemeExtension copyWith({
    Color? characterPrimary,
    Color? characterSecondary,
    Color? characterAccent,
    Color? contrastedPrimary,
    bool? isRetiredCharacter,
  }) {
    return AppThemeExtension(
      characterPrimary: characterPrimary ?? this.characterPrimary,
      characterSecondary: characterSecondary ?? this.characterSecondary,
      characterAccent: characterAccent ?? this.characterAccent,
      contrastedPrimary: contrastedPrimary ?? this.contrastedPrimary,
      isRetiredCharacter: isRetiredCharacter ?? this.isRetiredCharacter,
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
      characterSecondary: Color.lerp(
        characterSecondary,
        other.characterSecondary,
        t,
      )!,
      characterAccent: Color.lerp(characterAccent, other.characterAccent, t)!,
      contrastedPrimary: Color.lerp(
        contrastedPrimary,
        other.contrastedPrimary,
        t,
      )!,
      isRetiredCharacter: t < 0.5
          ? isRetiredCharacter
          : other.isRetiredCharacter,
    );
  }
}

/// Convenient extensions for accessing theme colors with proper contrast
extension ColorSchemeContrast on ColorScheme {
  /// Gets the primary color with automatic contrast adjustment for text on surface.
  /// Returns the pre-calculated contrasted color from AppThemeExtension if available,
  /// otherwise falls back to the standard primary color.
  Color get contrastedPrimary => primary;
}

extension ThemeDataContrast on ThemeData {
  /// Gets the primary color with automatic contrast adjustment for text on surface.
  /// Uses the pre-calculated color from AppThemeExtension for performance.
  Color get contrastedPrimary {
    final ext = extension<AppThemeExtension>();
    return ext?.contrastedPrimary ?? colorScheme.primary;
  }

  /// Gets the appropriate text shadow for display text based on brightness.
  /// Dark mode: subtle white glow, Light mode: soft drop shadow.
  List<Shadow> get displayTextShadow {
    return brightness == Brightness.dark
        ? []
        : [
            Shadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ];
  }
}
