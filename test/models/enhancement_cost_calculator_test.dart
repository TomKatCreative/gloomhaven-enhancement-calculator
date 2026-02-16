import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement_cost_calculator.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

/// Helper to find an enhancement by name.
Enhancement _find(String name) {
  return EnhancementData.enhancements.firstWhere((e) => e.name == name);
}

/// Helper to find an enhancement by name and category.
Enhancement _findByCategory(String name, EnhancementCategory category) {
  return EnhancementData.enhancements.firstWhere(
    (e) => e.name == name && e.category == category,
  );
}

void main() {
  group('EnhancementCostCalculator', () {
    // =========================================================================
    // showCost
    // =========================================================================
    group('showCost', () {
      test('false when no inputs', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.showCost, isFalse);
      });

      test('true when enhancement is set', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
        );
        expect(calc.showCost, isTrue);
      });

      test('true when cardLevel > 0', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          cardLevel: 1,
        );
        expect(calc.showCost, isTrue);
      });

      test('true when previousEnhancements > 0', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          previousEnhancements: 1,
        );
        expect(calc.showCost, isTrue);
      });
    });

    // =========================================================================
    // enhancementCost — base costs
    // =========================================================================
    group('enhancementCost', () {
      test('returns 0 for null enhancement', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.enhancementCost(null), 0);
      });

      test('returns GH cost for Gloomhaven edition', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.enhancementCost(_find('Move')), 30);
        expect(calc.enhancementCost(_find('Attack')), 50);
      });

      test('returns FH cost for Frosthaven edition', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.frosthaven);
        // Shield: GH=100, FH=80
        expect(calc.enhancementCost(_find('Shield')), 80);
      });

      test('returns FH cost for GH2E edition (with FH fallback)', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
        );
        // Retaliate: GH=100, FH=60
        expect(calc.enhancementCost(_find('Retaliate')), 60);
      });

      test('falls back to GH cost when FH cost is null', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.frosthaven);
        // Move: ghCost=30, fhCost=null → falls back to 30
        expect(calc.enhancementCost(_find('Move')), 30);
      });
    });

    // =========================================================================
    // enhancementCost — multipliers
    // =========================================================================
    group('enhancementCost multipliers', () {
      test('multi-target doubles cost in GH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          multipleTargets: true,
        );
        // Move: 30 * 2 = 60
        expect(calc.enhancementCost(_find('Move')), 60);
      });

      test('multi-target doubles cost in GH2E for non-excluded types', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          multipleTargets: true,
        );
        // Wound: 75 * 2 = 150
        expect(calc.enhancementCost(_find('Wound')), 150);
      });

      test('multi-target does NOT apply to target in GH2E', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          multipleTargets: true,
        );
        // Target: FH cost=75, multi-target excluded in GH2E
        expect(calc.enhancementCost(_find('Target')), 75);
      });

      test('multi-target does NOT apply to element in GH2E', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          multipleTargets: true,
        );
        // Element: GH=100, multi-target excluded in GH2E/FH
        expect(calc.enhancementCost(_find('Element')), 100);
      });

      test('multi-target applies to target in GH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          multipleTargets: true,
        );
        // Target: GH=50 * 2 = 100
        expect(calc.enhancementCost(_find('Target')), 100);
      });

      test('multi-target does NOT apply to hex in any edition', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          multipleTargets: true,
        );
        // 2 hexes: GH=100 (multi-target excluded for hex)
        expect(calc.enhancementCost(_find('2 hexes')), 100);
      });

      test('lost modifier halves cost in GH2E', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          lostNonPersistent: true,
        );
        // Wound: 75 / 2 = 38 (rounded)
        expect(calc.enhancementCost(_find('Wound')), 38);
      });

      test('lost modifier halves cost in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          lostNonPersistent: true,
        );
        // Move: 30 / 2 = 15
        expect(calc.enhancementCost(_find('Move')), 15);
      });

      test('lost modifier does NOT apply in GH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          lostNonPersistent: true,
        );
        // Move: stays 30 (no lost modifier in GH)
        expect(calc.enhancementCost(_find('Move')), 30);
      });

      test('persistent modifier triples cost in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          persistent: true,
        );
        // Move: 30 * 3 = 90
        expect(calc.enhancementCost(_find('Move')), 90);
      });

      test('persistent modifier does NOT apply in GH2E', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          persistent: true,
        );
        // Move: stays 30
        expect(calc.enhancementCost(_find('Move')), 30);
      });

      test('multi-target + lost in GH2E', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          multipleTargets: true,
          lostNonPersistent: true,
        );
        // Move: 30 * 2 = 60, then / 2 = 30
        expect(calc.enhancementCost(_find('Move')), 30);
      });

      test('multi-target + persistent in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          multipleTargets: true,
          persistent: true,
        );
        // Move: 30 * 2 = 60, * 3 = 180
        expect(calc.enhancementCost(_find('Move')), 180);
      });
    });

    // =========================================================================
    // enhancementCost — discounts
    // =========================================================================
    group('enhancementCost discounts', () {
      test('enhancer L2 subtracts 10g in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
        );
        // Move: 30 - 10 = 20
        expect(calc.enhancementCost(_find('Move')), 20);
      });

      test('enhancer L2 does NOT apply in GH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancerLvl2: true,
        );
        // Move: stays 30 (enhancer levels only in FH)
        expect(calc.enhancementCost(_find('Move')), 30);
      });

      test('hails discount subtracts 5g', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          hailsDiscount: true,
        );
        // Move: 30 - 5 = 25
        expect(calc.enhancementCost(_find('Move')), 25);
      });

      test('enhancer L2 + hails in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
          hailsDiscount: true,
        );
        // Move: 30 - 10 - 5 = 15
        expect(calc.enhancementCost(_find('Move')), 15);
      });

      test('cost does not go negative', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
          hailsDiscount: true,
        );
        // Pull: FH=20 - 10 - 5 = 5 (positive)
        expect(calc.enhancementCost(_find('Pull')), 5);

        // Now test with lost modifier too: 20 / 2 = 10 - 10 - 5 = -5 → 0
        final calc2 = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
          hailsDiscount: true,
          lostNonPersistent: true,
        );
        expect(calc2.enhancementCost(_find('Pull')), 0);
      });
    });

    // =========================================================================
    // cardLevelPenalty
    // =========================================================================
    group('cardLevelPenalty', () {
      test('returns 0 for level 0', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.cardLevelPenalty(0), 0);
      });

      test('returns 25g per level', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.cardLevelPenalty(1), 25);
        expect(calc.cardLevelPenalty(3), 75);
        expect(calc.cardLevelPenalty(8), 200);
      });

      test('party boon subtracts 5g/level in GH', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          partyBoon: true,
        );
        // Level 3: (25-5) * 3 = 60
        expect(calc.cardLevelPenalty(3), 60);
      });

      test('party boon subtracts 5g/level in GH2E', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          partyBoon: true,
        );
        // Level 2: (25-5) * 2 = 40
        expect(calc.cardLevelPenalty(2), 40);
      });

      test('party boon does NOT apply in FH', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          partyBoon: true,
        );
        // Level 2: 25 * 2 = 50 (party boon not supported)
        expect(calc.cardLevelPenalty(2), 50);
      });

      test('enhancer L3 subtracts 10g/level in FH', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl3: true,
        );
        // Level 3: (25-10) * 3 = 45
        expect(calc.cardLevelPenalty(3), 45);
      });

      test('enhancer L3 does NOT apply in GH (even if set)', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancerLvl3: true,
        );
        // Level 2: 25 * 2 = 50 (enhancer levels only in FH)
        expect(calc.cardLevelPenalty(2), 50);
      });
    });

    // =========================================================================
    // previousEnhancementsPenalty
    // =========================================================================
    group('previousEnhancementsPenalty', () {
      test('returns 0 for 0 previous enhancements', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.previousEnhancementsPenalty(0), 0);
      });

      test('returns 75g per enhancement', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.previousEnhancementsPenalty(1), 75);
        expect(calc.previousEnhancementsPenalty(3), 225);
      });

      test('enhancer L4 subtracts 25g/enh in FH', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl4: true,
        );
        // 2 prev: (75-25) * 2 = 100
        expect(calc.previousEnhancementsPenalty(2), 100);
      });

      test('enhancer L4 does NOT apply in GH', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancerLvl4: true,
        );
        expect(calc.previousEnhancementsPenalty(2), 150);
      });

      test('temp enhancement mode subtracts 20g', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          temporaryEnhancementMode: true,
        );
        // 1 prev: 75 - 20 = 55
        expect(calc.previousEnhancementsPenalty(1), 55);
      });

      test('enhancer L4 + temp enhancement in FH', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancerLvl4: true,
          temporaryEnhancementMode: true,
        );
        // 2 prev: (75-25) * 2 - 20 = 80
        expect(calc.previousEnhancementsPenalty(2), 80);
      });
    });

    // =========================================================================
    // totalCost
    // =========================================================================
    group('totalCost', () {
      test('returns 0 with no inputs', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.totalCost, 0);
      });

      test('enhancement only', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
        );
        expect(calc.totalCost, 30);
      });

      test('enhancement + card level', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Attack'),
          cardLevel: 2,
        );
        // 50 + (25*2) = 100
        expect(calc.totalCost, 100);
      });

      test('enhancement + card level + previous enhancements', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          cardLevel: 1,
          previousEnhancements: 1,
        );
        // 30 + 25 + 75 = 130
        expect(calc.totalCost, 130);
      });

      test('temporary enhancement mode applies 0.8 multiplier', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          previousEnhancements: 1,
          temporaryEnhancementMode: true,
        );
        // base: 30, prev: 75-20=55 → subtotal: 85 → 85*0.8=68
        expect(calc.totalCost, 68);
      });

      test('card level only (no enhancement)', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          cardLevel: 3,
        );
        // 0 + (25*3) = 75
        expect(calc.totalCost, 75);
      });

      test('previous enhancements only (no enhancement)', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          previousEnhancements: 2,
        );
        // 0 + (75*2) = 150
        expect(calc.totalCost, 150);
      });

      test('full FH calculation with all discounts', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Move'),
          cardLevel: 2,
          previousEnhancements: 1,
          enhancerLvl2: true,
          enhancerLvl3: true,
          enhancerLvl4: true,
        );
        // base: 30 - 10 = 20
        // card level: (25-10)*2 = 30
        // prev: (75-25)*1 = 50
        // total: 20 + 30 + 50 = 100
        expect(calc.totalCost, 100);
      });

      test('GH with multi-target and party boon', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          multipleTargets: true,
          cardLevel: 3,
          partyBoon: true,
        );
        // base: 30 * 2 = 60
        // card level: (25-5)*3 = 60
        // total: 120
        expect(calc.totalCost, 120);
      });

      test('FH persistent with enhancer L2', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Move'),
          persistent: true,
          enhancerLvl2: true,
        );
        // base: 30 * 3 = 90, - 10 = 80
        expect(calc.totalCost, 80);
      });

      test('GH2E lost + multi-target', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          enhancement: _find('Wound'),
          multipleTargets: true,
          lostNonPersistent: true,
        );
        // Wound: 75 * 2 = 150, / 2 = 75
        expect(calc.totalCost, 75);
      });

      test('hails discount with enhancement', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          hailsDiscount: true,
        );
        // 30 - 5 = 25
        expect(calc.totalCost, 25);
      });

      test('temp enhancement with card level and prev enhancements', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Attack'),
          cardLevel: 2,
          previousEnhancements: 1,
          temporaryEnhancementMode: true,
        );
        // base: 50
        // card level: 25*2 = 50
        // prev: 75 - 20 = 55
        // subtotal: 155
        // temp: ceil(155 * 0.8) = ceil(124) = 124
        expect(calc.totalCost, 124);
      });
    });

    // =========================================================================
    // eligibleForMultipleTargets (static)
    // =========================================================================
    group('eligibleForMultipleTargets', () {
      test('hex is never eligible', () {
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('2 hexes'),
            edition: GameEdition.gloomhaven,
          ),
          isFalse,
        );
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('2 hexes'),
            edition: GameEdition.frosthaven,
          ),
          isFalse,
        );
      });

      test('all non-hex types eligible in GH', () {
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Move'),
            edition: GameEdition.gloomhaven,
          ),
          isTrue,
        );
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Target'),
            edition: GameEdition.gloomhaven,
          ),
          isTrue,
        );
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Element'),
            edition: GameEdition.gloomhaven,
          ),
          isTrue,
        );
      });

      test('target excluded in GH2E', () {
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Target'),
            edition: GameEdition.gloomhaven2e,
          ),
          isFalse,
        );
      });

      test('element excluded in GH2E', () {
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Element'),
            edition: GameEdition.gloomhaven2e,
          ),
          isFalse,
        );
      });

      test('wild element excluded in FH', () {
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Wild Element'),
            edition: GameEdition.frosthaven,
          ),
          isFalse,
        );
      });

      test('regular effects eligible in GH2E/FH', () {
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Wound'),
            edition: GameEdition.gloomhaven2e,
          ),
          isTrue,
        );
        expect(
          EnhancementCostCalculator.eligibleForMultipleTargets(
            _find('Move'),
            edition: GameEdition.frosthaven,
          ),
          isTrue,
        );
      });
    });

    // =========================================================================
    // breakdown
    // =========================================================================
    group('breakdown', () {
      test('returns empty list when no inputs', () {
        const calc = EnhancementCostCalculator(edition: GameEdition.gloomhaven);
        expect(calc.breakdown, isEmpty);
      });

      test('single step for enhancement only', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(1));
        expect(steps[0].description, contains('Base cost'));
        expect(steps[0].description, contains('+1 Move'));
        expect(steps[0].value, 30);
      });

      test('base cost label uses +1 prefix for charPlusOne', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Attack'),
        );
        final steps = calc.breakdown;
        expect(steps[0].description, 'Base cost (+1 Attack)');
      });

      test('base cost label uses +1 prefix for summonPlusOne', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _findByCategory(
            'Move',
            EnhancementCategory.summonPlusOne,
          ),
        );
        final steps = calc.breakdown;
        expect(steps[0].description, 'Base cost (+1 Move)');
      });

      test('base cost label uses +1 prefix for target', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Target'),
        );
        final steps = calc.breakdown;
        expect(steps[0].description, 'Base cost (+1 Target)');
      });

      test('base cost label has no prefix for effects', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Wound'),
        );
        final steps = calc.breakdown;
        expect(steps[0].description, 'Base cost (Wound)');
      });

      test('multi-target step appears', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          multipleTargets: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(2));
        expect(steps[1].description, 'Multiple targets');
        expect(steps[1].formula, '×2');
        expect(steps[1].value, 60);
      });

      test('lost action step in GH2E', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven2e,
          enhancement: _find('Move'),
          lostNonPersistent: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(2));
        expect(steps[1].description, 'Lost action');
        expect(steps[1].formula, '÷2');
      });

      test('lost action step in FH says "non-persistent"', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Move'),
          lostNonPersistent: true,
        );
        final steps = calc.breakdown;
        expect(steps[1].description, 'Lost action (non-persistent)');
      });

      test('persistent action step in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Move'),
          persistent: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(2));
        expect(steps[1].description, 'Persistent action');
        expect(steps[1].formula, '×3');
        expect(steps[1].value, 90);
      });

      test('enhancer L2 discount step', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Move'),
          enhancerLvl2: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(2));
        expect(steps[1].description, 'Enhancer Level 2');
        expect(steps[1].formula, '−10g');
        expect(steps[1].value, 20);
      });

      test('hails discount step', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          hailsDiscount: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(2));
        expect(steps[1].description, "Hail's Discount");
        expect(steps[1].formula, '−5g');
        expect(steps[1].value, 25);
      });

      test('card level step with party boon modifier', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          cardLevel: 3,
          partyBoon: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(1));
        expect(steps[0].description, 'Card level 4');
        expect(steps[0].formula, '(25g − 5g) × 3');
        expect(steps[0].modifier, 'Party Boon: −5g/level');
        expect(steps[0].value, 60);
      });

      test('card level step with enhancer L3 modifier', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          cardLevel: 2,
          enhancerLvl3: true,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(1));
        expect(steps[0].description, 'Card level 3');
        expect(steps[0].formula, '(25g − 10g) × 2');
        expect(steps[0].modifier, 'Enhancer L3: −10g/level');
        expect(steps[0].value, 30);
      });

      test('card level step without discount', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          cardLevel: 2,
        );
        final steps = calc.breakdown;
        expect(steps[0].formula, '25g × 2');
        expect(steps[0].modifier, isNull);
      });

      test('previous enhancements step', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          previousEnhancements: 2,
        );
        final steps = calc.breakdown;
        expect(steps, hasLength(1));
        expect(steps[0].description, '2 previous enhancements');
        expect(steps[0].formula, '75g × 2');
        expect(steps[0].value, 150);
      });

      test('1 previous enhancement uses singular', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          previousEnhancements: 1,
        );
        final steps = calc.breakdown;
        expect(steps[0].description, '1 previous enhancement');
      });

      test('previous enhancements with enhancer L4', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          previousEnhancements: 2,
          enhancerLvl4: true,
        );
        final steps = calc.breakdown;
        expect(steps[0].formula, '(75g − 25g) × 2');
        expect(steps[0].modifier, contains('Enhancer L4'));
        expect(steps[0].value, 100);
      });

      test('previous enhancements with temp mode', () {
        const calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          previousEnhancements: 1,
          temporaryEnhancementMode: true,
        );
        final steps = calc.breakdown;
        // First step: prev enhancements with -20g
        expect(steps[0].formula, '75g × 1 − 20g');
        expect(steps[0].modifier, contains('Temp. Enh.: −20g'));
        expect(steps[0].value, 55);
        // Second step: temp mode ×0.8
        expect(steps[1].description, 'Temporary Enhancement (×0.8↑)');
        expect(steps[1].value, 44);
      });

      test('full breakdown with multiple steps', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Move'),
          multipleTargets: true,
          cardLevel: 2,
          previousEnhancements: 1,
          enhancerLvl2: true,
          enhancerLvl3: true,
          enhancerLvl4: true,
        );
        final steps = calc.breakdown;
        // Expected steps:
        // 1. Base cost (+1 Move) = 30
        // 2. Multiple targets ×2 = 60
        // 3. Enhancer Level 2 -10g = 50
        // 4. Card level 3 with L3 = (25-10)*2 = 30 → 80
        // 5. 1 previous enhancement with L4 = (75-25)*1 = 50 → 130
        expect(steps, hasLength(5));
        expect(steps[0].value, 30);
        expect(steps[1].value, 60);
        expect(steps[2].value, 50);
        expect(steps[3].value, 80);
        expect(steps[4].value, 130);
        expect(calc.totalCost, 130);
      });

      test('temp enhancement mode adds final ×0.8 step', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          temporaryEnhancementMode: true,
        );
        final steps = calc.breakdown;
        // 1. Base cost = 30
        // 2. Temp Enhancement ×0.8 = 24
        expect(steps, hasLength(2));
        expect(steps.last.description, 'Temporary Enhancement (×0.8↑)');
        expect(steps.last.value, 24);
      });
    });

    // =========================================================================
    // Edge cases
    // =========================================================================
    group('edge cases', () {
      test('all discounts together in FH', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Pull'),
          lostNonPersistent: true,
          enhancerLvl2: true,
          hailsDiscount: true,
          cardLevel: 1,
          previousEnhancements: 1,
          enhancerLvl3: true,
          enhancerLvl4: true,
          temporaryEnhancementMode: true,
        );
        // Pull FH: 20
        // lost: 20/2 = 10
        // L2: 10-10 = 0
        // hails: 0-5 = -5 → clamped to 0
        // card: (25-10)*1 = 15 → 15
        // prev: (75-25)*1 - 20 = 30 → 45
        // temp: ceil(45 * 0.8) = 36
        expect(calc.totalCost, 36);
      });

      test('breakdown final value matches totalCost', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.frosthaven,
          enhancement: _find('Attack'),
          multipleTargets: true,
          lostNonPersistent: true,
          enhancerLvl2: true,
          hailsDiscount: true,
          cardLevel: 3,
          previousEnhancements: 2,
          enhancerLvl3: true,
          enhancerLvl4: true,
        );
        final steps = calc.breakdown;
        expect(steps.last.value, calc.totalCost);
      });

      test('immutability: same instance returns same results', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          cardLevel: 2,
        );
        final cost1 = calc.totalCost;
        final cost2 = calc.totalCost;
        expect(cost1, cost2);
        expect(calc.breakdown.length, calc.breakdown.length);
      });

      test('accepts arbitrary enhancement for cost preview', () {
        final calc = EnhancementCostCalculator(
          edition: GameEdition.gloomhaven,
          enhancement: _find('Move'),
          multipleTargets: true,
        );
        // Calculator was built with Move as selected, but we can query
        // cost for a different enhancement
        final attackCost = calc.enhancementCost(_find('Attack'));
        // Attack: 50 * 2 = 100 (multi-target applies)
        expect(attackCost, 100);

        // Hex should NOT get multi-target even though multipleTargets is true
        final hexCost = calc.enhancementCost(_find('2 hexes'));
        expect(hexCost, 100); // 100 base, no multiplier
      });
    });
  });
}
