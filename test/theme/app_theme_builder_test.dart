import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/theme/app_theme_builder.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';

/// A config whose hash always collides, to prove the cache keys on `==`.
class _CollidingConfig extends ThemeConfig {
  const _CollidingConfig({
    required super.seedColor,
    required super.useDarkMode,
    required super.useDefaultFonts,
  });

  // Keeps ThemeConfig's real `==`; only the hash is forced to collide.
  @override
  // ignore: hash_and_equals
  int get hashCode => 0;
}

void main() {
  group('AppThemeBuilder cache contract', () {
    // The cache is keyed by ThemeConfig itself. ThemeConfig is immutable, so a
    // given config always produces the same theme — there is no scenario in
    // which the cache should need invalidation. These tests exist to lock that
    // contract in place.

    test('the same config returns an identical (cached) ThemeData', () {
      const config = ThemeConfig(
        seedColor: Color(0xff4e7ec1),
        useDarkMode: false,
        useDefaultFonts: false,
      );

      final a = AppThemeBuilder.buildLightTheme(config);
      final b = AppThemeBuilder.buildLightTheme(config);

      expect(
        identical(a, b),
        isTrue,
        reason: 'Cache should return the same instance',
      );
    });

    test('different seedColor produces a different ThemeData', () {
      const blue = ThemeConfig(
        seedColor: Color(0xff4e7ec1),
        useDarkMode: false,
        useDefaultFonts: false,
      );
      const red = ThemeConfig(
        seedColor: Color(0xffc14e4e),
        useDarkMode: false,
        useDefaultFonts: false,
      );

      final blueTheme = AppThemeBuilder.buildLightTheme(blue);
      final redTheme = AppThemeBuilder.buildLightTheme(red);

      expect(identical(blueTheme, redTheme), isFalse);
      expect(blueTheme.colorScheme.primary, equals(blue.seedColor));
      expect(redTheme.colorScheme.primary, equals(red.seedColor));
    });

    test('different useDefaultFonts produces a different ThemeData', () {
      const customFonts = ThemeConfig(
        seedColor: Color(0xff4e7ec1),
        useDarkMode: false,
        useDefaultFonts: false,
      );
      const defaultFonts = ThemeConfig(
        seedColor: Color(0xff4e7ec1),
        useDarkMode: false,
        useDefaultFonts: true,
      );

      final customTheme = AppThemeBuilder.buildLightTheme(customFonts);
      final defaultTheme = AppThemeBuilder.buildLightTheme(defaultFonts);

      expect(identical(customTheme, defaultTheme), isFalse);
      expect(
        customTheme.textTheme.bodyMedium?.fontFamily,
        isNot(equals(defaultTheme.textTheme.bodyMedium?.fontFamily)),
      );
    });

    test('light and dark caches are independent', () {
      const config = ThemeConfig(
        seedColor: Color(0xff4e7ec1),
        useDarkMode: false,
        useDefaultFonts: false,
      );

      final light = AppThemeBuilder.buildLightTheme(config);
      final dark = AppThemeBuilder.buildDarkTheme(config);

      expect(identical(light, dark), isFalse);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });

    test('configs with colliding hash codes get their own themes', () {
      const blue = _CollidingConfig(
        seedColor: Color(0xff4e7ec1),
        useDarkMode: false,
        useDefaultFonts: false,
      );
      const red = _CollidingConfig(
        seedColor: Color(0xffc14e4e),
        useDarkMode: false,
        useDefaultFonts: false,
      );
      expect(blue.hashCode, red.hashCode);

      expect(
        AppThemeBuilder.buildLightTheme(blue).colorScheme.primary,
        blue.seedColor,
      );
      expect(
        AppThemeBuilder.buildLightTheme(red).colorScheme.primary,
        red.seedColor,
      );
      expect(
        AppThemeBuilder.buildDarkTheme(blue).colorScheme.primary,
        blue.seedColor,
      );
      expect(
        AppThemeBuilder.buildDarkTheme(red).colorScheme.primary,
        red.seedColor,
      );
    });
  });

  group('AppThemeBuilder text theme', () {
    TextTheme textTheme({required bool useDefaultFonts, bool dark = false}) {
      final config = ThemeConfig(
        seedColor: const Color(0xff4e7ec1),
        useDarkMode: dark,
        useDefaultFonts: useDefaultFonts,
      );
      return (dark
              ? AppThemeBuilder.buildDarkTheme(config)
              : AppThemeBuilder.buildLightTheme(config))
          .textTheme;
    }

    test('default fonts use Inter everywhere with no display spacing', () {
      final theme = textTheme(useDefaultFonts: true);

      expect(theme.bodyMedium?.fontFamily, inter);
      expect(theme.labelSmall?.fontFamily, inter);
      expect(theme.displayLarge?.fontFamily, inter);
      expect(theme.displayMedium?.fontFamily, inter);
      expect(theme.displayMedium?.letterSpacing, isNull);
    });

    test('custom fonts use Nyala with a spaced PirataOne displayMedium', () {
      final theme = textTheme(useDefaultFonts: false);

      expect(theme.bodyMedium?.fontFamily, nyala);
      expect(theme.labelSmall?.fontFamily, nyala);
      expect(theme.displayLarge?.fontFamily, nyala);
      expect(theme.displayMedium?.fontFamily, pirataOne);
      expect(theme.displayMedium?.letterSpacing, 1.5);
    });

    test('displayMedium has a shadow in light mode only', () {
      for (final useDefaultFonts in [true, false]) {
        expect(
          textTheme(useDefaultFonts: useDefaultFonts).displayMedium?.shadows,
          isNotEmpty,
        );
        expect(
          textTheme(
            useDefaultFonts: useDefaultFonts,
            dark: true,
          ).displayMedium?.shadows,
          isEmpty,
        );
      }
    });
  });
}
