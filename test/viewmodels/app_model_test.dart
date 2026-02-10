import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';

void main() {
  group('AppModel', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPrefs().init();
    });

    group('initial state', () {
      test('page defaults to 0', () {
        final model = AppModel();
        expect(model.page, 0);
      });

      test('themeMode defaults to light when darkTheme is false', () {
        final model = AppModel();
        expect(model.themeMode, ThemeMode.light);
      });

      test('themeMode defaults to dark when darkTheme is true', () async {
        SharedPreferences.setMockInitialValues({'darkTheme': true});
        await SharedPrefs().init();
        final model = AppModel();
        expect(model.themeMode, ThemeMode.dark);
      });

      test('useDefaultFonts matches SharedPrefs', () {
        final model = AppModel();
        expect(model.useDefaultFonts, SharedPrefs().useDefaultFonts);
      });

      test('pageController is accessible', () {
        final model = AppModel();
        expect(model.pageController, isA<PageController>());
      });
    });

    group('page setter', () {
      test('updates value', () {
        final model = AppModel();
        model.page = 1;
        expect(model.page, 1);
      });

      test('notifies listeners', () {
        final model = AppModel();
        var notified = false;
        model.addListener(() => notified = true);
        model.page = 1;
        expect(notified, isTrue);
      });
    });

    group('themeMode setter', () {
      test('updates value', () {
        final model = AppModel();
        model.themeMode = ThemeMode.dark;
        expect(model.themeMode, ThemeMode.dark);
      });

      test('notifies listeners', () {
        final model = AppModel();
        var notified = false;
        model.addListener(() => notified = true);
        model.themeMode = ThemeMode.dark;
        expect(notified, isTrue);
      });
    });

    group('useDefaultFonts setter', () {
      test('updates value', () {
        final model = AppModel();
        model.useDefaultFonts = true;
        expect(model.useDefaultFonts, isTrue);
      });

      test('notifies listeners', () {
        final model = AppModel();
        var notified = false;
        model.addListener(() => notified = true);
        model.useDefaultFonts = true;
        expect(notified, isTrue);
      });
    });

    group('updateTheme()', () {
      test('updates themeMode when provided', () {
        final model = AppModel();
        model.updateTheme(themeMode: ThemeMode.dark);
        expect(model.themeMode, ThemeMode.dark);
      });

      test('does not change themeMode when null', () {
        final model = AppModel();
        final originalMode = model.themeMode;
        model.updateTheme();
        expect(model.themeMode, originalMode);
      });

      test('notifies listeners when themeMode provided', () {
        final model = AppModel();
        var notified = false;
        model.addListener(() => notified = true);
        model.updateTheme(themeMode: ThemeMode.dark);
        expect(notified, isTrue);
      });

      test('notifies listeners even when themeMode is null', () {
        final model = AppModel();
        var notified = false;
        model.addListener(() => notified = true);
        model.updateTheme();
        expect(notified, isTrue);
      });
    });
  });
}
