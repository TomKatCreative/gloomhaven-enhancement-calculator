/// Static repository of all Personal Quest definitions.
///
/// Contains all 24 base Gloomhaven quests (cards 510-533) using second
/// printing values. GH2E and Frosthaven quests will be added in future updates.
///
/// ## Usage
///
/// ```dart
/// final quest = PersonalQuestsRepository.getById('gh_510');
/// final ghQuests = PersonalQuestsRepository.getByEdition(GameEdition.gloomhaven);
/// ```
///
/// See also:
/// - [PersonalQuest] for the quest model
/// - [Character.personalQuestId] for the character-quest association
library;

import 'package:collection/collection.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/game_edition.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';

class PersonalQuestsRepository {
  static final List<PersonalQuest> quests = [
    PersonalQuest(
      id: 'gh_510',
      number: '510',
      title: 'Seeker of Xorn',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.plagueherald,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 3 scenarios with "Crypt" in the name',
          target: 3,
        ),
        PersonalQuestRequirement(
          description: 'Complete the Scenario 52 chain',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_511',
      number: '511',
      title: 'Merchant Class',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.quartermaster,
      requirements: const [
        PersonalQuestRequirement(description: 'Own 2 "head" items', target: 2),
        PersonalQuestRequirement(description: 'Own 2 "body" items', target: 2),
        PersonalQuestRequirement(description: 'Own 2 "legs" items', target: 2),
        PersonalQuestRequirement(description: 'Own 3 "hand" items', target: 3),
        PersonalQuestRequirement(description: 'Own 4 "small" items', target: 4),
      ],
    ),
    PersonalQuest(
      id: 'gh_512',
      number: '512',
      title: 'Greed is Good',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.quartermaster,
      requirements: const [
        PersonalQuestRequirement(description: 'Have 200 gold', target: 200),
      ],
    ),
    PersonalQuest(
      id: 'gh_513',
      number: '513',
      title: 'Finding the Cure',
      edition: GameEdition.gloomhaven,
      unlockEnvelope: 'X',
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 8 Forest Imps', target: 8),
        PersonalQuestRequirement(
          description: 'Complete the scenario chain',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_514',
      number: '514',
      title: 'A Study of Anatomy',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sawbones,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Party members exhausted',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_515',
      number: '515',
      title: 'Lawbringer',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sunkeeper,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill 20 Bandits or Cultists',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_516',
      number: '516',
      title: 'Pounds of Flesh',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 15 Vermlings', target: 15),
      ],
    ),
    PersonalQuest(
      id: 'gh_517',
      number: '517',
      title: 'Trophy Hunt',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.beastTyrant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill 20 unique monster types',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_518',
      number: '518',
      title: 'Eternal Wanderer',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.summoner,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 15 different scenarios',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_519',
      number: '519',
      title: 'Battle Legend',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.soothsinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Earn 15 battle goal checkmarks',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_520',
      number: '520',
      title: 'Implement of Light',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sunkeeper,
      requirements: const [
        PersonalQuestRequirement(description: 'Own Skullbane Axe', target: 1),
        PersonalQuestRequirement(description: 'Kill 7 undead', target: 7),
      ],
    ),
    PersonalQuest(
      id: 'gh_521',
      number: '521',
      title: 'Take Back the Trees',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.doomstalker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 3 Dagger Forest scenarios',
          target: 3,
        ),
        PersonalQuestRequirement(
          description: 'Complete the scenario chain',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_522',
      number: '522',
      title: 'The Thin Places',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.nightshroud,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 6 side scenarios',
          target: 6,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_523',
      number: '523',
      title: 'Aberrant Slayer',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.elementalist,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 1 Flame Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Frost Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Wind Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Earth Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Night Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Sun Demon', target: 1),
      ],
    ),
    PersonalQuest(
      id: 'gh_524',
      number: '524',
      title: 'Fearless Stand',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.beastTyrant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill 20 Elite monsters',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_525',
      number: '525',
      title: 'Piety in All Things',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sawbones,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Donate 120 gold to the Sanctuary of the Great Oak',
          target: 120,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_526',
      number: '526',
      title: 'Vengeance',
      edition: GameEdition.gloomhaven,
      unlockEnvelope: 'X',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 4 Gloomhaven scenarios',
          target: 4,
        ),
        PersonalQuestRequirement(
          description: 'Complete the scenario chain',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_527',
      number: '527',
      title: 'Zealot of the Blood God',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Become exhausted 12 times',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_528',
      number: '528',
      title: 'Goliath Toppler',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.doomstalker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 4 boss scenarios',
          target: 4,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_529',
      number: '529',
      title: 'The Fall of Man',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.nightshroud,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 2 Lingering Swamp scenarios',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Complete the scenario chain',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_530',
      number: '530',
      title: 'Augmented Abilities',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.summoner,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Purchase 4 enhancements',
          target: 4,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_531',
      number: '531',
      title: 'Elemental Samples',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.elementalist,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 1 scenario in each of 6 different regions',
          target: 6,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_532',
      number: '532',
      title: 'A Helping Hand',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.soothsinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Retire 2 other characters',
          target: 2,
        ),
      ],
    ),
    PersonalQuest(
      id: 'gh_533',
      number: '533',
      title: 'The Perfect Poison',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.plagueherald,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 3 Oozes', target: 3),
        PersonalQuestRequirement(description: 'Kill 3 Lurkers', target: 3),
        PersonalQuestRequirement(
          description: 'Kill 3 Spitting Drakes',
          target: 3,
        ),
      ],
    ),
  ];

  /// Returns a personal quest by its ID, or null if not found.
  static PersonalQuest? getById(String id) =>
      quests.firstWhereOrNull((q) => q.id == id);

  /// Returns all personal quests for a given edition.
  static List<PersonalQuest> getByEdition(GameEdition edition) =>
      quests.where((q) => q.edition == edition).toList();
}
