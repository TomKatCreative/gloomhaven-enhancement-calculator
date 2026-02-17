import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/enhancement_calculator_model.dart';

/// Helper to find an enhancement by name.
Enhancement _findEnhancement(String name) {
  return EnhancementData.enhancements.firstWhere((e) => e.name == name);
}

/// Helper to find an enhancement by name and category.
Enhancement _findEnhancementByCategory(
  String name,
  EnhancementCategory category,
) {
  return EnhancementData.enhancements.firstWhere(
    (e) => e.name == name && e.category == category,
  );
}

/// Sets up SharedPreferences with optional calculator-specific values.
Future<void> _setupPrefs({
  GameEdition edition = GameEdition.gloomhaven,
  bool partyBoon = false,
  bool enhancerLvl2 = false,
  bool enhancerLvl3 = false,
  bool enhancerLvl4 = false,
  bool hailsDiscount = false,
  bool temporaryEnhancementMode = false,
}) async {
  final values = <String, Object>{'gameEdition': edition.index};
  if (partyBoon) values['partyBoon'] = true;
  if (hailsDiscount) values['hailsDiscount'] = true;
  if (temporaryEnhancementMode) values['temporaryEnhancementMode'] = true;
  if (enhancerLvl2) {
    values['enhancerLvl1'] = true;
    values['enhancerLvl2'] = true;
  }
  if (enhancerLvl3) {
    values['enhancerLvl1'] = true;
    values['enhancerLvl2'] = true;
    values['enhancerLvl3'] = true;
  }
  if (enhancerLvl4) {
    values['enhancerLvl1'] = true;
    values['enhancerLvl2'] = true;
    values['enhancerLvl3'] = true;
    values['enhancerLvl4'] = true;
  }
  SharedPreferences.setMockInitialValues(values);
  await SharedPrefs().init();
}

void main() {
  group('EnhancementCalculatorModel', () {
    group('Initial State', () {
      test('default state has zero cost and no enhancement', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.totalCost, 0);
        expect(model.showCost, isFalse);
        expect(model.enhancement, isNull);
      });

      test('cardLevel defaults to 0', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.cardLevel, 0);
      });

      test('previousEnhancements defaults to 0', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.previousEnhancements, 0);
      });

      test('multipleTargets defaults to false', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.multipleTargets, isFalse);
      });

      test('lostNonPersistent and persistent default to false', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.lostNonPersistent, isFalse);
        expect(model.persistent, isFalse);
      });
    });

    group('enhancementCost() - Base Cost', () {
      test('returns 0 when enhancement is null', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.enhancementCost(null), 0);
      });

      test('returns ghCost for GH edition', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        expect(model.enhancementCost(move), 30);
      });

      test('returns fhCost for GH2E when available', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven2e);
        final model = EnhancementCalculatorModel();
        final target = _findEnhancement('Target');

        expect(model.enhancementCost(target), 75);
      });

      test('returns ghCost for GH2E when fhCost is null', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven2e);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        expect(model.enhancementCost(move), 30);
      });

      test('returns fhCost for FH when available', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();
        final target = _findEnhancement('Target');

        expect(model.enhancementCost(target), 75);
      });

      test('GH Target costs 50g, FH Target costs 75g', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final modelGH = EnhancementCalculatorModel();
        final target = _findEnhancement('Target');

        expect(modelGH.enhancementCost(target), 50);

        await _setupPrefs(edition: GameEdition.frosthaven);
        final modelFH = EnhancementCalculatorModel();

        expect(modelFH.enhancementCost(target), 75);
      });

      test('negative cost clamped to 0', () async {
        // With Hail's discount (-5g) + Enhancer L2 (-10g) on a cheap
        // enhancement, cost could go negative
        await _setupPrefs(
          edition: GameEdition.frosthaven,
          hailsDiscount: true,
          enhancerLvl2: true,
        );
        final model = EnhancementCalculatorModel();
        // 13 hexes costs 16g in FH — 16 - 10 - 5 = 1, still positive
        // But let's verify floor at 0 logic directly
        final enhancement = Enhancement(
          EnhancementCategory.charPlusOne,
          'Test',
          ghCost: 10,
        );

        // 10 - 10 (L2) - 5 (Hail's) = -5 → clamped to 0
        expect(model.enhancementCost(enhancement), 0);
      });
    });

    group('enhancementCost() - Multi-Target Multiplier', () {
      test(
        'doubles base cost when multipleTargets enabled and eligible',
        () async {
          await _setupPrefs(edition: GameEdition.gloomhaven);
          final model = EnhancementCalculatorModel();
          model.multipleTargets = true;

          final wound = _findEnhancement('Wound');
          // 75 * 2 = 150
          expect(model.enhancementCost(wound), 150);
        },
      );

      test('does not double when multipleTargets is false', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();
        model.multipleTargets = false;

        final wound = _findEnhancement('Wound');
        expect(model.enhancementCost(wound), 75);
      });

      test('Target is eligible in GH (multiTargetAppliesToAll)', () async {
        expect(
          EnhancementCalculatorModel.eligibleForMultipleTargets(
            _findEnhancement('Target'),
            edition: GameEdition.gloomhaven,
          ),
          isTrue,
        );
      });

      test('Target is NOT eligible in GH2E', () async {
        expect(
          EnhancementCalculatorModel.eligibleForMultipleTargets(
            _findEnhancement('Target'),
            edition: GameEdition.gloomhaven2e,
          ),
          isFalse,
        );
      });

      test('Target is NOT eligible in FH', () async {
        expect(
          EnhancementCalculatorModel.eligibleForMultipleTargets(
            _findEnhancement('Target'),
            edition: GameEdition.frosthaven,
          ),
          isFalse,
        );
      });

      test('Element is eligible in GH', () async {
        expect(
          EnhancementCalculatorModel.eligibleForMultipleTargets(
            _findEnhancement('Element'),
            edition: GameEdition.gloomhaven,
          ),
          isTrue,
        );
      });

      test('Element is NOT eligible in GH2E', () async {
        expect(
          EnhancementCalculatorModel.eligibleForMultipleTargets(
            _findEnhancement('Element'),
            edition: GameEdition.gloomhaven2e,
          ),
          isFalse,
        );
      });

      test('Wild Element is NOT eligible in FH', () async {
        expect(
          EnhancementCalculatorModel.eligibleForMultipleTargets(
            _findEnhancement('Wild Element'),
            edition: GameEdition.frosthaven,
          ),
          isFalse,
        );
      });

      test('Hex is never eligible in any edition', () async {
        final hex = _findEnhancement('2 hexes');
        for (final edition in GameEdition.values) {
          expect(
            EnhancementCalculatorModel.eligibleForMultipleTargets(
              hex,
              edition: edition,
            ),
            isFalse,
            reason: 'Hex should not be eligible in ${edition.displayName}',
          );
        }
      });

      test('Jump is eligible in all editions', () async {
        final jump = _findEnhancement('Jump');
        for (final edition in GameEdition.values) {
          expect(
            EnhancementCalculatorModel.eligibleForMultipleTargets(
              jump,
              edition: edition,
            ),
            isTrue,
            reason: 'Jump should be eligible in ${edition.displayName}',
          );
        }
      });

      test('Wound (negEffect) is eligible in all editions', () async {
        final wound = _findEnhancement('Wound');
        for (final edition in GameEdition.values) {
          expect(
            EnhancementCalculatorModel.eligibleForMultipleTargets(
              wound,
              edition: edition,
            ),
            isTrue,
          );
        }
      });

      test('Strengthen (posEffect) is eligible in all editions', () async {
        final strengthen = _findEnhancement('Strengthen');
        for (final edition in GameEdition.values) {
          expect(
            EnhancementCalculatorModel.eligibleForMultipleTargets(
              strengthen,
              edition: edition,
            ),
            isTrue,
          );
        }
      });
    });

    group('enhancementCost() - Lost Modifier', () {
      test('GH: lost toggle has no effect', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        // Since GH has no lost modifier, the code path won't trigger
        SharedPrefs().lostNonPersistent = true;
        final model = EnhancementCalculatorModel();

        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );
        // GH doesn't have lost modifier, so cost stays at 30
        expect(model.enhancementCost(move), 30);
      });

      test('GH2E: halves cost when lostNonPersistent is true', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final attack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.charPlusOne,
        );
        // 50 / 2 = 25
        expect(model.enhancementCost(attack), 25);
      });

      test('FH: halves cost when lostNonPersistent is true', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.frosthaven.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final attack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.charPlusOne,
        );
        // 50 / 2 = 25
        expect(model.enhancementCost(attack), 25);
      });

      test('rounding: odd cost rounds correctly', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final wound = _findEnhancement('Wound');
        // 75 / 2 = 37.5 → rounds to 38
        expect(model.enhancementCost(wound), 38);
      });

      test('multi-target + lost: doubles first then halves', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'multipleTargetsSelected': true,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final attack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.charPlusOne,
        );
        // 50 * 2 = 100, then 100 / 2 = 50
        expect(model.enhancementCost(attack), 50);
      });

      test('enhancementSelected clears lost for summon in GH2E', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        expect(model.lostNonPersistent, isTrue);

        final summonHP = _findEnhancementByCategory(
          'HP',
          EnhancementCategory.summonPlusOne,
        );
        model.enhancementSelected(summonHP);

        expect(model.lostNonPersistent, isFalse);
      });

      test(
        'enhancementSelected leaves lost enabled for summon in FH',
        () async {
          SharedPreferences.setMockInitialValues({
            'gameEdition': GameEdition.frosthaven.index,
            'lostNonPersistent': true,
          });
          await SharedPrefs().init();
          final model = EnhancementCalculatorModel();

          final summonHP = _findEnhancementByCategory(
            'HP',
            EnhancementCategory.summonPlusOne,
          );
          model.enhancementSelected(summonHP);

          // FH has persistent modifier, so lost is NOT cleared for summon
          expect(model.lostNonPersistent, isTrue);
        },
      );
    });

    group('enhancementCost() - Persistent Modifier', () {
      test('FH: triples cost when persistent is true', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.frosthaven.index,
          'persistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );
        // 30 * 3 = 90
        expect(model.enhancementCost(move), 90);
      });

      test('GH: persistent has no effect', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven.index,
          'persistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );
        expect(model.enhancementCost(move), 30);
      });

      test('GH2E: persistent has no effect', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'persistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );
        expect(model.enhancementCost(move), 30);
      });

      test('enhancementSelected clears persistent for summon', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.frosthaven.index,
          'persistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        final summonAttack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.summonPlusOne,
        );
        model.enhancementSelected(summonAttack);

        expect(model.persistent, isFalse);
      });

      test('setting lost clears persistent and vice versa', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();

        model.persistent = true;
        expect(model.persistent, isTrue);
        expect(model.lostNonPersistent, isFalse);

        model.lostNonPersistent = true;
        expect(model.lostNonPersistent, isTrue);
        expect(model.persistent, isFalse);
      });
    });

    group('enhancementCost() - Discounts', () {
      test('Enhancer L2 subtracts 10g in FH', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl2: true);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        // 30 - 10 = 20
        expect(model.enhancementCost(move), 20);
      });

      test('Hail\'s discount subtracts 5g', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, hailsDiscount: true);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        // 30 - 5 = 25
        expect(model.enhancementCost(move), 25);
      });

      test('Enhancer L2 + Hail\'s combined subtract 15g', () async {
        await _setupPrefs(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
          hailsDiscount: true,
        );
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        // 30 - 10 - 5 = 15
        expect(model.enhancementCost(move), 15);
      });

      test('Enhancer L2 has no effect in GH', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, enhancerLvl2: true);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        // GH doesn't have enhancer levels
        expect(model.enhancementCost(move), 30);
      });

      test('discount can\'t make enhancement cost negative', () async {
        await _setupPrefs(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
          hailsDiscount: true,
        );
        final model = EnhancementCalculatorModel();
        // Create a very cheap enhancement
        final enhancement = Enhancement(
          EnhancementCategory.charPlusOne,
          'Cheap',
          ghCost: 5,
        );

        // 5 - 10 - 5 = -10 → clamped to 0
        expect(model.enhancementCost(enhancement), 0);
      });
    });

    group('cardLevelPenalty()', () {
      test('level 0 returns 0g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.cardLevelPenalty(0), 0);
      });

      test('level 1 returns 25g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.cardLevelPenalty(1), 25);
      });

      test('level 2 returns 50g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.cardLevelPenalty(2), 50);
      });

      test('level 8 returns 200g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.cardLevelPenalty(8), 200);
      });

      test('Party Boon reduces by 5g/level in GH', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, partyBoon: true);
        final model = EnhancementCalculatorModel();

        // level 1: 25 - 5 = 20
        expect(model.cardLevelPenalty(1), 20);
      });

      test('Party Boon reduces by 5g/level at level 3', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, partyBoon: true);
        final model = EnhancementCalculatorModel();

        // level 3: 75 - 15 = 60
        expect(model.cardLevelPenalty(3), 60);
      });

      test('Enhancer L3 reduces by 10g/level in FH', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl3: true);
        final model = EnhancementCalculatorModel();

        // level 1: 25 - 10 = 15
        expect(model.cardLevelPenalty(1), 15);
      });

      test('Enhancer L3 at level 3 in FH', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl3: true);
        final model = EnhancementCalculatorModel();

        // level 3: 75 - 30 = 45
        expect(model.cardLevelPenalty(3), 45);
      });

      test('Party Boon in FH has no effect', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, partyBoon: true);
        final model = EnhancementCalculatorModel();

        // FH doesn't support party boon, no enhancer L3 set
        expect(model.cardLevelPenalty(1), 25);
      });

      test('Enhancer L3 in GH has no effect', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, enhancerLvl3: true);
        final model = EnhancementCalculatorModel();

        // GH doesn't have enhancer levels
        expect(model.cardLevelPenalty(1), 25);
      });
    });

    group('previousEnhancementsPenalty()', () {
      test('0 previous returns 0g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.previousEnhancementsPenalty(0), 0);
      });

      test('1 previous returns 75g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.previousEnhancementsPenalty(1), 75);
      });

      test('2 previous returns 150g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.previousEnhancementsPenalty(2), 150);
      });

      test('3 previous returns 225g', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.previousEnhancementsPenalty(3), 225);
      });

      test('Enhancer L4 reduces by 25g/enhancement in FH', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl4: true);
        final model = EnhancementCalculatorModel();

        // 1 prev: 75 - 25 = 50
        expect(model.previousEnhancementsPenalty(1), 50);
      });

      test('Enhancer L4 with 2 previous in FH', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl4: true);
        final model = EnhancementCalculatorModel();

        // 2 prev: 150 - 50 = 100
        expect(model.previousEnhancementsPenalty(2), 100);
      });

      test('temp enhancement subtracts flat 20g', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();

        // 1 prev: 75 - 20 = 55
        expect(model.previousEnhancementsPenalty(1), 55);
      });

      test('temp enhancement with 2 previous', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();

        // 2 prev: 150 - 20 = 130
        expect(model.previousEnhancementsPenalty(2), 130);
      });

      test('Enhancer L4 + temp combined', () async {
        await _setupPrefs(
          edition: GameEdition.frosthaven,
          enhancerLvl4: true,
          temporaryEnhancementMode: true,
        );
        final model = EnhancementCalculatorModel();

        // 1 prev: 75 - 25 - 20 = 30
        expect(model.previousEnhancementsPenalty(1), 30);
      });

      test('Enhancer L4 in GH has no effect', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, enhancerLvl4: true);
        final model = EnhancementCalculatorModel();

        expect(model.previousEnhancementsPenalty(1), 75);
      });
    });

    group('calculateCost() - End-to-End', () {
      test('enhancement only: totalCost = enhancementCost', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(move);

        expect(model.totalCost, 30);
        expect(model.showCost, isTrue);
      });

      test('card level only: totalCost = cardLevelPenalty', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        model.cardLevel = 2;

        expect(model.totalCost, 50);
        expect(model.showCost, isTrue);
      });

      test('previous enhancements only', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        model.previousEnhancements = 1;

        expect(model.totalCost, 75);
        expect(model.showCost, isTrue);
      });

      test('all combined', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(move);
        model.cardLevel = 1;
        model.previousEnhancements = 1;

        // 30 (move) + 25 (level 1) + 75 (1 prev) = 130
        expect(model.totalCost, 130);
      });

      test('showCost is true when any input is non-zero', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.showCost, isFalse);

        model.cardLevel = 1;
        expect(model.showCost, isTrue);
      });

      test('showCost is false when all inputs are zero/null', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.showCost, isFalse);
      });

      test('temporary enhancement mode: total * 0.8 ceil', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(move);
        model.cardLevel = 1;
        model.previousEnhancements = 1;

        // Enhancement: 30, Level: 25, Prev: 75-20=55
        // Total before temp: 30 + 25 + 55 = 110
        // After temp: ceil(110 * 0.8) = ceil(88) = 88
        expect(model.totalCost, 88);
      });

      test('temp mode with 0 previous: no -20g on penalty', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(move);

        // Enhancement: 30, no prev penalty (0 prev returns 0, not -20)
        // After temp: ceil(30 * 0.8) = ceil(24) = 24
        expect(model.totalCost, 24);
      });

      test('temp mode example from plan', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();
        final attack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(attack);
        model.cardLevel = 1;
        model.previousEnhancements = 1;

        // Enhancement: 50, Level: 25, Prev: 75-20=55
        // Total before temp: 50 + 25 + 55 = 130
        // After temp: ceil(130 * 0.8) = ceil(104) = 104
        expect(model.totalCost, 104);
      });

      test('notifyListeners called on calculateCost', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();
        int notifyCount = 0;
        model.addListener(() => notifyCount++);

        model.cardLevel = 1; // triggers calculateCost which notifies

        expect(notifyCount, greaterThan(0));
      });

      test('complex FH calculation with enhancer levels', () async {
        await _setupPrefs(
          edition: GameEdition.frosthaven,
          enhancerLvl2: true,
          enhancerLvl3: true,
          enhancerLvl4: true,
        );
        final model = EnhancementCalculatorModel();
        final attack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(attack);
        model.cardLevel = 2;
        model.previousEnhancements = 1;

        // Enhancement: 50 - 10 (L2) = 40
        // Card level: (25 - 10) * 2 = 30
        // Prev: (75 - 25) * 1 = 50
        // Total: 40 + 30 + 50 = 120
        expect(model.totalCost, 120);
      });
    });

    group('enhancementSelected()', () {
      test('sets enhancement and calculates cost', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(move);

        expect(model.enhancement, move);
        expect(model.totalCost, 30);
      });

      test('Target forces multipleTargets ON in GH', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Target'));

        expect(model.multipleTargets, isTrue);
        expect(model.disableMultiTargetsSwitch, isTrue);
      });

      test('Target forces multipleTargets OFF in GH2E', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven2e);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Target'));

        expect(model.multipleTargets, isFalse);
        expect(model.disableMultiTargetsSwitch, isTrue);
      });

      test('Hex forces multipleTargets OFF and disables switch', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('2 hexes'));

        expect(model.multipleTargets, isFalse);
        expect(model.disableMultiTargetsSwitch, isTrue);
      });

      test('Element in GH leaves switch enabled', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Element'));

        expect(model.disableMultiTargetsSwitch, isFalse);
      });

      test('Element in GH2E disables switch and forces off', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven2e);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Element'));

        expect(model.multipleTargets, isFalse);
        expect(model.disableMultiTargetsSwitch, isTrue);
      });

      test('Summon clears persistent', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.frosthaven.index,
          'persistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(
          _findEnhancementByCategory('HP', EnhancementCategory.summonPlusOne),
        );

        expect(model.persistent, isFalse);
      });

      test('default enhancement enables multi-target switch', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Wound'));

        expect(model.disableMultiTargetsSwitch, isFalse);
      });

      test('unavailable enhancement clears selection', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven2e);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Disarm'));

        expect(model.enhancement, isNull);
      });
    });

    group('gameVersionToggled()', () {
      test('clears persistent when switching away from FH', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.frosthaven.index,
          'persistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        expect(model.persistent, isTrue);

        model.gameEdition = GameEdition.gloomhaven;

        expect(model.persistent, isFalse);
      });

      test('clears lost when switching to GH', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        expect(model.lostNonPersistent, isTrue);

        model.gameEdition = GameEdition.gloomhaven;

        expect(model.lostNonPersistent, isFalse);
      });

      test('re-validates current enhancement', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();

        // Select Disarm (GH-only)
        model.enhancementSelected(_findEnhancement('Disarm'));
        expect(model.enhancement, isNotNull);

        // Switch to GH2E where Disarm is unavailable
        model.gameEdition = GameEdition.gloomhaven2e;

        expect(model.enhancement, isNull);
      });

      test('Ward cleared when switching to GH', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven2e);
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(_findEnhancement('Ward'));
        expect(model.enhancement, isNotNull);

        model.gameEdition = GameEdition.gloomhaven;

        expect(model.enhancement, isNull);
      });

      test('calls notifyListeners', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();
        int notifyCount = 0;
        model.addListener(() => notifyCount++);

        model.gameEdition = GameEdition.gloomhaven;

        expect(notifyCount, greaterThan(0));
      });

      test('edition getter returns cached value', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();

        expect(model.edition, GameEdition.frosthaven);

        model.gameEdition = GameEdition.gloomhaven2e;

        expect(model.edition, GameEdition.gloomhaven2e);
      });
    });

    group('resetCost()', () {
      test('resets all fields', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        // Set some state
        model.enhancementSelected(
          _findEnhancementByCategory('Move', EnhancementCategory.charPlusOne),
        );
        model.cardLevel = 2;
        model.previousEnhancements = 1;

        model.resetCost();

        expect(model.totalCost, 0);
        expect(model.showCost, isFalse);
        expect(model.enhancement, isNull);
        expect(model.cardLevel, 0);
        expect(model.previousEnhancements, 0);
        expect(model.multipleTargets, isFalse);
        expect(model.lostNonPersistent, isFalse);
        expect(model.persistent, isFalse);
      });

      test('clears SharedPrefs keys', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        model.cardLevel = 2;
        model.resetCost();

        expect(SharedPrefs().targetCardLvl, 0);
        expect(SharedPrefs().previousEnhancements, 0);
      });

      test('calls notifyListeners', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();
        int notifyCount = 0;
        model.addListener(() => notifyCount++);

        model.resetCost();

        expect(notifyCount, greaterThan(0));
      });
    });

    group('getCalculationBreakdown()', () {
      test('empty when no inputs', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.getCalculationBreakdown(), isEmpty);
      });

      test('base cost step shows enhancement name and cost', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(
          _findEnhancementByCategory('Move', EnhancementCategory.charPlusOne),
        );

        final steps = model.getCalculationBreakdown();

        expect(steps.length, 1);
        expect(steps[0].description, contains('+1 Move'));
        expect(steps[0].value, 30);
        expect(steps[0].formula, '30g');
      });

      test('multi-target step shows x2', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();
        final wound = _findEnhancement('Wound');

        model.enhancementSelected(wound);
        model.multipleTargets = true;

        final steps = model.getCalculationBreakdown();

        expect(steps.length, 2);
        expect(steps[1].description, 'Multiple targets');
        expect(steps[1].formula, '×2');
        expect(steps[1].value, 150);
      });

      test('lost step shows ÷2', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.gloomhaven2e.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();
        final attack = _findEnhancementByCategory(
          'Attack',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(attack);

        final steps = model.getCalculationBreakdown();
        final lostStep = steps.firstWhere((s) => s.formula == '÷2');

        expect(lostStep.description, 'Lost action');
        expect(lostStep.value, 25);
      });

      test('lost step in FH says non-persistent', () async {
        SharedPreferences.setMockInitialValues({
          'gameEdition': GameEdition.frosthaven.index,
          'lostNonPersistent': true,
        });
        await SharedPrefs().init();
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(
          _findEnhancementByCategory('Attack', EnhancementCategory.charPlusOne),
        );

        final steps = model.getCalculationBreakdown();
        final lostStep = steps.firstWhere((s) => s.formula == '÷2');

        expect(lostStep.description, 'Lost action (non-persistent)');
      });

      test('card level step shows formula', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, partyBoon: true);
        final model = EnhancementCalculatorModel();

        model.cardLevel = 2;

        final steps = model.getCalculationBreakdown();

        expect(steps.length, 1);
        expect(steps[0].description, 'Card level 3');
        expect(steps[0].modifier, contains('Party Boon'));
      });

      test('previous enhancements step with temp -20g', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();

        model.previousEnhancements = 1;

        final steps = model.getCalculationBreakdown();
        final prevStep = steps.firstWhere(
          (s) => s.description.contains('previous'),
        );

        expect(prevStep.formula, contains('− 20g'));
      });

      test('temp enhancement final step shows x0.8', () async {
        await _setupPrefs(temporaryEnhancementMode: true);
        final model = EnhancementCalculatorModel();
        final move = _findEnhancementByCategory(
          'Move',
          EnhancementCategory.charPlusOne,
        );

        model.enhancementSelected(move);

        final steps = model.getCalculationBreakdown();
        final tempStep = steps.lastWhere(
          (s) => s.description.contains('Temporary'),
        );

        expect(tempStep.description, contains('×0.8'));
      });
    });

    group('enhancerLvl*Applies getters', () {
      test(
        'enhancerLvl2Applies: true when FH + L2 on + enhancement set',
        () async {
          await _setupPrefs(
            edition: GameEdition.frosthaven,
            enhancerLvl2: true,
          );
          final model = EnhancementCalculatorModel();

          model.enhancementSelected(
            _findEnhancementByCategory('Move', EnhancementCategory.charPlusOne),
          );

          expect(model.enhancerLvl2Applies, isTrue);
        },
      );

      test('enhancerLvl2Applies: false when no enhancement', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl2: true);
        final model = EnhancementCalculatorModel();

        expect(model.enhancerLvl2Applies, isFalse);
      });

      test(
        'enhancerLvl3Applies: true when FH + L3 on + cardLevel > 0',
        () async {
          await _setupPrefs(
            edition: GameEdition.frosthaven,
            enhancerLvl3: true,
          );
          final model = EnhancementCalculatorModel();

          model.cardLevel = 1;

          expect(model.enhancerLvl3Applies, isTrue);
        },
      );

      test(
        'enhancerLvl4Applies: true when FH + L4 on + prevEnhancements > 0',
        () async {
          await _setupPrefs(
            edition: GameEdition.frosthaven,
            enhancerLvl4: true,
          );
          final model = EnhancementCalculatorModel();

          model.previousEnhancements = 1;

          expect(model.enhancerLvl4Applies, isTrue);
        },
      );

      test('all false in GH regardless of SharedPrefs values', () async {
        await _setupPrefs(
          edition: GameEdition.gloomhaven,
          enhancerLvl2: true,
          enhancerLvl3: true,
          enhancerLvl4: true,
        );
        final model = EnhancementCalculatorModel();

        model.enhancementSelected(
          _findEnhancementByCategory('Move', EnhancementCategory.charPlusOne),
        );
        model.cardLevel = 1;
        model.previousEnhancements = 1;

        expect(model.enhancerLvl2Applies, isFalse);
        expect(model.enhancerLvl3Applies, isFalse);
        expect(model.enhancerLvl4Applies, isFalse);
      });
    });

    group('partyBoon getter/setter', () {
      test('getter returns cached value', () async {
        await _setupPrefs(partyBoon: true);
        final model = EnhancementCalculatorModel();

        expect(model.partyBoon, isTrue);
      });

      test('setter updates cache and recalculates', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();
        model.cardLevel = 1;

        expect(model.partyBoon, isFalse);

        int notifyCount = 0;
        model.addListener(() => notifyCount++);

        model.partyBoon = true;

        expect(model.partyBoon, isTrue);
        expect(notifyCount, greaterThan(0));
        // With party boon: 25 - 5 = 20
        expect(model.cardLevelPenalty(1), 20);
      });
    });

    group('partyBoonApplies', () {
      test('true when edition supports it and partyBoon is on', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven, partyBoon: true);
        final model = EnhancementCalculatorModel();

        expect(model.partyBoonApplies, isTrue);
      });

      test('false when edition does not support it', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, partyBoon: true);
        final model = EnhancementCalculatorModel();

        expect(model.partyBoonApplies, isFalse);
      });

      test('false when partyBoon is off', () async {
        await _setupPrefs(edition: GameEdition.gloomhaven);
        final model = EnhancementCalculatorModel();

        expect(model.partyBoonApplies, isFalse);
      });
    });

    group('enhancerLvl setters', () {
      test('enhancerLvl2 setter updates cache and recalculates', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();

        model.enhancerLvl2 = true;

        expect(model.enhancerLvl2, isTrue);
        expect(SharedPrefs().enhancerLvl2, isTrue);
      });

      test('enhancerLvl3 setter cascades to lvl2', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();

        model.enhancerLvl3 = true;

        expect(model.enhancerLvl3, isTrue);
        expect(model.enhancerLvl2, isTrue);
      });

      test('enhancerLvl4 setter cascades to lvl2 and lvl3', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();

        model.enhancerLvl4 = true;

        expect(model.enhancerLvl4, isTrue);
        expect(model.enhancerLvl3, isTrue);
        expect(model.enhancerLvl2, isTrue);
      });

      test('disabling enhancerLvl2 cascades to clear lvl3 and lvl4', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl4: true);
        final model = EnhancementCalculatorModel();

        expect(model.enhancerLvl4, isTrue);

        model.enhancerLvl2 = false;

        expect(model.enhancerLvl2, isFalse);
        expect(model.enhancerLvl3, isFalse);
        expect(model.enhancerLvl4, isFalse);
      });
    });

    group('hasAnyEnhancerUpgrades', () {
      test('false when no enhancer levels', () async {
        await _setupPrefs(edition: GameEdition.frosthaven);
        final model = EnhancementCalculatorModel();

        expect(model.hasAnyEnhancerUpgrades, isFalse);
      });

      test('true when any enhancer level is on', () async {
        await _setupPrefs(edition: GameEdition.frosthaven, enhancerLvl2: true);
        final model = EnhancementCalculatorModel();

        expect(model.hasAnyEnhancerUpgrades, isTrue);
      });
    });

    group('reloadFromPrefs', () {
      test('picks up new SharedPrefs values', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        expect(model.cardLevel, 0);
        expect(model.enhancement, isNull);
        expect(model.hailsDiscount, isFalse);

        // Change SharedPrefs externally (simulating a backup restore)
        SharedPrefs().targetCardLvl = 3;
        SharedPrefs().enhancementTypeIndex = 1;
        SharedPrefs().hailsDiscount = true;
        SharedPrefs().multipleTargetsSwitch = true;
        SharedPrefs().lostNonPersistent = false;
        SharedPrefs().persistent = false;

        model.reloadFromPrefs();

        expect(model.cardLevel, 3);
        expect(model.enhancement, EnhancementData.enhancements[1]);
        expect(model.hailsDiscount, isTrue);
        expect(model.multipleTargets, isTrue);
      });

      test('triggers notifyListeners', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        int notifyCount = 0;
        model.addListener(() => notifyCount++);

        model.reloadFromPrefs();

        expect(notifyCount, 1);
      });

      test('handles out-of-range enhancementTypeIndex', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        // Set an index beyond the list
        SharedPrefs().enhancementTypeIndex = 9999;

        model.reloadFromPrefs();

        expect(model.enhancement, isNull);
        // Should still calculate without error
        expect(model.totalCost, 0);
      });

      test('handles enhancementTypeIndex of 0 (no selection)', () async {
        await _setupPrefs();
        final model = EnhancementCalculatorModel();

        // Select an enhancement first
        model.enhancementSelected(
          _findEnhancementByCategory('Move', EnhancementCategory.charPlusOne),
        );
        expect(model.enhancement, isNotNull);

        // Reset via prefs
        SharedPrefs().enhancementTypeIndex = 0;
        model.reloadFromPrefs();

        expect(model.enhancement, isNull);
      });
    });
  });
}
