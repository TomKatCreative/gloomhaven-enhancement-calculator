import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';

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
        // Hint text style
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),

        // Label styles (for floating labels)
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),

        // Outlined border (default state)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        // Focused state
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),

        // Error states
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),

        // Disabled state
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),

        // Content padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: largePadding,
          vertical: mediumPadding,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.bodyMedium,
          foregroundColor: ColorUtils.ensureTextContrast(
            primaryColor,
            colorScheme.surface,
          ),
          iconSize: iconSizeMedium,
        ),
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

      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: hairlineThickness,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 0,
        selectedItemColor: ColorUtils.ensureTextContrast(
          primaryColor,
          colorScheme.surfaceContainer,
        ),
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
          contrastedPrimary: ColorUtils.ensureTextContrast(
            primaryColor,
            colorScheme.surface,
          ),
        ),
      ],
    );
  }

  /// Builds the complete M3 TextTheme for default fonts mode (Inter).
  ///
  /// Based on M3 type scale, scaled up for better readability in this app.
  /// Display/Headline sizes kept at M3 defaults; Body/Label/Title scaled ~1.3x.
  static TextTheme _buildDefaultTextTheme(Brightness brightness) {
    final shadow = _textShadow(brightness);

    return TextTheme(
      // Display - large hero text (M3 defaults)
      displayLarge: const TextStyle(fontSize: 57, fontFamily: inter),
      displayMedium: TextStyle(
        fontSize: 45,
        fontFamily: inter,
        shadows: shadow,
      ),
      displaySmall: const TextStyle(fontSize: 36, fontFamily: inter),
      // Headline - screen/section titles (M3 defaults)
      headlineLarge: const TextStyle(fontSize: 32, fontFamily: inter),
      headlineMedium: const TextStyle(fontSize: 28, fontFamily: inter),
      headlineSmall: const TextStyle(fontSize: 24, fontFamily: inter),
      // Title - smaller titles, emphasized text (scaled up)
      titleLarge: const TextStyle(fontSize: 22, fontFamily: inter),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontFamily: inter,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: const TextStyle(
        fontSize: 16,
        fontFamily: inter,
        fontWeight: FontWeight.w500,
      ),
      // Body - main reading text (scaled up for readability)
      bodyLarge: const TextStyle(fontSize: 22, fontFamily: inter),
      bodyMedium: const TextStyle(fontSize: 20, fontFamily: inter),
      bodySmall: const TextStyle(fontSize: 18, fontFamily: inter),
      // Label - buttons, captions, annotations (scaled up)
      labelLarge: const TextStyle(
        fontSize: 16,
        fontFamily: inter,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: const TextStyle(
        fontSize: 14,
        fontFamily: inter,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontFamily: inter,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Builds the complete M3 TextTheme for custom fonts mode.
  ///
  /// Based on M3 type scale, scaled up for better readability in this app.
  /// - displayMedium: PirataOne (decorative game font for character names)
  /// - All others: Nyala (readable game-themed font)
  static TextTheme _buildCustomTextTheme(Brightness brightness) {
    final shadow = _textShadow(brightness);

    return TextTheme(
      // Display
      displayLarge: const TextStyle(fontSize: 57, fontFamily: nyala),
      displayMedium: TextStyle(
        fontSize: 45,
        fontFamily: pirataOne,
        letterSpacing: 1.5,
        shadows: shadow,
      ),
      displaySmall: const TextStyle(fontSize: 36, fontFamily: nyala),
      // Headline
      headlineLarge: const TextStyle(fontSize: 32, fontFamily: nyala),
      headlineMedium: const TextStyle(fontSize: 28, fontFamily: nyala),
      headlineSmall: const TextStyle(fontSize: 24, fontFamily: nyala),
      // Title
      titleLarge: const TextStyle(fontSize: 22, fontFamily: nyala),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontFamily: nyala,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: const TextStyle(
        fontSize: 16,
        fontFamily: nyala,
        fontWeight: FontWeight.w500,
      ),
      // Body
      bodyLarge: const TextStyle(fontSize: 22, fontFamily: nyala),
      bodyMedium: const TextStyle(fontSize: 20, fontFamily: nyala),
      bodySmall: const TextStyle(fontSize: 18, fontFamily: nyala),
      // Label
      labelLarge: const TextStyle(
        fontSize: 16,
        fontFamily: nyala,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: const TextStyle(
        fontSize: 14,
        fontFamily: nyala,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: const TextStyle(
        fontSize: 12,
        fontFamily: nyala,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Returns a subtle text shadow for light mode, empty for dark mode.
  /// Used for display and headline text to improve readability.
  static List<Shadow> _textShadow(Brightness brightness) {
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
