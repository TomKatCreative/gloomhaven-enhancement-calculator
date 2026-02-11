import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/party.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_data.dart';

void main() {
  late TownModel model;
  late FakeDatabaseHelper fakeDb;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefs().init();
    fakeDb = FakeDatabaseHelper();
    model = TownModel(databaseHelper: fakeDb);
  });

  group('TownModel', () {
    group('loadCampaigns', () {
      test('loads empty list when no campaigns exist', () async {
        await model.loadCampaigns();
        expect(model.campaigns, isEmpty);
        expect(model.activeCampaign, isNull);
      });

      test('loads campaigns and sets first as active', () async {
        final campaign = TestData.createCampaign();
        fakeDb.campaigns = [campaign];

        await model.loadCampaigns();

        expect(model.campaigns, hasLength(1));
        expect(model.activeCampaign?.id, 'campaign-1');
      });

      test('restores active campaign from SharedPrefs', () async {
        final c1 = TestData.createCampaign(id: 'c-1', name: 'Campaign 1');
        final c2 = TestData.createCampaign(id: 'c-2', name: 'Campaign 2');
        fakeDb.campaigns = [c1, c2];
        SharedPrefs().activeCampaignId = 'c-2';

        await model.loadCampaigns();

        expect(model.activeCampaign?.id, 'c-2');
        expect(model.activeCampaign?.name, 'Campaign 2');
      });

      test('falls back to first campaign if saved ID not found', () async {
        final campaign = TestData.createCampaign(id: 'c-1');
        fakeDb.campaigns = [campaign];
        SharedPrefs().activeCampaignId = 'nonexistent';

        await model.loadCampaigns();

        expect(model.activeCampaign?.id, 'c-1');
      });

      test('loads parties for active campaign', () async {
        final campaign = TestData.createCampaign();
        final party = TestData.createParty();
        fakeDb.campaigns = [campaign];
        fakeDb.partiesMap = {
          'campaign-1': [party],
        };

        await model.loadCampaigns();

        expect(model.parties, hasLength(1));
        expect(model.activeParty?.id, 'party-1');
      });

      test('restores active party from SharedPrefs', () async {
        final campaign = TestData.createCampaign();
        final p1 = TestData.createParty(id: 'p-1', name: 'Party 1');
        final p2 = TestData.createParty(id: 'p-2', name: 'Party 2');
        fakeDb.campaigns = [campaign];
        fakeDb.partiesMap = {
          'campaign-1': [p1, p2],
        };
        SharedPrefs().activePartyId = 'p-2';

        await model.loadCampaigns();

        expect(model.activeParty?.id, 'p-2');
      });
    });

    group('createCampaign', () {
      test('creates and sets active campaign', () async {
        await model.createCampaign(
          name: 'New Campaign',
          edition: GameEdition.gloomhaven,
        );

        expect(model.campaigns, hasLength(1));
        expect(model.activeCampaign?.name, 'New Campaign');
        expect(model.activeCampaign?.edition, GameEdition.gloomhaven);
        expect(SharedPrefs().activeCampaignId, isNotNull);
      });

      test('clears previous party state', () async {
        // Setup existing campaign with party
        await model.createCampaign(
          name: 'Campaign 1',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Party 1');
        expect(model.activeParty, isNotNull);

        // Create new campaign — should clear party
        await model.createCampaign(
          name: 'Campaign 2',
          edition: GameEdition.frosthaven,
        );
        expect(model.activeParty, isNull);
        expect(model.parties, isEmpty);
      });

      test('accepts starting prosperity checkmarks', () async {
        await model.createCampaign(
          name: 'Advanced',
          edition: GameEdition.gloomhaven,
          startingProsperityCheckmarks: 10,
        );

        expect(model.activeCampaign?.prosperityCheckmarks, 10);
        expect(model.activeCampaign?.prosperityLevel, 3);
      });
    });

    group('setActiveCampaign', () {
      test('switches active campaign and loads parties', () async {
        final c1 = TestData.createCampaign(id: 'c-1', name: 'Campaign 1');
        final c2 = TestData.createCampaign(id: 'c-2', name: 'Campaign 2');
        final p2 = TestData.createParty(
          id: 'p-2',
          campaignId: 'c-2',
          name: 'Party',
        );
        fakeDb.campaigns = [c1, c2];
        fakeDb.partiesMap = {
          'c-2': [p2],
        };
        await model.loadCampaigns();

        await model.setActiveCampaign(c2);

        expect(model.activeCampaign?.id, 'c-2');
        expect(model.parties, hasLength(1));
        expect(SharedPrefs().activeCampaignId, 'c-2');
      });
    });

    group('renameCampaign', () {
      test('updates campaign name', () async {
        await model.createCampaign(
          name: 'Old Name',
          edition: GameEdition.gloomhaven,
        );

        await model.renameCampaign('New Name');

        expect(model.activeCampaign?.name, 'New Name');
      });
    });

    group('deleteActiveCampaign', () {
      test('deletes campaign and falls back to next', () async {
        final c1 = TestData.createCampaign(id: 'c-1', name: 'Campaign 1');
        final c2 = TestData.createCampaign(id: 'c-2', name: 'Campaign 2');
        fakeDb.campaigns = [c1, c2];
        await model.loadCampaigns();
        await model.setActiveCampaign(c1);

        await model.deleteActiveCampaign();

        expect(model.campaigns, hasLength(1));
        expect(model.activeCampaign?.id, 'c-2');
      });

      test('sets null when last campaign deleted', () async {
        await model.createCampaign(
          name: 'Only Campaign',
          edition: GameEdition.gloomhaven,
        );

        await model.deleteActiveCampaign();

        expect(model.campaigns, isEmpty);
        expect(model.activeCampaign, isNull);
        expect(SharedPrefs().activeCampaignId, isNull);
      });
    });

    group('prosperity', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Test',
          edition: GameEdition.gloomhaven,
          startingProsperityCheckmarks: 5,
        );
      });

      test('incrementProsperity increases by 1', () async {
        await model.incrementProsperity();
        expect(model.activeCampaign?.prosperityCheckmarks, 6);
      });

      test('decrementProsperity decreases by 1', () async {
        await model.decrementProsperity();
        expect(model.activeCampaign?.prosperityCheckmarks, 4);
      });

      test('decrementProsperity does not go below 0', () async {
        await model.createCampaign(
          name: 'Zero',
          edition: GameEdition.gloomhaven,
          startingProsperityCheckmarks: 0,
        );

        await model.decrementProsperity();
        expect(model.activeCampaign?.prosperityCheckmarks, 0);
      });
    });

    group('createParty', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Test Campaign',
          edition: GameEdition.gloomhaven,
        );
      });

      test('creates and sets active party', () async {
        await model.createParty(name: 'Heroes');

        expect(model.parties, hasLength(1));
        expect(model.activeParty?.name, 'Heroes');
        expect(SharedPrefs().activePartyId, isNotNull);
      });

      test('accepts starting reputation', () async {
        await model.createParty(name: 'Infamous', startingReputation: -5);

        expect(model.activeParty?.reputation, -5);
      });
    });

    group('setActiveParty', () {
      test('switches active party', () async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Party 1');
        await model.createParty(name: 'Party 2');

        model.setActiveParty(model.parties.first);

        expect(model.activeParty?.name, 'Party 1');
      });
    });

    group('renameParty', () {
      test('updates party name', () async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Old Party');

        await model.renameParty('New Party');

        expect(model.activeParty?.name, 'New Party');
      });
    });

    group('deleteActiveParty', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
      });

      test('deletes and falls back to next party', () async {
        await model.createParty(name: 'Party 1');
        await model.createParty(name: 'Party 2');
        // Active is Party 2 (last created)
        model.setActiveParty(model.parties.last);

        await model.deleteActiveParty();

        expect(model.parties, hasLength(1));
        expect(model.activeParty?.name, 'Party 1');
      });

      test('sets null when last party deleted', () async {
        await model.createParty(name: 'Only Party');

        await model.deleteActiveParty();

        expect(model.parties, isEmpty);
        expect(model.activeParty, isNull);
        expect(SharedPrefs().activePartyId, isNull);
      });
    });

    group('updatePartyLocation', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Party');
      });

      test('updates location on active party', () async {
        await model.updatePartyLocation('Scenario 42');
        expect(model.activeParty?.location, 'Scenario 42');
      });

      test('persists location to database', () async {
        await model.updatePartyLocation('Scenario 42');
        // The fake DB stores the party by reference, so check via queryParties
        final parties = await fakeDb.queryParties(model.activeCampaign!.id);
        expect(parties.first.location, 'Scenario 42');
      });

      test('does nothing when no active party', () async {
        await model.deleteActiveParty();
        await model.updatePartyLocation('Scenario 42');
        expect(model.activeParty, isNull);
      });
    });

    group('updatePartyNotes', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Party');
      });

      test('updates notes on active party', () async {
        await model.updatePartyNotes('Watch out for traps');
        expect(model.activeParty?.notes, 'Watch out for traps');
      });

      test('persists notes to database', () async {
        await model.updatePartyNotes('Important note');
        final parties = await fakeDb.queryParties(model.activeCampaign!.id);
        expect(parties.first.notes, 'Important note');
      });

      test('does nothing when no active party', () async {
        await model.deleteActiveParty();
        await model.updatePartyNotes('Notes');
        expect(model.activeParty, isNull);
      });
    });

    group('toggleAchievement', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Party');
      });

      test('adds achievement when not present', () async {
        await model.toggleAchievement('Achievement 1');
        expect(model.activeParty?.achievements, contains('Achievement 1'));
      });

      test('removes achievement when already present', () async {
        await model.toggleAchievement('Achievement 1');
        expect(model.activeParty?.achievements, contains('Achievement 1'));

        await model.toggleAchievement('Achievement 1');
        expect(
          model.activeParty?.achievements,
          isNot(contains('Achievement 1')),
        );
      });

      test('can toggle multiple achievements', () async {
        await model.toggleAchievement('Achievement 1');
        await model.toggleAchievement('Achievement 2');
        expect(model.activeParty?.achievements, hasLength(2));
        expect(model.activeParty?.achievements, contains('Achievement 1'));
        expect(model.activeParty?.achievements, contains('Achievement 2'));
      });

      test('does nothing when no active party', () async {
        await model.deleteActiveParty();
        await model.toggleAchievement('Achievement 1');
        expect(model.activeParty, isNull);
      });
    });

    group('reputation', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await model.createParty(name: 'Party');
      });

      test('incrementReputation increases by 1', () async {
        await model.incrementReputation();
        expect(model.activeParty?.reputation, 1);
      });

      test('decrementReputation decreases by 1', () async {
        await model.decrementReputation();
        expect(model.activeParty?.reputation, -1);
      });

      test('incrementReputation does not exceed 20', () async {
        model.activeParty!.reputation = maxReputation;
        await model.incrementReputation();
        expect(model.activeParty?.reputation, maxReputation);
      });

      test('decrementReputation does not go below -20', () async {
        model.activeParty!.reputation = minReputation;
        await model.decrementReputation();
        expect(model.activeParty?.reputation, minReputation);
      });
    });

    group('donatedGold', () {
      setUp(() async {
        await model.createCampaign(
          name: 'Test',
          edition: GameEdition.gloomhaven,
        );
      });

      test('incrementDonatedGold increments by 10', () async {
        await model.incrementDonatedGold();
        expect(model.activeCampaign?.donatedGold, 10);
      });

      test('incrementDonatedGold caps at maxDonatedGold', () async {
        model.activeCampaign!.donatedGold = 95;
        await model.incrementDonatedGold();
        expect(model.activeCampaign?.donatedGold, maxDonatedGold);
      });

      test('incrementDonatedGold returns true when reaching 100', () async {
        model.activeCampaign!.donatedGold = 90;
        final result = await model.incrementDonatedGold();
        expect(result, true);
        expect(model.activeCampaign?.donatedGold, maxDonatedGold);
      });

      test('incrementDonatedGold returns false on other increments', () async {
        model.activeCampaign!.donatedGold = 0;
        final result = await model.incrementDonatedGold();
        expect(result, false);
        expect(model.activeCampaign?.donatedGold, 10);
      });

      test('incrementDonatedGold returns false when already at max', () async {
        model.activeCampaign!.donatedGold = maxDonatedGold;
        final result = await model.incrementDonatedGold();
        expect(result, false);
        expect(model.activeCampaign?.donatedGold, maxDonatedGold);
      });

      test('decrementDonatedGold decrements by 10', () async {
        model.activeCampaign!.donatedGold = 30;
        await model.decrementDonatedGold();
        expect(model.activeCampaign?.donatedGold, 20);
      });

      test('decrementDonatedGold does not go below 0', () async {
        model.activeCampaign!.donatedGold = 0;
        await model.decrementDonatedGold();
        expect(model.activeCampaign?.donatedGold, 0);
      });
    });

    group('isEditMode', () {
      test('defaults to false', () {
        expect(model.isEditMode, false);
      });

      test('can be toggled', () {
        model.isEditMode = true;
        expect(model.isEditMode, true);
        model.isEditMode = false;
        expect(model.isEditMode, false);
      });
    });
  });
}
