import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/app_model.dart';

void main() {
  group('AppModel', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPrefs().init();
    });

    group('initial state', () {
      test('page defaults to Characters tab when no initialPage saved', () {
        final model = AppModel();
        expect(model.page, kTownSheetEnabled ? 1 : 0);
      });

      test('page restores from SharedPrefs initialPage', () async {
        final maxPage = kTownSheetEnabled ? 2 : 1;
        SharedPreferences.setMockInitialValues({'initialPage': maxPage});
        await SharedPrefs().init();
        final model = AppModel();
        expect(model.page, maxPage);
      });

      test('page clamps out-of-range initialPage to valid range', () async {
        final maxPage = kTownSheetEnabled ? 2 : 1;
        SharedPreferences.setMockInitialValues({'initialPage': 99});
        await SharedPrefs().init();
        final model = AppModel();
        expect(model.page, maxPage);
      });

      test('pageController is accessible', () {
        final model = AppModel();
        expect(model.pageController, isA<PageController>());
      });

      test('pageController initialPage matches saved page', () async {
        SharedPreferences.setMockInitialValues({'initialPage': 1});
        await SharedPrefs().init();
        final model = AppModel();
        expect(model.pageController.initialPage, 1);
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

      test('persists to SharedPrefs', () {
        final model = AppModel();
        model.page = 2;
        expect(SharedPrefs().initialPage, 2);
      });
    });
  });
}
