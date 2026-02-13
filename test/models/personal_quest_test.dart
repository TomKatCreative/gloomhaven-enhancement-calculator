import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';

void main() {
  group('PersonalQuest', () {
    test('constructor sets all fields', () {
      final quest = PersonalQuest(
        id: 'pq_gh_510',
        number: 510,
        title: 'Seeker of Xorn',
        edition: GameEdition.gloomhaven,
        unlockClassCode: 'ph',
        requirements: const [
          PersonalQuestRequirement(description: 'Test req', target: 3),
        ],
      );

      expect(quest.id, 'pq_gh_510');
      expect(quest.number, 510);
      expect(quest.title, 'Seeker of Xorn');
      expect(quest.edition, GameEdition.gloomhaven);
      expect(quest.unlockClassCode, 'ph');
      expect(quest.requirements.length, 1);
      expect(quest.unlockEnvelope, isNull);
    });

    test('constructor with envelope unlock', () {
      final quest = PersonalQuest(
        id: 'pq_gh_513',
        number: 513,
        title: 'Finding the Cure',
        edition: GameEdition.gloomhaven,
        unlockEnvelope: 'X',
      );

      expect(quest.unlockEnvelope, 'X');
      expect(quest.unlockClassCode, isNull);
    });

    test('displayName combines number and title', () {
      final quest = PersonalQuest(
        id: 'pq_gh_510',
        number: 510,
        title: 'Seeker of Xorn',
        edition: GameEdition.gloomhaven,
      );

      expect(quest.displayName, '510 - Seeker of Xorn');
    });

    test('toMap produces correct map', () {
      final quest = PersonalQuest(
        id: 'pq_gh_510',
        number: 510,
        title: 'Seeker of Xorn',
        edition: GameEdition.gloomhaven,
      );

      final map = quest.toMap();
      expect(map[columnPersonalQuestId], 'pq_gh_510');
      expect(map[columnPersonalQuestNumber], 510);
      expect(map[columnPersonalQuestTitle], 'Seeker of Xorn');
      expect(map[columnPersonalQuestEdition], GameEdition.gloomhaven.name);
    });

    test('fromMap reconstructs quest', () {
      final map = {
        columnPersonalQuestId: 'pq_gh_512',
        columnPersonalQuestNumber: 512,
        columnPersonalQuestTitle: 'Greed is Good',
        columnPersonalQuestEdition: 'gloomhaven',
      };

      final quest = PersonalQuest.fromMap(map);
      expect(quest.id, 'pq_gh_512');
      expect(quest.number, 512);
      expect(quest.title, 'Greed is Good');
      expect(quest.edition, GameEdition.gloomhaven);
    });

    test('toMap/fromMap round-trip preserves data', () {
      final original = PersonalQuest(
        id: 'pq_gh_515',
        number: 515,
        title: 'Lawbringer',
        edition: GameEdition.gloomhaven,
      );

      final roundTripped = PersonalQuest.fromMap(original.toMap());
      expect(roundTripped.id, original.id);
      expect(roundTripped.number, original.number);
      expect(roundTripped.title, original.title);
      expect(roundTripped.edition, original.edition);
    });
  });

  group('PersonalQuestRequirement', () {
    test('constructor sets description and target', () {
      const req = PersonalQuestRequirement(
        description: 'Kill 20 Bandits',
        target: 20,
      );

      expect(req.description, 'Kill 20 Bandits');
      expect(req.target, 20);
    });
  });

  group('Progress encoding', () {
    test('encodeProgress produces JSON string', () {
      expect(encodeProgress([3, 5, 0]), '[3,5,0]');
    });

    test('decodeProgress parses JSON string', () {
      expect(decodeProgress('[3,5,0]'), [3, 5, 0]);
    });

    test('decodeProgress handles empty string', () {
      expect(decodeProgress(''), isEmpty);
    });

    test('decodeProgress handles empty array', () {
      expect(decodeProgress('[]'), isEmpty);
    });

    test('round-trip preserves progress', () {
      final progress = [12, 0, 7];
      expect(decodeProgress(encodeProgress(progress)), progress);
    });
  });
}
