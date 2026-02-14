import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

void main() {
  group('GameEdition', () {
    group('supportsPartyBoon', () {
      test('true for Gloomhaven', () {
        expect(GameEdition.gloomhaven.supportsPartyBoon, isTrue);
      });

      test('true for Gloomhaven 2e', () {
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

      test('true for Gloomhaven 2e', () {
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

      test('false for Gloomhaven 2e', () {
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

      test('false for Gloomhaven 2e', () {
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

      test('false for Gloomhaven 2e', () {
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

      test('Gloomhaven 2e', () {
        expect(GameEdition.gloomhaven2e.displayName, 'Gloomhaven 2e');
      });

      test('Frosthaven', () {
        expect(GameEdition.frosthaven.displayName, 'Frosthaven');
      });
    });

    group('maxStartingLevel', () {
      test('Gloomhaven returns prosperity level directly', () {
        expect(GameEdition.gloomhaven.maxStartingLevel(1), 1);
        expect(GameEdition.gloomhaven.maxStartingLevel(2), 2);
        expect(GameEdition.gloomhaven.maxStartingLevel(5), 5);
        expect(GameEdition.gloomhaven.maxStartingLevel(9), 9);
      });

      test('Gloomhaven 2e returns prosperity / 2 rounded up', () {
        expect(GameEdition.gloomhaven2e.maxStartingLevel(1), 1);
        expect(GameEdition.gloomhaven2e.maxStartingLevel(2), 1);
        expect(GameEdition.gloomhaven2e.maxStartingLevel(3), 2);
        expect(GameEdition.gloomhaven2e.maxStartingLevel(4), 2);
        expect(GameEdition.gloomhaven2e.maxStartingLevel(5), 3);
        expect(GameEdition.gloomhaven2e.maxStartingLevel(9), 5);
      });

      test('Frosthaven returns prosperity / 2 rounded up', () {
        expect(GameEdition.frosthaven.maxStartingLevel(1), 1);
        expect(GameEdition.frosthaven.maxStartingLevel(2), 1);
        expect(GameEdition.frosthaven.maxStartingLevel(3), 2);
        expect(GameEdition.frosthaven.maxStartingLevel(4), 2);
        expect(GameEdition.frosthaven.maxStartingLevel(5), 3);
        expect(GameEdition.frosthaven.maxStartingLevel(9), 5);
      });
    });

    group('startingGold', () {
      test('Gloomhaven: 15 * (level + 1)', () {
        expect(GameEdition.gloomhaven.startingGold(level: 1), 30);
        expect(GameEdition.gloomhaven.startingGold(level: 2), 45);
        expect(GameEdition.gloomhaven.startingGold(level: 5), 90);
        expect(GameEdition.gloomhaven.startingGold(level: 9), 150);
      });

      test('Gloomhaven 2e: 10 * prosperity + 15', () {
        expect(GameEdition.gloomhaven2e.startingGold(prosperityLevel: 0), 15);
        expect(GameEdition.gloomhaven2e.startingGold(prosperityLevel: 1), 25);
        expect(GameEdition.gloomhaven2e.startingGold(prosperityLevel: 3), 45);
        expect(GameEdition.gloomhaven2e.startingGold(prosperityLevel: 9), 105);
      });

      test('Frosthaven: 10 * prosperity + 20', () {
        expect(GameEdition.frosthaven.startingGold(prosperityLevel: 0), 20);
        expect(GameEdition.frosthaven.startingGold(prosperityLevel: 1), 30);
        expect(GameEdition.frosthaven.startingGold(prosperityLevel: 4), 60);
        expect(GameEdition.frosthaven.startingGold(prosperityLevel: 9), 110);
      });

      test('uses default parameter values', () {
        // Default: level=1, prosperityLevel=0
        expect(GameEdition.gloomhaven.startingGold(), 30);
        expect(GameEdition.gloomhaven2e.startingGold(), 15);
        expect(GameEdition.frosthaven.startingGold(), 20);
      });

      test('GH ignores prosperity, GH2E/FH ignore level', () {
        // GH gold depends only on level, not prosperity
        expect(
          GameEdition.gloomhaven.startingGold(level: 3, prosperityLevel: 9),
          60, // 15 * (3 + 1)
        );
        // GH2E gold depends only on prosperity, not level
        expect(
          GameEdition.gloomhaven2e.startingGold(level: 9, prosperityLevel: 3),
          45, // 10 * 3 + 15
        );
        // FH gold depends only on prosperity, not level
        expect(
          GameEdition.frosthaven.startingGold(level: 9, prosperityLevel: 3),
          50, // 10 * 3 + 20
        );
      });
    });
  });
}
