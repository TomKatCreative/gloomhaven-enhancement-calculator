import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/enhancement.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

void main() {
  group('Enhancement', () {
    group('cost()', () {
      test('GH returns ghCost', () {
        final enhancement = Enhancement(
          EnhancementCategory.charPlusOne,
          'Move',
          ghCost: 30,
        );

        expect(enhancement.cost(edition: GameEdition.gloomhaven), 30);
      });

      test('GH2E returns fhCost when available', () {
        final enhancement = Enhancement(
          EnhancementCategory.target,
          'Target',
          ghCost: 50,
          fhCost: 75,
        );

        expect(enhancement.cost(edition: GameEdition.gloomhaven2e), 75);
      });

      test('GH2E falls back to ghCost when fhCost is null', () {
        final enhancement = Enhancement(
          EnhancementCategory.charPlusOne,
          'Move',
          ghCost: 30,
        );

        expect(enhancement.cost(edition: GameEdition.gloomhaven2e), 30);
      });

      test('FH returns fhCost when available', () {
        final enhancement = Enhancement(
          EnhancementCategory.target,
          'Target',
          ghCost: 50,
          fhCost: 75,
        );

        expect(enhancement.cost(edition: GameEdition.frosthaven), 75);
      });

      test('FH falls back to ghCost when fhCost is null', () {
        final enhancement = Enhancement(
          EnhancementCategory.charPlusOne,
          'Attack',
          ghCost: 50,
        );

        expect(enhancement.cost(edition: GameEdition.frosthaven), 50);
      });
    });

    group('enhancements with no fhCost (same cost all editions)', () {
      test('Move costs 30g in all editions', () {
        final move = EnhancementData.enhancements.firstWhere(
          (e) =>
              e.name == 'Move' && e.category == EnhancementCategory.charPlusOne,
        );
        expect(move.cost(edition: GameEdition.gloomhaven), 30);
        expect(move.cost(edition: GameEdition.gloomhaven2e), 30);
        expect(move.cost(edition: GameEdition.frosthaven), 30);
      });

      test('Attack costs 50g in all editions', () {
        final attack = EnhancementData.enhancements.firstWhere(
          (e) =>
              e.name == 'Attack' &&
              e.category == EnhancementCategory.charPlusOne,
        );
        expect(attack.cost(edition: GameEdition.gloomhaven), 50);
        expect(attack.cost(edition: GameEdition.frosthaven), 50);
      });

      test('Wound costs 75g in all editions', () {
        final wound = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Wound',
        );
        expect(wound.cost(edition: GameEdition.gloomhaven), 75);
        expect(wound.cost(edition: GameEdition.frosthaven), 75);
      });

      test('Element costs 100g in all editions', () {
        final element = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Element',
        );
        expect(element.cost(edition: GameEdition.gloomhaven), 100);
        expect(element.cost(edition: GameEdition.frosthaven), 100);
      });

      test('Wild Element costs 150g in all editions', () {
        final wildElement = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Wild Element',
        );
        expect(wildElement.cost(edition: GameEdition.gloomhaven), 150);
        expect(wildElement.cost(edition: GameEdition.frosthaven), 150);
      });
    });

    group('enhancements with different fhCost', () {
      test('Target: GH=50, GH2E/FH=75', () {
        final target = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Target',
        );
        expect(target.cost(edition: GameEdition.gloomhaven), 50);
        expect(target.cost(edition: GameEdition.gloomhaven2e), 75);
        expect(target.cost(edition: GameEdition.frosthaven), 75);
      });

      test('Shield: GH=100, GH2E/FH=80', () {
        final shield = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Shield',
        );
        expect(shield.cost(edition: GameEdition.gloomhaven), 100);
        expect(shield.cost(edition: GameEdition.gloomhaven2e), 80);
        expect(shield.cost(edition: GameEdition.frosthaven), 80);
      });

      test('Retaliate: GH=100, GH2E/FH=60', () {
        final retaliate = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Retaliate',
        );
        expect(retaliate.cost(edition: GameEdition.gloomhaven), 100);
        expect(retaliate.cost(edition: GameEdition.frosthaven), 60);
      });

      test('Pull: GH=30, GH2E/FH=20', () {
        final pull = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Pull',
        );
        expect(pull.cost(edition: GameEdition.gloomhaven), 30);
        expect(pull.cost(edition: GameEdition.frosthaven), 20);
      });

      test('Teleport: GH=40, GH2E/FH=50', () {
        final teleport = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Teleport',
        );
        expect(teleport.cost(edition: GameEdition.gloomhaven), 40);
        expect(teleport.cost(edition: GameEdition.frosthaven), 50);
      });

      test('Summon HP: GH=50, GH2E/FH=40', () {
        final hp = EnhancementData.enhancements.firstWhere(
          (e) =>
              e.name == 'HP' && e.category == EnhancementCategory.summonPlusOne,
        );
        expect(hp.cost(edition: GameEdition.gloomhaven), 50);
        expect(hp.cost(edition: GameEdition.frosthaven), 40);
      });

      test('Summon Move: GH=100, GH2E/FH=60', () {
        final summonMove = EnhancementData.enhancements.firstWhere(
          (e) =>
              e.name == 'Move' &&
              e.category == EnhancementCategory.summonPlusOne,
        );
        expect(summonMove.cost(edition: GameEdition.gloomhaven), 100);
        expect(summonMove.cost(edition: GameEdition.frosthaven), 60);
      });
    });
  });

  group('EnhancementCategory', () {
    group('sectionTitle', () {
      test('charPlusOne returns Character', () {
        expect(EnhancementCategory.charPlusOne.sectionTitle, 'Character');
      });

      test('target returns Character', () {
        expect(EnhancementCategory.target.sectionTitle, 'Character');
      });

      test('summonPlusOne returns Summon', () {
        expect(EnhancementCategory.summonPlusOne.sectionTitle, 'Summon');
      });

      test('posEffect returns Effect', () {
        expect(EnhancementCategory.posEffect.sectionTitle, 'Effect');
      });

      test('negEffect returns Effect', () {
        expect(EnhancementCategory.negEffect.sectionTitle, 'Effect');
      });

      test('hex returns Existing hexes', () {
        expect(EnhancementCategory.hex.sectionTitle, 'Existing hexes');
      });
    });

    group('sectionAssetKey', () {
      test('charPlusOne returns plus_one', () {
        expect(EnhancementCategory.charPlusOne.sectionAssetKey, 'plus_one');
      });

      test('target returns plus_one', () {
        expect(EnhancementCategory.target.sectionAssetKey, 'plus_one');
      });

      test('summonPlusOne returns plus_one', () {
        expect(EnhancementCategory.summonPlusOne.sectionAssetKey, 'plus_one');
      });

      test('hex returns hex', () {
        expect(EnhancementCategory.hex.sectionAssetKey, 'hex');
      });

      test('posEffect returns null', () {
        expect(EnhancementCategory.posEffect.sectionAssetKey, isNull);
      });

      test('negEffect returns null', () {
        expect(EnhancementCategory.negEffect.sectionAssetKey, isNull);
      });
    });
  });
}
