import 'package:flutter/material.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_extensions.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';

class AppThemeBuilder {
  // Content-addressed theme cache, keyed by the config itself. ThemeConfig is
  // immutable with `==` defined over all theme inputs (seedColor, useDarkMode,
  // useDefaultFonts), so two configs that merely share a hash code never share
  // a theme. A given config always produces the same theme, so the cache
  // cannot go stale — no invalidation API is needed.
  static final Map<ThemeConfig, ThemeData> _lightThemeCache = {};
  static final Map<ThemeConfig, ThemeData> _darkThemeCache = {};

  static ThemeData buildLightTheme(ThemeConfig config) {
    return _lightThemeCache.putIfAbsent(
      config,
      () => _buildTheme(config: config, brightness: Brightness.light),
    );
  }

  static ThemeData buildDarkTheme(ThemeConfig config) {
    return _darkThemeCache.putIfAbsent(
      config,
      () => _buildTheme(config: config, brightness: Brightness.dark),
    );
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
      secondaryContainer: primaryContainer,
      onSecondaryContainer: onPrimaryContainer,
    );

    final textTheme = config.useDefaultFonts
        ? _buildTextTheme(brightness, bodyFont: inter, displayFont: inter)
        : _buildTextTheme(
            brightness,
            bodyFont: nyala,
            displayFont: pirataOne,
            displayLetterSpacing: 1.5,
          );

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

      // MaterialApp's defaults, set explicitly. A nested Theme with no
      // selection colors inherits the app's, and every Text depends on them,
      // so each character page (see CharacterPageTheme) would rebuild all its
      // text whenever the app color changes on a swipe.
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.primary.withValues(alpha: 0.4),
        cursorColor: colorScheme.primary,
      ),

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
          color: ColorUtils.ensureContrast(primaryColor, colorScheme.surface),
          fontWeight: FontWeight.w500,
        ),

        // Outlined border (default state)
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),

        // Focused state
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: ColorUtils.ensureContrast(primaryColor, colorScheme.surface),
          ),
        ),

        // Error states
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.error,
            width: focusedBorderThickness,
          ),
        ),

        // Disabled state
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),

        // Content padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: largePadding,
          vertical: smallPadding,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.bodyMedium,
          foregroundColor: ColorUtils.ensureContrast(
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

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 0,
        indicatorColor: ColorUtils.ensureContrast(
          primaryColor,
          colorScheme.surfaceContainer,
        ).withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: ColorUtils.ensureContrast(
                primaryColor,
                colorScheme.surfaceContainer,
              ),
            );
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: fontSizeLabelSmall,
              fontWeight: FontWeight.w600,
              color: ColorUtils.ensureContrast(
                primaryColor,
                colorScheme.surfaceContainer,
              ),
            );
          }
          return TextStyle(
            fontSize: fontSizeLabelSmall,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      segmentedButtonTheme: const SegmentedButtonThemeData(),

      cardTheme: CardThemeData(
        elevation: brightness == Brightness.dark ? 4 : 1,
        color: brightness == Brightness.dark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLow,
      ),

      popupMenuTheme: PopupMenuThemeData(
        labelTextStyle: WidgetStatePropertyAll(textTheme.bodySmall),
      ),

      chipTheme: ChipThemeData(showCheckmark: false),

      // Add custom extension with exact character color
      extensions: [
        AppThemeExtension(
          characterPrimary: primaryColor,
          contrastedPrimary: ColorUtils.ensureContrast(
            primaryColor,
            colorScheme.surface,
          ),
        ),
      ],
    );
  }

  /// Builds the complete M3 TextTheme.
  ///
  /// Based on M3 type scale, scaled up for better readability in this app.
  /// Display/Headline sizes kept at M3 defaults; Body/Label/Title scaled ~1.3x.
  /// [displayFont] is used only for displayMedium (character names); every
  /// other style uses [bodyFont].
  static TextTheme _buildTextTheme(
    Brightness brightness, {
    required String bodyFont,
    required String displayFont,
    double? displayLetterSpacing,
  }) {
    final shadow = _textShadow(brightness);

    return TextTheme(
      // Display - large hero text (M3 defaults)
      displayLarge: TextStyle(
        fontSize: fontSizeDisplayLarge,
        fontFamily: bodyFont,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeDisplayMedium,
        fontFamily: displayFont,
        letterSpacing: displayLetterSpacing,
        shadows: shadow,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeDisplaySmall,
        fontFamily: bodyFont,
      ),
      // Headline - screen/section titles (M3 defaults)
      headlineLarge: TextStyle(
        fontSize: fontSizeHeadlineLarge,
        fontFamily: bodyFont,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeHeadlineMedium,
        fontFamily: bodyFont,
      ),
      headlineSmall: TextStyle(
        fontSize: fontSizeHeadlineSmall,
        fontFamily: bodyFont,
      ),
      // Title - smaller titles, emphasized text (scaled up)
      titleLarge: TextStyle(fontSize: fontSizeTitleLarge, fontFamily: bodyFont),
      titleMedium: TextStyle(
        fontSize: fontSizeTitleMedium,
        fontFamily: bodyFont,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: fontSizeTitleSmall,
        fontFamily: bodyFont,
        fontWeight: FontWeight.w500,
      ),
      // Body - main reading text (scaled up for readability)
      bodyLarge: TextStyle(fontSize: fontSizeBodyLarge, fontFamily: bodyFont),
      bodyMedium: TextStyle(fontSize: fontSizeBodyMedium, fontFamily: bodyFont),
      bodySmall: TextStyle(fontSize: fontSizeBodySmall, fontFamily: bodyFont),
      // Label - buttons, captions, annotations (scaled up)
      labelLarge: TextStyle(
        fontSize: fontSizeLabelLarge,
        fontFamily: bodyFont,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: fontSizeLabelMedium,
        fontFamily: bodyFont,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: fontSizeLabelSmall,
        fontFamily: bodyFont,
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
              blurRadius: textShadowBlurRadius,
              offset: shadowOffset,
            ),
          ];
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
