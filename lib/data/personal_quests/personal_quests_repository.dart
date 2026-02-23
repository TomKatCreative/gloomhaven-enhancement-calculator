/// Static repository of all Personal Quest definitions.
///
/// Contains 105 quests across 5 editions:
/// - 24 base Gloomhaven quests (cards 510-533, second printing values)
/// - 22 Gloomhaven 2E quests (cards 01-22 / asset 537-558)
/// - 23 Frosthaven quests (cards 1-23 / asset 505-590)
/// - 28 Crimson Scales quests (22 core cards 330-351 + 6 add-on class quests)
/// - 8 Trail of Ashes quests (cards 641-648)
///
/// ## Usage
///
/// ```dart
/// final quest = PersonalQuestsRepository.getById('pq_gh_510');
/// final ghQuests = PersonalQuestsRepository.getByEdition(PersonalQuestEdition.gloomhaven);
/// final csQuests = PersonalQuestsRepository.getByEdition(PersonalQuestEdition.crimsonScales);
/// ```
///
/// See also:
/// - [PersonalQuest] for the quest model
/// - [Character.personalQuestId] for the character-quest association
library;

import 'package:collection/collection.dart';
import 'package:gloomhaven_enhancement_calc/data/player_classes/character_constants.dart';
import 'package:gloomhaven_enhancement_calc/models/personal_quest/personal_quest.dart';

class PersonalQuestsRepository {
  static final List<PersonalQuest> quests = [
    PersonalQuest(
      id: 'pq_gh_510',
      number: 510,
      title: 'Seeker of Xorn',
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 15 Vermlings', target: 15),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh_517',
      number: 517,
      title: 'Trophy Hunt',
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
      edition: PersonalQuestEdition.gloomhaven,
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
    // ── Gloomhaven 2E Personal Quests ──
    // number = GH2E card number (1-22), altNumber = Cephalofair asset number
    // All 22 quests unlock classes (no envelope unlocks), 2 per class
    PersonalQuest(
      id: 'pq_gh2e_537',
      number: 1,
      altNumber: 537,
      title: 'Political Intrigue',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.sunkeeper,
      requirements: const [
        PersonalQuestRequirement(description: 'Gain 30 Votes', target: 30),
        PersonalQuestRequirement(
          description: 'Then read Section 136.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_538',
      number: 2,
      altNumber: 538,
      title: 'Inn to Hospitality',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.quartermaster,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 2 scenarios where you performed a long rest',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 112.2',
          target: 1,
        ),
        PersonalQuestRequirement(
          description:
              'Then complete 3 more scenarios where you performed a long rest',
          target: 3,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 112.3',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_539',
      number: 3,
      altNumber: 539,
      title: 'Augmented Abilities',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.summoner,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Purchase 4 enhancements',
          target: 4,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 101.2',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_540',
      number: 4,
      altNumber: 540,
      title: 'The Fall of Man',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.nightshroud,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 15 Lurkers', target: 15),
        PersonalQuestRequirement(
          description: 'Then read Section 157.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_541',
      number: 5,
      altNumber: 541,
      title: 'Seeker of Xorn',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.plagueherald,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 3 scenarios with "Crypt" in the name',
          target: 3,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 69.3',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then complete "Realm of the Voice" (Scenario 43)',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 69.4',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_542',
      number: 6,
      altNumber: 542,
      title: 'Zealot of the Blood God',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Become exhausted 12 times',
          target: 12,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 164.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_543',
      number: 7,
      altNumber: 543,
      title: 'A Tale to Tell',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.soothsinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Experience 2 other characters retiring',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 130.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_544',
      number: 8,
      altNumber: 544,
      title: 'Take Back the Trees',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.doomstalker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 3 scenarios in the Dagger Forest',
          target: 3,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 142.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_545',
      number: 9,
      altNumber: 545,
      title: 'Finding the Cure',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.sawbones,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Visit 5 of these 7 locations: Gloomhaven, Dagger Forest, Lingering Swamp, Watcher Mountains, Copperneck Mountains, Misty Sea, Serpent\'s Kiss River',
          target: 5,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 122.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_546',
      number: 10,
      altNumber: 546,
      title: 'Aberrant Slayer',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.elementalist,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 1 Flame Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Frost Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Wind Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Earth Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Night Demon', target: 1),
        PersonalQuestRequirement(description: 'Kill 1 Sun Demon', target: 1),
        PersonalQuestRequirement(
          description: 'Then read Section 118.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_547',
      number: 11,
      altNumber: 547,
      title: 'Adoptive Parent',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.beastTyrant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill 20 different types of monsters',
          target: 20,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 131.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_548',
      number: 12,
      altNumber: 548,
      title: 'Implement of Light',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.sunkeeper,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill 20 Bandits or Cultists',
          target: 20,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 36.5',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then complete the linked scenario',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 36.6',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_549',
      number: 13,
      altNumber: 549,
      title: 'Merchant Class',
      edition: PersonalQuestEdition.gloomhaven2e,
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
        PersonalQuestRequirement(
          description: 'Then read Section 115.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_550',
      number: 14,
      altNumber: 550,
      title: 'Eternal Wanderer',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.summoner,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 15 different scenarios',
          target: 15,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 150.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_551',
      number: 15,
      altNumber: 551,
      title: 'Escaping the Sin-Ra',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.nightshroud,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 6 side scenarios (scenario number > 51)',
          target: 6,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 83.2',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then complete the linked scenario',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 83.3',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_552',
      number: 16,
      altNumber: 552,
      title: 'The Perfect Poison',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.plagueherald,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 3 Oozes', target: 3),
        PersonalQuestRequirement(description: 'Kill 3 Lurkers', target: 3),
        PersonalQuestRequirement(
          description: 'Kill 3 Spitting Drakes',
          target: 3,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 11.3',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_553',
      number: 17,
      altNumber: 553,
      title: 'Living on the Edge',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.berserker,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience your party members becoming exhausted 15 times',
          target: 15,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 120.2',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then complete the linked scenario',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 120.3',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_554',
      number: 18,
      altNumber: 554,
      title: 'Battle Legend',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.soothsinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Earn 15 GOAL from completed battle goals',
          target: 15,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 171.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_555',
      number: 19,
      altNumber: 555,
      title: 'Martial Study',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.doomstalker,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete 4 boss scenarios',
          target: 4,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 98.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_556',
      number: 20,
      altNumber: 556,
      title: 'Piety in All Things',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.sawbones,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Donate 120 gold to the Sanctuary of the Great Oak',
          target: 120,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 56.2',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_557',
      number: 21,
      altNumber: 557,
      title: 'Pursuit of Proficiency',
      edition: PersonalQuestEdition.gloomhaven2e,
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
        PersonalQuestRequirement(
          description: 'Then read Section 174.1',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_gh2e_558',
      number: 22,
      altNumber: 558,
      title: 'Trophy Hunt',
      edition: PersonalQuestEdition.gloomhaven2e,
      unlockClassCode: ClassCodes.beastTyrant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill 20 elite monsters',
          target: 20,
        ),
        PersonalQuestRequirement(
          description: 'Then read Section 67.2',
          target: 1,
        ),
      ],
    ),
    // ── Frosthaven Personal Quests ──
    // number = FH card number (1-23), altNumber = Cephalofair asset number
    PersonalQuest(
      id: 'pq_fh_581',
      number: 1,
      altNumber: 581,
      title: 'The Study of Plants',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '24/42',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Personally collect five different types of herbs through loot tokens',
          target: 5,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_582',
      number: 2,
      altNumber: 582,
      title: 'Searching for the Oak',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '24/42',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Personally loot eight lumber cards through loot tokens',
          target: 8,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Sacred Soil" (Scenario 69) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_583',
      number: 3,
      altNumber: 583,
      title: 'Merchant Class',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '37/74',
      requirements: const [
        PersonalQuestRequirement(description: 'Own 3 Head items', target: 3),
        PersonalQuestRequirement(description: 'Own 3 Body items', target: 3),
        PersonalQuestRequirement(description: 'Own 3 Feet items', target: 3),
        PersonalQuestRequirement(
          description: 'Own 3 One_Hand and/or Two_Hand items',
          target: 3,
        ),
        PersonalQuestRequirement(description: 'Own 4 Pocket items', target: 4),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_584',
      number: 4,
      altNumber: 584,
      title: 'Greed is Good',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '37/74',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Have 80 + 20 \u00d7 PROSPERITY gold in your possession',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_585',
      number: 5,
      altNumber: 585,
      title: 'Build, not Destroy',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '85/21',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience the construction of twelve different buildings or building upgrades',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_586',
      number: 6,
      altNumber: 586,
      title: 'Team Building',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '85/21',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'During eight different outpost phases, read a person\'s name in an event or section',
          target: 8,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_587',
      number: 7,
      altNumber: 587,
      title: 'Aesther Outpost',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '44/88',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Immediately unlock "A Strong Foundation" (Scenario 65) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_588',
      number: 8,
      altNumber: 588,
      title: 'Dangerous Game',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '44/88',
      requirements: const [
        PersonalQuestRequirement(description: 'Kill 2 Algox Guards', target: 2),
        PersonalQuestRequirement(
          description: 'Kill 2 Lurker Clawcrushers',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Kill 2 Robotic Boltshooters',
          target: 2,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_589',
      number: 9,
      altNumber: 589,
      title: 'Life Lessons',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '90/83',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Gain 150 experience from ability cards',
          target: 150,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_590',
      number: 10,
      altNumber: 590,
      title: 'Explore the Reaches',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '90/83',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Complete five different scenarios that require BOAT, CLIMBING_GEAR, or SLED',
          target: 5,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_505',
      number: 11,
      altNumber: 505,
      title: 'Refined Tastes',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '39/72',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Own items whose crafting costs include a total of at least fifteen items',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_509',
      number: 12,
      altNumber: 509,
      title: 'Threat from the Deep',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '90/42',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Immediately unlock "Invasion of the Docks" (Scenario 71) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_514',
      number: 13,
      altNumber: 514,
      title: 'End the Trickery',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '44/74',
      requirements: const [
        PersonalQuestRequirement(description: 'Kill fifteen Imps', target: 15),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_519',
      number: 14,
      altNumber: 519,
      title: 'Eternal Wanderer',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '37/72',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete a scenario in Whitefire Wood',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Copperneck Mountains',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Radiant Forest',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Crystal Fields',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Complete a scenario in Biting Sea',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_523',
      number: 15,
      altNumber: 523,
      title: 'Continued Prosperity',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '65/85',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Donate 70 gold to the Temple of the Great Oak',
          target: 70,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_527',
      number: 16,
      altNumber: 527,
      title: 'Prepared for the Worst',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '85/88',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Purchase five enhancements',
          target: 5,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_538',
      number: 17,
      altNumber: 538,
      title: 'Battle Legend',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '81/67',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Earn sixteen GOAL from completed battle goals',
          target: 16,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_542',
      number: 18,
      altNumber: 542,
      title: 'Let Them Be',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '44/67',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete eight side scenarios (numbered 65 or higher)',
          target: 8,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_545',
      number: 19,
      altNumber: 545,
      title: 'Quiet the Dead Places',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '81/67',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Immediately gain Abyss Axe blueprint (039)',
          target: 1,
        ),
        PersonalQuestRequirement(
          description:
              'Then use it to kill ten Frozen Corpses, Ice Wraiths, and/or Living Dooms',
          target: 10,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_549',
      number: 20,
      altNumber: 549,
      title: 'Return to Simplicity',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '24/21',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill fifteen Ruined Machines',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_552',
      number: 21,
      altNumber: 552,
      title: 'The Study of Life',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '39/72',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Capture eight enemies',
          target: 8,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_557',
      number: 22,
      altNumber: 557,
      title: 'The Greatest Challenge',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: '37/83',
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete twelve challenges',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_fh_543',
      number: 23,
      altNumber: 543,
      title: 'The Chosen One',
      edition: PersonalQuestEdition.frosthaven,
      unlockEnvelope: 'A',
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience ten allies exhaust during scenarios you otherwise complete',
          target: 10,
        ),
      ],
    ),
    // ── Crimson Scales Personal Quests ──
    // 22 core quests (cards 330-351), 2 per class, all unlock classes
    PersonalQuest(
      id: 'pq_cs_330',
      number: 330,
      title: 'Protect and Serve',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.bombard,
      requirements: const [
        PersonalQuestRequirement(description: 'Kill ten Inox', target: 10),
        PersonalQuestRequirement(
          description:
              'Then unlock "Siege Tower" (Scenario 33) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_331',
      number: 331,
      title: 'Weapons Specialist',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.bombard,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Consume fifteen One_Hand or Two_Hand items',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_332',
      number: 332,
      title: 'Experimentation',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.brightspark,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Play thirty cards for their lost action',
          target: 30,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_333',
      number: 333,
      title: 'Thrill Seeker',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.brightspark,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Reveal a room tile by opening a door twenty times',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_334',
      number: 334,
      title: 'Trap Setter',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.chainguard,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Disarm or cause an enemy to spring a trap during your turn fifteen times',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_335',
      number: 335,
      title: 'Bandit Banisher',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.chainguard,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill ten Guards or Archers',
          target: 10,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Prison Riot" (Scenario 35) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_336',
      number: 336,
      title: 'Creatures in the Night',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.chieftain,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill twenty Oozes, Forest Imps, or Black Imps',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_337',
      number: 337,
      title: 'Experienced Leader',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.chieftain,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Complete twelve scenarios where you gained at least 12 experience points',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_338',
      number: 338,
      title: 'Adrenaline Spike',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.fireKnight,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Kill an enemy and loot its money token in the same round fifteen times',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_339',
      number: 339,
      title: 'Mutual Support',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.fireKnight,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Kill thirty enemies that are adjacent to any of your allies',
          target: 30,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_340',
      number: 340,
      title: 'Thy be Blessed',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.hierophant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Draw a BLESS card twelve times during an attack',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_341',
      number: 341,
      title: 'Spiritual Gains',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.hierophant,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Spend 200 gold on enhancements',
          target: 200,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_342',
      number: 342,
      title: 'The Path of Agony',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.hollowpact,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience an ally or enemy dying or becoming exhausted during its own turn 13 times',
          target: 13,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_343',
      number: 343,
      title: 'Cruel Dominion',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.hollowpact,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Complete 10 scenarios during which you kill an enemy who has a negative condition',
          target: 10,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_344',
      number: 344,
      title: 'Natural Selection',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.luminary,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Generate FIRE two times',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Generate ICE two times',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Generate LIGHT two times',
          target: 2,
        ),
        PersonalQuestRequirement(
          description: 'Generate DARK two times',
          target: 2,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Burning Stones" (Scenario 37) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_345',
      number: 345,
      title: 'Predator and Prey',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.luminary,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Kill two or more enemies in the same turn fifteen times',
          target: 15,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_346',
      number: 346,
      title: 'An Adder Divides',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.mirefoot,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Occupy difficult terrain in 6 different scenarios',
          target: 6,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Festering Mire" (Scenario 39) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_347',
      number: 347,
      title: 'Field Research',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.mirefoot,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Poison twenty different types of monsters',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_348',
      number: 348,
      title: 'Conjurers Hand',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.spiritCaller,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Kill ten summoned monsters',
          target: 10,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_349',
      number: 349,
      title: 'No Rest for the Wicked',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.spiritCaller,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Complete ten scenarios where you only performed one type of rest (long or short)',
          target: 10,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_350',
      number: 350,
      title: 'Health First',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.starslinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Complete seven scenarios ending at full health',
          target: 7,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_351',
      number: 351,
      title: 'Limitless Searching',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.starslinger,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Loot thirty money tokens',
          target: 30,
        ),
      ],
    ),
    // ── Crimson Scales Add-On Class Quests ──
    // 6 quests for 3 add-on classes (2 per class), all unlock classes
    // These use displayNumberOverride for non-numeric card identifiers
    PersonalQuest(
      id: 'pq_cs_aa_001',
      number: 352,
      displayNumberOverride: 'AA-001',
      title: 'At All Costs',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.amberAegis,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience 8 scenarios where you negate damage by losing a card as normal while adjacent to an ally',
          target: 8,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "The Riches of the Steelsilk" (Scenario AA1) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_aa_002',
      number: 353,
      displayNumberOverride: 'AA-002',
      title: 'The Weight of Failure',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.amberAegis,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Complete eight scenarios without exhausting and with 2 or less HP remaining',
          target: 8,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Malign Echoes" (Scenario AA2) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_qa_001',
      number: 354,
      displayNumberOverride: 'QA-001',
      title: 'Ingenious Inventor',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.artificer,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Immediately gain Power Modulator (Item QA-01 - cannot be sold)',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Use this item to kill twelve enemies',
          target: 12,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Capstone Test" (Scenario QA1) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_qa_002',
      number: 355,
      displayNumberOverride: 'QA-002',
      title: 'Scrap Diver',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.artificer,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Loot two or more money tokens with a single action eight times',
          target: 8,
        ),
        PersonalQuestRequirement(
          description: 'Loot two treasure tiles',
          target: 2,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Mother Lode" (Scenario QA2) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_rm_001',
      number: 356,
      displayNumberOverride: 'RM-001',
      title: 'Brutal Enforcer',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.ruinmaw,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Gain Serrated Edge design (Item RM-01)',
          target: 1,
        ),
        PersonalQuestRequirement(
          description: 'Apply WOUND or RUPTURE to thirty enemies',
          target: 30,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Mind Your Manners" (Scenario RM1) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_cs_rm_002',
      number: 357,
      displayNumberOverride: 'RM-002',
      title: 'Apex Predator',
      edition: PersonalQuestEdition.crimsonScales,
      unlockClassCode: ClassCodes.ruinmaw,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Experience twenty rounds where during or after you perform an action with a Lost card, an enemy dies',
          target: 20,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Ruined Colony" (Scenario RM3) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    // ── Trail of Ashes Personal Quests ──
    // 8 quests (cards 641-648), 2 per class, all unlock classes
    // Note: Shardrender class has no personal quests (unlocked via campaign)
    PersonalQuest(
      id: 'pq_toa_641',
      number: 641,
      title: 'Grave Robber',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.incarnate,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Loot fifteen money tokens in scenarios with Living Bones, Living Corpses, or Living Spirits',
          target: 15,
        ),
        PersonalQuestRequirement(
          description:
              'Then unlock "Ternion Tomb" (Scenario 67) and follow it to a conclusion',
          target: 1,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_642',
      number: 642,
      title: 'Stand as One',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.incarnate,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Add the Battle Standard (Item 115) to the city supply',
          target: 1,
        ),
        PersonalQuestRequirement(
          description:
              'Experience your allies killing twelve enemies with abilities granted by you',
          target: 12,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_643',
      number: 643,
      title: 'False Dichotomies',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.rimehearth,
      requirements: const [
        PersonalQuestRequirement(
          description: 'Choose Option A on an event card eight times',
          target: 8,
        ),
        PersonalQuestRequirement(
          description: 'Choose Option B on an event card eight times',
          target: 8,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_644',
      number: 644,
      title: 'Shared Suffering',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.rimehearth,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Kill thirty enemies while they are adjacent to one or more of their allies',
          target: 30,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_645',
      number: 645,
      title: 'Speed is King',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.tempest,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Kill twenty enemies whose initiative is at least 20 slower than yours that round',
          target: 20,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_646',
      number: 646,
      title: 'Resourceful',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.tempest,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Perform a loot action while adjacent to an enemy at least twice during a scenario in ten different scenarios',
          target: 10,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_647',
      number: 647,
      title: 'Close to Nature',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.thornreaper,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Complete four scenarios that use at least one Bush, Tree, or Thorns overlay tile',
          target: 4,
        ),
      ],
    ),
    PersonalQuest(
      id: 'pq_toa_648',
      number: 648,
      title: 'In Good Time',
      edition: PersonalQuestEdition.trailOfAshes,
      unlockClassCode: ClassCodes.thornreaper,
      requirements: const [
        PersonalQuestRequirement(
          description:
              'Declare and then perform a long rest while an enemy is in the same room as you thirteen times',
          target: 13,
        ),
      ],
    ),
  ];

  /// Returns a personal quest by its ID, or null if not found.
  static PersonalQuest? getById(String id) =>
      quests.firstWhereOrNull((q) => q.id == id);

  /// Returns all personal quests for a given edition.
  static List<PersonalQuest> getByEdition(PersonalQuestEdition edition) =>
      quests.where((q) => q.edition == edition).toList();
}
