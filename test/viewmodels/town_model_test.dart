import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/campaign.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
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
    group('loadWorlds', () {
      test('loads empty list when no worlds exist', () async {
        await model.loadWorlds();
        expect(model.worlds, isEmpty);
        expect(model.activeWorld, isNull);
      });

      test('loads worlds and sets first as active', () async {
        final world = TestData.createWorld();
        fakeDb.worlds = [world];

        await model.loadWorlds();

        expect(model.worlds, hasLength(1));
        expect(model.activeWorld?.id, 'world-1');
      });

      test('restores active world from SharedPrefs', () async {
        final world1 = TestData.createWorld(id: 'w-1', name: 'World 1');
        final world2 = TestData.createWorld(id: 'w-2', name: 'World 2');
        fakeDb.worlds = [world1, world2];
        SharedPrefs().activeWorldId = 'w-2';

        await model.loadWorlds();

        expect(model.activeWorld?.id, 'w-2');
        expect(model.activeWorld?.name, 'World 2');
      });

      test('falls back to first world if saved ID not found', () async {
        final world = TestData.createWorld(id: 'w-1');
        fakeDb.worlds = [world];
        SharedPrefs().activeWorldId = 'nonexistent';

        await model.loadWorlds();

        expect(model.activeWorld?.id, 'w-1');
      });

      test('loads campaigns for active world', () async {
        final world = TestData.createWorld();
        final campaign = TestData.createCampaign();
        fakeDb.worlds = [world];
        fakeDb.campaignsMap = {
          'world-1': [campaign],
        };

        await model.loadWorlds();

        expect(model.campaigns, hasLength(1));
        expect(model.activeCampaign?.id, 'campaign-1');
      });

      test('restores active campaign from SharedPrefs', () async {
        final world = TestData.createWorld();
        final c1 = TestData.createCampaign(id: 'c-1', name: 'Party 1');
        final c2 = TestData.createCampaign(id: 'c-2', name: 'Party 2');
        fakeDb.worlds = [world];
        fakeDb.campaignsMap = {
          'world-1': [c1, c2],
        };
        SharedPrefs().activeCampaignId = 'c-2';

        await model.loadWorlds();

        expect(model.activeCampaign?.id, 'c-2');
      });
    });

    group('createWorld', () {
      test('creates and sets active world', () async {
        await model.createWorld(
          name: 'New World',
          edition: GameEdition.gloomhaven,
        );

        expect(model.worlds, hasLength(1));
        expect(model.activeWorld?.name, 'New World');
        expect(model.activeWorld?.edition, GameEdition.gloomhaven);
        expect(SharedPrefs().activeWorldId, isNotNull);
      });

      test('clears previous campaign state', () async {
        // Setup existing world with campaign
        await model.createWorld(
          name: 'World 1',
          edition: GameEdition.gloomhaven,
        );
        await model.createCampaign(name: 'Party 1');
        expect(model.activeCampaign, isNotNull);

        // Create new world — should clear campaign
        await model.createWorld(
          name: 'World 2',
          edition: GameEdition.frosthaven,
        );
        expect(model.activeCampaign, isNull);
        expect(model.campaigns, isEmpty);
      });

      test('accepts starting prosperity checkmarks', () async {
        await model.createWorld(
          name: 'Advanced',
          edition: GameEdition.gloomhaven,
          startingProsperityCheckmarks: 10,
        );

        expect(model.activeWorld?.prosperityCheckmarks, 10);
        expect(model.activeWorld?.prosperityLevel, 3);
      });
    });

    group('setActiveWorld', () {
      test('switches active world and loads campaigns', () async {
        final w1 = TestData.createWorld(id: 'w-1', name: 'World 1');
        final w2 = TestData.createWorld(id: 'w-2', name: 'World 2');
        final c2 = TestData.createCampaign(
          id: 'c-2',
          worldId: 'w-2',
          name: 'Party',
        );
        fakeDb.worlds = [w1, w2];
        fakeDb.campaignsMap = {
          'w-2': [c2],
        };
        await model.loadWorlds();

        await model.setActiveWorld(w2);

        expect(model.activeWorld?.id, 'w-2');
        expect(model.campaigns, hasLength(1));
        expect(SharedPrefs().activeWorldId, 'w-2');
      });
    });

    group('renameWorld', () {
      test('updates world name', () async {
        await model.createWorld(
          name: 'Old Name',
          edition: GameEdition.gloomhaven,
        );

        await model.renameWorld('New Name');

        expect(model.activeWorld?.name, 'New Name');
      });
    });

    group('deleteActiveWorld', () {
      test('deletes world and falls back to next', () async {
        final w1 = TestData.createWorld(id: 'w-1', name: 'World 1');
        final w2 = TestData.createWorld(id: 'w-2', name: 'World 2');
        fakeDb.worlds = [w1, w2];
        await model.loadWorlds();
        await model.setActiveWorld(w1);

        await model.deleteActiveWorld();

        expect(model.worlds, hasLength(1));
        expect(model.activeWorld?.id, 'w-2');
      });

      test('sets null when last world deleted', () async {
        await model.createWorld(
          name: 'Only World',
          edition: GameEdition.gloomhaven,
        );

        await model.deleteActiveWorld();

        expect(model.worlds, isEmpty);
        expect(model.activeWorld, isNull);
        expect(SharedPrefs().activeWorldId, isNull);
      });
    });

    group('prosperity', () {
      setUp(() async {
        await model.createWorld(
          name: 'Test',
          edition: GameEdition.gloomhaven,
          startingProsperityCheckmarks: 5,
        );
      });

      test('incrementProsperity increases by 1', () async {
        await model.incrementProsperity();
        expect(model.activeWorld?.prosperityCheckmarks, 6);
      });

      test('decrementProsperity decreases by 1', () async {
        await model.decrementProsperity();
        expect(model.activeWorld?.prosperityCheckmarks, 4);
      });

      test('decrementProsperity does not go below 0', () async {
        await model.createWorld(
          name: 'Zero',
          edition: GameEdition.gloomhaven,
          startingProsperityCheckmarks: 0,
        );

        await model.decrementProsperity();
        expect(model.activeWorld?.prosperityCheckmarks, 0);
      });
    });

    group('createCampaign', () {
      setUp(() async {
        await model.createWorld(
          name: 'Test World',
          edition: GameEdition.gloomhaven,
        );
      });

      test('creates and sets active campaign', () async {
        await model.createCampaign(name: 'Heroes');

        expect(model.campaigns, hasLength(1));
        expect(model.activeCampaign?.name, 'Heroes');
        expect(SharedPrefs().activeCampaignId, isNotNull);
      });

      test('accepts starting reputation', () async {
        await model.createCampaign(name: 'Infamous', startingReputation: -5);

        expect(model.activeCampaign?.reputation, -5);
      });
    });

    group('setActiveCampaign', () {
      test('switches active campaign', () async {
        await model.createWorld(name: 'World', edition: GameEdition.gloomhaven);
        await model.createCampaign(name: 'Party 1');
        await model.createCampaign(name: 'Party 2');

        model.setActiveCampaign(model.campaigns.first);

        expect(model.activeCampaign?.name, 'Party 1');
      });
    });

    group('renameCampaign', () {
      test('updates campaign name', () async {
        await model.createWorld(name: 'World', edition: GameEdition.gloomhaven);
        await model.createCampaign(name: 'Old Party');

        await model.renameCampaign('New Party');

        expect(model.activeCampaign?.name, 'New Party');
      });
    });

    group('deleteActiveCampaign', () {
      setUp(() async {
        await model.createWorld(name: 'World', edition: GameEdition.gloomhaven);
      });

      test('deletes and falls back to next campaign', () async {
        await model.createCampaign(name: 'Party 1');
        await model.createCampaign(name: 'Party 2');
        // Active is Party 2 (last created)
        model.setActiveCampaign(model.campaigns.last);

        await model.deleteActiveCampaign();

        expect(model.campaigns, hasLength(1));
        expect(model.activeCampaign?.name, 'Party 1');
      });

      test('sets null when last campaign deleted', () async {
        await model.createCampaign(name: 'Only Party');

        await model.deleteActiveCampaign();

        expect(model.campaigns, isEmpty);
        expect(model.activeCampaign, isNull);
        expect(SharedPrefs().activeCampaignId, isNull);
      });
    });

    group('reputation', () {
      setUp(() async {
        await model.createWorld(name: 'World', edition: GameEdition.gloomhaven);
        await model.createCampaign(name: 'Party');
      });

      test('incrementReputation increases by 1', () async {
        await model.incrementReputation();
        expect(model.activeCampaign?.reputation, 1);
      });

      test('decrementReputation decreases by 1', () async {
        await model.decrementReputation();
        expect(model.activeCampaign?.reputation, -1);
      });

      test('incrementReputation does not exceed 20', () async {
        model.activeCampaign!.reputation = maxReputation;
        await model.incrementReputation();
        expect(model.activeCampaign?.reputation, maxReputation);
      });

      test('decrementReputation does not go below -20', () async {
        model.activeCampaign!.reputation = minReputation;
        await model.decrementReputation();
        expect(model.activeCampaign?.reputation, minReputation);
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
