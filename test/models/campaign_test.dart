import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';

import '../helpers/test_data.dart';

void main() {
  group('Campaign', () {
    group('toMap / fromMap round-trip', () {
      test('preserves all fields', () {
        final campaign = TestData.createCampaign(
          id: 'c-123',
          worldId: 'w-456',
          name: 'The Heroes',
          reputation: 5,
        );

        final map = campaign.toMap();
        final restored = Campaign.fromMap(map);

        expect(restored.id, 'c-123');
        expect(restored.worldId, 'w-456');
        expect(restored.name, 'The Heroes');
        expect(restored.reputation, 5);
      });

      test('handles negative reputation', () {
        final campaign = TestData.createCampaign(reputation: -15);
        final restored = Campaign.fromMap(campaign.toMap());
        expect(restored.reputation, -15);
      });

      test('defaults reputation to 0 when null in map', () {
        final map = {
          columnCampaignId: 'c-1',
          columnCampaignWorldId: 'w-1',
          columnCampaignName: 'Party',
          columnCampaignReputation: null,
        };
        final campaign = Campaign.fromMap(map);
        expect(campaign.reputation, 0);
      });

      test('parses createdAt timestamp', () {
        final map = {
          columnCampaignId: 'c-1',
          columnCampaignWorldId: 'w-1',
          columnCampaignName: 'Party',
          columnCampaignReputation: 0,
          columnCampaignCreatedAt: '2025-06-20 14:00:00',
        };
        final campaign = Campaign.fromMap(map);
        expect(campaign.createdAt, isNotNull);
        expect(campaign.createdAt!.month, 6);
      });
    });

    group('reputation bounds constants', () {
      test('min reputation is -20', () {
        expect(minReputation, -20);
      });

      test('max reputation is 20', () {
        expect(maxReputation, 20);
      });
    });
  });
}
