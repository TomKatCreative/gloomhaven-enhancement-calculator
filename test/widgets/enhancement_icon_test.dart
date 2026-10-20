import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/enhancement_icon.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/element_stack_icon.dart';
import 'package:gloomhaven_enhancement_calc/utils/themed_svg.dart';

Enhancement _find(String name) =>
    EnhancementData.enhancements.firstWhere((e) => e.name == name);

void main() {
  Future<void> pumpIcon(WidgetTester tester, Enhancement enhancement) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancementIcon(
              enhancement: enhancement,
              size: iconSizeLarge,
            ),
          ),
        ),
      );

  group('EnhancementIcon', () {
    testWidgets('Element shows the stacked element icon at the given size', (
      tester,
    ) async {
      await pumpIcon(tester, _find('Element'));

      final stack = tester.widget<ElementStackIcon>(
        find.byType(ElementStackIcon),
      );
      expect(stack.size, iconSizeLarge);
      expect(
        tester
            .widgetList<ThemedSvg>(find.byType(ThemedSvg))
            .where((svg) => svg.showPlusOneOverlay),
        isEmpty,
      );
    });

    testWidgets('a +1 enhancement shows its icon with the +1 badge', (
      tester,
    ) async {
      final move = _find('Move');
      await pumpIcon(tester, move);

      final svg = tester.widget<ThemedSvg>(find.byType(ThemedSvg));
      expect(svg.assetKey, move.assetKey);
      expect(svg.showPlusOneOverlay, isTrue);
      expect(svg.width, iconSizeLarge);
      expect(svg.height, iconSizeLarge);
    });

    testWidgets('other enhancements show their icon without a badge', (
      tester,
    ) async {
      final wound = _find('Wound');
      await pumpIcon(tester, wound);

      final svg = tester.widget<ThemedSvg>(find.byType(ThemedSvg));
      expect(svg.assetKey, wound.assetKey);
      expect(svg.showPlusOneOverlay, isFalse);
    });
  });
}
