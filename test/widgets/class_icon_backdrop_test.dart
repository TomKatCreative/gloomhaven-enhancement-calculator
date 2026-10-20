import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/character/class_icon_backdrop.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/class_icon_svg.dart';
import 'package:gloomhaven_enhancement_calc/utils/color_utils.dart';

import '../helpers/test_data.dart';

void main() {
  Future<void> pumpBackdrop(
    WidgetTester tester, {
    required Character character,
    double headerHeight = 172,
    double collapseProgress = 0,
    Brightness brightness = Brightness.light,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Stack(
        children: [
          ClassIconBackdrop(
            character: character,
            headerHeight: headerHeight,
            collapseProgress: collapseProgress,
          ),
        ],
      ),
    ),
  );

  double opacity(WidgetTester tester) => tester
      .widget<Opacity>(
        find.ancestor(
          of: find.byType(ClassIconSvg),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  group('ClassIconBackdrop', () {
    testWidgets('bleeds past the top-right corner, sized to the header', (
      tester,
    ) async {
      await pumpBackdrop(
        tester,
        character: TestData.createCharacter(),
        headerHeight: 200,
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.right, -32);
      expect(positioned.top, -45);
      expect(positioned.width, 260);
      expect(positioned.height, 200 + chipBarHeight + 75);
    });

    testWidgets('fades from max opacity to invisible as the header collapses', (
      tester,
    ) async {
      final character = TestData.createCharacter();

      await pumpBackdrop(tester, character: character, collapseProgress: 0);
      expect(opacity(tester), ClassIconBackdrop.maxOpacity);

      await pumpBackdrop(tester, character: character, collapseProgress: 0.5);
      expect(opacity(tester), closeTo(ClassIconBackdrop.maxOpacity / 2, 1e-9));

      await pumpBackdrop(tester, character: character, collapseProgress: 1);
      expect(opacity(tester), 0.0);
    });

    testWidgets(
      'darkens a pale class colour to contrast with a light surface',
      (tester) async {
        // Sawbones' beige is far below 4.5:1 on a light surface.
        final sawbones = PlayerClasses.playerClasses.firstWhere(
          (c) => c.classCode == ClassCodes.sawbones,
        );
        final character = TestData.createCharacter(playerClass: sawbones);
        await pumpBackdrop(tester, character: character);

        final context = tester.element(find.byType(ClassIconSvg));
        final surface = Theme.of(context).colorScheme.surface;
        final icon = tester.widget<ClassIconSvg>(find.byType(ClassIconSvg));
        expect(icon.color, isNot(Color(sawbones.primaryColor)));
        expect(
          icon.color,
          ColorUtils.ensureContrast(Color(sawbones.primaryColor), surface),
        );
        expect(
          ColorUtils.contrastRatio(icon.color!, surface),
          greaterThanOrEqualTo(4.5),
        );
      },
    );

    testWidgets('a retired character follows the theme brightness', (
      tester,
    ) async {
      final character = TestData.createCharacter(isRetired: true);
      await pumpBackdrop(
        tester,
        character: character,
        brightness: Brightness.dark,
      );

      final context = tester.element(find.byType(ClassIconSvg));
      final theme = Theme.of(context);
      final icon = tester.widget<ClassIconSvg>(find.byType(ClassIconSvg));
      expect(
        icon.color,
        ColorUtils.ensureContrast(
          character.getEffectiveColor(Brightness.dark),
          theme.colorScheme.surface,
        ),
      );
    });
  });
}
