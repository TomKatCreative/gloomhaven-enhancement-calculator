import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';

void main() {
  group('ColorUtils.contrastRatio', () {
    test('black on white returns the maximum 21:1', () {
      expect(
        ColorUtils.contrastRatio(Colors.black, Colors.white),
        closeTo(21.0, 0.01),
      );
    });

    test('white on white returns 1.0 (no contrast)', () {
      expect(
        ColorUtils.contrastRatio(Colors.white, Colors.white),
        closeTo(1.0, 0.01),
      );
    });

    test('is symmetric — order does not matter', () {
      final a = ColorUtils.contrastRatio(Colors.red, Colors.green);
      final b = ColorUtils.contrastRatio(Colors.green, Colors.red);
      expect(a, equals(b));
    });

    test('mid grey on white meets WCAG AA threshold', () {
      // #767676 is the canonical "smallest grey that passes 4.5:1 on white".
      const grey = Color(0xff767676);
      expect(
        ColorUtils.contrastRatio(grey, Colors.white),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('ColorUtils.ensureContrast', () {
    test('returns the input color when contrast is already sufficient', () {
      // Black on white already has 21:1 contrast.
      const fg = Colors.black;
      const bg = Colors.white;
      expect(ColorUtils.ensureContrast(fg, bg), equals(fg));
    });

    test('darkens a light foreground on a light background', () {
      const lightBeige = Color(0xffdfddcb);
      const white = Colors.white;
      // Sanity: starting contrast is way below 4.5:1.
      expect(ColorUtils.contrastRatio(lightBeige, white), lessThan(4.5));

      final adjusted = ColorUtils.ensureContrast(lightBeige, white);
      // The output meets the threshold.
      expect(
        ColorUtils.contrastRatio(adjusted, white),
        greaterThanOrEqualTo(4.5),
      );
      // The adjusted color is darker than the input (lower luminance).
      expect(
        adjusted.computeLuminance(),
        lessThan(lightBeige.computeLuminance()),
      );
    });

    test('lightens a dark foreground on a dark background', () {
      const darkRed = Color(0xff5a0000);
      const black = Colors.black;
      expect(ColorUtils.contrastRatio(darkRed, black), lessThan(4.5));

      final adjusted = ColorUtils.ensureContrast(darkRed, black);
      expect(
        ColorUtils.contrastRatio(adjusted, black),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        adjusted.computeLuminance(),
        greaterThan(darkRed.computeLuminance()),
      );
    });

    test('respects custom minContrastRatio (AAA: 7.0)', () {
      const fg = Color(0xff898989);
      const bg = Colors.white;
      // 4.5:1 is already met for this grey on white.
      final aa = ColorUtils.ensureContrast(fg, bg);
      expect(ColorUtils.contrastRatio(aa, bg), greaterThanOrEqualTo(4.5));

      // But asking for AAA pushes it darker still.
      final aaa = ColorUtils.ensureContrast(fg, bg, minContrastRatio: 7.0);
      expect(ColorUtils.contrastRatio(aaa, bg), greaterThanOrEqualTo(7.0));
    });

    test('returns black or white when no in-between color works', () {
      // Forcing an unreachable ratio should bottom out at black on a light bg.
      final adjusted = ColorUtils.ensureContrast(
        Colors.grey,
        Colors.white,
        minContrastRatio: 999.0,
      );
      expect(adjusted, anyOf(equals(Colors.black), equals(Colors.white)));
    });
  });

  group('ColorUtils.readableTextColor', () {
    test('delegates to ensureContrast', () {
      // Same input → same output.
      const fg = Color(0xff888888);
      const bg = Colors.white;
      expect(
        ColorUtils.readableTextColor(fg, bg),
        equals(ColorUtils.ensureContrast(fg, bg)),
      );
    });
  });
}
