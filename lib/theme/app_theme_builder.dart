import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';

class AppThemeBuilder {
  /// The dark surface color for the Android system navigation bar.
  /// Note: This matches M3's default dark surface color.
  static const Color darkSurface = Color(0xff1c1b1f);
  // Cache themes to avoid rebuilding
  static final Map<int, ThemeData> _lightThemeCache = {};
  static final Map<int, ThemeData> _darkThemeCache = {};

  static ThemeData buildLightTheme(ThemeConfig config) {
    final cacheKey = config.hashCode;

    if (_lightThemeCache.containsKey(cacheKey)) {
      return _lightThemeCache[cacheKey]!;
    }

    final theme = _buildTheme(config: config, brightness: Brightness.light);

    _lightThemeCache[cacheKey] = theme;
    return theme;
  }

  static ThemeData buildDarkTheme(ThemeConfig config) {
    final cacheKey = config.hashCode;

    if (_darkThemeCache.containsKey(cacheKey)) {
      return _darkThemeCache[cacheKey]!;
    }

    final theme = _buildTheme(config: config, brightness: Brightness.dark);

    _darkThemeCache[cacheKey] = theme;
    return theme;
  }

  static void clearCache() {
    _lightThemeCache.clear();
    _darkThemeCache.clear();
  }

  static ThemeData _buildTheme({
    required ThemeConfig config,
    required Brightness brightness,
  }) {
    final primaryColor = config.seedColor;

    // Generate a neutral base palette, then override primary colors with character color
    final baseScheme = ColorScheme.fromSeed(
      seedColor: Colors.grey,
      brightness: brightness,
      surfaceTint: Colors.transparent,
    );

    // Calculate contrast colors based on the character's primary color brightness
    final onPrimary =
        ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    // Generate primary container as a lighter/darker variant of the primary
    final primaryContainer = brightness == Brightness.dark
        ? _lighten(primaryColor, 15)
        : _lighten(primaryColor, 30);
    final onPrimaryContainer =
        ThemeData.estimateBrightnessForColor(primaryContainer) ==
            Brightness.dark
        ? Colors.white
        : Colors.black87;

    // Override the primary accent colors with the character's color
    final colorScheme = baseScheme.copyWith(
      primary: primaryColor,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      // Also set secondary to match for consistency
      secondary: primaryColor,
      onSecondary: onPrimary,
    );

    final textTheme = config.useDefaultFonts
        ? _buildDefaultTextTheme(brightness)
        : _buildCustomTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: config.useDefaultFonts ? inter : nyala,
      textTheme: textTheme,

      // Disable splash effects
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,

      // Component themes
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyMedium,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.bodyMedium),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected) &&
              states.contains(WidgetState.disabled)) {
            return _lighten(primaryColor, 30);
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onPrimary;
          }
          return null;
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        actionTextColor: colorScheme.inversePrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.5,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return null;
          }),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: brightness == Brightness.dark ? 4 : 1,
        color: brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLow,
      ),

      chipTheme: ChipThemeData(
        showCheckmark: false,
        selectedColor: colorScheme.primaryContainer,
      ),

      // Add custom extension with exact character color
      extensions: [
        AppThemeExtension(
          characterPrimary: primaryColor,
          characterSecondary: primaryColor,
          characterAccent: _adjustColor(primaryColor, brightness),
        ),
      ],
    );
  }

  static TextTheme _buildDefaultTextTheme(Brightness brightness) {
    return const TextTheme().copyWith(
      bodyMedium: const TextStyle(fontSize: 20.0, fontFamily: inter),
      bodyLarge: const TextStyle(fontSize: 25),
      displayMedium: const TextStyle(fontFamily: inter),
    );
  }

  static TextTheme _buildCustomTextTheme(Brightness brightness) {
    return const TextTheme().copyWith(
      bodyMedium: const TextStyle(fontSize: 25.0, fontFamily: nyala),
      bodyLarge: const TextStyle(fontSize: 25),
      displayMedium: const TextStyle(fontFamily: pirataOne, letterSpacing: 1.5),
      headlineMedium: const TextStyle(fontSize: 35),
    );
  }

  static Color _adjustColor(Color color, Brightness brightness) {
    // Create lighter/darker variants based on brightness
    return brightness == Brightness.dark
        ? _lighten(color, 10)
        : _darken(color, 10);
  }

  static Color _darken(Color color, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final f = 1 - percent / 100;
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * f * 255).round(),
      (color.g * f * 255).round(),
      (color.b * f * 255).round(),
    );
  }

  static Color _lighten(Color color, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final p = percent / 100;
    final r = color.r * 255;
    final g = color.g * 255;
    final b = color.b * 255;
    return Color.fromARGB(
      (color.a * 255).round(),
      (r + (255 - r) * p).round(),
      (g + (255 - g) * p).round(),
      (b + (255 - b) * p).round(),
    );
  }
}
