import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

import '../helpers/test_data.dart';

void main() {
  group('Campaign', () {
    group('toMap / fromMap round-trip', () {
      test('preserves all fields', () {
        final campaign = TestData.createCampaign(
          id: 'c-123',
          name: 'My Campaign',
          edition: GameEdition.gloomhaven,
          prosperityCheckmarks: 12,
          donatedGold: 50,
        );

        final map = campaign.toMap();
        final restored = Campaign.fromMap(map);

        expect(restored.id, 'c-123');
        expect(restored.name, 'My Campaign');
        expect(restored.edition, GameEdition.gloomhaven);
        expect(restored.prosperityCheckmarks, 12);
        expect(restored.donatedGold, 50);
      });

      test('handles all editions', () {
        for (final edition in GameEdition.values) {
          final campaign = TestData.createCampaign(edition: edition);
          final restored = Campaign.fromMap(campaign.toMap());
          expect(restored.edition, edition);
        }
      });

      test('defaults prosperityCheckmarks to 0 when null in map', () {
        final map = {
          columnCampaignId: 'c-1',
          columnCampaignName: 'Test',
          columnCampaignEdition: 'gloomhaven',
          columnCampaignProsperityCheckmarks: null,
          columnCampaignDonatedGold: null,
        };
        final campaign = Campaign.fromMap(map);
        expect(campaign.prosperityCheckmarks, 0);
        expect(campaign.donatedGold, 0);
      });

      test('parses createdAt timestamp', () {
        final map = {
          columnCampaignId: 'c-1',
          columnCampaignName: 'Test',
          columnCampaignEdition: 'gloomhaven',
          columnCampaignProsperityCheckmarks: 0,
          columnCampaignDonatedGold: 0,
          columnCampaignCreatedAt: '2025-01-15 10:30:00',
        };
        final campaign = Campaign.fromMap(map);
        expect(campaign.createdAt, isNotNull);
        expect(campaign.createdAt!.year, 2025);
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
          final campaign = TestData.createCampaign(
            prosperityCheckmarks: checkmarks,
          );
          expect(campaign.prosperityLevel, expectedLevel);
        });
      });
    });

    group('prosperityLevel (other editions)', () {
      test('GH2E uses same thresholds', () {
        final campaign = TestData.createCampaign(
          edition: GameEdition.gloomhaven2e,
          prosperityCheckmarks: 23,
        );
        expect(campaign.prosperityLevel, 5);
      });

      test('Frosthaven uses same thresholds', () {
        final campaign = TestData.createCampaign(
          edition: GameEdition.frosthaven,
          prosperityCheckmarks: 40,
        );
        expect(campaign.prosperityLevel, 7);
      });
    });

    group('checkmarksForNextLevel', () {
      test('returns next threshold', () {
        final campaign = TestData.createCampaign(prosperityCheckmarks: 7);
        // Level 2 (need 5), next is level 3 (need 10)
        expect(campaign.checkmarksForNextLevel, 10);
      });

      test('returns null at max level', () {
        final campaign = TestData.createCampaign(prosperityCheckmarks: 65);
        expect(campaign.prosperityLevel, 9);
        expect(campaign.checkmarksForNextLevel, isNull);
      });
    });

    group('checkmarksForCurrentLevel', () {
      test('returns current level threshold', () {
        final campaign = TestData.createCampaign(prosperityCheckmarks: 7);
        // Level 2, threshold is 5
        expect(campaign.checkmarksForCurrentLevel, 5);
      });

      test('returns 0 for level 1', () {
        final campaign = TestData.createCampaign(prosperityCheckmarks: 0);
        expect(campaign.checkmarksForCurrentLevel, 0);
      });
    });

    group('maxProsperityLevel', () {
      test('is 9 for all editions', () {
        for (final edition in GameEdition.values) {
          final campaign = TestData.createCampaign(edition: edition);
          expect(campaign.maxProsperityLevel, 9);
        }
      });
    });

    group('maxDonatedGold', () {
      test('is 100', () {
        expect(maxDonatedGold, 100);
      });
    });
  });
}
