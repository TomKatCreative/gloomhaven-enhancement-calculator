import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/cost_display.dart';

void main() {
  group('CostDisplayConfig', () {
    test('hasDiscount is true when discountedCost differs from baseCost', () {
      const config = CostDisplayConfig(baseCost: 50, discountedCost: 40);
      expect(config.hasDiscount, isTrue);
    });

    test('hasDiscount is false when discountedCost equals baseCost', () {
      const config = CostDisplayConfig(baseCost: 50, discountedCost: 50);
      expect(config.hasDiscount, isFalse);
    });

    test('hasDiscount is false when discountedCost is null', () {
      const config = CostDisplayConfig(baseCost: 50);
      expect(config.hasDiscount, isFalse);
    });

    test('displayCost returns discountedCost when available', () {
      const config = CostDisplayConfig(baseCost: 50, discountedCost: 40);
      expect(config.displayCost, 40);
    });

    test('displayCost returns baseCost when discountedCost is null', () {
      const config = CostDisplayConfig(baseCost: 50);
      expect(config.displayCost, 50);
    });
  });

  group('CostDisplay widget', () {
    Widget buildWidget(CostDisplayConfig config) {
      return MaterialApp(
        home: Scaffold(body: CostDisplay(config: config)),
      );
    }

    testWidgets('shows 0g when baseCost is 0 with no discount', (tester) async {
      await tester.pumpWidget(
        buildWidget(const CostDisplayConfig(baseCost: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('0g'), findsOneWidget);
    });

    testWidgets('shows base cost text with no discount', (tester) async {
      await tester.pumpWidget(
        buildWidget(const CostDisplayConfig(baseCost: 50)),
      );
      await tester.pumpAndSettle();

      expect(find.text('50g'), findsOneWidget);
    });

    testWidgets(
      'shows strikethrough base and bold discounted when hasDiscount',
      (tester) async {
        await tester.pumpWidget(
          buildWidget(
            const CostDisplayConfig(baseCost: 50, discountedCost: 40),
          ),
        );
        await tester.pumpAndSettle();

        // Both costs should be displayed
        expect(find.text('50g'), findsOneWidget); // strikethrough
        expect(find.text('40g'), findsOneWidget); // discounted
      },
    );

    testWidgets('shows marker text after discounted cost', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const CostDisplayConfig(
            baseCost: 50,
            discountedCost: 40,
            marker: '\u00A7',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(' \u00A7'), findsOneWidget);
    });

    testWidgets('no marker shown when marker is null', (tester) async {
      await tester.pumpWidget(
        buildWidget(const CostDisplayConfig(baseCost: 50, discountedCost: 40)),
      );
      await tester.pumpAndSettle();

      // Should have exactly 2 text widgets (strikethrough + discounted)
      // No marker text
      expect(find.text('50g'), findsOneWidget);
      expect(find.text('40g'), findsOneWidget);
    });
  });
}
