import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/player_class_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';

void main() {
  group('PersonalQuestsRepository', () {
    test(
      'contains 105 total quests (24 GH + 22 GH2E + 23 FH + 28 CS + 8 TOA)',
      () {
        expect(PersonalQuestsRepository.quests.length, 105);
      },
    );

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

    test('checklist requirements have more items than target', () {
      for (final quest in PersonalQuestsRepository.quests) {
        for (final req in quest.requirements) {
          if (req.checklistItems != null) {
            expect(
              req.checklistItems!.length,
              greaterThanOrEqualTo(req.target),
              reason:
                  '${quest.id}: checklist has ${req.checklistItems!.length} '
                  'items but target is ${req.target}',
            );
          }
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
          PersonalQuestEdition.gloomhaven,
        );
        expect(ghQuests.length, 24);
      });

      test('quest numbers range from 510 to 533', () {
        final ghQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven,
        );
        final numbers = ghQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 510);
        expect(numbers.last, 533);
      });

      test('GH quests have no altNumber', () {
        final ghQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven,
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
          PersonalQuestEdition.gloomhaven,
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

    group('Gloomhaven 2e quests', () {
      test('contains 22 quests', () {
        final gh2eQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        expect(gh2eQuests.length, 22);
      });

      test('GH2E card numbers range from 1 to 22', () {
        final gh2eQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        final numbers = gh2eQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 1);
        expect(numbers.last, 22);
        expect(numbers.toSet().length, 22);
      });

      test('all quest IDs start with pq_gh2e_', () {
        final gh2eQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        for (final quest in gh2eQuests) {
          expect(quest.id, startsWith('pq_gh2e_'));
        }
      });

      test('all GH2E quests have altNumber (asset numbers 537-558)', () {
        final gh2eQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        final altNumbers = gh2eQuests.map((q) => q.altNumber).toList();
        for (final alt in altNumbers) {
          expect(alt, isNotNull);
        }
        final sortedAlts = altNumbers.cast<int>().toList()..sort();
        expect(sortedAlts.first, 537);
        expect(sortedAlts.last, 558);
      });

      test('displayNumber shows zero-padded number for GH2E quests', () {
        final quest = PersonalQuestsRepository.getById('pq_gh2e_537')!;
        expect(quest.number, 1);
        expect(quest.altNumber, 537);
        expect(quest.displayNumber, '01');
      });

      test('all GH2E quests unlock classes (no envelope unlocks)', () {
        final gh2eQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        for (final quest in gh2eQuests) {
          expect(
            quest.unlockClassCode,
            isNotNull,
            reason: '${quest.id} should unlock a class',
          );
          expect(
            quest.unlockEnvelope,
            isNull,
            reason: '${quest.id} should not unlock an envelope',
          );
        }
      });

      test('each GH2E class has exactly 2 quests (11 classes)', () {
        final gh2eQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        final classCounts = <String, int>{};
        for (final quest in gh2eQuests) {
          classCounts[quest.unlockClassCode!] =
              (classCounts[quest.unlockClassCode!] ?? 0) + 1;
        }
        for (final entry in classCounts.entries) {
          expect(
            entry.value,
            2,
            reason: 'Class ${entry.key} should have exactly 2 quests',
          );
        }
        expect(classCounts.length, 11);
      });

      group('specific quest data', () {
        test('01 Political Intrigue unlocks Sunkeeper', () {
          final quest = PersonalQuestsRepository.getById('pq_gh2e_537');
          expect(quest, isNotNull);
          expect(quest!.number, 1);
          expect(quest.altNumber, 537);
          expect(quest.title, 'Political Intrigue');
          expect(quest.requirements.length, 2);
          expect(quest.requirements[0].target, 30);
          expect(quest.requirements[1].description, startsWith('Then '));
          expect(quest.unlockClassCode, ClassCodes.sunkeeper);
        });

        test('09 Finding the Cure has checklist requirement', () {
          final quest = PersonalQuestsRepository.getById('pq_gh2e_545');
          expect(quest, isNotNull);
          expect(quest!.number, 9);
          expect(quest.requirements.length, 2);
          final checklist = quest.requirements[0];
          expect(checklist.target, 5);
          expect(checklist.checklistItems, isNotNull);
          expect(checklist.checklistItems!.length, 7);
          expect(quest.requirements[1].description, startsWith('Then '));
          expect(quest.unlockClassCode, ClassCodes.sawbones);
        });

        test('10 Aberrant Slayer has 2 requirements (enhance + read)', () {
          final quest = PersonalQuestsRepository.getById('pq_gh2e_546');
          expect(quest, isNotNull);
          expect(quest!.number, 10);
          expect(quest.requirements.length, 2);
          expect(quest.unlockClassCode, ClassCodes.elementalist);
        });

        test('13 Merchant Class has 6 requirements (5 slots + read)', () {
          final quest = PersonalQuestsRepository.getById('pq_gh2e_549');
          expect(quest, isNotNull);
          expect(quest!.number, 13);
          expect(quest.requirements.length, 6);
          expect(quest.unlockClassCode, ClassCodes.quartermaster);
        });
      });
    });

    group('Frosthaven quests', () {
      test('contains 23 quests', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.frosthaven,
        );
        expect(fhQuests.length, 23);
      });

      test('FH numbers range from 1 to 23', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.frosthaven,
        );
        final numbers = fhQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 1);
        expect(numbers.last, 23);
        expect(numbers.toSet().length, 23);
      });

      test('all FH quests have altNumber (asset number)', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.frosthaven,
        );
        for (final quest in fhQuests) {
          expect(
            quest.altNumber,
            isNotNull,
            reason: '${quest.id} should have altNumber',
          );
        }
      });

      test('displayNumber shows zero-padded number for FH quests', () {
        final quest = PersonalQuestsRepository.getById('pq_fh_581')!;
        expect(quest.number, 1);
        expect(quest.altNumber, 581);
        expect(quest.displayNumber, '01');
      });

      test('all quest IDs start with pq_fh_', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.frosthaven,
        );
        for (final quest in fhQuests) {
          expect(quest.id, startsWith('pq_fh_'));
        }
      });

      test('all FH quests unlock envelopes (no class unlocks)', () {
        final fhQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.frosthaven,
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
        test('FH #3 Merchant Class has 5 item slot requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_583');
          expect(quest, isNotNull);
          expect(quest!.number, 3);
          expect(quest.altNumber, 583);
          expect(quest.requirements.length, 5);
          expect(quest.unlockEnvelope, '37/74');
        });

        test('FH #14 Eternal Wanderer has 5 region requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_519');
          expect(quest, isNotNull);
          expect(quest!.number, 14);
          expect(quest.requirements.length, 5);
        });

        test('FH #8 Dangerous Game has 3 kill requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_588');
          expect(quest, isNotNull);
          expect(quest!.number, 8);
          expect(quest.requirements.length, 3);
          expect(quest.unlockEnvelope, '44/88');
        });

        test('FH #23 The Chosen One unlocks Envelope A', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_543');
          expect(quest, isNotNull);
          expect(quest!.number, 23);
          expect(quest.unlockEnvelope, 'A');
        });

        test('FH #9 Life Lessons has high target (150)', () {
          final quest = PersonalQuestsRepository.getById('pq_fh_589');
          expect(quest, isNotNull);
          expect(quest!.number, 9);
          expect(quest.requirements.first.target, 150);
        });
      });
    });

    group('Crimson Scales quests', () {
      test('contains 28 quests (22 core + 6 add-on)', () {
        final csQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        expect(csQuests.length, 28);
      });

      test('quest numbers range from 330 to 357', () {
        final csQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        final numbers = csQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 330);
        expect(numbers.last, 357);
        expect(numbers.toSet().length, 28);
      });

      test('all quest IDs start with pq_cs_', () {
        final csQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        for (final quest in csQuests) {
          expect(quest.id, startsWith('pq_cs_'));
        }
      });

      test('all CS quests unlock classes (no envelope unlocks)', () {
        final csQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        for (final quest in csQuests) {
          expect(
            quest.unlockClassCode,
            isNotNull,
            reason: '${quest.id} should unlock a class',
          );
          expect(
            quest.unlockEnvelope,
            isNull,
            reason: '${quest.id} should not unlock an envelope',
          );
        }
      });

      test('each CS class has exactly 2 quests', () {
        final csQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        final classCounts = <String, int>{};
        for (final quest in csQuests) {
          classCounts[quest.unlockClassCode!] =
              (classCounts[quest.unlockClassCode!] ?? 0) + 1;
        }
        for (final entry in classCounts.entries) {
          expect(
            entry.value,
            2,
            reason: 'Class ${entry.key} should have exactly 2 quests',
          );
        }
        // 11 core classes + 3 add-on classes
        expect(classCounts.length, 14);
      });

      test('add-on quests use displayNumberOverride', () {
        final addOnIds = [
          'pq_cs_aa_001',
          'pq_cs_aa_002',
          'pq_cs_qa_001',
          'pq_cs_qa_002',
          'pq_cs_rm_001',
          'pq_cs_rm_002',
        ];
        for (final id in addOnIds) {
          final quest = PersonalQuestsRepository.getById(id)!;
          expect(
            quest.displayNumberOverride,
            isNotNull,
            reason: '$id should have displayNumberOverride',
          );
          expect(
            quest.displayNumber,
            quest.displayNumberOverride,
            reason: '$id displayNumber should use override',
          );
        }
      });

      test('core quests do not use displayNumberOverride', () {
        final csQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        final coreQuests = csQuests.where(
          (q) => q.number >= 330 && q.number <= 351,
        );
        for (final quest in coreQuests) {
          expect(
            quest.displayNumberOverride,
            isNull,
            reason: '${quest.id} should not have displayNumberOverride',
          );
        }
      });

      group('specific quest data', () {
        test('330 Protect and Serve has 2 sequential requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_cs_330');
          expect(quest, isNotNull);
          expect(quest!.requirements.length, 2);
          expect(quest.requirements[0].target, 10);
          expect(quest.requirements[1].description, startsWith('Then '));
          expect(quest.unlockClassCode, ClassCodes.bombard);
        });

        test(
          '344 Natural Selection has 5 requirements (4 elements + scenario)',
          () {
            final quest = PersonalQuestsRepository.getById('pq_cs_344');
            expect(quest, isNotNull);
            expect(quest!.requirements.length, 5);
            expect(quest.requirements[4].description, startsWith('Then '));
            expect(quest.unlockClassCode, ClassCodes.luminary);
          },
        );

        test('339 Mutual Support has target 30', () {
          final quest = PersonalQuestsRepository.getById('pq_cs_339');
          expect(quest, isNotNull);
          expect(quest!.requirements.first.target, 30);
          expect(quest.unlockClassCode, ClassCodes.fireKnight);
        });

        test('AA-001 At All Costs displays as AA-001', () {
          final quest = PersonalQuestsRepository.getById('pq_cs_aa_001');
          expect(quest, isNotNull);
          expect(quest!.displayNumber, 'AA-001');
          expect(quest.displayName, 'AA-001: At All Costs');
          expect(quest.unlockClassCode, ClassCodes.amberAegis);
        });

        test('QA-001 Ingenious Inventor has 3 sequential requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_cs_qa_001');
          expect(quest, isNotNull);
          expect(quest!.requirements.length, 3);
          expect(quest.unlockClassCode, ClassCodes.artificer);
        });

        test('RM-002 Apex Predator has 2 requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_cs_rm_002');
          expect(quest, isNotNull);
          expect(quest!.requirements.length, 2);
          expect(quest.unlockClassCode, ClassCodes.ruinmaw);
        });
      });
    });

    group('Trail of Ashes quests', () {
      test('contains 8 quests', () {
        final toaQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.trailOfAshes,
        );
        expect(toaQuests.length, 8);
      });

      test('quest numbers range from 641 to 648', () {
        final toaQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.trailOfAshes,
        );
        final numbers = toaQuests.map((q) => q.number).toList()..sort();
        expect(numbers.first, 641);
        expect(numbers.last, 648);
        expect(numbers.toSet().length, 8);
      });

      test('all quest IDs start with pq_toa_', () {
        final toaQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.trailOfAshes,
        );
        for (final quest in toaQuests) {
          expect(quest.id, startsWith('pq_toa_'));
        }
      });

      test('all TOA quests unlock classes (no envelope unlocks)', () {
        final toaQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.trailOfAshes,
        );
        for (final quest in toaQuests) {
          expect(
            quest.unlockClassCode,
            isNotNull,
            reason: '${quest.id} should unlock a class',
          );
          expect(
            quest.unlockEnvelope,
            isNull,
            reason: '${quest.id} should not unlock an envelope',
          );
        }
      });

      test('each TOA class has exactly 2 quests', () {
        final toaQuests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.trailOfAshes,
        );
        final classCounts = <String, int>{};
        for (final quest in toaQuests) {
          classCounts[quest.unlockClassCode!] =
              (classCounts[quest.unlockClassCode!] ?? 0) + 1;
        }
        for (final entry in classCounts.entries) {
          expect(
            entry.value,
            2,
            reason: 'Class ${entry.key} should have exactly 2 quests',
          );
        }
        expect(classCounts.length, 4);
      });

      group('specific quest data', () {
        test('643 False Dichotomies has 2 requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_toa_643');
          expect(quest, isNotNull);
          expect(quest!.requirements.length, 2);
          expect(quest.requirements[0].target, 8);
          expect(quest.requirements[1].target, 8);
          expect(quest.unlockClassCode, ClassCodes.rimehearth);
        });

        test('644 Shared Suffering has target 30', () {
          final quest = PersonalQuestsRepository.getById('pq_toa_644');
          expect(quest, isNotNull);
          expect(quest!.requirements.first.target, 30);
        });

        test('641 Grave Robber has 2 sequential requirements', () {
          final quest = PersonalQuestsRepository.getById('pq_toa_641');
          expect(quest, isNotNull);
          expect(quest!.requirements.length, 2);
          expect(quest.requirements[1].description, startsWith('Then '));
          expect(quest.unlockClassCode, ClassCodes.incarnate);
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

      test('returns correct GH2E quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('pq_gh2e_537');
        expect(quest, isNotNull);
        expect(quest!.title, 'Political Intrigue');
        expect(quest.edition, PersonalQuestEdition.gloomhaven2e);
      });

      test('returns correct FH quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('pq_fh_581');
        expect(quest, isNotNull);
        expect(quest!.title, 'The Study of Plants');
        expect(quest.edition, PersonalQuestEdition.frosthaven);
      });

      test('returns correct CS quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('pq_cs_330');
        expect(quest, isNotNull);
        expect(quest!.title, 'Protect and Serve');
        expect(quest.edition, PersonalQuestEdition.crimsonScales);
      });

      test('returns correct TOA quest for valid ID', () {
        final quest = PersonalQuestsRepository.getById('pq_toa_641');
        expect(quest, isNotNull);
        expect(quest!.title, 'Grave Robber');
        expect(quest.edition, PersonalQuestEdition.trailOfAshes);
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
          PersonalQuestEdition.gloomhaven,
        );
        expect(quests.length, 24);
      });

      test('returns 22 quests for gloomhaven2e', () {
        final quests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.gloomhaven2e,
        );
        expect(quests.length, 22);
      });

      test('returns 23 quests for frosthaven', () {
        final quests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.frosthaven,
        );
        expect(quests.length, 23);
      });

      test('returns 28 quests for crimsonScales', () {
        final quests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.crimsonScales,
        );
        expect(quests.length, 28);
      });

      test('returns 8 quests for trailOfAshes', () {
        final quests = PersonalQuestsRepository.getByEdition(
          PersonalQuestEdition.trailOfAshes,
        );
        expect(quests.length, 8);
      });
    });

    group('displayName', () {
      test('GH quest shows number and title', () {
        final quest = PersonalQuestsRepository.getById('pq_gh_510')!;
        expect(quest.displayName, '510: Seeker of Xorn');
      });

      test('GH2E quest shows padded number and title', () {
        final quest = PersonalQuestsRepository.getById('pq_gh2e_537')!;
        expect(quest.displayName, '01: Political Intrigue');
      });

      test('FH quest shows padded number and title', () {
        final quest = PersonalQuestsRepository.getById('pq_fh_581')!;
        expect(quest.displayName, '01: The Study of Plants');
      });

      test('CS quest shows number and title', () {
        final quest = PersonalQuestsRepository.getById('pq_cs_330')!;
        expect(quest.displayName, '330: Protect and Serve');
      });

      test('TOA quest shows number and title', () {
        final quest = PersonalQuestsRepository.getById('pq_toa_641')!;
        expect(quest.displayName, '641: Grave Robber');
      });
    });
  });

  group('PersonalQuestRequirement.checkedCount', () {
    test('returns raw progress for standard requirements', () {
      const req = PersonalQuestRequirement(
        description: 'Kill 15 enemies',
        target: 15,
      );
      expect(req.checkedCount(0), 0);
      expect(req.checkedCount(7), 7);
      expect(req.checkedCount(15), 15);
    });

    test('counts set bits for checklist requirements', () {
      const req = PersonalQuestRequirement(
        description: 'Visit 3 locations:',
        target: 3,
        checklistItems: ['A', 'B', 'C', 'D', 'E'],
      );
      // No items checked
      expect(req.checkedCount(0), 0);
      // Item 0 checked (bit 0)
      expect(req.checkedCount(0x01), 1);
      // Items 0 and 2 checked (bits 0, 2)
      expect(req.checkedCount(0x05), 2);
      // Items 0, 1, 2 checked (bits 0, 1, 2)
      expect(req.checkedCount(0x07), 3);
      // All 5 items checked (bits 0-4)
      expect(req.checkedCount(0x1F), 5);
    });

    test('non-contiguous bits are counted correctly', () {
      const req = PersonalQuestRequirement(
        description: 'Visit 5 locations:',
        target: 5,
        checklistItems: ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
      );
      // Items 0, 2, 4, 5, 6 checked = 5 items
      expect(req.checkedCount(0x75), 5);
      // Items 1, 3, 5 checked = 3 items
      expect(req.checkedCount(0x2A), 3);
    });
  });
}
