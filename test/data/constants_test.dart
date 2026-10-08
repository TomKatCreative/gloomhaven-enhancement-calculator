import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/constants.dart';

void main() {
  group('page indices', () {
    // Pinned to literals so the tests that use these constants as expected
    // values can't go green if the indices drift from the real page count.
    test('match the bottom-nav layout for the Town flag', () {
      expect(kTownPageIndex, 0);
      expect(kCharactersPageIndex, kTownSheetEnabled ? 1 : 0);
      expect(kCalculatorPageIndex, kTownSheetEnabled ? 2 : 1);
    });

    test('Characters precedes Calculator, which is the last page', () {
      expect(kCharactersPageIndex + 1, kCalculatorPageIndex);
    });
  });
}
