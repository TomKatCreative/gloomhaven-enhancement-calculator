import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';

void main() {
  group('PersonalQuestsRepository', () {
    test('contains 47 total quests (24 GH + 23 FH)', () {
      expect(PersonalQuestsRepository.quests.length, 47);
    });

    test('all quest IDs are unique', () {
      final ids = PersonalQuestsRepository.quests.map((q) => q.id).toSet();
      expect(ids.length, PersonalQuestsRepository.quests.length);
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

    group('Gloomhaven quests', () {
      test('contains 24 quests', () {
        final ghQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.gloomhaven,
        );
        expect(ghQuests.length, 24);
      });

      test('quest numbers range from 510 to 533', () {
        final ghQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.gloomhaven,
        );
        final numbers = ghQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 510);
        expect(numbers.last, 533);
      });

      test('GH quests have no altNumber', () {
        final ghQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.gloomhaven,
        );
        for (final quest in ghQuests) {
          expect(
            quest.altNumber,
            isNull,
            reason: '${quest.id} should not have altNumber',
          );
        }
      });

      test('displayNumber shows just number for GH quests', () {
        final quest = PersonalQuestsRepository.getById('pq_gh_510')!;
        expect(quest.displayNumber, '510');
      });

      test('all quest IDs start with pq_gh_', () {
        final ghQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.gloomhaven,
        );
        for (final quest in ghQuests) {
          expect(quest.id, startsWith('pq_gh_'));
        }
      });

      test('exactly 2 quests unlock Envelope X', () {
        final envelopeQuests = PersonalQuestsRepository.quests
            .where((q) => q.unlockEnvelope == 'X')
            .toList();
        expect(envelopeQuests.length, 2);
        expect(envelopeQuests.map((q) => q.number), containsAll([513, 526]));
      });

      group('specific quest data', () {
        test('514 A Study of Anatomy has target 15 (second printing)', () {
          final quest = PersonalQuestsRepository.getById('pq_gh_514');
          expect(quest!.requirements.first.target, 15);
        });

        test('523 Aberrant Slayer has 6 requirements (one per demon type)', () {
          final quest = PersonalQuestsRepository.getById('pq_gh_523');
          expect(quest!.requirements.length, 6);
        });

        test('511 Merchant Class has 5 requirements (item slots)', () {
          final quest = PersonalQuestsRepository.getById('pq_gh_511');
          expect(quest!.requirements.length, 5);
        });

        test('533 The Perfect Poison has 3 requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_gh_533');
          expect(quest!.requirements.length, 3);
          expect(quest.unlockClassCode, ClassCodes.plagueherald);
        });
      });
    });

    group('Frosthaven quests', () {
      test('contains 23 quests', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        expect(fhQuests.length, 23);
      });

      test('FH numbers range from 1 to 23', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        final numbers = fhQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 1);
        expect(numbers.last, 23);
        expect(numbers.toSet().length, 23);
      });

      test('all FH quests have altNumber (asset number)', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        for (final quest in fhQuests) {
          expect(
            quest.altNumber,
            isNotNull,
            reason: '${quest.id} should have altNumber',
          );
        }
      });

      test('displayNumber shows both numbers for FH quests', () {
        final quest = PersonalQuestsRepository.getById('pq_fh_581')!;
        expect(quest.number, 1);
        expect(quest.altNumber, 581);
        expect(quest.displayNumber, '01 (581)');
      });

      test('all quest IDs start with pq_fh_', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        for (final quest in fhQuests) {
          expect(quest.id, startsWith('pq_fh_'));
        }
      });

      test('all FH quests unlock envelopes (no class unlocks)', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        for (final quest in fhQuests) {
          expect(
            quest.unlockEnvelope,
            isNotNull,
            reason: '${quest.id} should unlock an envelope',
          );
          expect(
            quest.unlockClassCode,
            isNull,
            reason: '${quest.id} should not unlock a class',
          );
        }
      });

      test('sequential requirement quests have "Then" prefix', () {
        // Quest 582: Searching for the Oak
        final quest582 = PersonalQuestsRepository.getById('pq_fh_582');
        expect(quest582, isNotNull);
        expect(quest582!.requirements.length, 2);
        expect(quest582.requirements[1].description, startsWith('Then '));

        // Quest 545: Quiet the Dead Places
        final quest545 = PersonalQuestsRepository.getById('pq_fh_545');
        expect(quest545, isNotNull);
        expect(quest545!.requirements.length, 2);
        expect(quest545.requirements[1].description, startsWith('Then '));
      });

      group('specific quest data', () {
        test('FH #3 (583) Merchant Class has 5 item slot requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_583');
          expect(quest, isNotNull);
          expect(quest!.number, 3);
          expect(quest.altNumber, 583);
          expect(quest.requirements.length, 5);
          expect(quest.unlockEnvelope, '37/74');
        });

        test('FH #14 (519) Eternal Wanderer has 5 region requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_519');
          expect(quest, isNotNull);
          expect(quest!.number, 14);
          expect(quest.requirements.length, 5);
        });

        test('FH #8 (588) Dangerous Game has 3 kill requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_588');
          expect(quest, isNotNull);
          expect(quest!.number, 8);
          expect(quest.requirements.length, 3);
          expect(quest.unlockEnvelope, '44/88');
        });

        test('FH #23 (543) The Chosen One unlocks Envelope A', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_543');
          expect(quest, isNotNull);
          expect(quest!.number, 23);
          expect(quest.unlockEnvelope, 'A');
        });

        test('FH #9 (589) Life Lessons has high target (150)', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_589');
          expect(quest, isNotNull);
          expect(quest!.number, 9);
          expect(quest.requirements.first.target, 150);
        });
      });
    });

    group('getById', () {
      test('returns correct GH quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('pq_gh_510');
        expect(quest, isNotNull);
        expect(quest!.title, 'Seeker of Xorn');
        expect(quest.unlockClassCode, ClassCodes.plagueherald);
      });

      test('returns correct FH quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('pq_fh_581');
        expect(quest, isNotNull);
        expect(quest!.title, 'The Study of Plants');
        expect(quest.edition, GameEdition.frosthaven);
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

      test('returns 23 quests for frosthaven', () {
        final quests = PersonalQuestsRepository.getByEdition(
          GameEdition.frosthaven,
        );
        expect(quests.length, 23);
      });

      test('returns empty list for gloomhaven2e (not yet added)', () {
        final quests = PersonalQuestsRepository.getByEdition(
          GameEdition.gloomhaven2e,
        );
        expect(quests, isEmpty);
      });
    });

    group('displayName', () {
      test('GH quest shows number and title', () {
        final quest = PersonalQuestsRepository.getById('pq_gh_510')!;
        expect(quest.displayName, '510 - Seeker of Xorn');
      });

      test('FH quest shows both numbers and title', () {
        final quest = PersonalQuestsRepository.getById('pq_fh_581')!;
        expect(quest.displayName, '01 (581) - The Study of Plants');
      });
    });
  });
}
