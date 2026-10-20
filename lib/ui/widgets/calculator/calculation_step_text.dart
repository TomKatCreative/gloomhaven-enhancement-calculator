import 'package:gloomhaven_enhancement_calc/l10n/app_localizations.dart';
import 'package:gloomhaven_enhancement_calc/models/calculation_step.dart';

/// Localized text for the cost breakdown shown in the cost chip.
extension CalculationStepText on CalculationStep {
  String title(AppLocalizations l10n) => switch (kind) {
    CalculationStepKind.baseCost => l10n.stepBaseCost(enhancementName!),
    CalculationStepKind.multipleTargets => l10n.multipleTargets,
    CalculationStepKind.lostAction => l10n.stepLostAction,
    CalculationStepKind.lostNonPersistentAction =>
      l10n.stepLostNonPersistentAction,
    CalculationStepKind.persistentAction => l10n.stepPersistentAction,
    CalculationStepKind.enhancerLevel2 => l10n.stepEnhancerLevel2,
    CalculationStepKind.hailsDiscount => l10n.stepHailsDiscount,
    CalculationStepKind.cardLevel => l10n.stepCardLevel(count!),
    CalculationStepKind.previousEnhancements => l10n.stepPreviousEnhancements(
      count!,
    ),
    CalculationStepKind.temporaryEnhancement => l10n.stepTemporaryEnhancement,
  };

  /// The step's discounts, one per line, or null when there are none.
  String? modifierText(AppLocalizations l10n) =>
      modifiers.isEmpty ? null : modifiers.map((m) => m.text(l10n)).join('\n');
}

extension CalculationModifierText on CalculationModifier {
  String text(AppLocalizations l10n) => switch (kind) {
    CalculationModifierKind.partyBoon => l10n.modifierPartyBoon(amount),
    CalculationModifierKind.enhancerLevel3 => l10n.modifierEnhancerLevel3(
      amount,
    ),
    CalculationModifierKind.enhancerLevel4 => l10n.modifierEnhancerLevel4(
      amount,
    ),
    CalculationModifierKind.temporaryEnhancement =>
      l10n.modifierTemporaryEnhancement(amount),
  };
}
