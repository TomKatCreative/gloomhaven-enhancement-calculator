/// Service for personal quest assignment and progress tracking.
///
/// Handles quest assignment, progress updates, and completion checks
/// independently of [CharactersModel], following the delegation pattern
/// established by [DatabaseBackupService] and [EnhancementCostCalculator].
///
/// See also:
/// - [PersonalQuest] for quest definitions
/// - [PersonalQuestsRepository] for static quest data
/// - [CharactersModel] which delegates PQ operations here
library;

import 'package:gloomhaven_enhancement_calc/data/database_helper_interface.dart';
import 'package:gloomhaven_enhancement_calc/data/personal_quests/personal_quests_repository.dart';
import 'package:gloomhaven_enhancement_calc/models/character.dart';

/// Manages personal quest assignment, progress, and completion.
///
/// This service is stateless — all state lives on the [Character] model
/// and is persisted via [IDatabaseHelper]. The service provides the
/// mutation logic that [CharactersModel] delegates to.
class PersonalQuestService {
  PersonalQuestService({required this.databaseHelper});

  final IDatabaseHelper databaseHelper;

  /// Assigns a quest (or clears it with null), resetting progress.
  ///
  /// When [questId] is non-null, progress is initialized to a zero-filled
  /// list matching the quest's requirement count. When null, the quest ID
  /// is cleared and progress is emptied.
  Future<void> updateQuest(Character character, String? questId) async {
    character.personalQuestId = questId ?? '';
    character.personalQuestProgress = questId != null
        ? List.filled(
            PersonalQuestsRepository.getById(questId)?.requirements.length ?? 0,
            0,
          )
        : [];
    await databaseHelper.updateCharacter(character);
  }

  /// Updates progress for a single requirement of the personal quest.
  ///
  /// Returns `true` if this update caused the quest to transition from
  /// incomplete to complete. Returns `false` otherwise.
  Future<bool> updateProgress(
    Character character,
    int requirementIndex,
    int value,
  ) async {
    final wasComplete = isComplete(character);
    character.personalQuestProgress[requirementIndex] = value;
    await databaseHelper.updateCharacter(character);
    final isNowComplete = isComplete(character);
    return !wasComplete && isNowComplete;
  }

  /// Whether all personal quest requirements are met for the given character.
  ///
  /// Returns false if no quest is assigned or if progress length doesn't
  /// match the number of requirements.
  static bool isComplete(Character character) {
    final quest = character.personalQuest;
    if (quest == null) return false;
    if (character.personalQuestProgress.length != quest.requirements.length) {
      return false;
    }
    for (int i = 0; i < quest.requirements.length; i++) {
      final req = quest.requirements[i];
      final progress = req.checkedCount(character.personalQuestProgress[i]);
      if (progress < req.target) {
        return false;
      }
    }
    return true;
  }
}
