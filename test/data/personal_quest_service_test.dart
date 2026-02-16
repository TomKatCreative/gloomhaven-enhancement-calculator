import 'package:flutter_test/flutter_test.dart';

import 'package:gloomhaven_enhancement_calc/data/personal_quest_service.dart';

import '../helpers/fake_database_helper.dart';
import '../helpers/test_data.dart';

void main() {
  late FakeDatabaseHelper fakeDb;
  late PersonalQuestService service;

  setUp(() {
    fakeDb = FakeDatabaseHelper();
    service = PersonalQuestService(databaseHelper: fakeDb);
  });

  tearDown(() {
    fakeDb.reset();
  });

  group('updateQuest', () {
    test('assigns a quest and initializes progress', () async {
      final character = TestData.createCharacter();
      fakeDb.characters = [character];

      await service.updateQuest(character, 'pq_gh_510');

      expect(character.personalQuestId, 'pq_gh_510');
      // pq_gh_510 has 2 requirements
      expect(character.personalQuestProgress, [0, 0]);
      expect(fakeDb.updateCalls, contains(character.uuid));
    });

    test('clears quest when questId is null', () async {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_510';
      character.personalQuestProgress = [3, 1];
      fakeDb.characters = [character];

      await service.updateQuest(character, null);

      expect(character.personalQuestId, '');
      expect(character.personalQuestProgress, isEmpty);
      expect(fakeDb.updateCalls, contains(character.uuid));
    });

    test('resets progress when changing quests', () async {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_510';
      character.personalQuestProgress = [5, 2];
      fakeDb.characters = [character];

      await service.updateQuest(character, 'pq_gh_515');

      expect(character.personalQuestId, 'pq_gh_515');
      // pq_gh_515 has 1 requirement
      expect(character.personalQuestProgress, [0]);
    });

    test('persists to database', () async {
      final character = TestData.createCharacter(uuid: 'persist-pq');
      fakeDb.characters = [character];

      await service.updateQuest(character, 'pq_gh_510');

      expect(fakeDb.updateCalls, contains('persist-pq'));
    });
  });

  group('updateProgress', () {
    test('updates a single requirement value', () async {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_510';
      character.personalQuestProgress = [0, 0];
      fakeDb.characters = [character];

      await service.updateProgress(character, 0, 3);

      expect(character.personalQuestProgress, [3, 0]);
    });

    test('persists to database', () async {
      final character = TestData.createCharacter(uuid: 'progress-persist');
      character.personalQuestId = 'pq_gh_510';
      character.personalQuestProgress = [0, 0];
      fakeDb.characters = [character];

      await service.updateProgress(character, 1, 5);

      expect(fakeDb.updateCalls, contains('progress-persist'));
    });

    test('returns true when quest transitions to complete', () async {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_515'; // 1 req: target 20
      character.personalQuestProgress = [19];
      fakeDb.characters = [character];

      final result = await service.updateProgress(character, 0, 20);

      expect(result, isTrue);
    });

    test('returns false for non-completing update', () async {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_515';
      character.personalQuestProgress = [5];
      fakeDb.characters = [character];

      final result = await service.updateProgress(character, 0, 6);

      expect(result, isFalse);
    });

    test('returns false when already complete', () async {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_515';
      character.personalQuestProgress = [20];
      fakeDb.characters = [character];

      final result = await service.updateProgress(character, 0, 21);

      expect(result, isFalse);
    });
  });

  group('isComplete', () {
    test('returns true when all requirements are met', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_515'; // 1 req: target 20
      character.personalQuestProgress = [20];

      expect(PersonalQuestService.isComplete(character), isTrue);
    });

    test('returns true when requirements are exceeded', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_515';
      character.personalQuestProgress = [25];

      expect(PersonalQuestService.isComplete(character), isTrue);
    });

    test('returns false when some requirements are not met', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_523'; // 6 binary reqs
      character.personalQuestProgress = [1, 1, 0, 1, 1, 1];

      expect(PersonalQuestService.isComplete(character), isFalse);
    });

    test('returns false when no quest assigned', () {
      final character = TestData.createCharacter();

      expect(PersonalQuestService.isComplete(character), isFalse);
    });

    test('returns false when progress length mismatches requirements', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_523'; // 6 reqs
      character.personalQuestProgress = [1, 1]; // only 2 values

      expect(PersonalQuestService.isComplete(character), isFalse);
    });

    test('returns true for all-binary quest with all ones', () {
      final character = TestData.createCharacter();
      character.personalQuestId = 'pq_gh_523'; // 6 binary reqs
      character.personalQuestProgress = [1, 1, 1, 1, 1, 1];

      expect(PersonalQuestService.isComplete(character), isTrue);
    });
  });
}
