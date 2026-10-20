import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations_en.dart';
import 'package:gloomhaven_enhancement_calc/l10n/app_localizations_pt.dart';
import 'package:gloomhaven_enhancement_calc/models/calculation_step.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculation_step_text.dart';

final en = AppLocalizationsEn();
final pt = AppLocalizationsPt();

void main() {
  group('CalculationStep', () {
    test('formula, details and modifiers are optional', () {
      const step = CalculationStep(
        kind: CalculationStepKind.multipleTargets,
        value: 50,
      );

      expect(step.formula, isNull);
      expect(step.enhancementName, isNull);
      expect(step.count, isNull);
      expect(step.modifiers, isEmpty);
    });

    test('value can be negative for intermediate steps', () {
      const step = CalculationStep(
        kind: CalculationStepKind.enhancerLevel2,
        value: -10,
        formula: '-10g',
      );

      expect(step.value, -10);
    });
  });

  group('CalculationStepText', () {
    test('every kind has a title', () {
      for (final kind in CalculationStepKind.values) {
        final step = CalculationStep(
          kind: kind,
          value: 0,
          enhancementName: '+1 Move',
          count: 2,
        );
        expect(step.title(en), isNotEmpty);
        expect(step.title(pt), isNotEmpty);
      }
    });

    test('titles fill in the step details', () {
      expect(
        const CalculationStep(
          kind: CalculationStepKind.baseCost,
          value: 30,
          enhancementName: '+1 Move',
        ).title(en),
        'Base cost (+1 Move)',
      );
      expect(
        const CalculationStep(
          kind: CalculationStepKind.cardLevel,
          value: 25,
          count: 4,
        ).title(en),
        'Card level 4',
      );
    });

    test('previous enhancements pluralizes in both locales', () {
      String title(int count, AppLocalizations l10n) => CalculationStep(
        kind: CalculationStepKind.previousEnhancements,
        value: 0,
        count: count,
      ).title(l10n);

      expect(title(1, en), '1 previous enhancement');
      expect(title(2, en), '2 previous enhancements');
      expect(title(1, pt), '1 melhoria anterior');
      expect(title(3, pt), '3 melhorias anteriores');
    });

    test('modifierText joins modifiers one per line', () {
      const step = CalculationStep(
        kind: CalculationStepKind.previousEnhancements,
        value: 0,
        count: 1,
        modifiers: [
          CalculationModifier(CalculationModifierKind.enhancerLevel4, 25),
          CalculationModifier(CalculationModifierKind.temporaryEnhancement, 20),
        ],
      );

      expect(step.modifierText(en), 'Enhancer L4: −25g/enh.\nTemp. Enh.: −20g');
    });

    test('modifierText is null without modifiers', () {
      const step = CalculationStep(
        kind: CalculationStepKind.lostAction,
        value: 0,
      );

      expect(step.modifierText(en), isNull);
    });
  });
}
