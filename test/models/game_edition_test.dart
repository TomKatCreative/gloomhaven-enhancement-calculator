import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

void main() {
  group('GameEdition', () {
    group('supportsPartyBoon', () {
      test('true for Gloomhaven', () {
        expect(GameEdition.gloomhaven.supportsPartyBoon, isTrue);
      });

      test('true for Gloomhaven 2E', () {
        expect(GameEdition.gloomhaven2e.supportsPartyBoon, isTrue);
      });

      test('false for Frosthaven', () {
        expect(GameEdition.frosthaven.supportsPartyBoon, isFalse);
      });
    });

    group('hasLostModifier', () {
      test('false for Gloomhaven', () {
        expect(GameEdition.gloomhaven.hasLostModifier, isFalse);
      });

      test('true for Gloomhaven 2E', () {
        expect(GameEdition.gloomhaven2e.hasLostModifier, isTrue);
      });

      test('true for Frosthaven', () {
        expect(GameEdition.frosthaven.hasLostModifier, isTrue);
      });
    });

    group('hasPersistentModifier', () {
      test('false for Gloomhaven', () {
        expect(GameEdition.gloomhaven.hasPersistentModifier, isFalse);
      });

      test('false for Gloomhaven 2E', () {
        expect(GameEdition.gloomhaven2e.hasPersistentModifier, isFalse);
      });

      test('true for Frosthaven', () {
        expect(GameEdition.frosthaven.hasPersistentModifier, isTrue);
      });
    });

    group('hasEnhancerLevels', () {
      test('false for Gloomhaven', () {
        expect(GameEdition.gloomhaven.hasEnhancerLevels, isFalse);
      });

      test('false for Gloomhaven 2E', () {
        expect(GameEdition.gloomhaven2e.hasEnhancerLevels, isFalse);
      });

      test('true for Frosthaven', () {
        expect(GameEdition.frosthaven.hasEnhancerLevels, isTrue);
      });
    });

    group('multiTargetAppliesToAll', () {
      test('true for Gloomhaven', () {
        expect(GameEdition.gloomhaven.multiTargetAppliesToAll, isTrue);
      });

      test('false for Gloomhaven 2E', () {
        expect(GameEdition.gloomhaven2e.multiTargetAppliesToAll, isFalse);
      });

      test('false for Frosthaven', () {
        expect(GameEdition.frosthaven.multiTargetAppliesToAll, isFalse);
      });
    });

    group('displayName', () {
      test('Gloomhaven', () {
        expect(GameEdition.gloomhaven.displayName, 'Gloomhaven');
      });

      test('Gloomhaven 2E', () {
        expect(GameEdition.gloomhaven2e.displayName, 'Gloomhaven 2E');
      });

      test('Frosthaven', () {
        expect(GameEdition.frosthaven.displayName, 'Frosthaven');
      });
    });
  });
}
