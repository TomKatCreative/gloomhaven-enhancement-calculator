/// Static repository of all Personal Quest definitions.
///
/// Contains all 24 base Gloomhaven quests (cards 510-533) using second
/// printing values. GH2E and Frosthaven quests will be added in future updates.
///
/// ## Usage
///
/// ```dart
/// final quest = PersonalQuestsRepository.getById('pq_gh_510');
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
      id: 'pq_gh_510',
      number: 510,
      title: 'Seeker of Xorn',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.plagueherald,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete three scenarios with "Crypt" in the name',
          target: 3,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Noxious Cellar" (Scenario 52) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_511',
      number: 511,
      title: 'Merchant Class',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.quartermaster,
      requirements: const [
        PersonalQuestRequirement(description: 'Own 2 Head items', target: 2),
        PersonalQuestRequirement(description: 'Own 2 Body items', target: 2),
        PersonalQuestRequirement(description: 'Own 2 Feet items', target: 2),
        PersonalQuestRequirement(
          description: 'Own 3 One_Hand or Two_Hand items',
          target: 3,
        ),
        PersonalQuestRequirement(description: 'Own 4 Pocket items', target: 4),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_512',
      number: 512,
      title: 'Greed is Good',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.quartermaster,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Have 200 gold in your possession',
          target: 200,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_513',
      number: 513,
      title: 'Finding the Cure',
      edition: GameEdition.gloomhaven,
      unlockEnvelope: 'X',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill eight Forest Imps',
          target: 8,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Forgotten Grove" (Scenario 59) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_514',
      number: 514,
      title: 'A Study of Anatomy',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sawbones,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience your party members becoming exhausted fifteen times',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_515',
      number: 515,
      title: 'Lawbringer',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sunkeeper,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill twenty Bandits or Cultists',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_516',
      number: 516,
      title: 'Pounds of Flesh',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 15 Vermlings', target: 15),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_517',
      number: 517,
      title: 'Trophy Hunt',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.beastTyrant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill twenty different types of monsters',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_518',
      number: 518,
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
      id: 'pq_gh_519',
      number: 519,
      title: 'Battle Legend',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.soothsinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Earn fifteen GOAL from completed battle goals',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_520',
      number: 520,
      title: 'Implement of Light',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.sunkeeper,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Find the Skullbane Axe in the Necormancer\'s Sanctum',
          target: 1,
        ),
        PersonalQuestRequirement(
          description:
              'Then use it to kill seven Living Bones, Living Corpses, or Living Spirits',
          target: 7,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_521',
      number: 521,
      title: 'Take Back the Trees',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.doomstalker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete three scenarios in the Dagger Forest',
          target: 3,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Foggy Thicket" (Scenario 55) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_522',
      number: 522,
      title: 'The Thin Places',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.nightshroud,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete six side scenarios (scenario number > 51)',
          target: 6,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_523',
      number: 523,
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
      id: 'pq_gh_524',
      number: 524,
      title: 'Fearless Stand',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.beastTyrant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill twenty elite monsters',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_525',
      number: 525,
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
      id: 'pq_gh_526',
      number: 526,
      title: 'Vengeance',
      edition: GameEdition.gloomhaven,
      unlockEnvelope: 'X',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete four scenarios in Gloomhaven',
          target: 4,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Investigation" (Scenario 57) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_527',
      number: 527,
      title: 'Zealot of the Blood God',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Become exhausted twelve times',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_528',
      number: 528,
      title: 'Goliath Toppler',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.doomstalker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete four boss scenarios',
          target: 4,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_529',
      number: 529,
      title: 'The Fall of Man',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.nightshroud,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete two scenarios in the Lingering Swamp',
          target: 2,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Fading Lighthouse" (Scenario 61) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_530',
      number: 530,
      title: 'Augmented Abilities',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.summoner,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Purchase four enhancements',
          target: 4,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_531',
      number: 531,
      title: 'Elemental Samples',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.elementalist,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete a scenario in Gloomhaven',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Dagger Forest',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Lingering Swamp',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Watcher Mountains',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Copperneck Mountains',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Misty Sea',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_532',
      number: 532,
      title: 'A Helping Hand',
      edition: GameEdition.gloomhaven,
      unlockClassCode: ClassCodes.soothsinger,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience two other characters achieving their personal quests',
          target: 2,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_533',
      number: 533,
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
