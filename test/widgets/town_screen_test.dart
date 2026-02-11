import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/shared_prefs.dart';
import 'package:gloomhaven_enhancement_calc/ui/screens/town_screen.dart';
import 'package:gloomhaven_enhancement_calc/viewmodels/town_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_helpers.dart';

void main() {
  late TownModel townModel;
  late FakeDatabaseHelper fakeDb;

  setUp(() async {
    // Collapse the campaign details card to avoid ProsperitySection overflow
    // in the test font environment. These tests focus on party switching.
    SharedPreferences.setMockInitialValues({'townDetailsExpanded': false});
    await SharedPrefs().init();
    fakeDb = FakeDatabaseHelper();
    townModel = TownModel(databaseHelper: fakeDb);
  });

  Widget buildTownScreen() {
    return wrapWithProviders(
      townModel: townModel,
      withLocalization: true,
      child: const Scaffold(body: TownScreen()),
    );
  }

  group('TownScreen party switching', () {
    group('trailing icon', () {
      testWidgets('hidden in view mode', (tester) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Party 1');
        await townModel.createParty(name: 'Party 2');

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
        expect(find.byIcon(Icons.group_add_rounded), findsNothing);
      });

      testWidgets('shows group_add icon when only one party exists', (
        tester,
      ) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Solo Party');
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.group_add_rounded), findsOneWidget);
        expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
      });

      testWidgets('shows swap_horiz icon when two or more parties exist', (
        tester,
      ) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Party 1');
        await townModel.createParty(name: 'Party 2');
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
        expect(find.byIcon(Icons.group_add_rounded), findsNothing);
      });

      testWidgets('no trailing icon when no parties exist', (tester) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.swap_horiz_rounded), findsNothing);
        expect(find.byIcon(Icons.group_add_rounded), findsNothing);
      });
    });

    group('party switcher bottom sheet', () {
      testWidgets('swap icon opens bottom sheet with party list', (
        tester,
      ) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Alpha');
        await townModel.createParty(name: 'Bravo');
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
        await tester.pumpAndSettle();

        // Bottom sheet shows both party names
        expect(find.text('Alpha'), findsWidgets);
        expect(find.text('Bravo'), findsWidgets);
      });

      testWidgets('tapping a party in sheet switches active party', (
        tester,
      ) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Alpha');
        await townModel.createParty(name: 'Bravo');
        // Active party is Bravo (last created)
        expect(townModel.activeParty?.name, 'Bravo');
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        // Open sheet
        await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
        await tester.pumpAndSettle();

        // Tap Alpha in the bottom sheet (find ListTile text)
        final alphaInSheet = find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Alpha'),
        );
        await tester.tap(alphaInSheet);
        await tester.pumpAndSettle();

        expect(townModel.activeParty?.name, 'Alpha');
      });

      testWidgets('bottom sheet has create button', (tester) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Alpha');
        await townModel.createParty(name: 'Bravo');
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
        await tester.pumpAndSettle();

        // "Create" button visible in the sheet header
        expect(find.text('Create'), findsOneWidget);
      });

      testWidgets('three parties all appear in bottom sheet', (tester) async {
        await townModel.createCampaign(
          name: 'Campaign',
          edition: GameEdition.gloomhaven,
        );
        await townModel.createParty(name: 'Alpha');
        await townModel.createParty(name: 'Bravo');
        await townModel.createParty(name: 'Charlie');
        townModel.isEditMode = true;

        await tester.pumpWidget(buildTownScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Alpha'), findsWidgets);
        expect(find.text('Bravo'), findsWidgets);
        expect(find.text('Charlie'), findsWidgets);
      });
    });
  });
}
