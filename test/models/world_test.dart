import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/world.dart';

import '../helpers/test_data.dart';

void main() {
  group('World', () {
    group('toMap / fromMap round-trip', () {
      test('preserves all fields', () {
        final world = TestData.createWorld(
          id: 'w-123',
          name: 'My World',
          edition: GameEdition.gloomhaven,
          prosperityCheckmarks: 12,
          donatedGold: 50,
        );

        final map = world.toMap();
        final restored = World.fromMap(map);

        expect(restored.id, 'w-123');
        expect(restored.name, 'My World');
        expect(restored.edition, GameEdition.gloomhaven);
        expect(restored.prosperityCheckmarks, 12);
        expect(restored.donatedGold, 50);
      });

      test('handles all editions', () {
        for (final edition in GameEdition.values) {
          final world = TestData.createWorld(edition: edition);
          final restored = World.fromMap(world.toMap());
          expect(restored.edition, edition);
        }
      });

      test('defaults prosperityCheckmarks to 0 when null in map', () {
        final map = {
          columnWorldId: 'w-1',
          columnWorldName: 'Test',
          columnWorldEdition: 'gloomhaven',
          columnWorldProsperityCheckmarks: null,
          columnWorldDonatedGold: null,
        };
        final world = World.fromMap(map);
        expect(world.prosperityCheckmarks, 0);
        expect(world.donatedGold, 0);
      });

      test('parses createdAt timestamp', () {
        final map = {
          columnWorldId: 'w-1',
          columnWorldName: 'Test',
          columnWorldEdition: 'gloomhaven',
          columnWorldProsperityCheckmarks: 0,
          columnWorldDonatedGold: 0,
          columnWorldCreatedAt: '2025-01-15 10:30:00',
        };
        final world = World.fromMap(map);
        expect(world.createdAt, isNotNull);
        expect(world.createdAt!.year, 2025);
      });
    });

    group('prosperityLevel (Gloomhaven thresholds)', () {
      // Thresholds: [0, 5, 10, 16, 23, 31, 40, 51, 65]
      final testCases = <int, int>{
        0: 1,
        1: 1,
        4: 1,
        5: 2,
        9: 2,
        10: 3,
        15: 3,
        16: 4,
        22: 4,
        23: 5,
        30: 5,
        31: 6,
        39: 6,
        40: 7,
        50: 7,
        51: 8,
        64: 8,
        65: 9,
        100: 9,
      };

      testCases.forEach((checkmarks, expectedLevel) {
        test('$checkmarks checkmarks → level $expectedLevel', () {
          final world = TestData.createWorld(prosperityCheckmarks: checkmarks);
          expect(world.prosperityLevel, expectedLevel);
        });
      });
    });

    group('prosperityLevel (other editions)', () {
      test('GH2E uses same thresholds', () {
        final world = TestData.createWorld(
          edition: GameEdition.gloomhaven2e,
          prosperityCheckmarks: 23,
        );
        expect(world.prosperityLevel, 5);
      });

      test('Frosthaven uses same thresholds', () {
        final world = TestData.createWorld(
          edition: GameEdition.frosthaven,
          prosperityCheckmarks: 40,
        );
        expect(world.prosperityLevel, 7);
      });
    });

    group('checkmarksForNextLevel', () {
      test('returns next threshold', () {
        final world = TestData.createWorld(prosperityCheckmarks: 7);
        // Level 2 (need 5), next is level 3 (need 10)
        expect(world.checkmarksForNextLevel, 10);
      });

      test('returns null at max level', () {
        final world = TestData.createWorld(prosperityCheckmarks: 65);
        expect(world.prosperityLevel, 9);
        expect(world.checkmarksForNextLevel, isNull);
      });
    });

    group('checkmarksForCurrentLevel', () {
      test('returns current level threshold', () {
        final world = TestData.createWorld(prosperityCheckmarks: 7);
        // Level 2, threshold is 5
        expect(world.checkmarksForCurrentLevel, 5);
      });

      test('returns 0 for level 1', () {
        final world = TestData.createWorld(prosperityCheckmarks: 0);
        expect(world.checkmarksForCurrentLevel, 0);
      });
    });

    group('maxProsperityLevel', () {
      test('is 9 for all editions', () {
        for (final edition in GameEdition.values) {
          final world = TestData.createWorld(edition: edition);
          expect(world.maxProsperityLevel, 9);
        }
      });
    });
  });
}
