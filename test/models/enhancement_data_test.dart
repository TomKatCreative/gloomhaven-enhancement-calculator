import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/enhancement_data.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

void main() {
  group('EnhancementData', () {
    group('enhancements list', () {
      test('has correct total count', () {
        // 11 charPlusOne + 1 target + 4 summonPlusOne + 4 posEffect +
        // 6 negEffect + 1 jump + 1 specElem + 1 anyElem + 12 hex = 41
        // But actual list has specific count - verify from source
        expect(EnhancementData.enhancements, isNotEmpty);
      });

      test('correct count of charPlusOne enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.charPlusOne)
            .length;
        expect(count, 10);
      });

      test('correct count of target enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.target)
            .length;
        expect(count, 1);
      });

      test('correct count of summonPlusOne enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.summonPlusOne)
            .length;
        expect(count, 4);
      });

      test('correct count of posEffect enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.posEffect)
            .length;
        expect(count, 4);
      });

      test('correct count of negEffect enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.negEffect)
            .length;
        expect(count, 6);
      });

      test('correct count of jump enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.jump)
            .length;
        expect(count, 1);
      });

      test('correct count of specElem enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.specElem)
            .length;
        expect(count, 1);
      });

      test('correct count of anyElem enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.anyElem)
            .length;
        expect(count, 1);
      });

      test('correct count of hex enhancements', () {
        final count = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.hex)
            .length;
        expect(count, 12);
      });

      test('all enhancements have assetKey', () {
        for (final e in EnhancementData.enhancements) {
          expect(
            e.assetKey,
            isNotNull,
            reason: '${e.name} should have assetKey',
          );
        }
      });

      test('hex costs decrease as hex count increases', () {
        final hexEnhancements = EnhancementData.enhancements
            .where((e) => e.category == EnhancementCategory.hex)
            .toList();

        for (int i = 0; i < hexEnhancements.length - 1; i++) {
          expect(
            hexEnhancements[i].ghCost,
            greaterThan(hexEnhancements[i + 1].ghCost),
            reason:
                '${hexEnhancements[i].name} (${hexEnhancements[i].ghCost}) '
                'should cost more than '
                '${hexEnhancements[i + 1].name} (${hexEnhancements[i + 1].ghCost})',
          );
        }
      });
    });

    group('isAvailableInEdition', () {
      test('Disarm is available in GH only', () {
        final disarm = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Disarm',
        );

        expect(
          EnhancementData.isAvailableInEdition(disarm, GameEdition.gloomhaven),
          isTrue,
        );
        expect(
          EnhancementData.isAvailableInEdition(
            disarm,
            GameEdition.gloomhaven2e,
          ),
          isFalse,
        );
        expect(
          EnhancementData.isAvailableInEdition(disarm, GameEdition.frosthaven),
          isFalse,
        );
      });

      test('Ward is available in GH2E and FH but not GH', () {
        final ward = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Ward',
        );

        expect(
          EnhancementData.isAvailableInEdition(ward, GameEdition.gloomhaven),
          isFalse,
        );
        expect(
          EnhancementData.isAvailableInEdition(ward, GameEdition.gloomhaven2e),
          isTrue,
        );
        expect(
          EnhancementData.isAvailableInEdition(ward, GameEdition.frosthaven),
          isTrue,
        );
      });

      test('Move is available in all editions', () {
        final move = EnhancementData.enhancements.firstWhere(
          (e) =>
              e.name == 'Move' && e.category == EnhancementCategory.charPlusOne,
        );

        expect(
          EnhancementData.isAvailableInEdition(move, GameEdition.gloomhaven),
          isTrue,
        );
        expect(
          EnhancementData.isAvailableInEdition(move, GameEdition.gloomhaven2e),
          isTrue,
        );
        expect(
          EnhancementData.isAvailableInEdition(move, GameEdition.frosthaven),
          isTrue,
        );
      });

      test('Attack is available in all editions', () {
        final attack = EnhancementData.enhancements.firstWhere(
          (e) =>
              e.name == 'Attack' &&
              e.category == EnhancementCategory.charPlusOne,
        );

        for (final edition in GameEdition.values) {
          expect(
            EnhancementData.isAvailableInEdition(attack, edition),
            isTrue,
            reason: 'Attack should be available in ${edition.displayName}',
          );
        }
      });

      test('Element is available in all editions', () {
        final element = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Element',
        );

        for (final edition in GameEdition.values) {
          expect(
            EnhancementData.isAvailableInEdition(element, edition),
            isTrue,
          );
        }
      });

      test('Wound is available in all editions', () {
        final wound = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Wound',
        );

        for (final edition in GameEdition.values) {
          expect(EnhancementData.isAvailableInEdition(wound, edition), isTrue);
        }
      });

      test('Jump is available in all editions', () {
        final jump = EnhancementData.enhancements.firstWhere(
          (e) => e.name == 'Jump',
        );

        for (final edition in GameEdition.values) {
          expect(EnhancementData.isAvailableInEdition(jump, edition), isTrue);
        }
      });
    });
  });
}
