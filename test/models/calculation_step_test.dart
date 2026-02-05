import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/calculation_step.dart';

void main() {
  group('CalculationStep', () {
    test('constructor sets all required fields', () {
      const step = CalculationStep(
        description: 'Base cost (+1 Move)',
        value: 30,
      );

      expect(step.description, 'Base cost (+1 Move)');
      expect(step.value, 30);
    });

    test('formula and modifier are nullable', () {
      const step = CalculationStep(description: 'Base cost', value: 50);

      expect(step.formula, isNull);
      expect(step.modifier, isNull);
    });

    test('formula and modifier can be set', () {
      const step = CalculationStep(
        description: 'Card level 3',
        value: 80,
        formula: '25g x 2',
        modifier: 'Party Boon: -5g/level',
      );

      expect(step.formula, '25g x 2');
      expect(step.modifier, 'Party Boon: -5g/level');
    });

    test('value can be negative for intermediate steps', () {
      const step = CalculationStep(
        description: 'Enhancer Level 2',
        value: -10,
        formula: '-10g',
      );

      expect(step.value, -10);
    });

    test('value can be zero', () {
      const step = CalculationStep(description: 'No cost', value: 0);

      expect(step.value, 0);
    });
  });
}
