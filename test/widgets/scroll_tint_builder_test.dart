import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/app_bar_utils.dart';

void main() {
  late Color background;
  late double progress;
  late ColorScheme colorScheme;

  Future<void> pumpTint(
    WidgetTester tester, {
    required bool tinted,
    Key? key,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          colorScheme = Theme.of(context).colorScheme;
          return ScrollTintBuilder(
            key: key,
            tinted: tinted,
            builder: (context, bg, p, _) {
              background = bg;
              progress = p;
              return const SizedBox();
            },
          );
        },
      ),
    ),
  );

  group('ScrollTintBuilder', () {
    testWidgets('starts at surface when not tinted', (tester) async {
      await pumpTint(tester, tinted: false);

      expect(progress, 0.0);
      expect(background, colorScheme.surface);
    });

    testWidgets('fades to the tinted background over the tint duration', (
      tester,
    ) async {
      await pumpTint(tester, tinted: false);
      await pumpTint(tester, tinted: true);
      expect(progress, 0.0);

      await tester.pump(tintAnimationDuration ~/ 2);
      expect(progress, greaterThan(0.0));
      expect(progress, lessThan(1.0));

      await tester.pump(tintAnimationDuration ~/ 2);
      expect(progress, 1.0);
      expect(background, AppBarUtils.getTintedBackground(colorScheme));
    });

    testWidgets('fades back to surface when no longer tinted', (tester) async {
      await pumpTint(tester, tinted: true);
      await pumpTint(tester, tinted: false);
      await tester.pumpAndSettle();

      expect(progress, 0.0);
      expect(background, colorScheme.surface);
    });

    testWidgets('a new key jumps straight to the current state', (
      tester,
    ) async {
      await pumpTint(tester, tinted: false, key: const ValueKey('a'));
      await pumpTint(tester, tinted: true, key: const ValueKey('b'));

      expect(progress, 1.0);
      expect(background, AppBarUtils.getTintedBackground(colorScheme));
    });
  });
}
