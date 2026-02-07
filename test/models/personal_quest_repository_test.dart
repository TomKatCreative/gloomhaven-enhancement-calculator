import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

void main() {
  group('PersonalQuestsRepository', () {
    test('contains 24 Gloomhaven quests', () {
      expect(PersonalQuestsRepository.quests.length, 24);
    });

    test('all quests have gloomhaven edition', () {
      for (final quest in PersonalQuestsRepository.quests) {
        expect(quest.edition, GameEdition.gloomhaven);
      }
    });

    test('quest numbers range from 510 to 533', () {
      final numbers =
          PersonalQuestsRepository.quests
              .map((q) => int.parse(q.number))
              .toList()
            ..sort();
      expect(numbers.first, 510);
      expect(numbers.last, 533);
      expect(numbers.length, 24);
    });

    test('all quest IDs start with gh_', () {
      for (final quest in PersonalQuestsRepository.quests) {
        expect(quest.id, startsWith('gh_'));
      }
    });

    test('all quests have at least one requirement', () {
      for (final quest in PersonalQuestsRepository.quests) {
        expect(
          quest.requirements,
          isNotEmpty,
          reason: '${quest.id} should have requirements',
        );
      }
    });

    test('all requirements have positive targets', () {
      for (final quest in PersonalQuestsRepository.quests) {
        for (final req in quest.requirements) {
          expect(
            req.target,
            greaterThan(0),
            reason: '${quest.id}: "${req.description}" should have target > 0',
          );
        }
      }
    });

    test('all requirements have non-empty descriptions', () {
      for (final quest in PersonalQuestsRepository.quests) {
        for (final req in quest.requirements) {
          expect(
            req.description,
            isNotEmpty,
            reason: '${quest.id} has empty requirement description',
          );
        }
      }
    });

    test('unlock class codes are valid ClassCodes constants', () {
      final validClassCodes = PlayerClasses.playerClasses
          .map((c) => c.classCode)
          .toSet();

      for (final quest in PersonalQuestsRepository.quests) {
        if (quest.unlockClassCode != null) {
          expect(
            validClassCodes.contains(quest.unlockClassCode),
            isTrue,
            reason:
                '${quest.id} has invalid classCode: ${quest.unlockClassCode}',
          );
        }
      }
    });

    test('quests unlock either a class or an envelope', () {
      for (final quest in PersonalQuestsRepository.quests) {
        final hasClass = quest.unlockClassCode != null;
        final hasEnvelope = quest.unlockEnvelope != null;
        expect(
          hasClass || hasEnvelope,
          isTrue,
          reason: '${quest.id} should unlock a class or envelope',
        );
        // Should not have both
        expect(
          hasClass && hasEnvelope,
          isFalse,
          reason: '${quest.id} should not unlock both a class and envelope',
        );
      }
    });

    test('exactly 2 quests unlock Envelope X', () {
      final envelopeQuests = PersonalQuestsRepository.quests
          .where((q) => q.unlockEnvelope == 'X')
          .toList();
      expect(envelopeQuests.length, 2);
      expect(envelopeQuests.map((q) => q.number), containsAll(['513', '526']));
    });

    group('getById', () {
      test('returns correct quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('gh_510');
        expect(quest, isNotNull);
        expect(quest!.title, 'Seeker of Xorn');
        expect(quest.unlockClassCode, ClassCodes.plagueherald);
      });

      test('returns null for invalid ID', () {
        expect(PersonalQuestsRepository.getById('gh_999'), isNull);
      });

      test('returns null for empty string', () {
        expect(PersonalQuestsRepository.getById(''), isNull);
      });
    });

    group('getByEdition', () {
      test('returns 24 quests for gloomhaven', () {
        final quests = PersonalQuestsRepository.getByEdition(
          GameEdition.gloomhaven,
        );
        expect(quests.length, 24);
      });

      test('returns empty list for frosthaven (not yet added)', () {
        final quests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        expect(quests, isEmpty);
      });
    });

    group('specific quest data', () {
      test('514 A Study of Anatomy has target 12 (second printing)', () {
        final quest = PersonalQuestsRepository.getById('gh_514');
        expect(quest!.requirements.first.target, 12);
      });

      test('523 Aberrant Slayer has 6 requirements (one per demon type)', () {
        final quest = PersonalQuestsRepository.getById('gh_523');
        expect(quest!.requirements.length, 6);
      });

      test('511 Merchant Class has 5 requirements (item slots)', () {
        final quest = PersonalQuestsRepository.getById('gh_511');
        expect(quest!.requirements.length, 5);
      });

      test('533 The Perfect Poison has 3 requirements', () {
        final quest = PersonalQuestsRepository.getById('gh_533');
        expect(quest!.requirements.length, 3);
        expect(quest.unlockClassCode, ClassCodes.plagueherald);
      });
    });
  });
}
