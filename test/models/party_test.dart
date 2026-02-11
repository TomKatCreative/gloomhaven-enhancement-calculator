import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';

import '../helpers/test_data.dart';

void main() {
  group('Party', () {
    group('toMap / fromMap round-trip', () {
      test('preserves all fields', () {
        final party = TestData.createParty(
          id: 'p-123',
          campaignId: 'c-456',
          name: 'The Heroes',
          reputation: 5,
          location: 'Scenario 42',
          notes: 'Watch out for traps',
          achievements: ['Achievement 1', 'Achievement 3'],
        );

        final map = party.toMap();
        final restored = Party.fromMap(map);

        expect(restored.id, 'p-123');
        expect(restored.campaignId, 'c-456');
        expect(restored.name, 'The Heroes');
        expect(restored.reputation, 5);
        expect(restored.location, 'Scenario 42');
        expect(restored.notes, 'Watch out for traps');
        expect(restored.achievements, ['Achievement 1', 'Achievement 3']);
      });

      test('handles negative reputation', () {
        final party = TestData.createParty(reputation: -15);
        final restored = Party.fromMap(party.toMap());
        expect(restored.reputation, -15);
      });

      test('defaults reputation to 0 when null in map', () {
        final map = {
          columnPartyId: 'p-1',
          columnPartyCampaignId: 'c-1',
          columnPartyName: 'Party',
          columnPartyReputation: null,
        };
        final party = Party.fromMap(map);
        expect(party.reputation, 0);
      });

      test('defaults location to empty string when null in map', () {
        final map = {
          columnPartyId: 'p-1',
          columnPartyCampaignId: 'c-1',
          columnPartyName: 'Party',
          columnPartyReputation: 0,
          columnPartyLocation: null,
        };
        final party = Party.fromMap(map);
        expect(party.location, '');
      });

      test('defaults notes to empty string when null in map', () {
        final map = {
          columnPartyId: 'p-1',
          columnPartyCampaignId: 'c-1',
          columnPartyName: 'Party',
          columnPartyReputation: 0,
          columnPartyNotes: null,
        };
        final party = Party.fromMap(map);
        expect(party.notes, '');
      });

      test('defaults achievements to empty list when null in map', () {
        final map = {
          columnPartyId: 'p-1',
          columnPartyCampaignId: 'c-1',
          columnPartyName: 'Party',
          columnPartyReputation: 0,
          columnPartyAchievements: null,
        };
        final party = Party.fromMap(map);
        expect(party.achievements, isEmpty);
      });

      test('defaults achievements to empty list when empty string in map', () {
        final map = {
          columnPartyId: 'p-1',
          columnPartyCampaignId: 'c-1',
          columnPartyName: 'Party',
          columnPartyReputation: 0,
          columnPartyAchievements: '',
        };
        final party = Party.fromMap(map);
        expect(party.achievements, isEmpty);
      });

      test('achievements JSON encoding round-trip', () {
        final party = TestData.createParty(
          achievements: ['First Blood', 'Town Guard'],
        );
        final map = party.toMap();

        // Verify it's stored as JSON
        expect(map[columnPartyAchievements], isA<String>());
        final decoded = jsonDecode(map[columnPartyAchievements] as String);
        expect(decoded, ['First Blood', 'Town Guard']);

        // Verify round-trip
        final restored = Party.fromMap(map);
        expect(restored.achievements, ['First Blood', 'Town Guard']);
      });

      test('empty achievements list encodes as empty JSON array', () {
        final party = TestData.createParty(achievements: []);
        final map = party.toMap();
        expect(map[columnPartyAchievements], '[]');
      });

      test('parses createdAt timestamp', () {
        final map = {
          columnPartyId: 'p-1',
          columnPartyCampaignId: 'c-1',
          columnPartyName: 'Party',
          columnPartyReputation: 0,
          columnPartyCreatedAt: '2025-06-20 14:00:00',
        };
        final party = Party.fromMap(map);
        expect(party.createdAt, isNotNull);
        expect(party.createdAt!.month, 6);
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

    group('shopPriceModifier', () {
      test('reputation 20 returns -5', () {
        final party = TestData.createParty(reputation: 20);
        expect(party.shopPriceModifier, -5);
      });

      test('reputation 19 returns -5', () {
        final party = TestData.createParty(reputation: 19);
        expect(party.shopPriceModifier, -5);
      });

      test('reputation 18 returns -4', () {
        final party = TestData.createParty(reputation: 18);
        expect(party.shopPriceModifier, -4);
      });

      test('reputation 15 returns -4', () {
        final party = TestData.createParty(reputation: 15);
        expect(party.shopPriceModifier, -4);
      });

      test('reputation 14 returns -3', () {
        final party = TestData.createParty(reputation: 14);
        expect(party.shopPriceModifier, -3);
      });

      test('reputation 11 returns -3', () {
        final party = TestData.createParty(reputation: 11);
        expect(party.shopPriceModifier, -3);
      });

      test('reputation 7 returns -2', () {
        final party = TestData.createParty(reputation: 7);
        expect(party.shopPriceModifier, -2);
      });

      test('reputation 3 returns -1', () {
        final party = TestData.createParty(reputation: 3);
        expect(party.shopPriceModifier, -1);
      });

      test('reputation 2 returns 0', () {
        final party = TestData.createParty(reputation: 2);
        expect(party.shopPriceModifier, 0);
      });

      test('reputation 0 returns 0', () {
        final party = TestData.createParty(reputation: 0);
        expect(party.shopPriceModifier, 0);
      });

      test('reputation -2 returns 0', () {
        final party = TestData.createParty(reputation: -2);
        expect(party.shopPriceModifier, 0);
      });

      test('reputation -3 returns 1', () {
        final party = TestData.createParty(reputation: -3);
        expect(party.shopPriceModifier, 1);
      });

      test('reputation -6 returns 1', () {
        final party = TestData.createParty(reputation: -6);
        expect(party.shopPriceModifier, 1);
      });

      test('reputation -7 returns 2', () {
        final party = TestData.createParty(reputation: -7);
        expect(party.shopPriceModifier, 2);
      });

      test('reputation -10 returns 2', () {
        final party = TestData.createParty(reputation: -10);
        expect(party.shopPriceModifier, 2);
      });

      test('reputation -11 returns 3', () {
        final party = TestData.createParty(reputation: -11);
        expect(party.shopPriceModifier, 3);
      });

      test('reputation -14 returns 3', () {
        final party = TestData.createParty(reputation: -14);
        expect(party.shopPriceModifier, 3);
      });

      test('reputation -15 returns 4', () {
        final party = TestData.createParty(reputation: -15);
        expect(party.shopPriceModifier, 4);
      });

      test('reputation -18 returns 4', () {
        final party = TestData.createParty(reputation: -18);
        expect(party.shopPriceModifier, 4);
      });

      test('reputation -19 returns 5', () {
        final party = TestData.createParty(reputation: -19);
        expect(party.shopPriceModifier, 5);
      });

      test('reputation -20 returns 5', () {
        final party = TestData.createParty(reputation: -20);
        expect(party.shopPriceModifier, 5);
      });
    });
  });
}
