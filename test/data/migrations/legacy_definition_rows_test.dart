import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/migrations/legacy_definition_rows.dart';
import 'package:gloomhaven_enhancement_calc/models/mastery/mastery.dart';
import 'package:gloomhaven_enhancement_calc/models/perk/perk.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';
import 'package:gloomhaven_enhancement_calc/models/player_class.dart';

// Literal column names on purpose: these pin the frozen on-disk shape that
// migrations v8–v18 write.
void main() {
  test('Perk.toLegacyRow builds a PerksTable row', () {
    final perk = Perk(3, 'Remove two -1 cards', grouped: true)
      ..classCode = 'br'
      ..variant = Variant.gloomhaven2E;

    expect(perk.toLegacyRow('03a'), {
      '_id': 'br_gloomhaven2E_03a',
      'Class': 'br',
      'Details': 'Remove two -1 cards',
      'IsGrouped': 1,
      'Variant': 'gloomhaven2E',
    });
  });

  test('Mastery.toLegacyRow builds a MasteriesTable row', () {
    final mastery = Mastery(1, masteryDetails: 'Never perform a move')
      ..classCode = 'br';

    expect(mastery.toLegacyRow('0'), {
      '_id': 'br_base_0',
      'Class': 'br',
      'Details': 'Never perform a move',
      'Variant': 'base',
    });
  });

  test('PersonalQuest.toLegacyRow builds a PersonalQuestsTable row', () {
    final quest = PersonalQuest(
      id: 'pq_gh_510',
      number: 510,
      title: 'Seeker of Xorn',
      edition: PersonalQuestEdition.gloomhaven,
    );

    expect(quest.toLegacyRow(), {
      '_id': 'pq_gh_510',
      'Number': 510,
      'Title': 'Seeker of Xorn',
      'Edition': 'gloomhaven',
    });
  });

  test('table names match the dropped definition tables', () {
    expect(tablePerks, 'PerksTable');
    expect(tableMasteries, 'MasteriesTable');
    expect(tablePersonalQuests, 'PersonalQuestsTable');
  });
}
