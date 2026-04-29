import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/theme/app_theme_builder.dart';
import 'package:gloomhaven_enhancement_calc/theme/theme_config.dart';

void main() {
  group('AppThemeBuilder cache contract', () {
    // The cache is content-addressed by ThemeConfig.hashCode. ThemeConfig is
    // immutable, so a given config always produces the same theme — there is
    // no scenario in which the cache should need invalidation. These tests
    // exist to lock that contract in place.

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
  });
}
